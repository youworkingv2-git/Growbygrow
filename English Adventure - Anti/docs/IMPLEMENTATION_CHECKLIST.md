# Implementation Checklist (For Prompt 02)
## English Adventure — MVP Build

This checklist bridges **Prompt 01 (Architecture, Design & Skeleton)** and **Prompt 02 (Implementation)**. Every item below should be executed in order while adhering to the architectural boundaries in `docs/ARCHITECTURE.md` and `docs/DECISIONS.md`.

---

## 1. Pre-Implementation Verification (Completed in Prompt 01)
- [x] `docs/PRD.md`, `docs/GDD.md`, `docs/ARCHITECTURE.md` aligned on MVP scope (1 World: Alphabet Island, 5 Mini-Games, 26 Letters, 100–150 Words, 15–20 Quests).
- [x] `docs/DATABASE_SCHEMA.md`, `docs/ERD.md`, and `supabase/migrations/001_initial_schema.sql` aligned.
- [x] `docs/LEARNING_CONTENT_SPEC.md` and `data/` JSON schemas aligned (letter name vs. letter sound strictly separated).
- [x] `project.godot`, `.env.example`, `.gitignore`, and modular folder structure created.

---

## 2. Phase 1 Checklist — Core & Backend Foundation
- [ ] Configure Godot 4 autoloads in `project.godot` (`GameManager`, `EventBus`, `StateManager`, `ConfigManager`, `AudioManager`, `LocalizationManager`).
- [ ] Implement `scripts/core/config_manager.gd` to read `SUPABASE_URL` and `SUPABASE_ANON_KEY` from environment/config (never hardcode keys).
- [ ] Implement `scripts/core/event_bus.gd` with all signals defined in `docs/ARCHITECTURE.md`.
- [ ] Implement `scripts/services/supabase_client.gd` and `auth_service.gd` (Anonymous Guest + Email Auth).
- [ ] Implement `scripts/save_load/save_manager.gd` (local JSON save + offline sync queue).
- [ ] Apply `supabase/migrations/001_initial_schema.sql` to Supabase dev project and test RLS policies.
- [ ] Set up GUT / GdUnit4 in `tests/` and write first unit tests for `SaveManager` and `ConfigManager`.

---

## 3. Phase 2 Checklist — World, Characters & Quests (Prompt 02 Completed)
- [x] Build `scenes/boot/boot.tscn`, `scenes/authentication/character_select.tscn`.
- [x] Implement `scripts/core/game_manager.gd`, `event_bus.gd`, `scripts/save_load/save_manager.gd`, and `scenes/world_map/world_map.tscn`.
- [x] Build Alphabet Island 5 area scenes (`scenes/adventure/alphabet_island/*.tscn`).
- [x] Implement `scripts/character/player_controller.gd` (Boy/Girl), `buddy_controller.gd`, `npc_controller.gd`.
- [x] Implement `scripts/quest/quest_manager.gd`, `scripts/dialogue/dialogue_manager.gd`, and `scripts/interaction/interaction_manager.gd`.
- [x] Author 3 sample framework quests (`data/quests/world_1/quests_world1.json`) and 4 NPCs (`data/npcs/npcs_world1.json`).
- [ ] Expand to 15–20 full learning quests once Learning Engine is wired in Prompt 03.

---

## 4. Phase 3 Checklist — Learning Engine, Content & Audio
- [ ] Implement `scripts/learning/learning_engine.gd`, `content_loader.gd`, `skill_router.gd` (zero dependency on `AdventureModule`).
- [ ] Implement `scripts/vocabulary/vocab_database.gd` and `scripts/grammar/grammar_engine.gd`.
- [ ] Implement `scripts/audio/audio_manager.gd` (music, SFX, `en-US` voice playback with replay support).
- [ ] Implement `scripts/assessment/placement_test.gd` (Initial Assessment screen).
- [ ] Implement `scripts/localization/localization_manager.gd` loading `localization/vi/*.csv`.
- [ ] Expand `data/alphabet/alphabet_data.json` to all 26 letters and `data/vocabulary/world_1/` to 100–150 words.
- [ ] Write and run `tools/content_validator/validate_vocabulary.py` and `validate_alphabet.py`.

---

## 5. Phase 4 Checklist — 5 MVP Mini-Games + Speaking Stub
- [ ] Implement `scripts/mini_games/mini_game_base.gd` and `mini_game_manager.gd`.
- [ ] Implement **Word Hunt** (`scenes/mini_games/word_hunt/`).
- [ ] Implement **Listening Mission** (`scenes/mini_games/listening_mission/`).
- [ ] Implement **Word Builder** (`scenes/mini_games/word_builder/`).
- [ ] Implement **Sentence Builder** (`scenes/mini_games/sentence_builder/`).
- [ ] Implement **Reading Challenge** (`scenes/mini_games/reading_challenge/`).
- [ ] Implement Speaking MVP stub (Listen & Repeat + Self-Rating) and Boss Battle wrapper (`Shadow Silencer`).
- [ ] Verify via integration test that `word_001` (`"apple"`) runs across all 5 mini-games without duplicated data.

---

## 6. Phase 5 Checklist — Progression, Rewards & SRS Review
- [ ] Implement `scripts/progression/progress_manager.gd` (EXP, Level, Gold, 1–3 Stars, anti-grinding checks).
- [ ] Implement `scripts/reward/reward_manager.gd` and `achievement_system.gd`.
- [ ] Implement `scripts/inventory/inventory_manager.gd`.
- [ ] Implement `scripts/review/spaced_repetition_engine.gd` (SM-2 algorithm updating `vocabulary_mastery`).
- [ ] Build `scenes/rewards/reward_screen.tscn`, `scenes/profile/learning_dashboard.tscn`, `inventory.tscn`, `achievements.tscn`.

---

## 7. Phase 6 & 7 Checklist — Responsive UI, Exports & QA
- [ ] Verify all 17 MVP screens across Mobile Portrait (360x800), Mobile Landscape (800x360), Tablet (768x1024), and Desktop Web (1280x800).
- [ ] Configure Godot export presets for Android, iOS, and Web.
- [ ] Test full offline gameplay → reconnect → Supabase delta sync.
- [ ] Run performance profiling (target 60 FPS on mid-range Android) and COPPA/privacy audit (no PII, no secrets).
