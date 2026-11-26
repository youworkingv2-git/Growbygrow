## Core Module

**Purpose:** Foundation of the entire game. Provides global services, event system, and state management used by all other modules.

**Key Scripts:**
- `game_manager.gd` – Singleton. Bootstraps the game, manages scene transitions, holds global game state.
- `event_bus.gd` – Singleton. Global signal hub for cross-module communication (Observer pattern).
- `state_manager.gd` – Manages application state machine (Boot → Auth → Home → Gameplay → etc.).
- `signal_definitions.gd` – Central file listing all EventBus signals with documentation.
- `constants.gd` – Game-wide constants (EXP tables, difficulty thresholds, etc.).
- `config_manager.gd` – Loads runtime config from environment (Supabase URL, etc.).

**Dependencies:** None (this module has no dependencies on other modules).

**Used By:** All other modules.

**Rules:**
- No learning logic here.
- No adventure logic here.
- This module only knows about system-level concerns.
- Must be stable; changes here affect everything.

**Key Signals (EventBus):**
```
game_state_changed(old_state, new_state)
scene_transition_requested(scene_path, transition_type)
error_occurred(error_code, error_message)
network_status_changed(is_online)
```
