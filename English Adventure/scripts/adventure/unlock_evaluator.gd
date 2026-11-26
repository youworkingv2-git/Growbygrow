class_name UnlockEvaluator
extends RefCounted
## Evaluates data-driven unlock & dialogue conditions for Areas, Quests, Chapters, and NPCs.


static func is_condition_met(condition: Dictionary, state: Dictionary) -> bool:
	if condition.is_empty():
		return true
	var cond_type: String = str(condition.get("type", "always_unlocked"))
	var completed_quests: Array = state.get("completed_quests", [])
	var claimed_quests: Array = state.get("claimed_quests", [])
	var active_quests: Dictionary = state.get("active_quests", {})
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
		"quests_claimed":
			for qid in condition.get("required_quests", []):
				if not claimed_quests.has(str(qid)):
					return false
			return true
		"quest_active":
			var req_q := str(condition.get("quest_id", ""))
			return active_quests.has(req_q)
		"quest_ready_to_claim":
			var qid := str(condition.get("quest_id", ""))
			return completed_quests.has(qid) and not claimed_quests.has(qid)
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
		"min_level":
			return int(state.get("level", 1)) >= int(condition.get("level", 1))
		"world_completed":
			var req_world := str(condition.get("required_world_id", ""))
			return bool(flags.get("world_completed_" + req_world, false))
		_:
			return false
