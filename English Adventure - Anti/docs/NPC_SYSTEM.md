# NPC System (Prompt 02)
## English Adventure

## 1. Architecture (`scripts/character/npc_controller.gd`)
- Data-driven via `data/npcs/npcs_world1.json`.
- Each NPC node (`scenes/characters/npc.tscn`) exposes `@export var npc_id: String` and loads its name, sprite, dialogue ID, quest links, and `appear_condition` at runtime.

## 2. Implemented NPCs (Alphabet Island)
| NPC ID | Name | Area | Role | Appear Condition |
|---|---|---|---|---|
| `professor_owl` | Professor Owl | Welcome Village | Main guide & teacher | `always` |
| `lily` | Lily | Welcome Village | Villager needing help with lost letters | `always` |
| `rocky` | Rocky | Letter Cave | Cave creature giving Shadow Gate clue | `always` |
| `crystal_guardian` | Crystal Guardian | Crystal Lake | Guardian unlocking Shadow Gate | `area_unlocked: crystal_lake` |
