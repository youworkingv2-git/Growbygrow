class_name QuestProgressTracker
extends RefCounted
## Tracks and queries per-quest & per-objective numeric progress (e.g. 3/5 words).


static func get_objective_progress(quest_id: String, objective_id: String, quest_def: Dictionary) -> Dictionary:
	if GameStateManager.completed_quests.has(quest_id) or GameStateManager.claimed_quests.has(quest_id):
		var target_done := 1
		for st in quest_def.get("steps", []):
			if typeof(st) == TYPE_DICTIONARY and str((st as Dictionary).get("id", "")) == objective_id:
				target_done = maxi(1, int((st as Dictionary).get("required_count", 1)))
				break
		return { "current": target_done, "target": target_done, "completed": true }

	var q_state: Dictionary = GameStateManager.active_quests.get(quest_id, {})
	var obj_map: Dictionary = q_state.get("objectives", {})
	if obj_map.has(objective_id):
		var entry: Dictionary = obj_map[objective_id]
		return {
			"current": int(entry.get("current", 0)),
			"target": maxi(1, int(entry.get("target", 1))),
			"completed": bool(entry.get("completed", false))
		}

	for st in quest_def.get("steps", []):
		if typeof(st) == TYPE_DICTIONARY and str((st as Dictionary).get("id", "")) == objective_id:
			return {
				"current": 0,
				"target": maxi(1, int((st as Dictionary).get("required_count", 1))),
				"completed": false
			}
	return { "current": 0, "target": 1, "completed": false }
