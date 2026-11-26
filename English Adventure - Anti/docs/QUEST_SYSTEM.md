# Quest System (Prompt 02)
## English Adventure

## 1. Architecture (`scripts/quest/quest_manager.gd`)
- Data-driven via `data/quests/world_1/quests_world1.json`.
- **States:** `Locked`, `Available`, `Active`, `Completed`.
- Listens to `EventBus.interaction_triggered` and `EventBus.area_entered` to advance quest steps automatically.
- **Anti-Duplicate Rewards:** `complete_quest()` verifies `not is_quest_completed(quest_id)` before awarding EXP, Gold, Magic Crystals, or unlocking areas.

## 2. Sample Quests Implemented
1. **`quest_01_new_adventure` (Quest 01 – A New Adventure):** Talk to Professor Owl → Inspect Village Signpost → Unlocks `alphabet_meadow` (+50 EXP, +20 Gold, +1 Crystal).
2. **`quest_02_lost_letters` (Quest 02 – Find the Lost Letters):** Visit `alphabet_meadow` → Inspect Letter Stone A & B → Unlocks `letter_cave` (+80 EXP, +35 Gold, +1 Crystal).
3. **`quest_03_mysterious_gate` (Quest 03 – The Mysterious Gate):** Talk to Rocky in `letter_cave` → Talk to Crystal Guardian in `crystal_lake` → Unlocks `shadow_gate` (+120 EXP, +50 Gold, +2 Crystals).
