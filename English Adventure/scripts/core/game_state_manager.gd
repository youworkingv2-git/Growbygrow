extends Node
## Authoritative runtime game state for player profile, world areas, chapters, quests,
## NPC encounters, dialogues, inventory, rewards, achievements, and persistence.

var profile_id: String = ""
var selected_character: String = "boy"
var nickname: String = "Explorer"
var current_area_id: String = "welcome_village"
var area_positions: Dictionary = {}
var unlocked_areas: Array[String] = ["welcome_village"]
var completed_areas: Array[String] = []
var completed_chapters: Array[String] = []

var active_quests: Dictionary = {}     # quest_id -> { step_index, collected_tags, objectives, started_at_utc }
var completed_quests: Array[String] = []
var claimed_quests: Array[String] = []
var rewarded_quests: Array[String] = []

var met_npcs: Array[String] = []
var npc_encounters: Dictionary = {}    # npc_id -> { talk_count, last_dialogue_id, last_talk_utc }
var seen_dialogues: Array[String] = []
var collected_objects: Array[String] = []
var inventory: Dictionary = {}         # item_id -> { id, name_vi, name_en, quantity, item_type, rarity, ... }
var flags: Dictionary = {}
var minigame_records: Dictionary = {}  # minigame_id -> { plays, best_learning_score, best_game_score, best_stars, last_played_utc }

var claimed_reward_keys: Array[String] = []
var reward_history: Array[Dictionary] = []
var unlocked_achievements: Array[String] = []

var exp: int = 0
var gold: int = 0
var stars: int = 0
var level: int = 1
var save_revision: int = 0
var last_saved_unix: int = 0
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
	completed_chapters = []
	active_quests = {}
	completed_quests = []
	claimed_quests = []
	rewarded_quests = []
	met_npcs = []
	npc_encounters = {}
	seen_dialogues = []
	collected_objects = []
	inventory = {}
	flags = {}
	minigame_records = {}
	claimed_reward_keys = []
	reward_history = []
	unlocked_achievements = []
	exp = 0
	gold = 0
	stars = 0
	level = 1
	save_revision = 0
	last_saved_unix = 0
	world_intro_seen = false
	pending_area_unlocked_popup = []


func apply_state_dict(data: Dictionary) -> void:
	profile_id = str(data.get("profile_id", SaveLoadManager._generate_uuid_v4()))
	selected_character = str(data.get("selected_character", "boy"))
	nickname = str(data.get("nickname", "Explorer"))
	current_area_id = str(data.get("current_area_id", "welcome_village"))
	area_positions = (data.get("area_positions", {}) as Dictionary).duplicate(true)

	unlocked_areas.clear()
	for a in data.get("unlocked_areas", ["welcome_village"]):
		if not unlocked_areas.has(str(a)):
			unlocked_areas.append(str(a))
	if not unlocked_areas.has("welcome_village"):
		unlocked_areas.append("welcome_village")

	completed_areas.clear()
	for a in data.get("completed_areas", []):
		if not completed_areas.has(str(a)):
			completed_areas.append(str(a))

	completed_chapters.clear()
	for ch in data.get("completed_chapters", []):
		if not completed_chapters.has(str(ch)):
			completed_chapters.append(str(ch))

	active_quests = (data.get("active_quests", {}) as Dictionary).duplicate(true)
	completed_quests.clear()
	for q in data.get("completed_quests", []):
		var qid := str(q)
		if not completed_quests.has(qid):
			completed_quests.append(qid)

	rewarded_quests.clear()
	for q in data.get("rewarded_quests", []):
		var qid := str(q)
		if not rewarded_quests.has(qid):
			rewarded_quests.append(qid)

	claimed_quests.clear()
	for q in data.get("claimed_quests", []):
		var qid := str(q)
		if not claimed_quests.has(qid):
			claimed_quests.append(qid)
	# Backward compatibility for Prompt 02-05 saves where rewarded_quests implied claimed
	for qid in rewarded_quests:
		if not claimed_quests.has(qid):
			claimed_quests.append(qid)

	met_npcs.clear()
	for n in data.get("met_npcs", []):
		if not met_npcs.has(str(n)):
			met_npcs.append(str(n))

	if typeof(data.get("npc_encounters", {})) == TYPE_DICTIONARY:
		npc_encounters = (data.get("npc_encounters", {}) as Dictionary).duplicate(true)
	else:
		npc_encounters = {}

	seen_dialogues.clear()
	for d_id in data.get("seen_dialogues", []):
		if not seen_dialogues.has(str(d_id)):
			seen_dialogues.append(str(d_id))

	collected_objects.clear()
	for o in data.get("collected_objects", []):
		if not collected_objects.has(str(o)):
			collected_objects.append(str(o))

	inventory = (data.get("inventory", {}) as Dictionary).duplicate(true)
	flags = (data.get("flags", {}) as Dictionary).duplicate(true)
	if typeof(data.get("minigame_records", {})) == TYPE_DICTIONARY:
		minigame_records = (data.get("minigame_records", {}) as Dictionary).duplicate(true)
	else:
		minigame_records = {}

	claimed_reward_keys.clear()
	for rk in data.get("claimed_reward_keys", []):
		if not claimed_reward_keys.has(str(rk)):
			claimed_reward_keys.append(str(rk))
	for qid in rewarded_quests:
		var qkey := "quest:" + qid
		if not claimed_reward_keys.has(qkey):
			claimed_reward_keys.append(qkey)

	reward_history.clear()
	for rh in data.get("reward_history", []):
		if typeof(rh) == TYPE_DICTIONARY:
			reward_history.append((rh as Dictionary).duplicate(true))

	unlocked_achievements.clear()
	for ach in data.get("unlocked_achievements", []):
		if not unlocked_achievements.has(str(ach)):
			unlocked_achievements.append(str(ach))

	exp = int(data.get("exp", 0))
	gold = int(data.get("gold", 0))
	stars = int(data.get("stars", 0))
	level = maxi(1, int(data.get("level", 1)))
	save_revision = int(data.get("save_revision", 0))
	last_saved_unix = int(data.get("last_saved_unix", 0))
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
		"completed_chapters": completed_chapters,
		"active_quests": active_quests,
		"completed_quests": completed_quests,
		"claimed_quests": claimed_quests,
		"rewarded_quests": rewarded_quests,
		"met_npcs": met_npcs,
		"npc_encounters": npc_encounters,
		"seen_dialogues": seen_dialogues,
		"collected_objects": collected_objects,
		"inventory": inventory,
		"flags": flags,
		"minigame_records": minigame_records,
		"claimed_reward_keys": claimed_reward_keys,
		"reward_history": reward_history,
		"unlocked_achievements": unlocked_achievements,
		"exp": exp,
		"gold": gold,
		"stars": stars,
		"level": level,
		"save_revision": save_revision,
		"last_saved_unix": last_saved_unix,
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


func mark_npc_met(npc_id: String, dialogue_id: String = "") -> void:
	if not met_npcs.has(npc_id):
		met_npcs.append(npc_id)
		EventBus.npc_met.emit(npc_id)
	var enc: Dictionary = npc_encounters.get(npc_id, { "talk_count": 0, "last_dialogue_id": "", "last_talk_utc": "" })
	enc["talk_count"] = int(enc.get("talk_count", 0)) + 1
	if not dialogue_id.is_empty():
		enc["last_dialogue_id"] = dialogue_id
	enc["last_talk_utc"] = Time.get_datetime_string_from_system(true)
	npc_encounters[npc_id] = enc


func mark_dialogue_seen(dialogue_id: String) -> void:
	if not dialogue_id.is_empty() and not seen_dialogues.has(dialogue_id):
		seen_dialogues.append(dialogue_id)


func is_object_collected(obj_id: String) -> bool:
	return collected_objects.has(obj_id)


func mark_object_collected(obj_id: String) -> void:
	if not collected_objects.has(obj_id):
		collected_objects.append(obj_id)


func add_item(item_dict: Dictionary) -> void:
	var item_id := str(item_dict.get("id", ""))
	if item_id.is_empty():
		return
	var qty := maxi(1, int(item_dict.get("quantity", 1)))
	var meta: Dictionary = DataRepository.get_item_def(item_id)
	if inventory.has(item_id):
		inventory[item_id]["quantity"] = int(inventory[item_id].get("quantity", 0)) + qty
	else:
		inventory[item_id] = {
			"id": item_id,
			"name_vi": str(item_dict.get("name_vi", meta.get("name_vi", item_id))),
			"name_en": str(item_dict.get("name_en", meta.get("name_en", item_id))),
			"item_type": str(item_dict.get("item_type", meta.get("item_type", "collectible"))),
			"rarity": str(item_dict.get("rarity", meta.get("rarity", "common"))),
			"acquisition_source_vi": str(item_dict.get("acquisition_source_vi", meta.get("acquisition_source_vi", ""))),
			"quantity": qty
		}
	EventBus.item_collected.emit(item_id, qty)
	EventBus.progress_updated.emit()


func set_flag(flag_name: String, value: bool = true) -> void:
	flags[flag_name] = value
	evaluate_all_unlocks(true)


func get_minigame_record(minigame_id: String) -> Dictionary:
	return (minigame_records.get(minigame_id, {}) as Dictionary).duplicate(true)


func record_minigame_result(minigame_id: String, learning_score: int, game_score: int, earned_stars: int) -> void:
	var rec: Dictionary = minigame_records.get(minigame_id, {
		"plays": 0,
		"best_learning_score": 0,
		"best_game_score": 0,
		"best_stars": 0,
		"last_played_utc": ""
	})
	rec["plays"] = int(rec.get("plays", 0)) + 1
	rec["best_learning_score"] = maxi(int(rec.get("best_learning_score", 0)), learning_score)
	rec["best_game_score"] = maxi(int(rec.get("best_game_score", 0)), game_score)
	rec["best_stars"] = maxi(int(rec.get("best_stars", 0)), earned_stars)
	rec["last_played_utc"] = Time.get_datetime_string_from_system(true)
	minigame_records[minigame_id] = rec
	evaluate_all_unlocks(true)


func add_exp_and_gold(add_exp: int, add_gold: int, add_stars: int = 0) -> void:
	exp += maxi(0, add_exp)
	gold += maxi(0, add_gold)
	stars += maxi(0, add_stars)
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
					EventBus.region_unlocked.emit(aid)
		if not completed_areas.has(aid):
			var comp_cond: Dictionary = area.get("completion_condition", {})
			if not comp_cond.is_empty() and UnlockEvaluator.is_condition_met(comp_cond, snapshot):
				completed_areas.append(aid)
				if notify_newly_unlocked:
					EventBus.region_completed.emit(aid)

	for ch in DataRepository.chapters_ordered:
		var cid := str(ch.get("id", ""))
		if cid.is_empty() or completed_chapters.has(cid):
			continue
		var ch_cond: Dictionary = ch.get("completion_condition", {})
		if not ch_cond.is_empty() and UnlockEvaluator.is_condition_met(ch_cond, snapshot):
			completed_chapters.append(cid)
			if notify_newly_unlocked:
				EventBus.chapter_completed.emit(cid)


func save_now(_reason: String = "manual") -> bool:
	save_revision += 1
	last_saved_unix = int(Time.get_unix_time_from_system())
	return SaveLoadManager.save_state(to_state_dict())


func _on_save_requested(reason: String) -> void:
	save_now(reason)
