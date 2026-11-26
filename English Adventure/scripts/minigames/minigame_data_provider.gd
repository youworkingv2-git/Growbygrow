class_name MiniGameDataProvider
extends RefCounted
## Single Learning-Engine-powered content generator for all 8 mini-games.
## Pulls directly from LearningEngine.content_repo + VocabularyManager + PhonicsManager
## + GrammarManager + SpeakingManager + dialogue_adventures.json.
## Zero duplicate vocabulary records are ever hardcoded inside mini-games.

const DIALOGUES_PATH := "res://data/minigames/dialogue_adventures.json"

static var _dialogue_cache: Array[Dictionary] = []


static func build_items_for(minigame_id: String, diff_cfg: Dictionary, context: Dictionary = {}) -> Array[Dictionary]:
	match minigame_id:
		"listen_and_find":
			return _build_listen_and_find(diff_cfg, context)
		"word_builder":
			return _build_word_builder(diff_cfg, context)
		"word_matching":
			return _build_word_matching(diff_cfg, context)
		"sentence_builder":
			return _build_sentence_builder(diff_cfg, context)
		"sound_detective":
			return _build_sound_detective(diff_cfg, context)
		"speaking_hero":
			return _build_speaking_hero(diff_cfg, context)
		"memory_quest":
			return _build_memory_quest(diff_cfg, context)
		"dialogue_adventure":
			return _build_dialogue_adventure(diff_cfg, context)
	return []


static func _get_vocab_pool(topic_filter: String, max_diff: int) -> Array[Dictionary]:
	var vm := LearningEngine.vocabulary_manager
	var pool := vm.get_words_for_difficulty(max_diff, topic_filter)
	if pool.size() < 4 and not topic_filter.is_empty():
		pool = vm.get_words_for_difficulty(max_diff, "")
	if pool.is_empty():
		pool = vm.get_all_words()
	return _prioritize_learning_words(pool)


static func _prioritize_learning_words(pool: Array[Dictionary]) -> Array[Dictionary]:
	# Prioritize due review / learning / new words before already mastered words
	var prioritized: Array[Dictionary] = []
	for item in pool:
		prioritized.append(item.duplicate(true))
	prioritized.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ma := float(a.get("mastery_score", 0.0))
		var mb := float(b.get("mastery_score", 0.0))
		return ma < mb
	)
	return prioritized


static func _max_diff_for_tier(tier: String) -> int:
	if tier == "easy":
		return 1
	if tier == "medium":
		return 2
	return 3


static func _build_listen_and_find(diff_cfg: Dictionary, context: Dictionary) -> Array[Dictionary]:
	var tier := str(diff_cfg.get("tier", "easy"))
	var round_count := int(diff_cfg.get("round_count", 4))
	var choice_count := int(diff_cfg.get("choice_count", 2))
	var topic := str(context.get("topic", ""))
	var pool := _get_vocab_pool(topic, _max_diff_for_tier(tier))
	var vm := LearningEngine.vocabulary_manager
	if str(context.get("quest_id", "")) == "quest_01_new_adventure":
		round_count = maxi(round_count, 5)
		var q1_words: Array[Dictionary] = []
		var q1_ids: Array[String] = ["word_apple", "word_cat", "word_dog", "word_book", "word_ball"]
		for qwid in q1_ids:
			var w := vm.get_word(qwid)
			if not w.is_empty():
				q1_words.append(w)
		for w_rest in pool:
			if not q1_ids.has(str(w_rest.get("id", ""))):
				q1_words.append(w_rest)
		if not q1_words.is_empty():
			pool = q1_words

	var out: Array[Dictionary] = []
	for i in range(mini(round_count, pool.size())):
		var target := pool[i]
		var wid := str(target.get("id", ""))
		var word_en := str(target.get("word", ""))
		var meaning_vi := str(target.get("meaning_vi", ""))
		var ipa := vm.get_ipa_for_accent(target)
		var audio_path := vm.get_audio_path_for_accent(target)

		# On Easy, avoid visually/phonetically near-identical distractors by picking from varied topics when possible
		var distractors := _pick_distinct_distractors(pool, wid, choice_count - 1, tier == "easy")
		var choices: Array[Dictionary] = []
		choices.append({
			"id": wid,
			"word": word_en,
			"meaning_vi": meaning_vi,
			"image_path": str(target.get("image_path", "")),
			"ipa": ipa,
			"is_correct": true
		})
		for d in distractors:
			choices.append({
				"id": str(d.get("id", "")),
				"word": str(d.get("word", "")),
				"meaning_vi": str(d.get("meaning_vi", "")),
				"image_path": str(d.get("image_path", "")),
				"ipa": vm.get_ipa_for_accent(d),
				"is_correct": false
			})
		choices.shuffle()

		out.append({
			"question_id": "laf_%s" % wid,
			"knowledge_id": wid,
			"skill": "listening",
			"target_word": word_en,
			"meaning_vi": meaning_vi,
			"ipa": ipa,
			"audio_path": audio_path,
			"example_sentence": str(target.get("example_sentence", "")),
			"prompt_vi": "Nghe từ tiếng Anh rồi chọn đúng hình ảnh nhé!",
			"choices": choices
		})
	return out


static func _pick_distinct_distractors(pool: Array[Dictionary], target_id: String, needed: int, prefer_different_topic: bool) -> Array[Dictionary]:
	var target_topic := ""
	for w in pool:
		if str(w.get("id", "")) == target_id:
			target_topic = str(w.get("topic", ""))
			break
	var first_pass: Array[Dictionary] = []
	var second_pass: Array[Dictionary] = []
	for w in pool:
		var wid := str(w.get("id", ""))
		if wid == target_id:
			continue
		var same_t := str(w.get("topic", "")) == target_topic
		if (prefer_different_topic and not same_t) or (not prefer_different_topic and same_t):
			first_pass.append(w)
		else:
			second_pass.append(w)
	first_pass.shuffle()
	second_pass.shuffle()
	var combined: Array[Dictionary] = []
	combined.append_array(first_pass)
	combined.append_array(second_pass)
	var out: Array[Dictionary] = []
	for i in range(mini(needed, combined.size())):
		out.append(combined[i])
	return out


static func _build_word_builder(diff_cfg: Dictionary, context: Dictionary) -> Array[Dictionary]:
	var tier := str(diff_cfg.get("tier", "easy"))
	var round_count := int(diff_cfg.get("round_count", 4))
	var max_len := int(diff_cfg.get("word_max_length", 4))
	var topic := str(context.get("topic", ""))
	var pool := _get_vocab_pool(topic, _max_diff_for_tier(tier))
	var vm := LearningEngine.vocabulary_manager

	var filtered: Array[Dictionary] = []
	for w in pool:
		var clean_w := str(w.get("word", "")).strip_edges().replace(" ", "")
		if clean_w.length() >= 2 and clean_w.length() <= max_len:
			filtered.append(w)
	if filtered.size() < round_count:
		filtered = pool

	var out: Array[Dictionary] = []
	for i in range(mini(round_count, filtered.size())):
		var target := filtered[i]
		var wid := str(target.get("id", ""))
		var word_upper := str(target.get("word", "")).strip_edges().to_upper()
		var letters: Array[String] = []
		for ch_i in range(word_upper.length()):
			letters.append(word_upper.substr(ch_i, 1))
		var scrambled: Array[String] = []
		scrambled.assign(letters)
		scrambled.shuffle()
		# Ensure scrambled differs from target when length >= 2 and letters aren't all identical
		if scrambled.size() >= 2 and "".join(scrambled) == word_upper:
			scrambled.reverse()

		out.append({
			"question_id": "wb_%s" % wid,
			"knowledge_id": wid,
			"skill": "writing",
			"target_word": word_upper,
			"display_word": str(target.get("word", "")),
			"meaning_vi": str(target.get("meaning_vi", "")),
			"image_path": str(target.get("image_path", "")),
			"ipa": vm.get_ipa_for_accent(target),
			"audio_path": vm.get_audio_path_for_accent(target),
			"example_sentence": str(target.get("example_sentence", "")),
			"letters_scrambled": scrambled
		})
	return out


static func _build_word_matching(diff_cfg: Dictionary, context: Dictionary) -> Array[Dictionary]:
	var tier := str(diff_cfg.get("tier", "easy"))
	var pair_count := int(diff_cfg.get("pair_count", 3))
	var topic := str(context.get("topic", ""))
	var pool := _get_vocab_pool(topic, _max_diff_for_tier(tier))
	var vm := LearningEngine.vocabulary_manager
	var mode := str(context.get("mode", "word_image")) # "word_image" or "word_vi"

	var pairs: Array[Dictionary] = []
	for i in range(mini(pair_count, pool.size())):
		var w := pool[i]
		pairs.append({
			"word_id": str(w.get("id", "")),
			"word": str(w.get("word", "")),
			"meaning_vi": str(w.get("meaning_vi", "")),
			"image_path": str(w.get("image_path", "")),
			"ipa": vm.get_ipa_for_accent(w),
			"audio_path": vm.get_audio_path_for_accent(w),
			"example_sentence": str(w.get("example_sentence", ""))
		})

	return [{
		"question_id": "wm_board_1",
		"knowledge_id": str(pairs[0].get("word_id", "")) if not pairs.is_empty() else "",
		"skill": "reading",
		"mode": mode,
		"pairs": pairs
	}]


static func _build_sentence_builder(diff_cfg: Dictionary, _context: Dictionary) -> Array[Dictionary]:
	var tier := str(diff_cfg.get("tier", "easy"))
	var round_count := int(diff_cfg.get("round_count", 4))
	var max_diff := _max_diff_for_tier(tier)

	var candidates: Array[Dictionary] = []
	# Pull from GrammarManager structures + example sentences
	for g in LearningEngine.grammar_manager.get_all_structures():
		if int(g.get("difficulty", 1)) > max_diff:
			continue
		var expl := str(g.get("explanation_vi", ""))
		for ex_var in g.get("example_sentences", []):
			if typeof(ex_var) == TYPE_DICTIONARY:
				var ex: Dictionary = ex_var
				var en := str(ex.get("en", "")).strip_edges()
				var vi := str(ex.get("vi", "")).strip_edges()
				if en.split(" ", false).size() >= 3:
					candidates.append({
						"grammar_id": str(g.get("id", "")),
						"sentence_en": en,
						"meaning_vi": vi,
						"explanation_vi": expl,
						"audio_path": str(ex.get("audio_path", "")),
						"accepted_variants": _build_sentence_variants(en)
					})
	# Also pull arrange_words items from Writing repository
	for w_item in LearningEngine.content_repo.writing_ordered:
		if str(w_item.get("activity_type", "")) == "arrange_words":
			var target := str(w_item.get("target_text", "")).strip_edges()
			if not target.is_empty():
				candidates.append({
					"grammar_id": str(w_item.get("word_id", "")),
					"sentence_en": target,
					"meaning_vi": str(w_item.get("prompt_vi", "")),
					"explanation_vi": str(w_item.get("explanation_vi", "")),
					"audio_path": "",
					"accepted_variants": _build_sentence_variants(target)
				})

	candidates.shuffle()
	var out: Array[Dictionary] = []
	for i in range(mini(round_count, candidates.size())):
		var c := candidates[i]
		var full_en := str(c.get("sentence_en", ""))
		var tokens := _tokenize_sentence(full_en)
		var scrambled: Array[String] = []
		scrambled.assign(tokens)
		scrambled.shuffle()
		if scrambled.size() >= 2 and " ".join(scrambled) == " ".join(tokens):
			scrambled.reverse()
		out.append({
			"question_id": "sb_%d_%s" % [i + 1, str(c.get("grammar_id", "g"))],
			"knowledge_id": str(c.get("grammar_id", "")),
			"skill": "writing",
			"target_sentence": full_en,
			"tokens_correct": tokens,
			"tokens_scrambled": scrambled,
			"accepted_variants": c.get("accepted_variants", []),
			"meaning_vi": str(c.get("meaning_vi", "")),
			"explanation_vi": str(c.get("explanation_vi", "")),
			"audio_path": str(c.get("audio_path", ""))
		})
	return out


static func _tokenize_sentence(sentence: String) -> Array[String]:
	var raw_parts := sentence.strip_edges().split(" ", false)
	var out: Array[String] = []
	for p in raw_parts:
		var clean := p.strip_edges()
		if not clean.is_empty():
			out.append(clean)
	return out


static func _build_sentence_variants(sentence: String) -> Array[String]:
	var base := _normalize_sentence(sentence)
	var variants: Array[String] = [base]
	# Accept I'm <-> I am, It's <-> It is, That's <-> That is, etc.
	if base.contains("i am "):
		variants.append(base.replace("i am ", "i'm "))
	if base.contains("i'm "):
		variants.append(base.replace("i'm ", "i am "))
	if base.contains("this is "):
		variants.append(base.replace("this is ", "that is "))
	return variants


static func _normalize_sentence(s: String) -> String:
	var out := s.strip_edges().to_lower()
	for p in [".", "!", "?"]:
		out = out.replace(p, "")
	while out.contains("  "):
		out = out.replace("  ", " ")
	return out.strip_edges()


static func _build_sound_detective(diff_cfg: Dictionary, _context: Dictionary) -> Array[Dictionary]:
	var tier := str(diff_cfg.get("tier", "easy"))
	var round_count := int(diff_cfg.get("round_count", 4))
	var choice_count := int(diff_cfg.get("choice_count", 3))
	var pm := LearningEngine.phonics_manager
	var letters := pm.get_all_letters()
	var out: Array[Dictionary] = []

	# Part 1: Letter Sound vs Letter Name challenges (Pre-A1 safe)
	var shuffled_letters: Array[Dictionary] = []
	for l_item in letters:
		shuffled_letters.append(l_item.duplicate(true))
	shuffled_letters.shuffle()
	var letter_rounds := mini(round_count if tier == "easy" else 2, shuffled_letters.size())
	for i in range(letter_rounds):
		var target: Dictionary = shuffled_letters[i]
		var target_upper := str(target.get("letter_upper", "A"))
		var sound_ipa := str(target.get("letter_sound_ipa", ""))
		var name_ipa := pm.get_letter_name_ipa(target)
		var ask_sound := (i % 2 == 0)
		var target_lower := target_upper.to_lower()
		var anchor_ids: Array = target.get("anchor_word_ids", [])
		var anchor_word := ""
		for aid in anchor_ids:
			var w := LearningEngine.vocabulary_manager.get_word(str(aid))
			var candidate := str(w.get("word", "")).to_lower()
			if not candidate.is_empty() and (candidate.begins_with(target_lower) or (target_lower == "x" and candidate.contains("x"))):
				anchor_word = candidate
				break
		if anchor_word.is_empty():
			var fallback_examples := {
				"j": "jam", "q": "queen", "v": "van", "x": "box", "z": "zoo"
			}
			anchor_word = str(fallback_examples.get(target_lower, ""))
			if anchor_word.is_empty() and not anchor_ids.is_empty():
				var w0 := LearningEngine.vocabulary_manager.get_word(str(anchor_ids[0]))
				anchor_word = str(w0.get("word", target_lower))

		var choices: Array[Dictionary] = [{
			"id": str(target.get("id", "")),
			"label": target_upper,
			"sub_label": sound_ipa if ask_sound else name_ipa,
			"is_correct": true
		}]
		for other in shuffled_letters:
			if choices.size() >= choice_count:
				break
			var o_upper := str(other.get("letter_upper", ""))
			if o_upper == target_upper:
				continue
			choices.append({
				"id": str(other.get("id", "")),
				"label": o_upper,
				"sub_label": "",
				"is_correct": false
			})
		choices.shuffle()

		var prompt := "Tìm chữ cái có ÂM CHỮ CÁI %s (như trong '%s')!" % [sound_ipa, anchor_word] if ask_sound else "Tìm chữ cái có TÊN CHỮ CÁI đọc là %s!" % name_ipa
		var speak_text := anchor_word if ask_sound else target_upper
		out.append({
			"question_id": "sd_%s_%s" % [str(target.get("id", "")), "sound" if ask_sound else "name"],
			"knowledge_id": str(target.get("id", "")),
			"skill": "listening",
			"mode": "letter_sound" if ask_sound else "letter_name",
			"target_label": target_upper,
			"target_ipa": sound_ipa if ask_sound else name_ipa,
			"speak_text": speak_text,
			"audio_path": "",
			"prompt_vi": prompt,
			"explanation_vi": "Chữ %s: Tên chữ là %s, còn âm cơ bản là %s (ví dụ: %s)." % [target_upper, name_ipa, sound_ipa, anchor_word],
			"choices": choices
		})

	# Part 2 (Medium/Hard): Confusable phonics word pairs from phonics_units / vocab
	if tier != "easy" and out.size() < round_count:
		var vocab := _get_vocab_pool("", 2)
		for v_i in range(mini(round_count - out.size(), vocab.size())):
			var w := vocab[v_i]
			var word_en := str(w.get("word", ""))
			var wid := str(w.get("id", ""))
			var dist := _pick_distinct_distractors(vocab, wid, choice_count - 1, false)
			var w_choices: Array[Dictionary] = [{
				"id": wid,
				"label": word_en.capitalize(),
				"sub_label": LearningEngine.vocabulary_manager.get_ipa_for_accent(w),
				"is_correct": true
			}]
			for d in dist:
				w_choices.append({
					"id": str(d.get("id", "")),
					"label": str(d.get("word", "")).capitalize(),
					"sub_label": "",
					"is_correct": false
				})
			w_choices.shuffle()
			out.append({
				"question_id": "sd_word_%s" % wid,
				"knowledge_id": wid,
				"skill": "listening",
				"mode": "word_phonics",
				"target_label": word_en.capitalize(),
				"target_ipa": LearningEngine.vocabulary_manager.get_ipa_for_accent(w),
				"speak_text": word_en,
				"audio_path": LearningEngine.vocabulary_manager.get_audio_path_for_accent(w),
				"prompt_vi": "Nghe thật kỹ và chọn đúng từ được phát âm!",
				"explanation_vi": "%s (%s) — nghĩa là %s." % [word_en.capitalize(), LearningEngine.vocabulary_manager.get_ipa_for_accent(w), str(w.get("meaning_vi", ""))],
				"choices": w_choices
			})
	return out


static func _build_speaking_hero(diff_cfg: Dictionary, _context: Dictionary) -> Array[Dictionary]:
	var round_count := int(diff_cfg.get("round_count", 4))
	var max_diff := _max_diff_for_tier(str(diff_cfg.get("tier", "easy")))
	var items := LearningEngine.speaking_manager.get_all_items()
	var out: Array[Dictionary] = []
	for item in items:
		if int(item.get("difficulty", 1)) > max_diff:
			continue
		var wid := str(item.get("word_id", ""))
		var word_rec := LearningEngine.vocabulary_manager.get_word(wid) if not wid.is_empty() else {}
		out.append({
			"question_id": str(item.get("id", "")),
			"knowledge_id": wid if not wid.is_empty() else str(item.get("id", "")),
			"skill": "speaking",
			"speaking_mode": str(item.get("speaking_mode", "repeat_word")),
			"prompt_vi": str(item.get("prompt_vi", "")),
			"target_text_en": str(item.get("target_text_en", "")),
			"ipa": str(item.get("ipa", "")),
			"mouth_hint_vi": str(item.get("mouth_hint_vi", "")),
			"meaning_vi": str(word_rec.get("meaning_vi", "")),
			"image_path": str(word_rec.get("image_path", "")),
			"audio_path": str(item.get("audio_path", ""))
		})
		if out.size() >= round_count:
			break
	return out


static func _build_memory_quest(diff_cfg: Dictionary, context: Dictionary) -> Array[Dictionary]:
	var tier := str(diff_cfg.get("tier", "easy"))
	var pair_count := int(diff_cfg.get("pair_count", 3))
	var topic := str(context.get("topic", ""))
	var pool := _get_vocab_pool(topic, _max_diff_for_tier(tier))
	var vm := LearningEngine.vocabulary_manager
	var mode := str(context.get("mode", "word_image")) # "word_image" | "word_vi" | "audio_image"
	if str(context.get("quest_id", "")) == "quest_04_crystal_guardian":
		pair_count = maxi(pair_count, 4)
		var all_ids: Array[String] = []
		for w_all in vm.get_all_words():
			all_ids.append(str(w_all.get("id", "")))
		var due := LearningEngine.review_engine.get_due_review_items(all_ids, pair_count)
		var rev_pool: Array[Dictionary] = []
		var seen_ids := {}
		for d in due:
			var wid := str(d.get("item_id", ""))
			var w_rec := vm.get_word(wid)
			if not w_rec.is_empty() and not seen_ids.has(wid):
				seen_ids[wid] = true
				rev_pool.append(w_rec)
		for w_rest in pool:
			var rwid := str(w_rest.get("id", ""))
			if not seen_ids.has(rwid):
				rev_pool.append(w_rest)
		if not rev_pool.is_empty():
			pool = rev_pool

	var pairs: Array[Dictionary] = []
	for i in range(mini(pair_count, pool.size())):
		var w := pool[i]
		pairs.append({
			"word_id": str(w.get("id", "")),
			"word": str(w.get("word", "")),
			"meaning_vi": str(w.get("meaning_vi", "")),
			"image_path": str(w.get("image_path", "")),
			"ipa": vm.get_ipa_for_accent(w),
			"audio_path": vm.get_audio_path_for_accent(w),
			"example_sentence": str(w.get("example_sentence", ""))
		})
	return [{
		"question_id": "mq_board_1",
		"knowledge_id": str(pairs[0].get("word_id", "")) if not pairs.is_empty() else "",
		"skill": "listening" if mode == "audio_image" else "reading",
		"mode": mode,
		"pairs": pairs
	}]


static func get_dialogue_scenarios() -> Array[Dictionary]:
	if not _dialogue_cache.is_empty():
		var cached_out: Array[Dictionary] = []
		for sc in _dialogue_cache:
			cached_out.append(sc.duplicate(true))
		return cached_out
	if not FileAccess.file_exists(DIALOGUES_PATH):
		return []
	var f := FileAccess.open(DIALOGUES_PATH, FileAccess.READ)
	if f == null:
		return []
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return []
	var doc: Dictionary = parsed
	for s_var in doc.get("scenarios", []):
		if typeof(s_var) == TYPE_DICTIONARY:
			_dialogue_cache.append(s_var as Dictionary)
	var out: Array[Dictionary] = []
	for sc in _dialogue_cache:
		out.append(sc.duplicate(true))
	return out


static func _build_dialogue_adventure(_diff_cfg: Dictionary, context: Dictionary) -> Array[Dictionary]:
	var scenarios := get_dialogue_scenarios()
	if scenarios.is_empty():
		return []
	var req_id := str(context.get("scenario_id", ""))
	var chosen: Dictionary = scenarios[0]
	if not req_id.is_empty():
		for sc in scenarios:
			if str(sc.get("id", "")) == req_id:
				chosen = sc
				break
	else:
		# Pick a rotating scenario based on plays so learners experience all 8 topics
		var plays := int(GameStateManager.get_minigame_record("dialogue_adventure").get("plays", 0))
		chosen = scenarios[plays % scenarios.size()]

	var out: Array[Dictionary] = []
	var turns: Array = chosen.get("turns", [])
	for t_i in range(turns.size()):
		if typeof(turns[t_i]) != TYPE_DICTIONARY:
			continue
		var turn: Dictionary = turns[t_i]
		var linked: Array = chosen.get("linked_vocab_ids", [])
		var first_vocab := str(linked[0]) if not linked.is_empty() else ""
		out.append({
			"question_id": "%s_%s" % [str(chosen.get("id", "dlg")), str(turn.get("id", turn.get("turn_id", t_i)))],
			"knowledge_id": first_vocab,
			"skill": "reading",
			"scenario_id": str(chosen.get("id", "")),
			"scenario_title_en": str(chosen.get("title_en", "")),
			"scenario_title_vi": str(chosen.get("title_vi", "")),
			"npc_name": str(chosen.get("npc_name_vi", chosen.get("npc_name", "Professor Owl"))),
			"npc_line_en": str(turn.get("npc_en", turn.get("npc_line_en", ""))),
			"npc_line_vi": str(turn.get("npc_vi", turn.get("npc_line_vi", ""))),
			"prompt_vi": str(turn.get("prompt_vi", "")),
			"explanation_vi": str(turn.get("explanation_vi", "")),
			"options": turn.get("options", [])
		})
	return out
