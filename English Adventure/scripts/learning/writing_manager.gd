class_name WritingManager
extends RefCounted
## Manages Writing activities: fill missing letter, assemble letters into word,
## fill word in sentence, arrange words into sentence, and guided sentence writing
## with support for multiple valid equivalent answers (acceptable_answers).

var _repo: LearningContentRepository


func _init(repo: LearningContentRepository) -> void:
	_repo = repo


func get_all_items() -> Array[Dictionary]:
	return _repo.writing_ordered


func get_item(item_id: String) -> Dictionary:
	return _repo.writing_by_id.get(item_id, {})


func _normalize_writing_text(txt: String) -> String:
	var out := txt.strip_edges().to_lower()
	while out.contains("  "):
		out = out.replace("  ", " ")
	out = out.rstrip(".!?")
	return out.strip_edges()


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
		var norm_sub := _normalize_writing_text(clean)
		var norm_cor := _normalize_writing_text(correct)
		if not norm_sub.is_empty() and norm_sub == norm_cor:
			is_correct = true
		else:
			var accepted: Array = item.get("acceptable_answers", [])
			for acc_var in accepted:
				var norm_acc := _normalize_writing_text(str(acc_var))
				if not norm_acc.is_empty() and norm_sub == norm_acc:
					is_correct = true
					break

	var display_correct := str(item.get("target_text", correct))
	return {
		"is_correct": is_correct,
		"correct_answer": display_correct,
		"explanation_vi": str(item.get("explanation_vi", "")),
		"word_id": str(item.get("word_id", ""))
	}
