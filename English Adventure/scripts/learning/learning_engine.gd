extends Node
## Autoload facade for the English Learning Engine.
## Orchestrates Curriculum, Vocabulary, Phrases, Phonics, Grammar, 4 Skills, Assessment,
## Learning Progress, Spaced Repetition Review, Level Unlocking, Quest hooks, and Mini-Games.

var content_repo: LearningContentRepository
var path_manager: LearningPathManager
var progress_manager: LearningProgressManager
var review_engine: ReviewEngine
var vocabulary_manager: VocabularyManager
var phonics_manager: PhonicsManager
var grammar_manager: GrammarManager
var listening_manager: ListeningManager
var speaking_manager: SpeakingManager
var reading_manager: ReadingManager
var writing_manager: WritingManager
var question_manager: QuestionManager
var assessment_engine: AssessmentEngine

var _active_lesson_id: String = ""
var _active_lesson_attempts: int = 0
var _active_lesson_first_try_correct: int = 0
var _active_lesson_total_questions: int = 0
var _learning_hub_requested_lesson: String = ""


func _ready() -> void:
	initialize_engine()
	EventBus.learning_hook_requested.connect(_on_learning_hook_requested)


func initialize_engine() -> void:
	content_repo = LearningContentRepository.new()
	content_repo.reload_all()

	path_manager = LearningPathManager.new(content_repo)
	progress_manager = LearningProgressManager.new(content_repo.spaced_repetition_config)
	review_engine = ReviewEngine.new(content_repo.spaced_repetition_config, progress_manager)
	vocabulary_manager = VocabularyManager.new(content_repo, progress_manager)
	phonics_manager = PhonicsManager.new(content_repo)
	grammar_manager = GrammarManager.new(content_repo)
	listening_manager = ListeningManager.new(content_repo)
	speaking_manager = SpeakingManager.new(content_repo)
	reading_manager = ReadingManager.new(content_repo)
	writing_manager = WritingManager.new(content_repo)
	question_manager = QuestionManager.new(content_repo, vocabulary_manager)
	assessment_engine = AssessmentEngine.new()

	AppLogger.info(
		"LearningEngine",
		"Initialized: %d letters, %d vocab, %d phrases, %d phonics units, %d grammar, %d lessons" % [
			content_repo.alphabet_ordered.size(),
			content_repo.vocab_ordered.size(),
			content_repo.phrases_ordered.size(),
			content_repo.phonics_units_ordered.size(),
			content_repo.grammar_ordered.size(),
			content_repo.lessons_ordered.size()
		]
	)


func get_lesson_questions(lesson_id: String) -> Array[Dictionary]:
	var activities := path_manager.get_activities_for_lesson(lesson_id)
	var questions: Array[Dictionary] = []
	for act in activities:
		var q := question_manager.build_question_for_activity(act)
		if not q.is_empty():
			questions.append(q)
	return questions


func start_lesson(lesson_id: String) -> Array[Dictionary]:
	var qs := get_lesson_questions(lesson_id)
	_active_lesson_id = lesson_id
	_active_lesson_attempts = 0
	_active_lesson_first_try_correct = 0
	_active_lesson_total_questions = qs.size()
	EventBus.lesson_started.emit(lesson_id)
	return qs


func submit_question_answer(
	question_payload: Dictionary,
	selected_answer: String,
	response_time_ms: int,
	number_of_attempts: int,
	hint_used: bool
) -> Dictionary:
	var skill := str(question_payload.get("skill", "reading"))
	var eval_res := {}

	match skill:
		"listening":
			eval_res = listening_manager.evaluate_answer(question_payload, selected_answer)
		"reading":
			eval_res = reading_manager.evaluate_answer(question_payload, selected_answer)
		"writing":
			eval_res = writing_manager.evaluate_answer(question_payload, selected_answer)
		"speaking":
			eval_res = speaking_manager.mark_self_practiced(question_payload, selected_answer)
		_:
			eval_res = reading_manager.evaluate_answer(question_payload, selected_answer)

	var is_correct := bool(eval_res.get("is_correct", false))
	var correct_answer := str(eval_res.get("correct_answer", ""))
	var explanation_vi := str(eval_res.get("explanation_vi", ""))
	var word_id := str(eval_res.get("word_id", question_payload.get("word_id", "")))

	var attempt := assessment_engine.create_attempt_record(
		GameStateManager.profile_id,
		str(question_payload.get("activity_id", "")),
		str(question_payload.get("question_id", "")),
		selected_answer,
		correct_answer,
		is_correct,
		response_time_ms,
		number_of_attempts,
		hint_used
	)

	var feedback := assessment_engine.build_feedback(
		is_correct,
		correct_answer,
		explanation_vi,
		number_of_attempts,
		hint_used,
		str(question_payload.get("audio_path", ""))
	)

	_active_lesson_attempts += 1
	if is_correct and number_of_attempts == 1 and not hint_used:
		_active_lesson_first_try_correct += 1

	progress_manager.record_attempt(
		attempt,
		skill,
		word_id,
		int(feedback.get("game_score", 0)),
		int(feedback.get("learning_score", 0))
	)
	if not word_id.is_empty():
		review_engine.record_review_outcome(word_id, is_correct and number_of_attempts == 1, response_time_ms)

	feedback["attempt"] = attempt
	return feedback


func complete_active_lesson() -> Dictionary:
	if _active_lesson_id.is_empty():
		return {}
	var lesson := path_manager.get_lesson(_active_lesson_id)
	var topic_id := str(lesson.get("topic_id", ""))
	var topic_lessons := path_manager.get_lessons_for_topic(topic_id)
	var topic_ids: Array[String] = []
	for ls in topic_lessons:
		topic_ids.append(str(ls.get("id", "")))

	var was_completed := progress_manager.is_lesson_completed(_active_lesson_id)
	progress_manager.mark_lesson_completed(_active_lesson_id, topic_id, topic_ids)

	var rewards: Dictionary = lesson.get("rewards", {})
	var granted_exp := 0
	var granted_gold := 0
	if not was_completed:
		granted_exp = int(rewards.get("exp", 20))
		granted_gold = int(rewards.get("gold", 10))
		if granted_exp > 0 or granted_gold > 0:
			GameStateManager.add_exp_and_gold(granted_exp, granted_gold)
		GameStateManager.set_flag("lesson_done_" + _active_lesson_id, true)
		GameStateManager.save_now("lesson_completed_" + _active_lesson_id)

	var summary := {
		"lesson_id": _active_lesson_id,
		"title_vi": str(lesson.get("title_vi", "")),
		"total_questions": _active_lesson_total_questions,
		"first_try_correct": _active_lesson_first_try_correct,
		"exp_granted": granted_exp,
		"gold_granted": granted_gold,
		"already_completed_before": was_completed
	}
	var finished_id := _active_lesson_id
	_active_lesson_id = ""
	EventBus.lesson_completed.emit(finished_id, summary)
	return summary


## Evaluates multi-factor Pre-A1 -> A1 unlock readiness (never based on a single quiz).
func evaluate_a1_unlock_status() -> Dictionary:
	var criteria: Dictionary = content_repo.a1_unlock_criteria
	var req_lessons := int(criteria.get("min_pre_a1_lessons_completed", 6))
	var req_remembered := int(criteria.get("min_remembered_or_mastered_items", 15))
	var req_acc := float(criteria.get("min_overall_accuracy_pct", 60.0))
	var req_quests: Array = criteria.get("required_quest_ids", ["quest_03_mysterious_gate"])

	var four := progress_manager.get_four_state_summary()
	var pre_a1_done := 0
	for lid in progress_manager.completed_lessons:
		var ls := path_manager.get_lesson(lid)
		if str(ls.get("world_id", "")) == "world_01":
			pre_a1_done += 1

	var remembered := int(four.get("remembered_items", 0))
	var acc := float(four.get("overall_accuracy_pct", 0.0))
	var quests_ok := true
	for qid_var in req_quests:
		var qid := str(qid_var)
		if GameStateManager == null or not GameStateManager.get_flag("quest_completed_" + qid, false):
			quests_ok = false
			break

	var unlocked := (
		pre_a1_done >= req_lessons
		and remembered >= req_remembered
		and acc >= req_acc
		and quests_ok
	)
	return {
		"unlocked": unlocked,
		"pre_a1_lessons_done": pre_a1_done,
		"pre_a1_lessons_required": req_lessons,
		"remembered_items": remembered,
		"remembered_required": req_remembered,
		"overall_accuracy_pct": acc,
		"accuracy_required": req_acc,
		"quests_completed": quests_ok,
		"required_quests": req_quests
	}


## Public API for Prompt 05/09 Mini-Games: returns reusable vocabulary & dynamic questions
func get_mini_game_vocabulary_pack(topic: String = "", max_difficulty: int = 2, count: int = 8, cefr_level: String = "") -> Array[Dictionary]:
	var pool := vocabulary_manager.get_words_for_difficulty(max_difficulty, topic, cefr_level)
	var out: Array[Dictionary] = []
	for i in range(mini(count, pool.size())):
		out.append(pool[i])
	return out


func get_review_question_batch(limit: int = 6) -> Array[Dictionary]:
	var all_ids: Array[String] = []
	for w in content_repo.vocab_ordered:
		all_ids.append(str(w.get("id", "")))
	var due := review_engine.get_due_review_items(all_ids, limit)
	var batch: Array[Dictionary] = []
	var skills_cycle: Array[String] = ["reading", "writing", "listening"]
	var idx := 0
	for d in due:
		var wid := str(d.get("item_id", ""))
		var support := progress_manager.get_adaptive_support_for_item(wid)
		var sk: String = "listening" if bool(support.get("needs_support", false)) else skills_cycle[idx % skills_cycle.size()]
		var q := question_manager.build_reusable_vocab_question(wid, sk)
		if not q.is_empty():
			q["adaptive_support"] = support
			batch.append(q)
		idx += 1
	return batch


func get_phonics_quiz_batch() -> Array[Dictionary]:
	return question_manager.build_phonics_quiz_batch()


func consume_requested_lesson() -> String:
	var lid := _learning_hub_requested_lesson
	_learning_hub_requested_lesson = ""
	return lid


func _on_learning_hook_requested(hook_payload: Dictionary) -> void:
	var lid := str(hook_payload.get("lesson_id", ""))
	if not lid.is_empty():
		_learning_hub_requested_lesson = lid
		AppLogger.info("LearningEngine", "Queued learning hook lesson: " + lid)
