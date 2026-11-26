class_name QuestionManager
extends RefCounted
## Normalizes activities from Listening, Reading, Writing, Speaking, or dynamically
## reused Vocabulary records into a uniform QuestionPayload for any Lesson or Mini-game.

var _repo: LearningContentRepository
var _vocab: VocabularyManager


func _init(repo: LearningContentRepository, vocab: VocabularyManager) -> void:
	_repo = repo
	_vocab = vocab


func build_question_for_activity(activity: Dictionary) -> Dictionary:
	var skill := str(activity.get("skill", "reading"))
	var source_type := str(activity.get("source_type", skill))
	var source_id := str(activity.get("source_id", ""))
	var act_id := str(activity.get("id", source_id))

	var item: Dictionary = {}
	match source_type:
		"listening":
			item = _repo.listening_by_id.get(source_id, {})
		"reading":
			item = _repo.reading_by_id.get(source_id, {})
		"writing":
			item = _repo.writing_by_id.get(source_id, {})
		"speaking":
			item = _repo.speaking_by_id.get(source_id, {})

	if item.is_empty():
		return {}

	var payload := item.duplicate(true)
	payload["activity_id"] = act_id
	payload["question_id"] = "q_" + source_id
	payload["skill"] = skill
	payload["source_type"] = source_type

	var wid := str(item.get("word_id", ""))
	if not wid.is_empty():
		var w := _vocab.get_word(wid)
		if not w.is_empty():
			payload["word_data"] = w
			if not payload.has("image_path") or str(payload.get("image_path", "")).is_empty():
				payload["image_path"] = str(w.get("image_path", ""))
			if not payload.has("ipa") or str(payload.get("ipa", "")).is_empty():
				payload["ipa"] = _vocab.get_ipa_for_accent(w)

	return payload


func build_reusable_vocab_question(word_id: String, skill: String) -> Dictionary:
	var w := _vocab.get_word(word_id)
	if w.is_empty():
		return {}
	var word_en := str(w.get("word", ""))
	var meaning_vi := str(w.get("meaning_vi", ""))
	var distractors := _vocab.get_distractor_words(word_id, 2)

	if skill == "listening":
		var opts: Array[Dictionary] = [
			{ "id": "opt_0", "label_en": word_en, "word_id": word_id, "is_correct": true }
		]
		var idx := 1
		for d in distractors:
			opts.append({ "id": "opt_%d" % idx, "label_en": str(d.get("word", "")), "word_id": str(d.get("id", "")), "is_correct": false })
			idx += 1
		opts.shuffle()
		return {
			"activity_id": "dyn_list_" + word_id,
			"question_id": "q_dyn_list_" + word_id,
			"skill": "listening",
			"activity_type": "listen_word_choose_image",
			"prompt_vi": "Nghe từ '%s' và chọn hình đúng:" % word_en,
			"transcript_en": word_en,
			"ipa": _vocab.get_ipa_for_accent(w),
			"word_id": word_id,
			"word_data": w,
			"options": opts,
			"explanation_vi": "'%s' (%s) nghĩa là '%s'." % [word_en, _vocab.get_ipa_for_accent(w), meaning_vi],
			"audio_status": str(w.get("audio_status", "missing_asset")),
			"audio_path": _vocab.get_audio_path_for_accent(w)
		}

	if skill == "writing":
		var upper := word_en.to_upper()
		var missing_idx := mini(1, upper.length() - 1)
		var missing_ch := upper.substr(missing_idx, 1)
		var pattern_chars: PackedStringArray = []
		for i in range(upper.length()):
			pattern_chars.append("_" if i == missing_idx else upper.substr(i, 1))
		var choices: Array[String] = [missing_ch]
		for extra in ["A", "E", "O", "L", "T", "S"]:
			if choices.size() >= 4:
				break
			if not choices.has(extra):
				choices.append(extra)
		choices.shuffle()
		return {
			"activity_id": "dyn_write_" + word_id,
			"question_id": "q_dyn_write_" + word_id,
			"skill": "writing",
			"activity_type": "fill_missing_letter",
			"prompt_vi": "Điền chữ cái còn thiếu cho '%s':" % meaning_vi,
			"pattern": " ".join(pattern_chars),
			"target_text": upper,
			"missing_letter": missing_ch,
			"word_id": word_id,
			"word_data": w,
			"image_path": str(w.get("image_path", "")),
			"letter_choices": choices,
			"explanation_vi": "'%s' viết là %s (%s)." % [meaning_vi, upper, _vocab.get_ipa_for_accent(w)]
		}

	# Default: reading word -> meaning
	var r_opts: Array[Dictionary] = [
		{ "id": "opt_0", "label_vi": meaning_vi, "is_correct": true }
	]
	var r_idx := 1
	for d in distractors:
		r_opts.append({ "id": "opt_%d" % r_idx, "label_vi": str(d.get("meaning_vi", "")), "is_correct": false })
		r_idx += 1
	r_opts.shuffle()
	return {
		"activity_id": "dyn_read_" + word_id,
		"question_id": "q_dyn_read_" + word_id,
		"skill": "reading",
		"activity_type": "read_word_choose_meaning",
		"prompt_vi": "Đọc từ sau và chọn nghĩa tiếng Việt đúng:",
		"text_en": word_en,
		"ipa": _vocab.get_ipa_for_accent(w),
		"word_id": word_id,
		"word_data": w,
		"image_path": str(w.get("image_path", "")),
		"options": r_opts,
		"explanation_vi": "'%s' nghĩa là '%s'. Ví dụ: %s" % [word_en, meaning_vi, str(w.get("example_sentence", ""))]
	}
