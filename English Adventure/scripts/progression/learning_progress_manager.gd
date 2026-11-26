class_name LearningProgressManager
extends RefCounted
## Persists player learning progress offline-first: item mastery states
## (new/learning/practicing/reviewing/mastered), skill accuracy, completed lessons/topics,
## attempt logs, and sync outbox queuing for Supabase.

const PROGRESS_PATH := "user://profiles/learning_progress.json"
const TEMP_PROGRESS_PATH := "user://profiles/learning_progress.json.tmp"

var item_states: Dictionary = {}       # item_id -> { status, mastery_score, correct_count, wrong_count, skills_verified, last_attempt_utc }
var skill_stats: Dictionary = {}       # skill -> { attempts, correct, accuracy_pct, avg_time_ms }
var completed_lessons: Array[String] = []
var completed_topics: Array[String] = []
var attempt_history: Array[Dictionary] = []
var total_learning_score: int = 0
var total_game_score: int = 0

var _sr_config: Dictionary = {}


func _init(sr_config: Dictionary) -> void:
	_sr_config = sr_config
	_init_default_skills()
	load_progress()


func _init_default_skills() -> void:
	for sk in ["listening", "speaking", "reading", "writing"]:
		if not skill_stats.has(sk):
			skill_stats[sk] = {
				"attempts": 0,
				"correct": 0,
				"accuracy_pct": 0.0,
				"total_time_ms": 0
			}


func get_item_status(item_id: String) -> String:
	if not item_states.has(item_id):
		return "new"
	return str(item_states[item_id].get("status", "new"))


func get_item_mastery(item_id: String) -> float:
	if not item_states.has(item_id):
		return 0.0
	return float(item_states[item_id].get("mastery_score", 0.0))


func is_lesson_completed(lesson_id: String) -> bool:
	return completed_lessons.has(lesson_id)


func record_attempt(attempt: Dictionary, skill: String, target_item_id: String, lesson_game_score: int, lesson_learning_score: int) -> void:
	attempt_history.append(attempt)
	if attempt_history.size() > 300:
		attempt_history = attempt_history.slice(attempt_history.size() - 300, attempt_history.size())

	total_game_score += maxi(0, lesson_game_score)
	if bool(attempt.get("is_correct", false)):
		total_learning_score += maxi(0, lesson_learning_score)

	# Update skill statistics
	if not skill_stats.has(skill):
		skill_stats[skill] = { "attempts": 0, "correct": 0, "accuracy_pct": 0.0, "total_time_ms": 0 }
	var st: Dictionary = skill_stats[skill]
	st["attempts"] = int(st.get("attempts", 0)) + 1
	if bool(attempt.get("is_correct", false)) and int(attempt.get("number_of_attempts", 1)) == 1:
		st["correct"] = int(st.get("correct", 0)) + 1
	st["total_time_ms"] = int(st.get("total_time_ms", 0)) + int(attempt.get("response_time_ms", 0))
	var att_n := maxi(1, int(st["attempts"]))
	st["accuracy_pct"] = round((float(st["correct"]) / float(att_n)) * 1000.0) / 10.0
	skill_stats[skill] = st

	# Update item mastery & state
	if not target_item_id.is_empty():
		_update_item_mastery(target_item_id, skill, attempt)

	save_progress()
	SaveLoadManager.enqueue_sync_event("learning_attempt", {
		"profile_id": GameStateManager.profile_id,
		"attempt": attempt,
		"skill": skill,
		"target_item_id": target_item_id
	})
	EventBus.learning_activity_answered.emit(attempt)
	EventBus.learning_progress_updated.emit()


func _update_item_mastery(item_id: String, skill: String, attempt: Dictionary) -> void:
	var rec: Dictionary = item_states.get(item_id, {
		"status": "new",
		"mastery_score": 0.0,
		"correct_count": 0,
		"wrong_count": 0,
		"skills_verified": [],
		"last_attempt_utc": ""
	})
	var mastery := float(rec.get("mastery_score", 0.0))
	var is_correct := bool(attempt.get("is_correct", false))
	var attempts_n := int(attempt.get("number_of_attempts", 1))
	var hint_used := bool(attempt.get("hint_used", false))

	var gain := float(_sr_config.get("correct_mastery_gain", 22.0))
	var first_bonus := float(_sr_config.get("first_try_bonus_mastery", 6.0))
	var hint_pen := float(_sr_config.get("hint_penalty_mastery", 8.0))
	var wrong_loss := float(_sr_config.get("wrong_mastery_loss", 15.0))

	if is_correct:
		rec["correct_count"] = int(rec.get("correct_count", 0)) + 1
		if attempts_n == 1:
			mastery += gain + first_bonus
		else:
			mastery += gain * 0.45
		if hint_used:
			mastery -= hint_pen
		var verified: Array = rec.get("skills_verified", [])
		if not verified.has(skill):
			verified.append(skill)
		rec["skills_verified"] = verified
	else:
		rec["wrong_count"] = int(rec.get("wrong_count", 0)) + 1
		mastery -= wrong_loss

	mastery = clampf(mastery, 0.0, 100.0)
	rec["mastery_score"] = round(mastery * 10.0) / 10.0
	rec["last_attempt_utc"] = str(attempt.get("completed_at_utc", ""))

	var req_skills := int(_sr_config.get("min_distinct_skills_for_mastery", 2))
	var mastered_th := float(_sr_config.get("mastered_threshold", 85.0))
	var reviewing_th := float(_sr_config.get("reviewing_threshold", 70.0))
	var practicing_th := float(_sr_config.get("practicing_threshold", 45.0))
	var skills_count := (rec.get("skills_verified", []) as Array).size()

	if not is_correct:
		rec["status"] = "reviewing" if mastery >= practicing_th else "learning"
	elif mastery >= mastered_th and skills_count >= req_skills:
		rec["status"] = "mastered"
	elif mastery >= reviewing_th:
		rec["status"] = "reviewing"
	elif mastery >= practicing_th:
		rec["status"] = "practicing"
	else:
		rec["status"] = "learning"

	item_states[item_id] = rec


func mark_lesson_completed(lesson_id: String, topic_id: String, topic_all_lesson_ids: Array[String]) -> void:
	if not completed_lessons.has(lesson_id):
		completed_lessons.append(lesson_id)
	if not topic_id.is_empty() and not completed_topics.has(topic_id):
		var all_done := true
		for lid in topic_all_lesson_ids:
			if not completed_lessons.has(lid):
				all_done = false
				break
		if all_done and not topic_all_lesson_ids.is_empty():
			completed_topics.append(topic_id)
	save_progress()
	SaveLoadManager.enqueue_sync_event("lesson_completed", {
		"profile_id": GameStateManager.profile_id,
		"lesson_id": lesson_id,
		"topic_id": topic_id,
		"completed_at_utc": Time.get_datetime_string_from_system(true)
	})
	EventBus.learning_progress_updated.emit()


func get_weak_skills(max_threshold_pct: float = 75.0) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for sk in ["listening", "speaking", "reading", "writing"]:
		var st: Dictionary = skill_stats.get(sk, {})
		var att := int(st.get("attempts", 0))
		var acc := float(st.get("accuracy_pct", 0.0))
		if att > 0 and acc < max_threshold_pct:
			out.append({ "skill": sk, "accuracy_pct": acc, "attempts": att })
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("accuracy_pct", 0.0)) < float(b.get("accuracy_pct", 0.0))
	)
	return out


func get_frequently_missed_items() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for item_id_var in item_states.keys():
		var item_id := str(item_id_var)
		var rec: Dictionary = item_states[item_id]
		var wrongs := int(rec.get("wrong_count", 0))
		if wrongs > 0 and str(rec.get("status", "")) != "mastered":
			out.append({
				"item_id": item_id,
				"wrong_count": wrongs,
				"mastery_score": float(rec.get("mastery_score", 0.0)),
				"status": str(rec.get("status", "learning"))
			})
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("wrong_count", 0)) > int(b.get("wrong_count", 0))
	)
	return out


func save_progress() -> bool:
	DirAccess.make_dir_recursive_absolute("user://profiles")
	var payload := {
		"profile_id": GameStateManager.profile_id,
		"item_states": item_states,
		"skill_stats": skill_stats,
		"completed_lessons": completed_lessons,
		"completed_topics": completed_topics,
		"attempt_history": attempt_history,
		"total_learning_score": total_learning_score,
		"total_game_score": total_game_score,
		"updated_at_utc": Time.get_datetime_string_from_system(true)
	}
	var json_str := JSON.stringify(payload, "\t")
	var f := FileAccess.open(TEMP_PROGRESS_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(json_str)
		f.close()
		var err := DirAccess.rename_absolute(
			ProjectSettings.globalize_path(TEMP_PROGRESS_PATH),
			ProjectSettings.globalize_path(PROGRESS_PATH)
		)
		if err == OK:
			return true
	var direct := FileAccess.open(PROGRESS_PATH, FileAccess.WRITE)
	if direct == null:
		return false
	direct.store_string(json_str)
	direct.close()
	return true


func load_progress() -> void:
	if not FileAccess.file_exists(PROGRESS_PATH):
		return
	var f := FileAccess.open(PROGRESS_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var d: Dictionary = parsed
	if typeof(d.get("item_states", {})) == TYPE_DICTIONARY:
		item_states = (d.get("item_states", {}) as Dictionary).duplicate(true)
	if typeof(d.get("skill_stats", {})) == TYPE_DICTIONARY:
		var loaded_sk: Dictionary = d.get("skill_stats", {})
		for k in loaded_sk.keys():
			skill_stats[str(k)] = loaded_sk[k]
	completed_lessons.clear()
	for l_var in d.get("completed_lessons", []):
		completed_lessons.append(str(l_var))
	completed_topics.clear()
	for t_var in d.get("completed_topics", []):
		completed_topics.append(str(t_var))
	attempt_history.clear()
	for a_var in d.get("attempt_history", []):
		if typeof(a_var) == TYPE_DICTIONARY:
			attempt_history.append(a_var)
	total_learning_score = int(d.get("total_learning_score", 0))
	total_game_score = int(d.get("total_game_score", 0))
