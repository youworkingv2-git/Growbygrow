class_name QuestRegistry
extends RefCounted
## Indexes Main Quests, Side Quests, Chapters, NPC givers, Area associations, and Mini-game hooks.

var _repo: QuestRepository


func _init(repo: QuestRepository) -> void:
	_repo = repo


func get_quests_by_type(quest_type: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for q in _repo.get_all_quests():
		if str(q.get("quest_type", "main")) == quest_type:
			out.append(q)
	return out


func get_quests_for_area(area_id: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for q in _repo.get_all_quests():
		if str(q.get("area_id", "")) == area_id:
			out.append(q)
	return out


func get_quests_for_npc(npc_id: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for q in _repo.get_all_quests():
		if str(q.get("giver_npc_id", "")) == npc_id or str(q.get("turn_in_npc_id", "")) == npc_id:
			out.append(q)
	return out
