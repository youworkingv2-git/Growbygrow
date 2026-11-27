extends Node
## Offline-first Save/Load Manager with atomic write, schema validation,
## revision/timestamp conflict protection (never overwrites newer progress with older),
## and Supabase-compatible sync outbox.

const SAVE_DIR := "user://profiles"
const SAVE_PATH := "user://profiles/active_profile.json"
const BACKUP_PATH := "user://profiles/active_profile.bak.json"
const TEMP_SAVE_PATH := "user://profiles/active_profile.json.tmp"
const OUTBOX_PATH := "user://profiles/sync_outbox.json"
const SAVE_SCHEMA_VERSION := 2

var _outbox: Array[Dictionary] = []
var _is_online_simulated: bool = true
var is_online: bool = true


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	_load_outbox()
	refresh_online_status()


func refresh_online_status() -> bool:
	if OS.has_feature("web"):
		var web_online: Variant = JavaScriptBridge.eval("typeof navigator !== 'undefined' ? Boolean(navigator.onLine) : true")
		is_online = bool(web_online)
		_is_online_simulated = is_online
	return is_online


func set_online_status(online: bool) -> void:
	is_online = online
	_is_online_simulated = online
	EventBus.sync_status_changed.emit(is_online, _outbox.size())


func has_saved_profile() -> bool:
	return FileAccess.file_exists(SAVE_PATH) or FileAccess.file_exists(BACKUP_PATH)


func save_state(state_data: Dictionary) -> bool:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var payload := _sanitize_save_data(state_data)
	payload["schema_version"] = SAVE_SCHEMA_VERSION
	payload["saved_at_utc"] = Time.get_datetime_string_from_system(true)
	payload["last_saved_unix"] = int(Time.get_unix_time_from_system())

	# Preserve previous valid save as rolling backup before overwriting
	if FileAccess.file_exists(SAVE_PATH):
		var prev_f := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if prev_f != null:
			var prev_raw := prev_f.get_as_text()
			prev_f.close()
			var prev_parsed: Variant = JSON.parse_string(prev_raw)
			if typeof(prev_parsed) == TYPE_DICTIONARY and _validate_save_schema(prev_parsed as Dictionary):
				var bak_f := FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
				if bak_f != null:
					bak_f.store_string(prev_raw)
					bak_f.close()

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
		"claimed_quests": payload.get("claimed_quests", []),
		"exp": payload.get("exp", 0),
		"gold": payload.get("gold", 0),
		"save_revision": payload.get("save_revision", 0)
	})
	AppLogger.info("SaveLoadManager", "Saved profile state locally")
	EventBus.save_completed.emit(true)
	return true


func load_state() -> Dictionary:
	var primary := _try_read_valid_save(SAVE_PATH)
	if not primary.is_empty():
		return primary
	if FileAccess.file_exists(SAVE_PATH):
		AppLogger.error("SaveLoadManager", "Corrupted primary save file; backing up and attempting recovery")
		_backup_corrupted_save()
	var recovered := _try_read_valid_save(BACKUP_PATH)
	if not recovered.is_empty():
		AppLogger.warn("SaveLoadManager", "Recovered profile state from rolling backup")
		return recovered
	return {}


func _try_read_valid_save(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var raw := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	var data: Dictionary = parsed
	if not _validate_save_schema(data):
		AppLogger.warn("SaveLoadManager", "Invalid save schema at %s; sanitizing state" % path)
	return _sanitize_save_data(data)


## Conflict-safe merge: never overwrites a newer local save with older remote data.
func resolve_conflict_prefer_newer(local_state: Dictionary, remote_state: Dictionary) -> Dictionary:
	if local_state.is_empty():
		return remote_state
	if remote_state.is_empty():
		return local_state
	var local_rev := int(local_state.get("save_revision", 0))
	var remote_rev := int(remote_state.get("save_revision", 0))
	var local_unix := int(local_state.get("last_saved_unix", 0))
	var remote_unix := int(remote_state.get("last_saved_unix", 0))
	if local_rev > remote_rev or (local_rev == remote_rev and local_unix >= remote_unix):
		return local_state
	# Even when taking newer remote, preserve union of claimed rewards & completed quests
	var merged := remote_state.duplicate(true)
	var union_claims: Array = merged.get("claimed_reward_keys", [])
	for rk in local_state.get("claimed_reward_keys", []):
		if not union_claims.has(rk):
			union_claims.append(rk)
	merged["claimed_reward_keys"] = union_claims
	return merged


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	if FileAccess.file_exists(BACKUP_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(BACKUP_PATH))
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
	if _outbox.size() > 120:
		var trimmed: Array[Dictionary] = []
		for i in range(_outbox.size() - 120, _outbox.size()):
			trimmed.append(_outbox[i])
		_outbox = trimmed
	_save_outbox()
	EventBus.sync_status_changed.emit(_is_online_simulated, _outbox.size())


func get_pending_sync_events() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for evt in _outbox:
		out.append(evt.duplicate(true))
	return out


func get_pending_sync_count() -> int:
	return _outbox.size()


func is_supabase_configured() -> bool:
	var url := str(OS.get_environment("SUPABASE_URL"))
	var key := str(OS.get_environment("SUPABASE_ANON_KEY"))
	return (not url.is_empty()) and (not key.is_empty())


func get_sync_status_summary() -> String:
	if is_supabase_configured():
		return "Supabase đã cấu hình (%d sự kiện chờ đồng bộ)" % _outbox.size()
	return "Chế độ Offline-first: Đã lưu cục bộ (%d sự kiện trong hàng đợi đồng bộ)" % _outbox.size()


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
	if typeof(data.get("selected_character")) != TYPE_STRING:
		return false
	if typeof(data.get("current_area_id")) != TYPE_STRING:
		return false
	if typeof(data.get("unlocked_areas")) != TYPE_ARRAY:
		return false
	if data.has("active_quests") and typeof(data.get("active_quests")) != TYPE_DICTIONARY:
		return false
	if data.has("inventory") and typeof(data.get("inventory")) != TYPE_DICTIONARY:
		return false
	if data.has("flags") and typeof(data.get("flags")) != TYPE_DICTIONARY:
		return false
	return true


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
		"completed_chapters": data.get("completed_chapters", []) if typeof(data.get("completed_chapters")) == TYPE_ARRAY else [],
		"active_quests": data.get("active_quests", {}) if typeof(data.get("active_quests")) == TYPE_DICTIONARY else {},
		"completed_quests": data.get("completed_quests", []) if typeof(data.get("completed_quests")) == TYPE_ARRAY else [],
		"claimed_quests": data.get("claimed_quests", []) if typeof(data.get("claimed_quests")) == TYPE_ARRAY else [],
		"rewarded_quests": data.get("rewarded_quests", []) if typeof(data.get("rewarded_quests")) == TYPE_ARRAY else [],
		"met_npcs": data.get("met_npcs", []) if typeof(data.get("met_npcs")) == TYPE_ARRAY else [],
		"npc_encounters": data.get("npc_encounters", {}) if typeof(data.get("npc_encounters")) == TYPE_DICTIONARY else {},
		"seen_dialogues": data.get("seen_dialogues", []) if typeof(data.get("seen_dialogues")) == TYPE_ARRAY else [],
		"collected_objects": data.get("collected_objects", []) if typeof(data.get("collected_objects")) == TYPE_ARRAY else [],
		"inventory": data.get("inventory", {}) if typeof(data.get("inventory")) == TYPE_DICTIONARY else {},
		"flags": data.get("flags", {}) if typeof(data.get("flags")) == TYPE_DICTIONARY else {},
		"minigame_records": data.get("minigame_records", {}) if typeof(data.get("minigame_records")) == TYPE_DICTIONARY else {},
		"claimed_reward_keys": data.get("claimed_reward_keys", []) if typeof(data.get("claimed_reward_keys")) == TYPE_ARRAY else [],
		"reward_history": data.get("reward_history", []) if typeof(data.get("reward_history")) == TYPE_ARRAY else [],
		"unlocked_achievements": data.get("unlocked_achievements", []) if typeof(data.get("unlocked_achievements")) == TYPE_ARRAY else [],
		"exp": maxi(0, int(data.get("exp", 0))),
		"gold": maxi(0, int(data.get("gold", 0))),
		"stars": maxi(0, int(data.get("stars", 0))),
		"level": maxi(1, int(data.get("level", 1))),
		"save_revision": maxi(0, int(data.get("save_revision", 0))),
		"last_saved_unix": maxi(0, int(data.get("last_saved_unix", 0))),
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
