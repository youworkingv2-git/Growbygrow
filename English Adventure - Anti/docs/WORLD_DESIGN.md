# World Design — Alphabet Island (Prompt 02)
## English Adventure

## 1. Narrative Context
The world of **Linguara** has been silenced by **The Silent Shadow**, stealing letters, words, and sounds. **Alphabet Island** (World 1) is the first region players restore by collecting **Magic Crystals** and unlocking sealed areas.

## 2. World Architecture (Expandable to 6 Worlds)
Defined in `data/worlds/worlds.json`:
- **Active in MVP:** `world_1` — Alphabet Island (`welcome_village` default spawn)
- **Reserved for Future Phases:** `world_2` (Vocabulary Forest), `world_3` (Sentence Kingdom), `world_4` (Listening Ocean), `world_5` (Speaking City), `world_6` (Challenge Kingdom)

## 3. The 5 Areas of Alphabet Island
Defined in `data/areas/alphabet_island_areas.json`:

| # | Area ID | Name | Unlock Condition | Key Entities |
|---|---|---|---|---|
| 1 | `welcome_village` | Welcome Village | `default_unlocked` | Professor Owl, Lily, Signpost, Portal to Meadow |
| 2 | `alphabet_meadow` | Alphabet Meadow | Complete `quest_01_new_adventure` | Letter Stone A, Letter Stone B, Portals |
| 3 | `letter_cave` | Letter Cave | Complete `quest_02_lost_letters` | Rocky, Treasure Chest (Magic Crystal), Portals |
| 4 | `crystal_lake` | Crystal Lake | Visit `letter_cave` | Crystal Guardian, Magic Crystal, Portals |
| 5 | `shadow_gate` | The Shadow Gate | Complete `quest_03_mysterious_gate` | The Shadow Gate (Boss seal), Portal back |

## 4. Scene & Boundary Design
All 5 scenes reside in `scenes/adventure/alphabet_island/*.tscn` using `Node2D` (`y_sort_enabled = true`), `StaticBody2D` perimeter walls, `Player`, `Buddy`, `AreaHUD`, and `DialogueBox`.
