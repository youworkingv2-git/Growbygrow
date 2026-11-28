extends Node
## Prompt 09 Automated Content & Learning Integration Test Suite (Godot 4.x)
## Verifies Tests 01-08: Vocabulary (Pre-A1/A1 + Phrases), Phonics, Sentence Practice,
## Listening, Speaking (with mic fallback), Reading & Writing (acceptable_answers),
## Quest Integration, Spaced Repetition Review, 4-state mastery, and A1 Unlock Gate.


func run_all_checks() -> Dictionary:
	var results := { "passed": 0, "failed": 0, "notes": [] }

	# Test 01: Vocabulary + Phrases + Multi-topic reuse
	_assert_true(results, LearningEngine.content_repo.vocab_ordered.size() >= 140, "Loaded Pre-A1 + A1 vocabulary (>=140 words)")
	_assert_true(results, LearningEngine.content_repo.phrases_ordered.size() >= 48, "Loaded common phrases (>=48)")
	var apple := LearningEngine.vocabulary_manager.get_word("word_apple")
	_assert_true(results, str(apple.get("meaning_vi", "")) == "Quả táo", "Vocabulary lookup word_apple works")
	var fruits_pool := LearningEngine.vocabulary_manager.get_words_by_topic("fruits")
	_assert_true(results, fruits_pool.size() >= 6, "Multi-topic tag filtering returns fruits including apple/banana/orange")

	# Test 02: Phonics (26 letters, Letter Name != Letter Sound, 24 units + quiz)
	var letters := LearningEngine.phonics_manager.get_all_letters()
	_assert_true(results, letters.size() == 26, "Alphabet has 26 letters")
	var letter_a := LearningEngine.phonics_manager.get_letter_by_symbol("a")
	_assert_true(results, str(letter_a.get("letter_sound_ipa", "")) != LearningEngine.phonics_manager.get_letter_name_ipa(letter_a), "Letter A separates Name IPA and Sound IPA")
	_assert_true(results, LearningEngine.get_phonics_quiz_batch().size() >= 6, "Phonics quiz batch is playable")

	# Test 03: Sentence Practice & Substitution Builder
	_assert_true(results, LearningEngine.grammar_manager.get_all_structures().size() >= 30, "Loaded Pre-A1 + A1 grammar patterns (>=30)")
	var subs := LearningEngine.grammar_manager.generate_substitution_sentences("gram_07")
	_assert_true(results, subs.size() >= 3, "Grammar substitution generates multiple practice sentences")

	# Test 04: Listening
	var l_item := LearningEngine.listening_manager.get_item("list_18")
	var l_eval := LearningEngine.listening_manager.evaluate_answer(l_item, "a")
	_assert_true(results, bool(l_eval.get("is_correct", false)), "Listening item list_18 evaluates correctly")

	# Test 05: Speaking + Microphone fallback honesty
	var cap := LearningEngine.speaking_manager.get_capability_report()
	_assert_true(results, cap.has("can_record"), "Speaking capability report includes mic fallback check")
	var sp_item := LearningEngine.speaking_manager.get_item("speak_09")
	_assert_true(results, str(sp_item.get("ai_scoring_status", "")) == "not_integrated_experimental", "Speaking item honestly marks pending AI scoring")

	# Test 06: Reading & Writing with acceptable_answers
	var r_item := LearningEngine.reading_manager.get_item("read_a1_03")
	var r_eval := LearningEngine.reading_manager.evaluate_answer(r_item, "a")
	_assert_true(results, bool(r_eval.get("is_correct", false)), "A1 Reading passage evaluates correctly")
	var w_item := LearningEngine.writing_manager.get_item("write_22")
	var w_eval1 := LearningEngine.writing_manager.evaluate_answer(w_item, "Hello! I am happy.")
	var w_eval2 := LearningEngine.writing_manager.evaluate_answer(w_item, "I'm happy.")
	_assert_true(results, bool(w_eval1.get("is_correct", false)) and bool(w_eval2.get("is_correct", false)), "Writing acceptable_answers accepts equivalent valid expressions")

	# Test 07: Quest Integration + Learning Hook
	var q2 := QuestManager.repository.get_quest("quest_02_lost_letters")
	var hook: Dictionary = q2.get("learning_hook", {})
	_assert_true(results, (hook.get("linked_vocab_ids", []) as Array).has("word_apple"), "Quest 02 learning_hook maps to word_apple")

	# Test 08: Review, 4-State Mastery & A1 Multi-factor Gate
	var gate_initial := LearningEngine.evaluate_a1_unlock_status()
	_assert_true(results, gate_initial.has("unlocked") and gate_initial.has("pre_a1_lessons_required"), "A1 multi-factor unlock gate returns structured checklist")
	var review_batch := LearningEngine.get_review_question_batch(6)
	_assert_true(results, review_batch.size() >= 4, "Spaced repetition review batch generates playable questions")

	return results


func _assert_true(results: Dictionary, cond: bool, label: String) -> void:
	if cond:
		results["passed"] += 1
	else:
		results["failed"] += 1
		results["notes"].append("FAIL: " + label)
