class_name AssessmentEngine
extends RefCounted
## Evaluates learning responses, records structured attempt logs, produces constructive
## Vietnamese feedback, and strictly separates Game Score, Learning Score, and Mastery.

const POSITIVE_PRAISES: Array[String] = [
	"Tuyệt vời! Bé trả lời rất chính xác!",
	"Giỏi quá! Tiếp tục phát huy nhé!",
	"Chính xác rồi! Buddy rất tự hào về bé!",
	"Xuất sắc! Bé nhớ bài rất tốt!"
]


func create_attempt_record(
	player_id: String,
	activity_id: String,
	question_id: String,
	selected_answer: String,
	correct_answer: String,
	is_correct: bool,
	response_time_ms: int,
	number_of_attempts: int,
	hint_used: bool
) -> Dictionary:
	return {
		"player_id": player_id,
		"activity_id": activity_id,
		"question_id": question_id,
		"selected_answer": selected_answer,
		"correct_answer": correct_answer,
		"is_correct": is_correct,
		"response_time_ms": maxi(0, response_time_ms),
		"number_of_attempts": maxi(1, number_of_attempts),
		"hint_used": hint_used,
		"completed_at_utc": Time.get_datetime_string_from_system(true)
	}


func build_feedback(
	is_correct: bool,
	correct_answer: String,
	explanation_vi: String,
	number_of_attempts: int,
	hint_used: bool,
	audio_path: String = ""
) -> Dictionary:
	var learning_score_delta := 0
	var game_score_delta := 0
	if is_correct:
		if number_of_attempts == 1 and not hint_used:
			learning_score_delta = 100
			game_score_delta = 15
		elif number_of_attempts == 1:
			learning_score_delta = 80
			game_score_delta = 10
		else:
			learning_score_delta = 60
			game_score_delta = 5
		var praise := POSITIVE_PRAISES[number_of_attempts % POSITIVE_PRAISES.size()]
		return {
			"is_correct": true,
			"headline_vi": praise,
			"correct_answer": correct_answer,
			"explanation_vi": explanation_vi,
			"allow_retry": false,
			"can_proceed": true,
			"replay_audio_path": audio_path,
			"learning_score": learning_score_delta,
			"game_score": game_score_delta
		}

	# Wrong answer: never show only an X; always show correct answer + VI explanation + retry
	return {
		"is_correct": false,
		"headline_vi": "Chưa đúng rồi, mình cùng xem đáp án và thử lại nhé!",
		"correct_answer": correct_answer,
		"explanation_vi": explanation_vi if not explanation_vi.is_empty() else "Hãy xem kỹ đáp án đúng và nghe/đọc lại kiến thức trước khi thử lại.",
		"allow_retry": true,
		"can_proceed": false,
		"replay_audio_path": audio_path,
		"learning_score": 0,
		"game_score": 0
	}
