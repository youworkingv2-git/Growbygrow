class_name GrammarManager
extends RefCounted
## Manages starter Grammar structures, Vietnamese explanations, common mistakes,
## and dynamic substitution-slot sentence generation.

var _repo: LearningContentRepository


func _init(repo: LearningContentRepository) -> void:
	_repo = repo


func get_all_structures() -> Array[Dictionary]:
	return _repo.grammar_ordered


func get_structure(grammar_id: String) -> Dictionary:
	return _repo.grammar_by_id.get(grammar_id, {})


func get_model_sentences() -> Array[Dictionary]:
	return _repo.model_sentences


func generate_substitution_sentences(grammar_id: String) -> Array[String]:
	var g := get_structure(grammar_id)
	if g.is_empty():
		return []
	var pattern := str(g.get("structure", ""))
	var slots: Array = g.get("substitution_slots", [])
	if slots.is_empty() or typeof(slots[0]) != TYPE_DICTIONARY:
		return []
	var first_slot: Dictionary = slots[0]
	var options: Array = first_slot.get("options", [])
	var sentences: Array[String] = []
	for opt_var in options:
		var opt := str(opt_var)
		if pattern.contains("..."):
			sentences.append(pattern.replace("...", opt))
		else:
			sentences.append("%s %s" % [pattern, opt])
	return sentences
