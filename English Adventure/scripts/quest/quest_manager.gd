extends Node
## Data-driven Quest System managing Locked / Available / Active / Completed states,
## step tracking, duplicate-reward prevention, and Prompt 03 learning hooks.


func _ready() -> void:
	EventBus.area_entered.connect(_on_area_entered)
	EventBus.minigame_completed.connect(_on_minigame_completed)


func get_quest_status(quest_id: String) -> String:
	if GameStateManager.completed_quests.has(quest_id):
		return "completed"
	if GameStateManager.active_quests.has(quest_id):
		return "active"
	var q: Dictionary = DataRepository.quests_by_id.get(quest_id, {})
	if q.is_empty():
		return "locked"
	var cond: Dictionary = q.get("start_condition", {})
	if UnlockEvaluator.is_condition_met(cond, GameStateManager.to_state_dict()):
		return "available"
	return "locked"


func get_active_quest_id() -> String:
	for q in DataRepository.quests_ordered:
		var qid := str(q.get("id", ""))
		if get_quest_status(qid) == "active":
			return qid
	return ""


func get_next_suggested_quest() -> Dictionary:
	var active_id := get_active_quest_id()
	if not active_id.is_empty():
		return DataRepository.quests_by_id.get(active_id, {})
	for q in DataRepository.quests_ordered:
		var qid := str(q.get("id", ""))
		if get_quest_status(qid) == "available":
			return q
	return {}


func get_current_step(quest_id: String) -> Dictionary:
	var q: Dictionary = DataRepository.quests_by_id.get(quest_id, {})
	var steps: Array = q.get("steps", [])
	var state: Dictionary = GameStateManager.active_quests.get(quest_id, {})
	var idx := int(state.get("step_index", 0))
	if idx >= 0 and idx < steps.size():
		return steps[idx]
	return {}


func start_quest(quest_id: String) -> bool:
	var status := get_quest_status(quest_id)
	if status == "active" or status == "completed" or status == "locked":
		return false
	GameStateManager.active_quests[quest_id] = {
		"step_index": 0,
		"collected_tags": {}
	}
	GameStateManager.save_now("quest_started_" + quest_id)
	EventBus.quest_started.emit(quest_id)
	AppLogger.info("QuestManager", "Quest started: " + quest_id)
	# Immediately satisfy step 0 if it matches talking to the quest giver or being in the target area
	var q: Dictionary = DataRepository.quests_by_id.get(quest_id, {})
	var giver := str(q.get("giver_npc_id", ""))
	if not giver.is_empty() and GameStateManager.met_npcs.has(giver):
		report_npc_talk(giver)
	report_area_visited(GameStateManager.current_area_id)
	return true


func has_available_quest_for_npc(npc_id: String) -> String:
	for q in DataRepository.quests_ordered:
		var qid := str(q.get("id", ""))
		if str(q.get("giver_npc_id", "")) == npc_id and get_quest_status(qid) == "available":
			return qid
	return ""


func is_npc_current_target(npc_id: String) -> bool:
	for qid in GameStateManager.active_quests.keys():
		var step := get_current_step(str(qid))
		if str(step.get("type", "")) == "talk_to_npc" and str(step.get("target_id", "")) == npc_id:
			return true
	return false


func report_npc_talk(npc_id: String) -> void:
	_process_step_event("talk_to_npc", npc_id, "")


func report_area_visited(area_id: String) -> void:
	_process_step_event("visit_area", area_id, "")


func report_object_interacted(object_id: String, object_tag: String = "") -> void:
	_process_step_event("interact_object", object_id, object_tag)
	if not object_tag.is_empty():
		_process_step_event("collect_tag", object_id, object_tag)


func _process_step_event(event_type: String, target_id: String, tag: String) -> void:
	var keys := GameStateManager.active_quests.keys().duplicate()
	for qid_var in keys:
		var qid := str(qid_var)
		var q: Dictionary = DataRepository.quests_by_id.get(qid, {})
		var steps: Array = q.get("steps", [])
		var progress: Dictionary = GameStateManager.active_quests.get(qid, {})
		var idx := int(progress.get("step_index", 0))
		if idx >= steps.size():
			continue

		var step: Dictionary = steps[idx]
		var step_type := str(step.get("type", ""))
		var advanced := false

		if step_type == event_type and event_type != "collect_tag":
			if str(step.get("target_id", "")) == target_id:
				advanced = true
		elif step_type == "collect_tag" and event_type == "collect_tag":
			var req_tag := str(step.get("target_tag", ""))
			if req_tag == tag:
				var collected_map: Dictionary = progress.get("collected_tags", {})
				var items_for_tag: Array = collected_map.get(req_tag, [])
				if not items_for_tag.has(target_id):
					items_for_tag.append(target_id)
					collected_map[req_tag] = items_for_tag
					progress["collected_tags"] = collected_map
				var req_count := int(step.get("required_count", 1))
				if items_for_tag.size() >= req_count:
					advanced = true
				else:
					GameStateManager.active_quests[qid] = progress
					EventBus.quest_step_updated.emit(qid, idx)
					GameStateManager.save_now("quest_subprogress")

		if advanced:
			idx += 1
			progress["step_index"] = idx
			GameStateManager.active_quests[qid] = progress
			if idx >= steps.size():
				_complete_quest(qid)
			else:
				EventBus.quest_step_updated.emit(qid, idx)
				GameStateManager.save_now("quest_step_" + qid)
				# Chain-check in case next step is already in current area
				if str(steps[idx].get("type", "")) == "visit_area" and str(steps[idx].get("target_id", "")) == GameStateManager.current_area_id:
					report_area_visited(GameStateManager.current_area_id)


func _complete_quest(quest_id: String) -> void:
	if GameStateManager.completed_quests.has(quest_id):
		return
	var q: Dictionary = DataRepository.quests_by_id.get(quest_id, {})
	GameStateManager.active_quests.erase(quest_id)
	GameStateManager.completed_quests.append(quest_id)

	var rewards: Dictionary = q.get("rewards", {})
	# Duplicate reward protection
	if not GameStateManager.rewarded_quests.has(quest_id):
		GameStateManager.rewarded_quests.append(quest_id)
		var reward_exp := int(rewards.get("exp", 0))
		var reward_gold := int(rewards.get("gold", 0))
		GameStateManager.add_exp_and_gold(reward_exp, reward_gold)

		for item in rewards.get("items", []):
			if typeof(item) == TYPE_DICTIONARY:
				GameStateManager.add_item(item)

		for flag_name in rewards.get("set_flags", []):
			GameStateManager.flags[str(flag_name)] = true

	EventBus.quest_completed.emit(quest_id, rewards)
	trigger_learning_hook_for_quest(quest_id)
	GameStateManager.evaluate_all_unlocks(true)
	GameStateManager.save_now("quest_completed_" + quest_id)
	AppLogger.info("QuestManager", "Quest completed: " + quest_id)


func trigger_learning_hook_for_quest(quest_id: String) -> void:
	var q: Dictionary = DataRepository.quests_by_id.get(quest_id, {})
	var hook: Dictionary = q.get("learning_hook", {})
	if not hook.is_empty():
		EventBus.learning_hook_requested.emit({
			"quest_id": quest_id,
			"lesson_id": hook.get("future_lesson_id", ""),
			"skills": hook.get("skills", [])
		})


func get_quest_minigame_id(quest_id: String) -> String:
	var q: Dictionary = DataRepository.quests_by_id.get(quest_id, {})
	var hook: Dictionary = q.get("learning_hook", {})
	return str(hook.get("future_minigame_id", ""))


func _on_minigame_completed(minigame_id: String, result: Dictionary) -> void:
	if bool(result.get("passed", true)):
		_process_step_event("minigame_completed", minigame_id, "")


func _on_area_entered(area_id: String) -> void:
	report_area_visited(area_id)
