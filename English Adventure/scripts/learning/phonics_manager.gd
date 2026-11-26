class_name PhonicsManager
extends RefCounted
## Manages Alphabet (26 letters), Letter Names vs Letter Sounds,
## Short/Long Vowels, Consonants, Digraphs, Vowel Teams, Patterns, and Word Blending.

var _repo: LearningContentRepository


func _init(repo: LearningContentRepository) -> void:
	_repo = repo


func get_all_letters() -> Array[Dictionary]:
	return _repo.alphabet_ordered


func get_letter_by_symbol(symbol: String) -> Dictionary:
	var target := symbol.strip_edges().to_lower()
	for l in _repo.alphabet_ordered:
		if str(l.get("letter_lower", "")) == target:
			return l
	return {}


func get_letter_name_ipa(letter_dict: Dictionary, accent: String = "") -> String:
	var acc := accent if not accent.is_empty() else SettingsManager.preferred_accent
	var map_ipa: Dictionary = letter_dict.get("letter_name_ipa", {})
	return str(map_ipa.get(acc, map_ipa.get("en-US", "")))


func get_phonics_categories() -> Array[String]:
	return _repo.phonics_categories


func get_phonics_units(category_filter: String = "") -> Array[Dictionary]:
	if category_filter.is_empty():
		return _repo.phonics_units_ordered
	var out: Array[Dictionary] = []
	for u in _repo.phonics_units_ordered:
		if str(u.get("category", "")) == category_filter:
			out.append(u)
	return out


func get_phonics_unit(unit_id: String) -> Dictionary:
	return _repo.phonics_by_id.get(unit_id, {})
