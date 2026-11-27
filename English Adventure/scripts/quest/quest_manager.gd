extends Node
## Data-driven QuestManager orchestrating QuestRepository, QuestRegistry, QuestStateManager,
## QuestObjectiveManager, QuestConditionEvaluator, QuestProgressTracker, QuestRewardManager,
## QuestNotificationManager, and QuestEventHandler.

var repository: QuestRepository
var registry: QuestRegistry
var state_manager: QuestStateManager
var event_handler: QuestEventHandler
var _syncing_precompleted: bool = false


func _ready() -> void:
	repository = QuestRepository.new()
	registry = QuestRegistry.new(repository)
	state_manager = QuestStateManager.new(repository)
	event_handler = QuestEventHandler.new()

	EventBus.area_entered.connect(_on_area_entered)
	EventBus.area_unlocked.connect(_on_area_unlocked)
	EventBus.minigame_completed.connect(_on_minigame_completed)
	EventBus.minigame_answered.connect(_on_minigame_answered)
	EventBus.learning_activity_answered.connect(_on_learning_activity_answered)
	EventBus.lesson_completed.connect(_on_lesson_completed)
	EventBus.item_collected.connect(_on_item_collected)


func get_quest_status(quest_id: String) -> String:
	return state_manager.get_legacy_status(quest_id)


func get_detailed_quest_status(quest_id: String) -> String:
	return state_manager.get_status(quest_id)


func get_active_quest_id() -> String:
	for q in repository.get_all_quests():
		var qid := str(q.get("id", ""))
		if get_quest_status(qid) == "active":
			return qid
	return ""


func get_next_suggested_quest() -> Dictionary:
	var active_id := get_active_quest_id()
	if not active_id.is_empty():
		return repository.get_quest(active_id)
	for q in repository.get_all_quests():
		var qid := str(q.get("id", ""))
		if get_quest_status(qid) == "available":
			return q
	return {}


func get_current_step(quest_id: String) -> Dictionary:
	var q := repository.get_quest(quest_id)
	var steps: Array = q.get("steps", [])
	var state: Dictionary = GameStateManager.active_quests.get(quest_id, {})
	var idx := int(state.get("step_index", 0))
	if idx >= 0 and idx < steps.size():
		return steps[idx]
	return {}


func get_objective_progress(quest_id: String, objective_id: String) -> Dictionary:
	var q := repository.get_quest(quest_id)
	return QuestProgressTracker.get_objective_progress(quest_id, objective_id, q)


func get_quests_by_filter(filter_mode: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for q in repository.get_all_quests():
		var qid := str(q.get("id", ""))
		var st := get_detailed_quest_status(qid)
		var qtype := str(q.get("quest_type", "main"))
		match filter_mode:
			"main":
				if qtype == "main" and st != "locked":
					out.append(q)
			"side":
				if qtype == "side" and st != "locked":
					out.append(q)
			"completed":
				if st == "completed" or st == "claimed":
					out.append(q)
			"locked":
				if st == "locked":
					out.append(q)
			_:
				out.append(q)
	return out


func start_quest(quest_id: String) -> bool:
	var detailed := get_detailed_quest_status(quest_id)
	if detailed in ["accepted", "in_progress", "completed", "claimed", "locked"]:
		return false
	var q := repository.get_quest(quest_id)
	GameStateManager.active_quests[quest_id] = {
		"step_index": 0,
		"collected_tags": {},
		"has_progress": false,
		"objectives": QuestObjectiveManager.init_objectives_state(q),
		"started_at_utc": Time.get_datetime_string_from_system(true)
	}
	GameStateManager.save_now("quest_started_" + quest_id)
	EventBus.quest_started.emit(quest_id)
	EventBus.quest_accepted.emit(quest_id)
	QuestNotificationManager.notify_started(q)
	AppLogger.info("QuestManager", "Quest started: " + quest_id)

	var giver := str(q.get("giver_npc_id", ""))
	if not giver.is_empty() and GameStateManager.met_npcs.has(giver):
		report_npc_talk(giver)
	report_area_visited(GameStateManager.current_area_id)
	_sync_precompleted_world_objectives(quest_id)
	return true


func claim_quest_reward(quest_id: String) -> Dictionary:
	var q := repository.get_quest(quest_id)
	return QuestRewardManager.claim_quest_reward(quest_id, q)


func has_available_quest_for_npc(npc_id: String) -> String:
	for q in repository.get_all_quests():
		var qid := str(q.get("id", ""))
		if str(q.get("giver_npc_id", "")) == npc_id and get_detailed_quest_status(qid) == "available":
			return qid
	return ""


func is_npc_turn_in_ready(npc_id: String) -> String:
	for q in repository.get_all_quests():
		var qid := str(q.get("id", ""))
		var turn_in := str(q.get("turn_in_npc_id", q.get("giver_npc_id", "")))
		if turn_in == npc_id and get_detailed_quest_status(qid) == "completed":
			return qid
	return ""


func is_npc_current_target(npc_id: String) -> bool:
	for qid_var in GameStateManager.active_quests.keys():
		var qid := str(qid_var)
		var q := repository.get_quest(qid)
		var steps: Array = q.get("steps", [])
		var prog: Dictionary = GameStateManager.active_quests.get(qid, {})
		var obj_map: Dictionary = prog.get("objectives", {})
		for idx in QuestObjectiveManager.get_eligible_indices(steps, obj_map):
			var st: Dictionary = steps[idx]
			var st_type := str(st.get("type", ""))
			if st_type in ["talk_to_npc", "return_to_npc"] and str(st.get("target_id", "")) == npc_id:
				return true
	return false


func resolve_npc_dialogue(npc_data: Dictionary) -> String:
	var state_dict := GameStateManager.to_state_dict()
	for rule_var in npc_data.get("dialogue_rules", []):
		if typeof(rule_var) != TYPE_DICTIONARY:
			continue
		var rule: Dictionary = rule_var
		var cond: Dictionary = rule.get("condition", {})
		if QuestConditionEvaluator.is_npc_condition_met(cond, state_dict):
			var did := str(rule.get("dialogue_id", ""))
			if not did.is_empty():
				return did
	return str(npc_data.get("default_dialogue_id", ""))


func resolve_npc_followup_minigame(npc_data: Dictionary) -> Dictionary:
	var follow: Variant = npc_data.get("followup_minigame", {})
	if typeof(follow) != TYPE_DICTIONARY or (follow as Dictionary).is_empty():
		return {}
	var fdict: Dictionary = follow
	var cond: Dictionary = fdict.get("condition", {})
	if QuestConditionEvaluator.is_npc_condition_met(cond, GameStateManager.to_state_dict()):
		return {
			"minigame_id": str(fdict.get("minigame_id", "")),
			"context": {
				"source_type": "npc",
				"source_id": str(npc_data.get("id", "")),
				"bypass_unlock": true
			}
		}
	return {}


func report_npc_talk(npc_id: String) -> void:
	_process_step_event("talk_to_npc", { "target_id": npc_id })


func report_area_visited(area_id: String) -> void:
	_process_step_event("visit_area", { "target_id": area_id })


func report_object_interacted(object_id: String, object_tag: String = "") -> void:
	_process_step_event("interact_object", { "target_id": object_id })
	if not object_tag.is_empty():
		_process_step_event("collect_tag", { "target_id": object_id, "tag": object_tag })


func _process_step_event(event_type: String, payload: Dictionary) -> void:
	var keys := GameStateManager.active_quests.keys().duplicate()
	for qid_var in keys:
		var qid := str(qid_var)
		var q := repository.get_quest(qid)
		if q.is_empty():
			continue
		var progress: Dictionary = GameStateManager.active_quests.get(qid, {})
		var res := QuestObjectiveManager.process_event_on_quest(q, progress, event_type, payload)
		if not bool(res.get("updated", false)):
			continue

		GameStateManager.active_quests[qid] = progress
		var last_obj: Dictionary = res.get("last_objective", {})
		if not last_obj.is_empty():
			var obj_id := str(last_obj.get("objective_id", ""))
			EventBus.quest_objective_updated.emit(
				qid,
				obj_id,
				int(last_obj.get("current", 0)),
				int(last_obj.get("target", 1))
			)
			for st in q.get("steps", []):
				if typeof(st) == TYPE_DICTIONARY and str((st as Dictionary).get("id", "")) == obj_id:
					QuestNotificationManager.notify_objective_updated(q, st as Dictionary, last_obj)
					break

		if bool(res.get("all_required_completed", false)):
			_complete_quest(qid)
		else:
			EventBus.quest_step_updated.emit(qid, int(res.get("step_index", 0)))
			GameStateManager.save_now("quest_step_" + qid)
			_sync_precompleted_world_objectives(qid)


func _sync_precompleted_world_objectives(quest_id: String) -> void:
	if _syncing_precompleted or not GameStateManager.active_quests.has(quest_id):
		return
	var q := repository.get_quest(quest_id)
	if q.is_empty():
		return
	_syncing_precompleted = true
	var steps: Array = q.get("steps", [])
	for _pass_idx in range(steps.size() + 1):
		if not GameStateManager.active_quests.has(quest_id):
			break
		var prog: Dictionary = GameStateManager.active_quests.get(quest_id, {})
		var obj_map: Dictionary = prog.get("objectives", {})
		var did_update := false
		for idx in QuestObjectiveManager.get_eligible_indices(steps, obj_map):
			var st: Dictionary = steps[idx]
			var st_type := str(st.get("type", ""))
			var target_id := str(st.get("target_id", ""))
			match st_type:
				"visit_area":
					if target_id == GameStateManager.current_area_id:
						var r := QuestObjectiveManager.process_event_on_quest(q, prog, "visit_area", { "target_id": target_id })
						if bool(r.get("updated", false)):
							did_update = true
				"interact_object":
					if GameStateManager.is_object_collected(target_id):
						var r := QuestObjectiveManager.process_event_on_quest(q, prog, "interact_object", { "target_id": target_id })
						if bool(r.get("updated", false)):
							did_update = true
				"collect_tag":
					var req_tag := str(st.get("target_tag", ""))
					for oid in GameStateManager.collected_objects:
						var odef: Dictionary = DataRepository.objects_by_id.get(str(oid), {})
						if str(odef.get("tag", "")) == req_tag:
							var r := QuestObjectiveManager.process_event_on_quest(q, prog, "collect_tag", { "target_id": str(oid), "tag": req_tag })
							if bool(r.get("updated", false)):
								did_update = true
				"collect_item":
					if int((GameStateManager.inventory.get(target_id, {}) as Dictionary).get("quantity", 0)) > 0:
						var r := QuestObjectiveManager.process_event_on_quest(q, prog, "collect_item", { "target_id": target_id })
						if bool(r.get("updated", false)):
							did_update = true
				"open_new_area":
					if GameStateManager.is_area_unlocked(target_id):
						var r := QuestObjectiveManager.process_event_on_quest(q, prog, "open_new_area", { "target_id": target_id })
						if bool(r.get("updated", false)):
							did_update = true
		if not did_update:
			break
		GameStateManager.active_quests[quest_id] = prog
		if QuestObjectiveManager.are_all_required_completed(steps, prog.get("objectives", {})):
			_complete_quest(quest_id)
			break
		EventBus.quest_step_updated.emit(quest_id, int(prog.get("step_index", 0)))
		GameStateManager.save_now("quest_sync_" + quest_id)
	_syncing_precompleted = false


func _complete_quest(quest_id: String) -> void:
	if GameStateManager.completed_quests.has(quest_id):
		return
	var q := repository.get_quest(quest_id)
	GameStateManager.active_quests.erase(quest_id)
	GameStateManager.completed_quests.append(quest_id)

	var rewards: Dictionary = q.get("rewards", {})
	for flag_name in rewards.get("set_flags", []):
		GameStateManager.flags[str(flag_name)] = true

	QuestNotificationManager.notify_completed(q)
	EventBus.quest_completed.emit(quest_id, rewards)
	trigger_learning_hook_for_quest(quest_id)
	GameStateManager.evaluate_all_unlocks(true)
	GameStateManager.save_now("quest_completed_" + quest_id)

	# Auto-claim only if configured as auto; default manual_or_npc transitions Completed -> Claimed via HUD/NPC
	if str(q.get("claim_mode", "manual_or_npc")) == "auto":
		claim_quest_reward(quest_id)
	AppLogger.info("QuestManager", "Quest completed (ready to claim): " + quest_id)


func trigger_learning_hook_for_quest(quest_id: String) -> void:
	var q := repository.get_quest(quest_id)
	var hook: Dictionary = q.get("learning_hook", {})
	if not hook.is_empty():
		EventBus.learning_hook_requested.emit({
			"quest_id": quest_id,
			"lesson_id": hook.get("future_lesson_id", ""),
			"skills": hook.get("skills", [])
		})


func get_quest_minigame_id(quest_id: String) -> String:
	var q := repository.get_quest(quest_id)
	var hook: Dictionary = q.get("learning_hook", {})
	return str(hook.get("future_minigame_id", ""))


func _on_minigame_completed(minigame_id: String, result: Dictionary) -> void:
	var dedup := "mg_comp:%s:%s" % [minigame_id, str(result.get("completed_at_utc", result.get("completion_time_ms", "")))]
	if event_handler.is_duplicate_event(dedup):
		return
	if bool(result.get("passed", true)):
		_process_step_event("complete_minigame", { "target_id": minigame_id })


func _on_minigame_answered(minigame_id: String, attempt_record: Dictionary) -> void:
	var qid_str := str(attempt_record.get("question_id", ""))
	var is_ok := bool(attempt_record.get("is_correct", false))
	var kid := str(attempt_record.get("knowledge_id", ""))
	if not is_ok:
		return
	var dedup := "mg_ans:%s:%s:%s" % [minigame_id, qid_str, str(attempt_record.get("completed_at_utc", ""))]
	if event_handler.is_duplicate_event(dedup):
		return
	_process_step_event("learn_vocabulary", {
		"knowledge_id": kid if not kid.is_empty() else qid_str,
		"target_id": kid,
		"is_correct": true,
		"increment": 1
	})
	_process_step_event("answer_questions_correctly", {
		"is_correct": true,
		"increment": 1
	})


func _on_learning_activity_answered(attempt_record: Dictionary) -> void:
	# Mini-game attempts already emit minigame_answered; avoid double-counting them here
	if attempt_record.has("minigame_id"):
		return
	if not bool(attempt_record.get("is_correct", false)):
		return
	var kid := str(attempt_record.get("knowledge_id", attempt_record.get("question_id", "")))
	var dedup := "learn_ans:%s:%s" % [str(attempt_record.get("question_id", "")), str(attempt_record.get("completed_at_utc", ""))]
	if event_handler.is_duplicate_event(dedup):
		return
	_process_step_event("learn_vocabulary", {
		"knowledge_id": kid,
		"target_id": kid,
		"is_correct": true,
		"increment": 1
	})
	_process_step_event("answer_questions_correctly", {
		"is_correct": true,
		"increment": 1
	})


func _on_lesson_completed(lesson_id: String, _summary: Dictionary) -> void:
	_process_step_event("complete_learning_activity", { "target_id": lesson_id })


func _on_item_collected(item_id: String, _quantity: int) -> void:
	_process_step_event("collect_item", { "target_id": item_id })


func _on_area_entered(area_id: String) -> void:
	report_area_visited(area_id)


func _on_area_unlocked(area_id: String) -> void:
	_process_step_event("open_new_area", { "target_id": area_id })
