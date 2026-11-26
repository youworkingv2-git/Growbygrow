class_name VocabularyManager
extends RefCounted
## Single source of truth for Vocabulary records, reusable across Listening,
## Speaking, Reading, Writing, Review, and future Prompt 05 mini-games.

var _repo: LearningContentRepository
var _progress: LearningProgressManager


func _init(repo: LearningContentRepository, progress: LearningProgressManager) -> void:
	_repo = repo
	_progress = progress


func get_all_words() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for w in _repo.vocab_ordered:
		out.append(enrich_with_status(w))
	return out


func get_word(word_id: String) -> Dictionary:
	var w: Dictionary = _repo.vocab_by_id.get(word_id, {})
	if w.is_empty():
		return {}
	return enrich_with_status(w)


func get_words_by_topic(topic: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for w in _repo.vocab_ordered:
		if str(w.get("topic", "")) == topic:
			out.append(enrich_with_status(w))
	return out


func get_topics() -> Array[String]:
	var seen: Dictionary = {}
	var out: Array[String] = []
	for w in _repo.vocab_ordered:
		var t := str(w.get("topic", ""))
		if not t.is_empty() and not seen.has(t):
			seen[t] = true
			out.append(t)
	return out


func get_words_for_difficulty(max_difficulty: int, topic_filter: String = "") -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for w in _repo.vocab_ordered:
		if int(w.get("difficulty", 1)) <= max_difficulty:
			if topic_filter.is_empty() or str(w.get("topic", "")) == topic_filter:
				out.append(enrich_with_status(w))
	return out


func get_related_words(word_id: String) -> Array[Dictionary]:
	var w: Dictionary = _repo.vocab_by_id.get(word_id, {})
	var out: Array[Dictionary] = []
	for rel_var in w.get("related_words", []):
		var rel := get_word(str(rel_var))
		if not rel.is_empty():
			out.append(rel)
	return out


func get_distractor_words(target_word_id: String, count: int = 2) -> Array[Dictionary]:
	var target: Dictionary = _repo.vocab_by_id.get(target_word_id, {})
	var target_topic := str(target.get("topic", ""))
	var same_topic: Array[Dictionary] = []
	var other_topic: Array[Dictionary] = []
	for w in _repo.vocab_ordered:
		var wid := str(w.get("id", ""))
		if wid == target_word_id:
			continue
		if str(w.get("topic", "")) == target_topic:
			same_topic.append(w)
		else:
			other_topic.append(w)

	var combined: Array[Dictionary] = []
	combined.append_array(same_topic)
	combined.append_array(other_topic)
	var out: Array[Dictionary] = []
	for i in range(mini(count, combined.size())):
		out.append(combined[i])
	return out


func get_ipa_for_accent(word_dict: Dictionary, accent: String = "") -> String:
	var acc := accent if not accent.is_empty() else SettingsManager.preferred_accent
	if acc == "en-GB":
		return str(word_dict.get("ipa_uk", word_dict.get("ipa_us", "")))
	return str(word_dict.get("ipa_us", ""))


func get_audio_path_for_accent(word_dict: Dictionary, accent: String = "") -> String:
	var acc := accent if not accent.is_empty() else SettingsManager.preferred_accent
	if acc == "en-GB":
		var uk := str(word_dict.get("audio_uk_path", ""))
		if not uk.is_empty():
			return uk
	return str(word_dict.get("audio_us_path", ""))


func enrich_with_status(word_dict: Dictionary) -> Dictionary:
	var copy := word_dict.duplicate(true)
	var wid := str(copy.get("id", ""))
	copy["learning_status"] = _progress.get_item_status(wid)
	copy["mastery_score"] = _progress.get_item_mastery(wid)
	return copy
