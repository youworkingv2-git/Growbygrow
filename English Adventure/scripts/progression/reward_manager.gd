extends Node
## Autoload RewardManager: unified idempotent reward ledger across Quests, Mini-Games,
## Objects, Lessons, and Achievements. Prevents duplicate claims and queues sync events.

var _evaluating_achievements: bool = false


func _ready() -> void:
	EventBus.quest_reward_claimed.connect(func(_qid: String, _r: Dictionary) -> void: evaluate_achievements())
	EventBus.minigame_completed.connect(func(_mg: String, _r: Dictionary) -> void: evaluate_achievements())
	EventBus.learning_activity_answered.connect(func(_a: Dictionary) -> void: evaluate_achievements())
	EventBus.area_unlocked.connect(func(_aid: String) -> void: evaluate_achievements())
	EventBus.item_collected.connect(func(_iid: String, _q: int) -> void: evaluate_achievements())


func has_claimed(reward_key: String) -> bool:
	return GameStateManager.claimed_reward_keys.has(reward_key)


func grant_reward(
	reward_key: String,
	source_type: String,
	source_id: String,
	reward_cfg: Dictionary,
	allow_repeat: bool = false
) -> Dictionary:
	if not allow_repeat and not reward_key.is_empty() and has_claimed(reward_key):
		AppLogger.info("RewardManager", "Blocked duplicate reward claim: " + reward_key)
		return {
			"granted": false,
			"duplicate_blocked": true,
			"exp_granted": 0,
			"gold_granted": 0,
			"stars_granted": 0,
			"items_granted": []
		}

	var exp_amt := maxi(0, int(reward_cfg.get("exp", 0)))
	var gold_amt := maxi(0, int(reward_cfg.get("gold", 0)))
	var stars_amt := maxi(0, int(reward_cfg.get("stars", 0)))
	var items_granted: Array[Dictionary] = []

	if exp_amt > 0 or gold_amt > 0 or stars_amt > 0:
		GameStateManager.add_exp_and_gold(exp_amt, gold_amt, stars_amt)

	for item_var in reward_cfg.get("items", []):
		if typeof(item_var) == TYPE_DICTIONARY:
			var it := (item_var as Dictionary).duplicate(true)
			GameStateManager.add_item(it)
			items_granted.append(it)

	for flag_name in reward_cfg.get("set_flags", []):
		GameStateManager.flags[str(flag_name)] = true

	if not reward_key.is_empty() and not GameStateManager.claimed_reward_keys.has(reward_key):
		GameStateManager.claimed_reward_keys.append(reward_key)

	var ledger_entry := {
		"reward_id": reward_key if not reward_key.is_empty() else ("%s:%s:%d" % [source_type, source_id, Time.get_ticks_msec()]),
		"source_type": source_type,
		"source_id": source_id,
		"exp": exp_amt,
		"gold": gold_amt,
		"stars": stars_amt,
		"items": items_granted,
		"claim_status": "claimed",
		"granted_at_utc": Time.get_datetime_string_from_system(true)
	}
	GameStateManager.reward_history.append(ledger_entry)
	if GameStateManager.reward_history.size() > 150:
		var trimmed: Array[Dictionary] = []
		for i in range(GameStateManager.reward_history.size() - 150, GameStateManager.reward_history.size()):
			trimmed.append(GameStateManager.reward_history[i])
		GameStateManager.reward_history = trimmed

	SaveLoadManager.enqueue_sync_event("reward_granted", ledger_entry)
	EventBus.reward_granted.emit(ledger_entry)
	GameStateManager.evaluate_all_unlocks(true)
	evaluate_achievements()
	GameStateManager.save_now("reward_" + source_type)

	return {
		"granted": true,
		"duplicate_blocked": false,
		"exp_granted": exp_amt,
		"gold_granted": gold_amt,
		"stars_granted": stars_amt,
		"items_granted": items_granted,
		"ledger_entry": ledger_entry
	}


func evaluate_achievements() -> void:
	if _evaluating_achievements:
		return
	_evaluating_achievements = true
	var newly := AchievementManager.check_newly_unlocked()
	for ach in newly:
		var aid := str(ach.get("id", ""))
		if aid.is_empty() or GameStateManager.unlocked_achievements.has(aid):
			continue
		GameStateManager.unlocked_achievements.append(aid)
		var title := LocalizationManager.pick_text(ach, "title")
		var rw: Dictionary = ach.get("rewards", {})
		grant_reward("achievement:" + aid, "achievement", aid, rw, false)
		EventBus.achievement_unlocked.emit(aid, title)
	_evaluating_achievements = false
