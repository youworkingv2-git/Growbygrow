class_name AchievementManager
extends RefCounted
## Evaluates data-driven Achievement conditions against current GameState & LearningEngine.


static func check_newly_unlocked() -> Array[Dictionary]:
	var newly: Array[Dictionary] = []
	for ach in DataRepository.achievements_ordered:
		var aid := str(ach.get("id", ""))
		if aid.is_empty() or GameStateManager.unlocked_achievements.has(aid):
			continue
		var cond: Dictionary = ach.get("condition", {})
		if _is_achievement_met(cond):
			newly.append(ach.duplicate(true))
	return newly


static func _is_achievement_met(cond: Dictionary) -> bool:
	var ctype := str(cond.get("type", ""))
	var min_n := int(cond.get("min_count", 1))
	match ctype:
		"quests_claimed_count":
			return GameStateManager.claimed_quests.size() >= min_n
		"quests_claimed_contains":
			return GameStateManager.claimed_quests.has(str(cond.get("quest_id", "")))
		"minigames_played_count":
			var total_plays := 0
			for rec_var in GameStateManager.minigame_records.values():
				if typeof(rec_var) == TYPE_DICTIONARY:
					total_plays += int((rec_var as Dictionary).get("plays", 0))
			return total_plays >= min_n
		"correct_answers_total":
			var correct_n := 0
			if LearningEngine != null and LearningEngine.progress_manager != null:
				for att in LearningEngine.progress_manager.attempt_history:
					if bool(att.get("is_correct", false)):
						correct_n += 1
			return correct_n >= min_n
		"area_unlocked":
			return GameStateManager.is_area_unlocked(str(cond.get("area_id", "")))
		"crystals_count":
			return GameStateManager.get_magic_crystal_count() >= min_n
		"side_quests_claimed_count":
			var cnt := 0
			for qid in GameStateManager.claimed_quests:
				var q: Dictionary = DataRepository.quests_by_id.get(qid, {})
				if str(q.get("quest_type", "main")) == "side":
					cnt += 1
			return cnt >= min_n
		_:
			return false
