# MINI-GAME REGISTRY (`data/minigames/minigame_registry.json`)

## 1. 8 Mini-Game Cốt Lõi (Playable)
| ID | Tên | Kỹ năng | Trạng thái | Nguồn dữ liệu Learning Engine |
|---|---|---|---|---|
| `listen_and_find` | Listen and Find | Listening | `playable_priority` | `world_01_vocab.json` |
| `word_builder` | Word Builder | Reading, Writing | `playable_priority` | `world_01_vocab.json` |
| `word_matching` | Word Matching | Reading, Vocabulary | `playable_priority` | `world_01_vocab.json` |
| `sentence_builder` | Sentence Builder | Reading, Writing, Grammar | `playable_priority` | `world_01_grammar.json`, `world_01_writing.json` |
| `sound_detective` | Sound Detective | Listening, Phonics | `playable_extended` | `alphabet_a_z.json`, `world_01_vocab.json` |
| `speaking_hero` | Speaking Hero | Speaking | `playable_extended` | `world_01_speaking.json`, `world_01_vocab.json` |
| `memory_quest` | Memory Quest | Listening, Reading, Vocabulary | `playable_extended` | `world_01_vocab.json` |
| `dialogue_adventure` | Dialogue Adventure | Listening, Speaking, Reading | `playable_extended` | `dialogue_adventures.json` + `world_01_vocab.json` |

## 2. 8 Template Mở Rộng (Extensible Roadmap — Prompt 06+)
`spelling_challenge`, `word_racing`, `picture_quiz`, `listening_maze`, `grammar_puzzle`, `conversation_battle`, `reading_adventure`, `boss_challenge` được khai báo sẵn trong `minigame_registry.json` với `availability_status: "planned_template"`, cho phép thêm controller mới trong `MiniGameFactory` mà không cần sửa `MiniGameManager`.
