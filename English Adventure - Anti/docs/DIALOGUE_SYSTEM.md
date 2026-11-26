# Dialogue System (Prompt 02)
## English Adventure

## 1. Architecture
- **Manager:** `DialogueManager` (`scripts/dialogue/dialogue_manager.gd`, Autoload)
- **UI:** `DialogueBox` (`scenes/ui/dialogue_box.tscn`, `scripts/ui/dialogue_box_ui.gd`)
- **Data:** `data/dialogue/dialogues_world1.json`

## 2. Features
- Bilingual display: English line (`TextEnLabel` in gold) + Vietnamese explanation (`TextViLabel` with typewriter effect).
- Speaker avatar & name dynamically loaded per line (supports multi-speaker conversations between Professor Owl, Buddy, and NPCs).
- `Tiếp tục` button skips typing or advances to next line; `Đóng` button closes safely.
- Player movement is paused while `DialogueManager.is_active == true`.
