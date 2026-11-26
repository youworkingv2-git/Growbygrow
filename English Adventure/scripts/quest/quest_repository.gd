class_name QuestRepository
extends RefCounted
## Data access facade over DataRepository for Quests and Chapters.


func get_all_quests() -> Array[Dictionary]:
	return DataRepository.quests_ordered


func get_quest(quest_id: String) -> Dictionary:
	return DataRepository.quests_by_id.get(quest_id, {})


func get_all_chapters() -> Array[Dictionary]:
	return DataRepository.chapters_ordered


func get_chapter(chapter_id: String) -> Dictionary:
	return DataRepository.chapters_by_id.get(chapter_id, {})
