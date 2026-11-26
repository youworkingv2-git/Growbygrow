extends Node
## Global Signal Hub for English Adventure.
## Decouples Adventure Engine, Learning Engine, UI, and Save/Load.

# Application & Scene Lifecycle
signal game_state_changed(old_state: String, new_state: String)
signal area_change_requested(area_id: String, spawn_pos: Vector2)
signal area_entered(area_id: String)
signal area_unlocked(area_id: String)

# Character & Player
signal player_gender_selected(gender: String, player_name: String)
signal player_moved(position: Vector2)
signal buddy_state_changed(state: String)
signal buddy_hint_requested(text_vi: String)

# Interaction & Dialogue
signal interactable_nearby(interactable: Node)
signal interactable_left(interactable: Node)
signal interaction_triggered(interactable_id: String)
signal dialogue_started(dialogue_id: String)
signal dialogue_ended(dialogue_id: String, on_complete_event: String)

# Quest System
signal quest_started(quest_id: String)
signal quest_step_updated(quest_id: String, step_index: int)
signal quest_completed(quest_id: String, reward: Dictionary)
signal quest_log_updated()

# Save / Load
signal save_completed(success: bool)
signal load_completed(success: bool)
signal error_occurred(error_code: String, message_vi: String)
