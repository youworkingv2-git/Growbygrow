# Test Report — Prompt 02
## English Adventure

| Field | Value |
|---|---|
| **Date** | 2026-11-26 |
| **Environment** | Windows (Static & File-Reference Verification; Godot 4 CLI binary not installed in local PATH) |

## 1. Checks Performed & Passed
| Check | Scope | Result |
|---|---|---|
| **JSON Schema & Syntax Validation** | All 7 `.json` files in `data/` (`worlds`, `areas`, `npcs`, `dialogue`, `quests`, `alphabet`, `vocabulary`) | **PASS (7/7 valid JSON)** |
| **Resource Path Integrity (`res://`)** | All `.tscn`, `.gd`, `.json`, and `project.godot` | **PASS (0 missing `res://` references after cleanup)** |
| **Autoload Configuration** | `project.godot` registers `EventBus`, `SaveManager`, `LocalizationManager`, `DialogueManager`, `QuestManager`, `InteractionManager`, `GameManager` | **PASS** |
| **Unlock & Anti-Duplicate Logic Review** | `GameManager.enter_area()` checks `SaveManager.is_area_unlocked()`; `QuestManager.complete_quest()` checks `is_quest_completed()` | **PASS (Code Verified)** |

## 2. Checks Not Executed Locally (Requires Godot 4 Editor / Runtime)
Because `godot` / `godot4` executable is not installed on the current machine, live runtime execution in Godot 4 could not be launched here. The following should be run immediately upon opening the project in **Godot 4.3+**:
- [ ] Run `boot.tscn` (F5) → verify Character Selection (Boy/Girl) → Welcome Village.
- [ ] Verify keyboard (`WASD`/Arrows, `E`) and Mobile Virtual Joystick + `Tương Tác` button.
- [ ] Complete Quest 01 → verify `alphabet_meadow` unlocks and persists after restart (`user://english_adventure_save.json`).
- [ ] Verify responsive layout at `1280x720` (Desktop) and `360x800` / `800x360` (Mobile).
