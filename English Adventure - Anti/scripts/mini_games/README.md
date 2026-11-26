## Mini-Games Module

**Purpose:** Contains all mini-game implementations. Each game receives vocabulary/question data as parameters and knows nothing about the game world or quest system.

**Architecture:** All mini-games extend `MiniGameBase` which provides the common interface.

**Key Scripts:**
- `mini_game_manager.gd` – Launches mini-games, handles transitions, collects results.
- `mini_game_base.gd` – Abstract base class. Defines the interface all mini-games must implement.

**Mini-Games (MVP):**

| Script | Game Type | Skill Focus |
|--------|-----------|-------------|
| `word_hunt_game.gd` | Word Hunt | Reading + Recognition |
| `listening_mission_game.gd` | Listening Mission | Listening |
| `word_builder_game.gd` | Word Builder | Writing + Phonics |
| `sentence_builder_game.gd` | Sentence Builder | Grammar + Writing |
| `reading_challenge_game.gd` | Reading Challenge | Reading + Comprehension |

**MiniGameBase Interface:**
```gdscript
# Every mini-game MUST implement:
func initialize(questions: Array[QuestionData], config: MiniGameConfig) -> void
func start() -> void
func get_result() -> MiniGameResult
signal completed(result: MiniGameResult)
signal question_answered(question_id: String, is_correct: bool)
```

**RULES:**
1. Mini-games NEVER load data from files or databases.
2. Mini-games NEVER know which quest or world they belong to.
3. All content comes from the `initialize()` call.
4. Mini-games report results via signals and `get_result()`.
5. Difficulty is set via `MiniGameConfig`, not hardcoded.

**Dependencies:**
- Core Module (EventBus, signals)
- Audio Module (play feedback sounds)
- Localization Module (Vietnamese feedback text)

**Does NOT depend on:**
- Adventure Module
- Quest Module
- Backend Service
