extends Node
## Authoritative runtime game state for player profile, world areas, quests, NPCs, inventory, and persistence.

var profile_id: String = ""
var selected_character: String = "boy"
var nickname: String = "Explorer"
var current_area_id: String = "welcome_village"
var area_positions: Dictionary = {}
var unlocked_areas: Array[String] = ["welcome_village"]
var completed_areas: Array[String] = []

var active_quests: Dictionary = {}     # quest_id -> { "step_index": int, "collected_tags": Dictionary }
var completed_quests: Array[String] = []
var rewarded_quests: Array[String] = []

var met_npcs: Array[String] = []
var collected_objects: Array[String] = []
var inventory: Dictionary = {}         # item_id -> { "id", "name_vi", "name_en", "quantity" }
var flags: Dictionary = {}

var exp: int = 0
var gold: int = 0
var level: int = 1
var world_intro_seen: bool = false
var pending_area_unlocked_popup: Array[String] = []


func _ready() -> void:
	EventBus.save_requested.connect(_on_save_requested)
	load_or_initialize()


func load_or_initialize() -> bool:
	var saved := SaveLoadManager.load_state()
	if saved.is_empty():
		reset_new_game()
		return false
	apply_state_dict(saved)
	evaluate_all_unlocks(false)
	return true


func reset_new_game() -> void:
	profile_id = SaveLoadManager._generate_uuid_v4()
	selected_character = "boy"
	nickname = "Explorer"
	current_area_id = "welcome_village"
	area_positions = {}
	unlocked_areas = ["welcome_village"]
	completed_areas = []
	active_quests = {}
	completed_quests = []
	rewarded_quests = []
	met_npcs = []
	collected_objects = []
	inventory = {}
	flags = {}
	exp = 0
	gold = 0
	level = 1
	world_intro_seen = false
	pending_area_unlocked_popup = []


func apply_state_dict(data: Dictionary) -> void:
	profile_id = str(data.get("profile_id", SaveLoadManager._generate_uuid_v4()))
	selected_character = str(data.get("selected_character", "boy"))
	nickname = str(data.get("nickname", "Explorer"))
	current_area_id = str(data.get("current_area_id", "welcome_village"))
	area_positions = data.get("area_positions", {}).duplicate(true)

	unlocked_areas.clear()
	for a in data.get("unlocked_areas", ["welcome_village"]):
		if not unlocked_areas.has(str(a)):
			unlocked_areas.append(str(a))
	if not unlocked_areas.has("welcome_village"):
		unlocked_areas.append("welcome_village")

	completed_areas.clear()
	for a in data.get("completed_areas", []):
		completed_areas.append(str(a))

	active_quests = data.get("active_quests", {}).duplicate(true)
	completed_quests.clear()
	for q in data.get("completed_quests", []):
		completed_quests.append(str(q))
	rewarded_quests.clear()
	for q in data.get("rewarded_quests", []):
		rewarded_quests.append(str(q))

	met_npcs.clear()
	for n in data.get("met_npcs", []):
		met_npcs.append(str(n))
	collected_objects.clear()
	for o in data.get("collected_objects", []):
		collected_objects.append(str(o))

	inventory = data.get("inventory", {}).duplicate(true)
	flags = data.get("flags", {}).duplicate(true)
	exp = int(data.get("exp", 0))
	gold = int(data.get("gold", 0))
	level = maxi(1, int(data.get("level", 1)))
	world_intro_seen = bool(data.get("world_intro_seen", false))


func to_state_dict() -> Dictionary:
	return {
		"profile_id": profile_id,
		"selected_character": selected_character,
		"nickname": nickname,
		"current_area_id": current_area_id,
		"area_positions": area_positions,
		"unlocked_areas": unlocked_areas,
		"completed_areas": completed_areas,
		"active_quests": active_quests,
		"completed_quests": completed_quests,
		"rewarded_quests": rewarded_quests,
		"met_npcs": met_npcs,
		"collected_objects": collected_objects,
		"inventory": inventory,
		"flags": flags,
		"exp": exp,
		"gold": gold,
		"level": level,
		"world_intro_seen": world_intro_seen
	}


func set_character_profile(gender: String, player_nickname: String) -> void:
	selected_character = "girl" if gender == "girl" else "boy"
	var clean := player_nickname.strip_edges()
	nickname = clean if clean.length() >= 2 else ("Mia" if selected_character == "girl" else "Leo")
	save_now("character_selected")
	EventBus.character_selected.emit(selected_character, nickname)


func set_player_position(area_id: String, pos: Vector2) -> void:
	area_positions[area_id] = { "x": pos.x, "y": pos.y }


func get_saved_position(area_id: String, fallback_pos: Vector2) -> Vector2:
	if area_positions.has(area_id):
		var p: Dictionary = area_positions[area_id]
		return Vector2(float(p.get("x", fallback_pos.x)), float(p.get("y", fallback_pos.y)))
	return fallback_pos


func is_area_unlocked(area_id: String) -> bool:
	return unlocked_areas.has(area_id)


func is_area_completed(area_id: String) -> bool:
	return completed_areas.has(area_id)


func get_area_status(area_id: String) -> String:
	if not is_area_unlocked(area_id):
		return "locked"
	if is_area_completed(area_id):
		return "completed"
	if area_id == current_area_id or area_positions.has(area_id):
		return "in_progress"
	return "unlocked"


func mark_npc_met(npc_id: String) -> void:
	if not met_npcs.has(npc_id):
		met_npcs.append(npc_id)
		EventBus.npc_met.emit(npc_id)


func is_object_collected(obj_id: String) -> bool:
	return collected_objects.has(obj_id)


func mark_object_collected(obj_id: String) -> void:
	if not collected_objects.has(obj_id):
		collected_objects.append(obj_id)


func add_item(item_dict: Dictionary) -> void:
	var item_id := str(item_dict.get("id", ""))
	if item_id.is_empty():
		return
	var qty := int(item_dict.get("quantity", 1))
	if inventory.has(item_id):
		inventory[item_id]["quantity"] = int(inventory[item_id].get("quantity", 0)) + qty
	else:
		inventory[item_id] = {
			"id": item_id,
			"name_vi": str(item_dict.get("name_vi", item_id)),
			"name_en": str(item_dict.get("name_en", item_id)),
			"quantity": qty
		}
	EventBus.item_collected.emit(item_id, qty)
	EventBus.progress_updated.emit()


func set_flag(flag_name: String, value: bool = true) -> void:
	flags[flag_name] = value
	evaluate_all_unlocks(true)


func add_exp_and_gold(add_exp: int, add_gold: int) -> void:
	exp += maxi(0, add_exp)
	gold += maxi(0, add_gold)
	var prev_level := level
	while exp >= _exp_for_next_level(level):
		exp -= _exp_for_next_level(level)
		level += 1
	if level > prev_level:
		EventBus.level_up.emit(level)
	EventBus.progress_updated.emit()


func get_exp_for_next_level() -> int:
	return _exp_for_next_level(level)


func get_magic_crystal_count() -> int:
	var total := 0
	for item_id_var in inventory.keys():
		var item_id := str(item_id_var)
		if item_id.contains("crystal"):
			total += int(inventory[item_id].get("quantity", 0))
	return total


func _exp_for_next_level(lv: int) -> int:
	return int(round(100.0 * float(lv) * 1.15))


func evaluate_all_unlocks(notify_newly_unlocked: bool = true) -> void:
	var snapshot := to_state_dict()
	for area in DataRepository.areas_ordered:
		var aid := str(area.get("id", ""))
		if aid.is_empty():
			continue
		if not unlocked_areas.has(aid):
			var cond: Dictionary = area.get("unlock_condition", {})
			if UnlockEvaluator.is_condition_met(cond, snapshot):
				unlocked_areas.append(aid)
				if notify_newly_unlocked:
					pending_area_unlocked_popup.append(aid)
					EventBus.area_unlocked.emit(aid)
		if not completed_areas.has(aid):
			var comp_cond: Dictionary = area.get("completion_condition", {})
			if not comp_cond.is_empty() and UnlockEvaluator.is_condition_met(comp_cond, snapshot):
				completed_areas.append(aid)


func save_now(reason: String = "manual") -> bool:
	return SaveLoadManager.save_state(to_state_dict())


func _on_save_requested(reason: String) -> void:
	save_now(reason)
