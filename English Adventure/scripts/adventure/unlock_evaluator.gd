class_name UnlockEvaluator
extends RefCounted
## Evaluates data-driven unlock conditions for Areas, Quests, and NPC appearances.


static func is_condition_met(condition: Dictionary, state: Dictionary) -> bool:
	if condition.is_empty():
		return true
	var cond_type: String = str(condition.get("type", "always_unlocked"))
	var completed_quests: Array = state.get("completed_quests", [])
	var unlocked_areas: Array = state.get("unlocked_areas", [])
	var flags: Dictionary = state.get("flags", {})
	var inventory: Dictionary = state.get("inventory", {})

	match cond_type:
		"always_unlocked", "always_available", "always":
			return true
		"quests_completed":
			for qid in condition.get("required_quests", []):
				if not completed_quests.has(str(qid)):
					return false
			return true
		"flags_required":
			for flag_name in condition.get("required_flags", []):
				if not bool(flags.get(str(flag_name), false)):
					return false
			return true
		"quests_and_items":
			for qid in condition.get("required_quests", []):
				if not completed_quests.has(str(qid)):
					return false
			for item_id in condition.get("required_items", []):
				var item_entry: Dictionary = inventory.get(str(item_id), {})
				if int(item_entry.get("quantity", 0)) <= 0:
					return false
			return true
		"area_unlocked":
			var req_area := str(condition.get("area_id", ""))
			return unlocked_areas.has(req_area)
		"world_completed":
			var req_world := str(condition.get("required_world_id", ""))
			return bool(flags.get("world_completed_" + req_world, false))
		_:
			return false
