class_name QuestStateManager
extends RefCounted
## Manages Quest lifecycle states: locked, available, accepted, in_progress, completed, claimed.
## Never transitions a quest to Failed for wrong learning answers.

var _repo: QuestRepository


func _init(repo: QuestRepository) -> void:
	_repo = repo


func get_status(quest_id: String) -> String:
	if GameStateManager.claimed_quests.has(quest_id):
		return "claimed"
	if GameStateManager.completed_quests.has(quest_id):
		return "completed"
	if GameStateManager.active_quests.has(quest_id):
		var prog: Dictionary = GameStateManager.active_quests.get(quest_id, {})
		if int(prog.get("step_index", 0)) > 0 or bool(prog.get("has_progress", false)):
			return "in_progress"
		return "accepted"
	var q := _repo.get_quest(quest_id)
	if q.is_empty():
		return "locked"
	if QuestConditionEvaluator.can_start_quest(q, GameStateManager.to_state_dict()):
		return "available"
	return "locked"


## Legacy-compatible 4-state mapping used by QuestCardWidget / existing UI checks.
func get_legacy_status(quest_id: String) -> String:
	var st := get_status(quest_id)
	match st:
		"claimed", "completed":
			return "completed"
		"accepted", "in_progress":
			return "active"
		"available":
			return "available"
		_:
			return "locked"
