extends Node
## Global signal bus decoupling Adventure, Character, Quest, UI, Progression, and Save/Load.

signal ui_locale_changed(locale: String)
signal viewport_breakpoint_changed(breakpoint_name: String, viewport_size: Vector2)

signal character_selected(gender: String, nickname: String)
signal area_entered(area_id: String)
signal area_unlocked(area_id: String)
signal area_locked_attempted(area_id: String, reason_vi: String)

signal interactable_focused(interactable_data: Dictionary)
signal interactable_unfocused()
signal interaction_triggered(interactable_id: String, interactable_type: String)

signal dialogue_started(dialogue_id: String)
signal dialogue_ended(dialogue_id: String)

signal buddy_state_changed(state_name: String, message: String)
signal npc_met(npc_id: String)

signal quest_started(quest_id: String)
signal quest_step_updated(quest_id: String, step_index: int)
signal quest_completed(quest_id: String, rewards: Dictionary)

signal item_collected(item_id: String, quantity: int)
signal progress_updated()
signal toast_requested(message: String, kind: String)

signal save_requested(reason: String)
signal save_completed(success: bool)

# Extension hook for Prompt 03+ Learning Engine & Mini-game launch
signal learning_hook_requested(hook_payload: Dictionary)
