extends Node
## Manages local JSON persistence (offline-first) and prepares cloud sync payloads.
## Never stores sensitive PII or API secrets.

const SAVE_FILE_PATH := "user://english_adventure_save.json"
const SCHEMA_VERSION := 1

var player_data: Dictionary = {}

func _ready() -> void:
	load_game()

func get_default_data() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"player_name": "Nhà Thám Hiểm",
		"avatar_type": "", # "boy" or "girl" - empty until chosen
		"current_world_id": "world_1",
		"current_area_id": "welcome_village",
		"last_position": { "x": 320.0, "y": 400.0 },
		"exp": 0,
		"gold": 0,
		"magic_crystals": 0,
		"unlocked_areas": ["welcome_village"],
		"visited_areas": ["welcome_village"],
		"active_quests": {},
		"completed_quests": [],
		"met_npcs": [],
		"collected_items": [],
		"pending_sync": false
	}

func save_game() -> bool:
	player_data["schema_version"] = SCHEMA_VERSION
	player_data["pending_sync"] = true
	var json_str := JSON.stringify(player_data, "\t")
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file == null:
		var err_msg := "Không thể mở file lưu tiến trình."
		EventBus.error_occurred.emit("SAVE_OPEN_FAILED", err_msg)
		EventBus.save_completed.emit(false)
		return false
	file.store_string(json_str)
	file.close()
	EventBus.save_completed.emit(true)
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		player_data = get_default_data()
		EventBus.load_completed.emit(true)
		return true

	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		player_data = get_default_data()
		EventBus.error_occurred.emit("LOAD_OPEN_FAILED", "Lỗi đọc dữ liệu lưu. Đã khôi phục mặc định.")
		EventBus.load_completed.emit(false)
		return false

	var content := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(content)
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("schema_version"):
		player_data = get_default_data()
		EventBus.error_occurred.emit("SAVE_CORRUPTED", "Dữ liệu lưu bị hỏng. Đã tạo hồ sơ mới an toàn.")
		EventBus.load_completed.emit(false)
		return false

	# Merge missing keys safely for forward compatibility
	var defaults := get_default_data()
	for key in defaults:
		if not parsed.has(key):
			parsed[key] = defaults[key]
	player_data = parsed
	EventBus.load_completed.emit(true)
	return true

func reset_save() -> void:
	player_data = get_default_data()
	save_game()

func set_character(gender: String, display_name: String) -> void:
	player_data["avatar_type"] = gender
	if display_name.strip_edges() != "":
		player_data["player_name"] = display_name.strip_edges()
	save_game()

func has_selected_character() -> bool:
	var avatar: String = player_data.get("avatar_type", "")
	return avatar == "boy" or avatar == "girl"

func is_area_unlocked(area_id: String) -> bool:
	var unlocked: Array = player_data.get("unlocked_areas", [])
	return area_id in unlocked

func unlock_area(area_id: String) -> void:
	var unlocked: Array = player_data.get("unlocked_areas", [])
	if not (area_id in unlocked):
		unlocked.append(area_id)
		player_data["unlocked_areas"] = unlocked
		save_game()
		EventBus.area_unlocked.emit(area_id)

func mark_area_visited(area_id: String) -> void:
	var visited: Array = player_data.get("visited_areas", [])
	if not (area_id in visited):
		visited.append(area_id)
		player_data["visited_areas"] = visited
	player_data["current_area_id"] = area_id
	save_game()

func update_player_position(pos: Vector2) -> void:
	player_data["last_position"] = { "x": pos.x, "y": pos.y }

func mark_npc_met(npc_id: String) -> void:
	var met: Array = player_data.get("met_npcs", [])
	if not (npc_id in met):
		met.append(npc_id)
		player_data["met_npcs"] = met
		save_game()

func add_collected_item(item_id: String) -> bool:
	var items: Array = player_data.get("collected_items", [])
	if item_id in items:
		return false
	items.append(item_id)
	player_data["collected_items"] = items
	save_game()
	return true

func has_collected_item(item_id: String) -> bool:
	return item_id in player_data.get("collected_items", [])
