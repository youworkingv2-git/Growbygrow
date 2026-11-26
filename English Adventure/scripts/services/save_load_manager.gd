extends Node
## Offline-first Save/Load Manager with atomic write, schema validation, and Supabase-compatible sync outbox.

const SAVE_DIR := "user://profiles"
const SAVE_PATH := "user://profiles/active_profile.json"
const TEMP_SAVE_PATH := "user://profiles/active_profile.json.tmp"
const OUTBOX_PATH := "user://profiles/sync_outbox.json"
const SAVE_SCHEMA_VERSION := 1

var _outbox: Array[Dictionary] = []


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	_load_outbox()


func has_saved_profile() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_state(state_data: Dictionary) -> bool:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var payload := state_data.duplicate(true)
	payload["schema_version"] = SAVE_SCHEMA_VERSION
	payload["saved_at_utc"] = Time.get_datetime_string_from_system(true)

	var json_str := JSON.stringify(payload, "\t")
	var f := FileAccess.open(TEMP_SAVE_PATH, FileAccess.WRITE)
	if f == null:
		AppLogger.error("SaveLoadManager", "Failed to open temp save file for writing")
		EventBus.save_completed.emit(false)
		return false
	f.store_string(json_str)
	f.close()

	var err := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(TEMP_SAVE_PATH),
		ProjectSettings.globalize_path(SAVE_PATH)
	)
	if err != OK:
		# Fallback direct write if rename across virtual path fails on some OS
		var direct := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		if direct == null:
			AppLogger.error("SaveLoadManager", "Save failed with error code: %d" % err)
			EventBus.save_completed.emit(false)
			return false
		direct.store_string(json_str)
		direct.close()

	enqueue_sync_event("profile_snapshot", {
		"profile_id": payload.get("profile_id", ""),
		"current_area_id": payload.get("current_area_id", ""),
		"completed_quests": payload.get("completed_quests", []),
		"exp": payload.get("exp", 0),
		"gold": payload.get("gold", 0)
	})
	AppLogger.info("SaveLoadManager", "Saved profile state locally")
	EventBus.save_completed.emit(true)
	return true


func load_state() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		AppLogger.error("SaveLoadManager", "Cannot open save file")
		return {}
	var raw := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		AppLogger.error("SaveLoadManager", "Corrupted save file; backing up and returning empty state")
		_backup_corrupted_save()
		return {}
	var data: Dictionary = parsed
	if not _validate_save_schema(data):
		AppLogger.warn("SaveLoadManager", "Invalid save schema; sanitizing state")
		return _sanitize_save_data(data)
	return data


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	_outbox.clear()
	_save_outbox()


func enqueue_sync_event(event_type: String, payload: Dictionary) -> void:
	var evt := {
		"client_event_id": _generate_uuid_v4(),
		"event_type": event_type,
		"payload": payload,
		"occurred_at_utc": Time.get_datetime_string_from_system(true)
	}
	_outbox.append(evt)
	# Keep outbox bounded locally until Supabase sync is enabled in later phase
	if _outbox.size() > 100:
		_outbox = _outbox.slice(_outbox.size() - 100, _outbox.size())
	_save_outbox()


func get_pending_sync_events() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for evt in _outbox:
		out.append(evt.duplicate(true))
	return out


func _load_outbox() -> void:
	if not FileAccess.file_exists(OUTBOX_PATH):
		return
	var f := FileAccess.open(OUTBOX_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) == TYPE_ARRAY:
		_outbox.clear()
		for item in parsed:
			if typeof(item) == TYPE_DICTIONARY:
				_outbox.append(item)


func _save_outbox() -> void:
	var f := FileAccess.open(OUTBOX_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(_outbox))
	f.close()


func _validate_save_schema(data: Dictionary) -> bool:
	return data.has("selected_character") and data.has("current_area_id") and data.has("unlocked_areas")


func _sanitize_save_data(data: Dictionary) -> Dictionary:
	var gender := str(data.get("selected_character", "boy"))
	if gender != "boy" and gender != "girl":
		gender = "boy"
	var unlocked: Variant = data.get("unlocked_areas", ["welcome_village"])
	if typeof(unlocked) != TYPE_ARRAY or unlocked.is_empty():
		unlocked = ["welcome_village"]
	return {
		"profile_id": str(data.get("profile_id", _generate_uuid_v4())),
		"selected_character": gender,
		"nickname": str(data.get("nickname", "Explorer")),
		"current_area_id": str(data.get("current_area_id", "welcome_village")),
		"area_positions": data.get("area_positions", {}) if typeof(data.get("area_positions")) == TYPE_DICTIONARY else {},
		"unlocked_areas": unlocked,
		"completed_areas": data.get("completed_areas", []) if typeof(data.get("completed_areas")) == TYPE_ARRAY else [],
		"active_quests": data.get("active_quests", {}) if typeof(data.get("active_quests")) == TYPE_DICTIONARY else {},
		"completed_quests": data.get("completed_quests", []) if typeof(data.get("completed_quests")) == TYPE_ARRAY else [],
		"rewarded_quests": data.get("rewarded_quests", []) if typeof(data.get("rewarded_quests")) == TYPE_ARRAY else [],
		"met_npcs": data.get("met_npcs", []) if typeof(data.get("met_npcs")) == TYPE_ARRAY else [],
		"collected_objects": data.get("collected_objects", []) if typeof(data.get("collected_objects")) == TYPE_ARRAY else [],
		"inventory": data.get("inventory", {}) if typeof(data.get("inventory")) == TYPE_DICTIONARY else {},
		"flags": data.get("flags", {}) if typeof(data.get("flags")) == TYPE_DICTIONARY else {},
		"exp": maxi(0, int(data.get("exp", 0))),
		"gold": maxi(0, int(data.get("gold", 0))),
		"level": maxi(1, int(data.get("level", 1))),
		"world_intro_seen": bool(data.get("world_intro_seen", false))
	}


func _backup_corrupted_save() -> void:
	var backup_path := SAVE_DIR + "/corrupted_%d.json" % Time.get_unix_time_from_system()
	DirAccess.rename_absolute(
		ProjectSettings.globalize_path(SAVE_PATH),
		ProjectSettings.globalize_path(backup_path)
	)


func _generate_uuid_v4() -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var bytes := PackedByteArray()
	for i in range(16):
		bytes.append(rng.randi_range(0, 255))
	bytes[6] = (bytes[6] & 0x0f) | 0x40
	bytes[8] = (bytes[8] & 0x3f) | 0x80
	return "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x" % [
		bytes[0], bytes[1], bytes[2], bytes[3],
		bytes[4], bytes[5], bytes[6], bytes[7],
		bytes[8], bytes[9], bytes[10], bytes[11],
		bytes[12], bytes[13], bytes[14], bytes[15]
	]
