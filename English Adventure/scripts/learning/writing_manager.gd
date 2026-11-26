class_name WritingManager
extends RefCounted
## Manages Writing activities: fill missing letter, assemble letters into word,
## fill word in sentence, arrange words into sentence, and simple sentence writing.

var _repo: LearningContentRepository


func _init(repo: LearningContentRepository) -> void:
	_repo = repo


func get_all_items() -> Array[Dictionary]:
	return _repo.writing_ordered


func get_item(item_id: String) -> Dictionary:
	return _repo.writing_by_id.get(item_id, {})


func evaluate_answer(item: Dictionary, submitted_answer: String) -> Dictionary:
	var atype := str(item.get("activity_type", ""))
	var clean := submitted_answer.strip_edges()
	var correct := ""
	var is_correct := false

	if atype == "fill_missing_letter":
		correct = str(item.get("missing_letter", ""))
		is_correct = clean.to_upper() == correct.to_upper()
	elif atype == "fill_word_in_sentence":
		correct = str(item.get("target_word", ""))
		is_correct = clean.to_lower() == correct.to_lower()
	else:
		correct = str(item.get("target_text", ""))
		var norm_sub := clean.to_lower().rstrip(".!?")
		var norm_cor := correct.to_lower().rstrip(".!?")
		is_correct = norm_sub == norm_cor

	var display_correct := str(item.get("target_text", correct))
	return {
		"is_correct": is_correct,
		"correct_answer": display_correct,
		"explanation_vi": str(item.get("explanation_vi", "")),
		"word_id": str(item.get("word_id", ""))
	}
