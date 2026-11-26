class_name MiniGameSession
extends RefCounted
## Manages the unified 8-stage lifecycle of a single mini-game session:
## 1. Introduction -> 2. Learning Objective -> 3. Instructions -> 4. Gameplay
## -> 5. Immediate Feedback -> 6. Result Summary -> 7. Reward -> 8. Return to Adventure.

enum Stage {
	INTRO,
	OBJECTIVE,
	INSTRUCTIONS,
	GAMEPLAY,
	FEEDBACK,
	SUMMARY,
	REWARD,
	RETURNED
}

var session_id: String = ""
var minigame_id: String = ""
var registry_entry: Dictionary = {}
var launch_context: Dictionary = {}
var difficulty_tier: String = "easy"
var difficulty_config: Dictionary = {}
var current_stage: Stage = Stage.INTRO

var items: Array[Dictionary] = []
var current_index: int = 0
var current_item_attempts: int = 0
var current_item_hint_used: bool = false

var correct_answers: int = 0
var incorrect_answers: int = 0
var first_try_correct: int = 0
var total_attempts: int = 0
var total_hints_used: int = 0
var consecutive_first_try: int = 0
var learning_score: int = 0
var game_score: int = 0

var session_started_ms: int = 0
var item_started_ms: int = 0
var last_feedback: Dictionary = {}
var completed_result: MiniGameResult = null


func _init(entry: Dictionary, context: Dictionary, diff_tier: String, diff_cfg: Dictionary) -> void:
	minigame_id = str(entry.get("id", ""))
	registry_entry = entry.duplicate(true)
	launch_context = context.duplicate(true)
	difficulty_tier = diff_tier
	difficulty_config = diff_cfg.duplicate(true)
	session_id = "%s_%d" % [minigame_id, Time.get_ticks_msec()]
	session_started_ms = Time.get_ticks_msec()
	item_started_ms = session_started_ms


func set_items(challenge_items: Array[Dictionary]) -> void:
	items = challenge_items
	current_index = 0
	current_item_attempts = 0
	current_item_hint_used = false
	item_started_ms = Time.get_ticks_msec()


func begin_gameplay() -> void:
	current_stage = Stage.GAMEPLAY
	session_started_ms = Time.get_ticks_msec()
	item_started_ms = session_started_ms


func get_current_item() -> Dictionary:
	if current_index >= 0 and current_index < items.size():
		return items[current_index]
	return {}


func use_hint() -> void:
	if not current_item_hint_used:
		current_item_hint_used = true
		total_hints_used += 1


func record_answer(
	selected_answer: String,
	is_correct: bool,
	correct_display: String,
	meaning_vi: String,
	explanation_vi: String,
	example_en: String = "",
	audio_path: String = "",
	transcript_en: String = ""
) -> Dictionary:
	current_item_attempts += 1
	total_attempts += 1
	var now_ms := Time.get_ticks_msec()
	var resp_ms := maxi(0, now_ms - item_started_ms)

	var item := get_current_item()
	var knowledge_id := str(item.get("knowledge_id", item.get("word_id", "")))
	var question_id := str(item.get("question_id", "%s_q_%d" % [minigame_id, current_index + 1]))
	var activity_id := "mg_%s_%s" % [minigame_id, question_id]
	var skill := str(item.get("skill", "reading"))

	if is_correct:
		correct_answers += 1
		if current_item_attempts == 1:
			first_try_correct += 1
			consecutive_first_try += 1
		else:
			consecutive_first_try = 0
	else:
		incorrect_answers += 1
		consecutive_first_try = 0

	var round_scores := MiniGameScoring.calculate_round_scores(
		is_correct,
		current_item_attempts,
		current_item_hint_used,
		difficulty_tier
	)
	learning_score += int(round_scores.get("learning_score", 0))
	game_score += int(round_scores.get("game_score", 0))

	# Adaptive difficulty check (based on accuracy/mistakes, never speed alone)
	difficulty_tier = MiniGameDifficulty.adjust_tier_after_round(
		difficulty_tier,
		consecutive_first_try,
		1 if not is_correct else 0
	)

	# Report directly to Prompt 04 AssessmentEngine, ProgressManager, and ReviewEngine
	var attempt_record := LearningEngine.assessment_engine.create_attempt_record(
		GameStateManager.profile_id,
		activity_id,
		question_id,
		selected_answer,
		correct_display,
		is_correct,
		resp_ms,
		current_item_attempts,
		current_item_hint_used
	)
	attempt_record["minigame_id"] = minigame_id
	attempt_record["knowledge_id"] = knowledge_id
	attempt_record["learning_activity_id"] = activity_id

	LearningEngine.progress_manager.record_attempt(
		attempt_record,
		skill,
		knowledge_id,
		int(round_scores.get("game_score", 0)),
		int(round_scores.get("learning_score", 0))
	)
	if not knowledge_id.is_empty():
		LearningEngine.review_engine.record_review_outcome(
			knowledge_id,
			is_correct and current_item_attempts == 1,
			resp_ms
		)

	SaveLoadManager.enqueue_sync_event("minigame_question_answered", {
		"session_id": session_id,
		"attempt": attempt_record
	})

	last_feedback = MiniGameFeedback.build_item_feedback(
		is_correct,
		correct_display,
		meaning_vi,
		explanation_vi,
		example_en,
		audio_path,
		transcript_en,
		current_item_attempts,
		current_item_hint_used
	)
	last_feedback["attempt_record"] = attempt_record

	EventBus.minigame_answered.emit(minigame_id, attempt_record)
	return last_feedback


func advance_to_next_item() -> bool:
	current_index += 1
	current_item_attempts = 0
	current_item_hint_used = false
	item_started_ms = Time.get_ticks_msec()
	return current_index < items.size()


func finalize_session() -> MiniGameResult:
	current_stage = Stage.SUMMARY
	var elapsed_ms := maxi(500, Time.get_ticks_msec() - session_started_ms)
	var reward_cfg: Dictionary = registry_entry.get("reward_config", {})
	var thresholds: Array = reward_cfg.get("stars_thresholds", [0.5, 0.75, 0.9])
	var total_n := maxi(1, items.size())

	var summary := MiniGameScoring.build_summary(
		minigame_id,
		total_n,
		correct_answers,
		incorrect_answers,
		first_try_correct,
		total_attempts,
		total_hints_used,
		elapsed_ms,
		learning_score,
		game_score,
		thresholds
	)

	var quest_id := str(launch_context.get("quest_id", ""))
	var reward_summary := MiniGameReward.grant_rewards(minigame_id, summary, reward_cfg, quest_id)
	current_stage = Stage.REWARD

	var res := MiniGameResult.new()
	res.minigame_id = minigame_id
	res.source_type = str(launch_context.get("source_type", "arcade"))
	res.source_id = str(launch_context.get("source_id", ""))
	res.quest_id = quest_id
	res.difficulty_tier = difficulty_tier
	res.total_items = total_n
	res.correct_answers = correct_answers
	res.incorrect_answers = incorrect_answers
	res.first_try_correct = first_try_correct
	res.total_attempts = total_attempts
	res.hints_used = total_hints_used
	res.completion_time_ms = elapsed_ms
	res.learning_score = learning_score
	res.game_score = game_score
	res.accuracy = float(summary.get("accuracy", 0.0))
	res.stars = int(summary.get("stars", 1))
	res.passed = bool(summary.get("passed", true))
	res.reward_summary = reward_summary
	res.completed_at_utc = Time.get_datetime_string_from_system(true)

	completed_result = res
	SaveLoadManager.enqueue_sync_event("minigame_session_completed", res.to_dict())
	return res
