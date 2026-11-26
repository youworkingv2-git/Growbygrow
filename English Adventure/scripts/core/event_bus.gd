extends Node
## Global signal bus decoupling Adventure, Character, Quest, Learning, MiniGame,
## Reward, Inventory, World Progression, UI, Audio, and Save/Load.

signal ui_locale_changed(locale: String)
signal viewport_breakpoint_changed(breakpoint_name: String, viewport_size: Vector2)
signal settings_changed()

signal character_selected(gender: String, nickname: String)
signal area_entered(area_id: String)
signal area_unlocked(area_id: String)
signal area_locked_attempted(area_id: String, reason_vi: String)
signal region_unlocked(region_id: String)
signal region_completed(region_id: String)
signal chapter_completed(chapter_id: String)

signal interactable_focused(interactable_data: Dictionary)
signal interactable_unfocused()
signal interaction_triggered(interactable_id: String, interactable_type: String)
signal player_interacted_with_npc(npc_id: String)

signal dialogue_started(dialogue_id: String)
signal dialogue_ended(dialogue_id: String)
signal dialogue_completed(dialogue_id: String)

signal buddy_state_changed(state_name: String, message: String)
signal npc_met(npc_id: String)

signal quest_available(quest_id: String)
signal quest_started(quest_id: String)
signal quest_accepted(quest_id: String)
signal quest_step_updated(quest_id: String, step_index: int)
signal quest_objective_updated(quest_id: String, objective_id: String, current_count: int, target_count: int)
signal quest_completed(quest_id: String, rewards: Dictionary)
signal quest_reward_claimed(quest_id: String, rewards: Dictionary)

signal item_collected(item_id: String, quantity: int)
signal inventory_item_used(item_id: String, context: Dictionary)
signal level_up(new_level: int)
signal achievement_unlocked(achievement_id: String, title: String)
signal reward_granted(reward_entry: Dictionary)
signal progress_updated()
signal toast_requested(message: String, kind: String)
signal pause_toggled(is_paused: bool)

signal save_requested(reason: String)
signal save_completed(success: bool)
signal sync_status_changed(is_online: bool, pending_count: int)

# Extension hook for Learning Engine & Mini-game launch
signal learning_hook_requested(hook_payload: Dictionary)
signal lesson_started(lesson_id: String)
signal lesson_completed(lesson_id: String, summary: Dictionary)
signal learning_activity_started(activity_id: String, skill: String)
signal learning_activity_completed(activity_id: String, skill: String, is_correct: bool)
signal learning_activity_answered(attempt_record: Dictionary)
signal learning_knowledge_mastered(knowledge_id: String, mastery_score: float)
signal learning_progress_updated()

# Mini-Game System signals (Prompt 05)
signal minigame_started(minigame_id: String, context: Dictionary)
signal minigame_answered(minigame_id: String, attempt_record: Dictionary)
signal minigame_completed(minigame_id: String, result: Dictionary)
