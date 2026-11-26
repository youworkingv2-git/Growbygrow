class_name QuestRewardManager
extends RefCounted
## Bridges Quest Completion -> RewardManager with strict single-claim enforcement.


static func claim_quest_reward(quest_id: String, quest_def: Dictionary) -> Dictionary:
	if GameStateManager.claimed_quests.has(quest_id) or RewardManager.has_claimed("quest:" + quest_id):
		AppLogger.info("QuestRewardManager", "Quest reward already claimed: " + quest_id)
		return { "granted": false, "duplicate_blocked": true }

	if not GameStateManager.completed_quests.has(quest_id):
		AppLogger.warn("QuestRewardManager", "Cannot claim reward before quest completion: " + quest_id)
		return { "granted": false, "not_completed": true }

	var rewards: Dictionary = quest_def.get("rewards", {})
	var res := RewardManager.grant_reward("quest:" + quest_id, "quest", quest_id, rewards, false)
	if bool(res.get("granted", false)):
		if not GameStateManager.claimed_quests.has(quest_id):
			GameStateManager.claimed_quests.append(quest_id)
		if not GameStateManager.rewarded_quests.has(quest_id):
			GameStateManager.rewarded_quests.append(quest_id)
		GameStateManager.evaluate_all_unlocks(true)
		GameStateManager.save_now("quest_claimed_" + quest_id)
		EventBus.quest_reward_claimed.emit(quest_id, rewards)
	return res
