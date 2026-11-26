class_name LearningPathManager
extends RefCounted
## Manages curriculum hierarchy: LearningPath -> Level -> World -> Topic -> Lesson -> LearningActivity.

var _repo: LearningContentRepository


func _init(repo: LearningContentRepository) -> void:
	_repo = repo


func get_learning_path_info() -> Dictionary:
	return _repo.curriculum.get("learning_path", {})


func get_levels() -> Array[Dictionary]:
	return _repo.levels_ordered


func get_worlds_for_level(level_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for w_var in _repo.curriculum.get("worlds", []):
		if typeof(w_var) == TYPE_DICTIONARY:
			var w: Dictionary = w_var
			if str(w.get("level_id", "")) == level_id:
				result.append(w)
	return result


func get_topics_for_world(world_id: String) -> Array[Dictionary]:
	var w: Dictionary = _repo.worlds_by_id.get(world_id, {})
	var result: Array[Dictionary] = []
	for t_var in w.get("topics", []):
		if typeof(t_var) == TYPE_DICTIONARY:
			result.append(t_var)
	return result


func get_lessons_for_topic(topic_id: String) -> Array[Dictionary]:
	var t: Dictionary = _repo.topics_by_id.get(topic_id, {})
	var result: Array[Dictionary] = []
	for ls_var in t.get("lessons", []):
		if typeof(ls_var) == TYPE_DICTIONARY:
			result.append(ls_var)
	return result


func get_all_lessons() -> Array[Dictionary]:
	return _repo.lessons_ordered


func get_lesson(lesson_id: String) -> Dictionary:
	return _repo.lessons_by_id.get(lesson_id, {})


func get_lesson_for_quest(quest_id: String) -> Dictionary:
	for ls in _repo.lessons_ordered:
		if str(ls.get("quest_id", "")) == quest_id:
			return ls
	return {}


func get_activities_for_lesson(lesson_id: String) -> Array[Dictionary]:
	var ls := get_lesson(lesson_id)
	var result: Array[Dictionary] = []
	for act_var in ls.get("activities", []):
		if typeof(act_var) == TYPE_DICTIONARY:
			result.append(act_var)
	return result
