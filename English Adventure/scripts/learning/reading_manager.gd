class_name ReadingManager
extends RefCounted
## Manages Reading activities: word->meaning, word->image, match word-image,
## short sentences, fill-in-the-blank, sentence word ordering, and short passages.

var _repo: LearningContentRepository


func _init(repo: LearningContentRepository) -> void:
	_repo = repo


func get_all_items() -> Array[Dictionary]:
	return _repo.reading_ordered


func get_item(item_id: String) -> Dictionary:
	return _repo.reading_by_id.get(item_id, {})


func evaluate_answer(item: Dictionary, selected_answer: String) -> Dictionary:
	var atype := str(item.get("activity_type", ""))
	var correct := ""
	var is_correct := false

	if atype == "arrange_words_sentence":
		var tokens: Array = item.get("tokens", [])
		var expected_parts: PackedStringArray = []
		for t in tokens:
			expected_parts.append(str(t))
		correct = " ".join(expected_parts)
		is_correct = selected_answer.strip_edges().to_lower() == correct.to_lower()
	else:
		for opt_var in item.get("options", []):
			if typeof(opt_var) == TYPE_DICTIONARY:
				var opt: Dictionary = opt_var
				if bool(opt.get("is_correct", false)):
					correct = str(opt.get("label_en", opt.get("label_vi", opt.get("id", ""))))
					if str(opt.get("id", "")) == selected_answer or correct == selected_answer:
						is_correct = true

	return {
		"is_correct": is_correct,
		"correct_answer": correct,
		"explanation_vi": str(item.get("explanation_vi", "")),
		"word_id": str(item.get("word_id", ""))
	}
