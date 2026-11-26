class_name MiniGameResult
extends RefCounted
## Structured Mini-Game Result payload passed to Assessment, Progress, Reward, and Quest systems.

var minigame_id: String = ""
var source_type: String = "arcade"
var source_id: String = ""
var quest_id: String = ""
var difficulty_tier: String = "easy"
var total_items: int = 0
var correct_answers: int = 0
var incorrect_answers: int = 0
var first_try_correct: int = 0
var total_attempts: int = 0
var hints_used: int = 0
var completion_time_ms: int = 0
var learning_score: int = 0
var game_score: int = 0
var accuracy: float = 0.0
var stars: int = 1
var passed: bool = false
var reward_summary: Dictionary = {}
var completed_at_utc: String = ""


func to_dict() -> Dictionary:
	return {
		"minigame_id": minigame_id,
		"source_type": source_type,
		"source_id": source_id,
		"quest_id": quest_id,
		"difficulty_tier": difficulty_tier,
		"total_items": total_items,
		"correct_answers": correct_answers,
		"incorrect_answers": incorrect_answers,
		"first_try_correct": first_try_correct,
		"attempts": total_attempts,
		"hints_used": hints_used,
		"completion_time_ms": completion_time_ms,
		"learning_score": learning_score,
		"game_score": game_score,
		"accuracy": accuracy,
		"stars": stars,
		"passed": passed,
		"reward_summary": reward_summary,
		"completed_at_utc": completed_at_utc
	}
