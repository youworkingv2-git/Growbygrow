class_name MiniGameScoring
extends RefCounted
## Separates Correct Answers, Incorrect Answers, Attempts, Hints Used, Completion Time,
## Learning Score, Game Score, Stars, and Mastery Progress.
## Never uses completion speed as the sole pass/fail criterion.


static func calculate_round_scores(
	is_correct: bool,
	attempts: int,
	hint_used: bool,
	difficulty_tier: String
) -> Dictionary:
	if not is_correct:
		return {
			"learning_score": 0,
			"game_score": 0
		}

	var base_learn := 100
	var base_game := 20
	if attempts > 1:
		base_learn = 65
		base_game = 10
	if hint_used:
		base_learn = maxi(40, base_learn - 20)
		base_game = maxi(5, base_game - 5)

	var diff_bonus := 0
	if difficulty_tier == "medium":
		diff_bonus = 5
	elif difficulty_tier == "hard":
		diff_bonus = 10

	return {
		"learning_score": base_learn,
		"game_score": base_game + diff_bonus
	}


static func compute_stars(correct_first_try: int, total_correct: int, total_items: int, thresholds: Array) -> int:
	if total_items <= 0 or total_correct <= 0:
		return 1 # Positive reinforcement: completing practice always earns at least 1 star
	var weighted := (float(total_correct) * 0.65 + float(correct_first_try) * 0.35) / float(total_items)
	var t1 := float(thresholds[0]) if thresholds.size() > 0 else 0.5
	var t2 := float(thresholds[1]) if thresholds.size() > 1 else 0.75
	var t3 := float(thresholds[2]) if thresholds.size() > 2 else 0.9
	if weighted >= t3:
		return 3
	if weighted >= t2:
		return 2
	if weighted >= t1 or total_correct > 0:
		return 1
	return 1


static func build_summary(
	minigame_id: String,
	total_items: int,
	correct_answers: int,
	incorrect_answers: int,
	first_try_correct: int,
	total_attempts: int,
	hints_used: int,
	completion_time_ms: int,
	learning_score: int,
	game_score: int,
	thresholds: Array
) -> Dictionary:
	var accuracy := 0.0
	if total_items > 0:
		accuracy = clampf(float(correct_answers) / float(total_items), 0.0, 1.0)
	var stars := compute_stars(first_try_correct, correct_answers, total_items, thresholds)
	return {
		"minigame_id": minigame_id,
		"total_items": total_items,
		"correct_answers": correct_answers,
		"incorrect_answers": incorrect_answers,
		"first_try_correct": first_try_correct,
		"attempts": total_attempts,
		"hints_used": hints_used,
		"completion_time_ms": completion_time_ms,
		"learning_score": learning_score,
		"game_score": game_score,
		"accuracy": round(accuracy * 1000.0) / 10.0,
		"stars": stars,
		"passed": correct_answers > 0
	}
