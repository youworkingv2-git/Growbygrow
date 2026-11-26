# Character System (Prompt 02)
## English Adventure

## 1. Main Player Character (`scripts/character/player_controller.gd`)
- **Selection:** Boy Adventurer (`boy`) or Girl Adventurer (`girl`) via `scenes/authentication/character_select.tscn`.
- **Persistence:** Saved in `SaveManager.player_data["avatar_type"]` and `player_name`. Zero gameplay/stat differences between genders.
- **Controls:**
  - **Desktop:** `W/A/S/D` or Arrow Keys to move, `Shift` to run, `Space` to jump state, `E` to interact.
  - **Mobile:** On-screen Virtual Joystick (bottom-left) + `Tương Tác` button (bottom-right) in `AreaHUD`.
- **Animation State Structure:** `IDLE`, `WALK`, `RUN`, `JUMP`, `INTERACT`, `CELEBRATE`, `HURT` (currently using procedural bobbing + sprite flip, ready for `AnimatedSprite2D` frames).

## 2. Companion Dragon — Buddy (`scripts/character/buddy_controller.gd`)
- Smoothly follows the player (`lerp` with `follow_offset`) and faces the player.
- **Supported States:** `idle`, `happy`, `sad`, `surprised`, `thinking`, `talking`, `celebrating`.
- Reacts automatically to `EventBus.dialogue_started`, `EventBus.dialogue_ended`, `EventBus.quest_completed`, and `EventBus.buddy_state_changed`.
