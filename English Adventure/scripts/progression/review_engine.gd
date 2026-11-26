class_name ReviewEngine
extends RefCounted
## Configurable Spaced Repetition Engine driven entirely by spaced_repetition_config.json.
## Schedules review intervals, adapts ease factors, and selects optimal review batches.

const SCHEDULE_PATH := "user://profiles/review_schedule.json"

var schedules: Dictionary = {} # item_id -> { streak, interval_days, ease_factor, next_review_unix, last_reviewed_utc }
var _config: Dictionary = {}
var _progress: LearningProgressManager


func _init(config: Dictionary, progress: LearningProgressManager) -> void:
	_config = config
	_progress = progress
	load_schedule()


func record_review_outcome(item_id: String, is_correct_first_try: bool, response_time_ms: int) -> Dictionary:
	if item_id.is_empty():
		return {}

	var intervals: Array = _config.get("initial_intervals_days", [0.0, 1.0, 3.0, 7.0, 14.0, 30.0])
	var def_ease := float(_config.get("ease_factor_default", 2.5))
	var min_ease := float(_config.get("ease_factor_min", 1.3))
	var max_ease := float(_config.get("ease_factor_max", 3.0))
	var fast_ms := int(_config.get("fast_response_threshold_ms", 4500))
	var fast_bonus := float(_config.get("ease_bonus_on_fast_correct", 0.15))
	var wrong_pen := float(_config.get("ease_penalty_on_wrong", -0.25))

	var rec: Dictionary = schedules.get(item_id, {
		"streak": 0,
		"interval_days": 0.0,
		"ease_factor": def_ease,
		"next_review_unix": 0,
		"last_reviewed_utc": ""
	})

	var streak := int(rec.get("streak", 0))
	var ease := float(rec.get("ease_factor", def_ease))
	var interval_days := float(rec.get("interval_days", 0.0))

	if is_correct_first_try:
		streak += 1
		if response_time_ms <= fast_ms:
			ease = clampf(ease + fast_bonus, min_ease, max_ease)
		if streak < intervals.size():
			interval_days = float(intervals[streak])
		else:
			interval_days = round(maxf(1.0, interval_days) * ease * 10.0) / 10.0
	else:
		# Reset streak so missed knowledge returns quickly to practice list
		streak = 0
		ease = clampf(ease + wrong_pen, min_ease, max_ease)
		interval_days = float(intervals[0]) if intervals.size() > 0 else 0.0

	var now_unix := int(Time.get_unix_time_from_system())
	var next_unix := now_unix + int(round(interval_days * 86400.0))

	rec["streak"] = streak
	rec["interval_days"] = interval_days
	rec["ease_factor"] = round(ease * 100.0) / 100.0
	rec["next_review_unix"] = next_unix
	rec["last_reviewed_utc"] = Time.get_datetime_string_from_system(true)
	schedules[item_id] = rec

	save_schedule()
	SaveLoadManager.enqueue_sync_event("review_schedule_updated", {
		"profile_id": GameStateManager.profile_id,
		"item_id": item_id,
		"schedule": rec
	})
	return rec


func get_due_review_items(all_vocab_ids: Array[String], limit: int = 0) -> Array[Dictionary]:
	var max_items := limit if limit > 0 else int(_config.get("max_daily_review_batch", 12))
	var now_unix := int(Time.get_unix_time_from_system())
	var due: Array[Dictionary] = []

	for item_id_var in schedules.keys():
		var item_id := str(item_id_var)
		var rec: Dictionary = schedules[item_id]
		var next_u := int(rec.get("next_review_unix", 0))
		var status := _progress.get_item_status(item_id)
		if next_u <= now_unix or status == "reviewing" or int(rec.get("streak", 0)) == 0:
			due.append({
				"item_id": item_id,
				"priority": (1000.0 - _progress.get_item_mastery(item_id)) + (500.0 if int(rec.get("streak", 0)) == 0 else 0.0),
				"interval_days": float(rec.get("interval_days", 0.0)),
				"status": status
			})

	due.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("priority", 0.0)) > float(b.get("priority", 0.0))
	)

	# If user has fewer scheduled reviews than limit, supplement with unpracticed starter words
	if due.size() < mini(4, max_items):
		for wid in all_vocab_ids:
			if due.size() >= mini(4, max_items):
				break
			var already := false
			for d in due:
				if str(d.get("item_id", "")) == wid:
					already = true
					break
			if not already and _progress.get_item_status(wid) == "new":
				due.append({ "item_id": wid, "priority": 10.0, "interval_days": 0.0, "status": "new" })

	return due.slice(0, mini(max_items, due.size()))


func save_schedule() -> void:
	DirAccess.make_dir_recursive_absolute("user://profiles")
	var f := FileAccess.open(SCHEDULE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(schedules, "\t"))
	f.close()


func load_schedule() -> void:
	if not FileAccess.file_exists(SCHEDULE_PATH):
		return
	var f := FileAccess.open(SCHEDULE_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) == TYPE_DICTIONARY:
		schedules = (parsed as Dictionary).duplicate(true)
