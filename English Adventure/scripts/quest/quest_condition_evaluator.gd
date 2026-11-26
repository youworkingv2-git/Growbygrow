class_name QuestConditionEvaluator
extends RefCounted
## Evaluates start, unlock, level, region, prerequisite, and completion conditions for Quests.


static func can_start_quest(quest_def: Dictionary, state: Dictionary) -> bool:
	if quest_def.is_empty():
		return false
	var req_level := int(quest_def.get("required_level", 1))
	if int(state.get("level", 1)) < req_level:
		return false
	var start_cond: Dictionary = quest_def.get("start_condition", {})
	return UnlockEvaluator.is_condition_met(start_cond, state)


static func is_npc_condition_met(cond: Dictionary, state: Dictionary) -> bool:
	return UnlockEvaluator.is_condition_met(cond, state)
