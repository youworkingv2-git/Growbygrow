# World Map System (Prompt 02)
## English Adventure

## 1. Scene & Script
- **Scene:** `scenes/world_map/world_map.tscn`
- **Script:** `scripts/ui/world_map_ui.gd`
- **Data:** `data/areas/alphabet_island_areas.json`

## 2. Features
- Displays all 5 areas of **Alphabet Island** with live status badges: `Locked`, `Unlocked`, `In Progress`, `Completed`.
- Clicking any area updates the Detail Panel (`DetailTitle`, `DetailStatus`, `DetailDesc`).
- **Lock Enforcement:** Locked areas disable the `Khám phá ngay!` button and show a Vietnamese unlock hint; `GameManager.enter_area()` also enforces `SaveManager.is_area_unlocked()` so direct scene calls cannot bypass locks.
- Displays Player Stats (Name, EXP, Gold, Magic Crystals) and active Quest Summary.
