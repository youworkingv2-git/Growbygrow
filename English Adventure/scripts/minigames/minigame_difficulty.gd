class_name MiniGameDifficulty
extends RefCounted
## Adaptive Difficulty Manager (MiniGameDifficultyManager).
## Adjusts difficulty from mastery, accuracy streak, wrong count, attempts, and hints used.
## Never penalizes beginners or increases difficulty solely from answer speed.

const TIERS := ["easy", "medium", "hard"]


static func resolve_adaptive_tier(minigame_id: String, requested_tier: String = "auto") -> String:
	if requested_tier in TIERS:
		return requested_tier

	var pm := LearningEngine.progress_manager
	if pm == null:
		return "easy"

	var entry := MiniGameManager.registry.get_entry(minigame_id) if MiniGameManager != null else {}
	var skills: Array = entry.get("learning_skills", [])
	var primary_skill := str(skills[0]) if not skills.is_empty() else "reading"
	if primary_skill == "vocabulary" or primary_skill == "phonics" or primary_skill == "grammar":
		primary_skill = "reading" if primary_skill != "phonics" else "listening"

	var st: Dictionary = pm.skill_stats.get(primary_skill, {})
	var attempts := int(st.get("attempts", 0))
	var acc := float(st.get("accuracy_pct", 0.0))

	# Also check recent wrong items & player's previous minigame record
	var missed_count := pm.get_frequently_missed_items().size()
	var mg_rec: Dictionary = GameStateManager.get_minigame_record(minigame_id)
	var plays := int(mg_rec.get("plays", 0))
	var best_stars := int(mg_rec.get("best_stars", 0))

	# Keep beginners supported until they build steady accuracy without many mistakes
	if attempts < 4 or plays == 0 or missed_count >= 4 or acc < 62.0:
		return "easy"
	if acc >= 84.0 and best_stars >= 2 and missed_count <= 1:
		return "hard"
	if acc >= 70.0 and plays >= 1:
		return "medium"
	return "easy"


static func get_config_for(minigame_id: String, tier: String) -> Dictionary:
	var t := tier if tier in TIERS else "easy"
	var cfg := {
		"tier": t,
		"label_vi": "Dễ (Làm quen)" if t == "easy" else ("Vừa (Thử thách)" if t == "medium" else "Nâng cao"),
		"choice_count": 2 if t == "easy" else (3 if t == "medium" else 4),
		"word_max_length": 4 if t == "easy" else (6 if t == "medium" else 10),
		"pair_count": 3 if t == "easy" else (4 if t == "medium" else 6),
		"round_count": 4 if t == "easy" else (5 if t == "medium" else 6),
		"max_hints": 3 if t == "easy" else (2 if t == "medium" else 1),
		"show_vi_support": true if t != "hard" else false,
		"soft_timer_sec": 0 if t != "hard" else 90
	}

	match minigame_id:
		"listen_and_find":
			cfg["choice_count"] = 2 if t == "easy" else (3 if t == "medium" else 5)
		"memory_quest":
			cfg["pair_count"] = 3 if t == "easy" else (4 if t == "medium" else 6)
		"word_matching":
			cfg["pair_count"] = 3 if t == "easy" else (4 if t == "medium" else 5)
			cfg["soft_timer_sec"] = 0 if t != "hard" else 75
		"word_builder":
			cfg["word_max_length"] = 3 if t == "easy" else (5 if t == "medium" else 10)
			cfg["max_hints"] = 3 if t == "easy" else (2 if t == "medium" else 1)

	return cfg


static func adjust_tier_after_round(current_tier: String, consecutive_first_try: int, wrong_count: int) -> String:
	var idx := TIERS.find(current_tier)
	if idx == -1:
		idx = 0
	# Never raise difficulty just for being fast; require sustained accuracy
	if wrong_count >= 2 and idx > 0:
		return TIERS[idx - 1]
	if consecutive_first_try >= 3 and wrong_count == 0 and idx < TIERS.size() - 1:
		return TIERS[idx + 1]
	return TIERS[idx]
