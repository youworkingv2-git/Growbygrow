extends Node
## Manages Quest lifecycle (Locked -> Available -> Active -> Completed),
## step progression, anti-duplicate reward granting, and area unlocking.

const QUESTS_PATH := "res://data/quests/world_1/quests_world1.json"

var quests_by_id: Dictionary = {}
var quest_order: Array[String] = []

func _ready() -> void:
	_load_quests()
	EventBus.interaction_triggered.connect(_on_interaction_triggered)
	EventBus.area_entered.connect(_on_area_entered)
	# Auto-start Quest 01 if not started and not completed
	call_deferred("_ensure_initial_quest")

func _load_quests() -> void:
	if not FileAccess.file_exists(QUESTS_PATH):
		push_error("Missing quests file: " + QUESTS_PATH)
		return
	var file := FileAccess.open(QUESTS_PATH, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) == TYPE_DICTIONARY and parsed.has("quests"):
		for q in parsed["quests"]:
			var qid: String = q.get("id", "")
			quests_by_id[qid] = q
			quest_order.append(qid)

func _ensure_initial_quest() -> void:
	if get_quest_status("quest_01_new_adventure") == "Available":
		start_quest("quest_01_new_adventure")

func get_quest_status(quest_id: String) -> String:
	if is_quest_completed(quest_id):
		return "Completed"
	var active: Dictionary = SaveManager.player_data.get("active_quests", {})
	if active.has(quest_id):
		return "Active"
	if _is_unlock_condition_met(quest_id):
		return "Available"
	return "Locked"

func is_quest_completed(quest_id: String) -> bool:
	var completed: Array = SaveManager.player_data.get("completed_quests", [])
	return quest_id in completed

func _is_unlock_condition_met(quest_id: String) -> bool:
	var q: Dictionary = quests_by_id.get(quest_id, {})
	if q.is_empty():
		return false
	var cond: Dictionary = q.get("unlock_condition", {})
	var ctype: String = cond.get("type", "default_unlocked")
	match ctype:
		"default_unlocked":
			return true
		"quest_completed":
			return is_quest_completed(cond.get("quest_id", ""))
		_:
			return false

func start_quest(quest_id: String) -> bool:
	if get_quest_status(quest_id) != "Available":
		return false
	var active: Dictionary = SaveManager.player_data.get("active_quests", {})
	active[quest_id] = { "current_step": 0 }
	SaveManager.player_data["active_quests"] = active
	SaveManager.save_game()
	EventBus.quest_started.emit(quest_id)
	EventBus.quest_log_updated.emit()
	return true

func get_active_quest_id() -> String:
	var active: Dictionary = SaveManager.player_data.get("active_quests", {})
	for qid in quest_order:
		if active.has(qid):
			return qid
	return ""

func get_active_quest_summary() -> Dictionary:
	var qid := get_active_quest_id()
	if qid == "":
		return {}
	var q: Dictionary = quests_by_id.get(qid, {})
	var active: Dictionary = SaveManager.player_data.get("active_quests", {})
	var step_idx: int = active[qid].get("current_step", 0)
	var steps: Array = q.get("steps", [])
	var step_desc := ""
	if step_idx < steps.size():
		step_desc = steps[step_idx].get("description_vi", "")
	return {
		"id": qid,
		"name_vi": q.get("name_vi", ""),
		"name_en": q.get("name_en", ""),
		"step_index": step_idx,
		"total_steps": steps.size(),
		"step_description_vi": step_desc
	}

func get_quests_for_area(area_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for qid in quest_order:
		var q: Dictionary = quests_by_id[qid]
		if q.get("area_id", "") == area_id:
			result.append(q)
	return result

func _on_interaction_triggered(target_id: String) -> void:
	_check_step_progress("interact_npc", target_id)
	_check_step_progress("interact_object", target_id)

func _on_area_entered(area_id: String) -> void:
	_check_step_progress("visit_area", area_id)

func _check_step_progress(target_type: String, target_id: String) -> void:
	var active: Dictionary = SaveManager.player_data.get("active_quests", {})
	var keys := active.keys()
	for qid in keys:
		var q: Dictionary = quests_by_id.get(qid, {})
		var steps: Array = q.get("steps", [])
		var step_idx: int = active[qid].get("current_step", 0)
		if step_idx >= steps.size():
			continue
		var step: Dictionary = steps[step_idx]
		if step.get("target_type", "") == target_type and step.get("target_id", "") == target_id:
			advance_quest_step(qid)

func advance_quest_step(quest_id: String) -> void:
	var active: Dictionary = SaveManager.player_data.get("active_quests", {})
	if not active.has(quest_id):
		return
	var q: Dictionary = quests_by_id.get(quest_id, {})
	var steps: Array = q.get("steps", [])
	var next_idx: int = active[quest_id].get("current_step", 0) + 1
	if next_idx >= steps.size():
		complete_quest(quest_id)
	else:
		active[quest_id]["current_step"] = next_idx
		SaveManager.player_data["active_quests"] = active
		SaveManager.save_game()
		EventBus.quest_step_updated.emit(quest_id, next_idx)
		EventBus.quest_log_updated.emit()

func complete_quest(quest_id: String) -> void:
	# Prevent duplicate completion & duplicate rewards
	if is_quest_completed(quest_id):
		return
	var active: Dictionary = SaveManager.player_data.get("active_quests", {})
	active.erase(quest_id)
	SaveManager.player_data["active_quests"] = active

	var completed: Array = SaveManager.player_data.get("completed_quests", [])
	completed.append(quest_id)
	SaveManager.player_data["completed_quests"] = completed

	var q: Dictionary = quests_by_id.get(quest_id, {})
	var reward: Dictionary = q.get("reward", {})
	SaveManager.player_data["exp"] = SaveManager.player_data.get("exp", 0) + reward.get("exp", 0)
	SaveManager.player_data["gold"] = SaveManager.player_data.get("gold", 0) + reward.get("gold", 0)
	SaveManager.player_data["magic_crystals"] = SaveManager.player_data.get("magic_crystals", 0) + reward.get("magic_crystals", 0)

	var unlock_area_id: String = reward.get("unlocks_area_id", "")
	if unlock_area_id != "":
		SaveManager.unlock_area(unlock_area_id)

	SaveManager.save_game()
	EventBus.quest_completed.emit(quest_id, reward)
	EventBus.quest_log_updated.emit()

	# Auto-activate next available quest in MVP flow
	for next_qid in quest_order:
		if get_quest_status(next_qid) == "Available":
			start_quest(next_qid)
			break
