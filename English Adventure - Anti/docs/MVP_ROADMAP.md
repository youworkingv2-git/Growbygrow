# MVP Development Roadmap
## English Adventure

| Field | Value |
|---|---|
| **Document Version** | 1.0 |
| **Date** | 2026-11-26 |
| **Estimated Total Duration** | 17–22 Weeks (approx. 4.5–5.5 months) |
| **MVP Scope** | 1 World (Alphabet Island), 5 Mini-Games, 26 Letters, 100–150 Vocab, 15–20 Quests |

---

## Overall Timeline & Team

### Recommended Team
- **1–2 Godot 4 / GDScript Developers** (Architecture, Adventure, Mini-Games, UI)
- **1 Backend / Tools Engineer** (Supabase, Migrations, Sync, Content Validator)
- **1 2.5D Cartoon Artist / Animator** (Characters, Alphabet Island, UI assets)
- **1 Educational Content Creator** (Vietnamese/English copy, 150 words, audio recording/curation)
- **1 QA Engineer** (Cross-platform testing, offline/sync, child playtesting)

---

## Phase 1: Architecture, Project Setup & Core Systems
**Goal:** Establish the Godot 4 modular skeleton, Core singletons, Supabase backend, and offline-first Save/Load pipeline.  
**Duration Estimate:** 2–3 Weeks  
**Can Parallelize:** Yes — Godot Core setup and Supabase schema/migrations can run in parallel.

### Tasks
1. Finalize `project.godot` settings (mobile renderer, canvas_items stretch, input maps).
2. Implement **Core Module**: `GameManager`, `EventBus` (SignalBus), `StateManager`, `ConfigManager` (reads `.env` / runtime config without hardcoding secrets).
3. Deploy `supabase/migrations/001_initial_schema.sql` and verify RLS policies.
4. Implement **Backend Service Module**: `SupabaseClient`, `AuthService` (anonymous guest + email login).
5. Implement **Save/Load Module**: Local JSON save + offline sync queue.
6. Set up automated unit test runner (GUT or GdUnit4) in `tests/`.

### Deliverables
- Bootable Godot 4 project transitioning Splash → Auth (Guest/Email) → Empty Home stub.
- Live Supabase dev project with RLS verified.

### Dependencies
- Approved `ARCHITECTURE.md` and `DATABASE_SCHEMA.md`.

### Acceptance Criteria
- Guest login works offline and online; no API secret keys in repository.
- Save state persists across app restarts.

### Potential Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Supabase HTTP auth token refresh edge cases in Godot | Medium | High | Encapsulate token refresh + retry in `SupabaseClient` early |

---

## Phase 2: World Map, Characters & Quest System
**Goal:** Build Alphabet Island exploration, playable Boy/Girl explorer, Buddy companion, and the Quest/Dialogue engine.  
**Duration Estimate:** 2–3 Weeks  
**Can Parallelize:** Yes — Art assets for Alphabet Island & characters can be produced alongside QuestManager logic.

### Tasks
1. Implement **Adventure Module**: `WorldManager`, `MapController`, 4 regions of Alphabet Island with 2.5D parallax.
2. Implement **Character Module**: `PlayerController` (Boy/Girl), `BuddyController`, `NPCController`, animation state machine.
3. Implement **Quest Module**: `QuestManager`, `QuestTracker`, `DialogueSystem` reading from `data/quests/world_1/`.
4. Author 15–20 quest JSON definitions for Alphabet Island.

### Deliverables
- Playable 2.5D Alphabet Island where player walks, talks to Buddy/NPCs, and triggers quest steps.

### Dependencies
- Phase 1 Core Module & EventBus.

### Acceptance Criteria
- Player can navigate all 4 regions, trigger dialogues, and transition between `dialogue` and `mini_game` quest steps.

### Potential Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| 2.5D depth sorting / parallax glitches on varying aspect ratios | Medium | Medium | Test on 16:9, 20:9, and 4:3 viewports from week 1 |

---

## Phase 3: Learning Engine, Vocabulary & Audio
**Goal:** Build the independent Learning Engine, load 26 letters + 100–150 words from JSON, integrate Audio, and implement Initial Assessment.  
**Duration Estimate:** 3–4 Weeks  
**Can Parallelize:** Yes — Content creation & audio recording can run in parallel with `LearningEngine` coding.

### Tasks
1. Implement **Learning Module**: `LearningEngine`, `ContentLoader`, `SkillRouter`, `LearningSession`.
2. Implement **Vocabulary** & **Grammar** modules loading from `data/`.
3. Implement **Audio Module**: `AudioManager` with pre-loaded `en-US` audio + cache.
4. Implement **Assessment Module**: 5–8 question adaptive Initial Assessment.
5. Implement **Localization Module**: Vietnamese UI strings (`localization/vi/`).
6. Run `tools/content_validator/` on all 26 letters + 100–150 MVP words.

### Deliverables
- Verified JSON dataset (26 letters, 100–150 words, 10–15 sentence structures) + working AudioManager + Initial Assessment flow.

### Dependencies
- Phase 1 Core Module.

### Acceptance Criteria
- 100% of MVP vocabulary passes automated validation (IPA, Vietnamese meaning, audio, image).
- `LearningEngine` has zero imports/references to `AdventureModule`.

### Potential Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Audio asset size bloating Web/Mobile build | High | Medium | Compress speech MP3/OGG to mono 64kbps; lazy-load optional assets |

---

## Phase 4: Mini-Games (5 MVP Games)
**Goal:** Implement `MiniGameBase` and all 5 required mini-games fed purely by `LearningEngine` parameters.  
**Duration Estimate:** 3–4 Weeks  
**Can Parallelize:** Yes — Once `MiniGameBase` is locked, individual mini-games can be built in parallel.

### Tasks
1. Implement `MiniGameBase` & `MiniGameManager`.
2. Build **Word Hunt** (scene object finding).
3. Build **Listening Mission** (audio-to-choice).
4. Build **Word Builder** (letter tiles + phonics blending).
5. Build **Sentence Builder** (word tile ordering).
6. Build **Reading Challenge** (illustrated passage + tap-to-hear + comprehension).
7. Add Speaking MVP stub (Listen & Repeat + Self-Rating) inside optional quest steps.
8. Add Boss Battle flow (multi-phase wrapper chaining Listening → Word Builder → Sentence Builder).

### Deliverables
- All 5 mini-games playable standalone and inside quests using the same shared vocabulary pool.

### Dependencies
- Phase 2 Quest System + Phase 3 Learning Engine & Audio.

### Acceptance Criteria
- The same word (e.g., `"apple"`) runs cleanly across all 5 mini-games with zero duplicated data.

### Potential Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Drag-and-drop UX feels finicky for 10-year-olds on small screens | Medium | High | Support **both** tap-to-place and drag-and-drop in Word/Sentence Builder |

---

## Phase 5: Progression, Rewards & Review System
**Goal:** Connect learning results to EXP, Gold, Stars, Magic Crystals, Achievements, and SM-2 Spaced Repetition.  
**Duration Estimate:** 2 Weeks  
**Can Parallelize:** Partly — Achievements/Inventory UI can be built alongside SRS logic.

### Tasks
1. Implement **Progress Module** (EXP curve, Level-up, Stars, anti-grinding checks).
2. Implement **Reward Module** & **Inventory Module** (20+ achievements, Magic Crystals, cosmetics).
3. Implement **Review Module** (SM-2 algorithm, `vocabulary_mastery`, daily review queue).
4. Wire **Learning Dashboard** data.

### Deliverables
- End-to-end progression loop: Quest → Rewards → Mastery tracking → Next-day SRS Review.

### Dependencies
- Phase 4 Mini-Games + Phase 3 Assessment.

### Acceptance Criteria
- Mastery level cannot be farmed by repeating one easy mini-game; SRS schedules future reviews accurately.

### Potential Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Offline/online sync conflicts on XP or inventory | Medium | Medium | Use idempotent quest completion keys + max-progress merge strategy |

---

## Phase 6: Responsive UI & Multi-Platform Polish
**Goal:** Implement all 17 MVP screens with true responsive layouts for Mobile Portrait, Landscape, Tablet, and Desktop Web.  
**Duration Estimate:** 3 Weeks  
**Can Parallelize:** Yes — Export preset configuration and screen polish can run in parallel.

### Tasks
1. Polish all 17 MVP screens per `UI_UX_SPEC.md` (excluding Parent Dashboard).
2. Implement responsive breakpoints (Portrait bottom nav vs. Desktop/Tablet side rail).
3. Configure Godot export presets for **Android (AAB/APK)**, **iOS (Xcode)**, and **Web (HTML5/WASM)**.
4. Optimize textures (ETC2/ASTC) and target 60 FPS on mid-range Android.

### Deliverables
- Playable builds on Android, iOS, and Web browsers.

### Dependencies
- Phases 2–5 complete.

### Acceptance Criteria
- Desktop Web layout uses proper multi-column/side-rail UI (not a stretched phone screen).
- Stable 60 FPS on mid-range Android test device.

### Potential Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Godot 4 Web export audio/microphone quirks in Safari/iOS | High | Medium | Test Web build early; gate mic recording gracefully if browser denies permissions |

---

## Phase 7: QA, Optimization & MVP Release
**Goal:** Validate stability, offline/online sync, educational effectiveness with target-age testers, and ship MVP.  
**Duration Estimate:** 2–3 Weeks  
**Can Parallelize:** No — sequential stabilization and release gate.

### Tasks
1. Execute full QA regression test plan (unit, integration, offline/online transitions).
2. Conduct beta playtest with 5–10 Vietnamese children aged 9–11 (using synthetic test accounts—no real PII).
3. Fix UX friction, audio timing, and performance bugs from beta.
4. Prepare store listings, privacy policy (COPPA/child-safe), and deploy Web + Mobile MVP.

### Deliverables
- Production-ready MVP v0.1.0 + Beta Test Report.

### Acceptance Criteria (MVP Success Metrics)
1. **Engagement:** Average session length > 15 minutes; Day-7 retention > 40%.
2. **Learning Efficacy:** > 70% recall on taught MVP words after 1 week.
3. **Extensibility:** Adding a sample World 2 quest + 10 new words requires **zero** core code changes.
