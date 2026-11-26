class_name MiniGameReward
extends RefCounted
## Evaluates configurable mini-game rewards with idempotent duplicate-reward protection.


static func grant_rewards(minigame_id: String, summary: Dictionary, reward_config: Dictionary, quest_context_id: String = "") -> Dictionary:
	var flag_key := "mg_first_reward_" + minigame_id
	var already_first_rewarded := bool(GameStateManager.flags.get(flag_key, false))
	var exp_amt := 0
	var gold_amt := 0
	var crystal_granted := {}

	var accuracy_ratio := float(summary.get("accuracy", 0.0)) / 100.0
	var min_acc := float(reward_config.get("min_accuracy_for_crystal", 0.6))

	# Prevent duplicate quest/first-time reward spamming
	if not quest_context_id.is_empty():
		var q_flag := "mg_quest_reward_" + quest_context_id + "_" + minigame_id
		if bool(GameStateManager.flags.get(q_flag, false)):
			already_first_rewarded = true
		else:
			GameStateManager.flags[q_flag] = true

	if not already_first_rewarded:
		exp_amt = int(reward_config.get("exp", 25))
		gold_amt = int(reward_config.get("gold", 10))
		GameStateManager.flags[flag_key] = true
	else:
		exp_amt = int(reward_config.get("replay_exp", 8))
		gold_amt = int(reward_config.get("replay_gold", 4))

	if exp_amt > 0 or gold_amt > 0:
		GameStateManager.add_exp_and_gold(exp_amt, gold_amt)

	var crystal_cfg: Variant = reward_config.get("crystal_item", {})
	if typeof(crystal_cfg) == TYPE_DICTIONARY and not (crystal_cfg as Dictionary).is_empty():
		var cdict := crystal_cfg as Dictionary
		var cid := str(cdict.get("id", ""))
		var one_time_c := bool(reward_config.get("one_time_crystal", true))
		var already_has := GameStateManager.inventory.has(cid)
		if (not one_time_c or not already_has) and accuracy_ratio >= min_acc:
			GameStateManager.add_item(cdict)
			crystal_granted = cdict.duplicate(true)

	GameStateManager.record_minigame_result(
		minigame_id,
		int(summary.get("learning_score", 0)),
		int(summary.get("game_score", 0)),
		int(summary.get("stars", 1))
	)
	GameStateManager.save_now("minigame_complete_" + minigame_id)

	return {
		"exp_granted": exp_amt,
		"gold_granted": gold_amt,
		"crystal_granted": crystal_granted,
		"is_replay": already_first_rewarded
	}
