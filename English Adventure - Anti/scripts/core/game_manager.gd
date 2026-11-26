extends Node
## Global GameManager: coordinates scene transitions, world/area loading,
## and enforces unlock checks before entering any area scene.

const CHARACTER_SELECT_SCENE := "res://scenes/authentication/character_select.tscn"
const WORLD_MAP_SCENE := "res://scenes/world_map/world_map.tscn"
const AREAS_DATA_PATH := "res://data/areas/alphabet_island_areas.json"

var areas_by_id: Dictionary = {}
var area_order: Array[String] = []
var current_area_id: String = ""
var is_transitioning: bool = false

func _ready() -> void:
	_load_areas_data()
	EventBus.area_change_requested.connect(_on_area_change_requested)

func _load_areas_data() -> void:
	if not FileAccess.file_exists(AREAS_DATA_PATH):
		push_error("Missing areas data: " + AREAS_DATA_PATH)
		return
	var file := FileAccess.open(AREAS_DATA_PATH, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) == TYPE_DICTIONARY and parsed.has("areas"):
		for area in parsed["areas"]:
			var aid: String = area.get("id", "")
			areas_by_id[aid] = area
			area_order.append(aid)

func get_area_info(area_id: String) -> Dictionary:
	return areas_by_id.get(area_id, {})

func get_all_areas() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for aid in area_order:
		list.append(areas_by_id[aid])
	return list

func get_area_status(area_id: String) -> String:
	if not SaveManager.is_area_unlocked(area_id):
		return "Locked"
	var visited: Array = SaveManager.player_data.get("visited_areas", [])
	# Check if area's main quest is completed
	for q in QuestManager.get_quests_for_area(area_id):
		if QuestManager.is_quest_completed(q["id"]):
			return "Completed"
	if area_id in visited:
		return "In Progress"
	return "Unlocked"

func go_to_character_select() -> void:
	_change_scene_with_fade(CHARACTER_SELECT_SCENE)

func go_to_world_map() -> void:
	SaveManager.save_game()
	_change_scene_with_fade(WORLD_MAP_SCENE)

func enter_area(area_id: String, custom_spawn: Vector2 = Vector2(-1, -1)) -> bool:
	if is_transitioning:
		return false
	if not areas_by_id.has(area_id):
		EventBus.error_occurred.emit("AREA_NOT_FOUND", "Khu vực không tồn tại.")
		return false
	if not SaveManager.is_area_unlocked(area_id):
		EventBus.error_occurred.emit("AREA_LOCKED", "Khu vực này chưa được mở khóa! Hãy hoàn thành nhiệm vụ trước.")
		return false

	var info: Dictionary = areas_by_id[area_id]
	var scene_path: String = info.get("scene_path", "")
	if not ResourceLoader.exists(scene_path):
		EventBus.error_occurred.emit("SCENE_MISSING", "Không tìm thấy cảnh khu vực: " + area_id)
		return false

	current_area_id = area_id
	SaveManager.mark_area_visited(area_id)

	if custom_spawn.x >= 0 and custom_spawn.y >= 0:
		SaveManager.update_player_position(custom_spawn)
	elif info.has("default_spawn"):
		var sp: Dictionary = info["default_spawn"]
		SaveManager.update_player_position(Vector2(sp.get("x", 320), sp.get("y", 400)))

	_change_scene_with_fade(scene_path)
	EventBus.area_entered.emit(area_id)
	return true

func _on_area_change_requested(area_id: String, spawn_pos: Vector2) -> void:
	enter_area(area_id, spawn_pos)

func _change_scene_with_fade(scene_path: String) -> void:
	is_transitioning = true
	# Simple safe deferred transition; UI transition overlay can listen to signals
	get_tree().call_deferred("change_scene_to_file", scene_path)
	await get_tree().process_frame
	is_transitioning = false
