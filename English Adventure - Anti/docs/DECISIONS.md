# Architecture Decision Records (ADR)
## English Adventure

This document records the key architectural, technical, and product decisions made for **English Adventure**, along with alternatives considered and trade-offs.

---

## ADR-001: Godot 4 as Game Engine
**Date:** 2026-11-26  
**Status:** Accepted  
**Deciders:** Game Architect, Senior Godot Developer  

### Context
We need a cross-platform game engine capable of exporting to Android, iOS, and Web/Desktop with strong 2D/2.5D UI tools, lightweight mobile footprint, and zero licensing royalties.

### Decision
Use **Godot 4.x** with the Mobile renderer.

### Alternatives Considered
| Option | Pros | Cons | Why Not Chosen |
|---|---|---|---|
| Unity | Mature ecosystem, strong 3D | Runtime fee concerns, heavier mobile build size | Licensing risk & unnecessary overhead for 2.5D |
| Unreal Engine | High-end 3D graphics | Heavyweight for mobile/web; overkill for cartoon 2.5D | Poor web export & large binary size |
| Flutter / React Native | Great for forms/apps | Weak for real-time 2.5D adventure gameplay & animations | Risks feeling like a flashcard app |

### Consequences
**Positive:** Small APK/WASM size, fast iteration, MIT license, built-in scene/signal architecture.  
**Negative/Trade-offs:** Smaller third-party SDK ecosystem (e.g., no official Supabase SDK — requires custom REST wrapper).

---

## ADR-002: Supabase as Backend
**Date:** 2026-11-26  
**Status:** Accepted  
**Deciders:** Database Architect, Game Architect  

### Context
Need relational data modeling (vocabulary ↔ mini-games ↔ SRS mastery), authentication, file storage for audio/images, and Row Level Security.

### Decision
Use **Supabase (PostgreSQL + Auth + Storage + REST API)**.

### Alternatives Considered
| Option | Pros | Cons | Why Not Chosen |
|---|---|---|---|
| Firebase | Great offline SDK, easy auth | NoSQL makes complex relational SRS/content queries awkward | Relational PostgreSQL fits learning graphs better |
| Custom Node/Python API | Full control | High DevOps & maintenance cost for small team | Slows MVP delivery |

### Consequences
**Positive:** Clean SQL schema, strict RLS for child data isolation, easy migrations.  
**Negative/Trade-offs:** Requires building an offline-first cache/sync layer in Godot.

---

## ADR-003: 2.5D Cartoon Art Style
**Date:** 2026-11-26  
**Status:** Accepted  
**Deciders:** Game Designer, UI/UX Designer  

### Context
Target devices include mid-range Android phones and Web browsers. Full 3D assets are expensive to produce and heavy to render.

### Decision
Use **2.5D Cartoon** (layered 2D sprites with parallax depth, drop shadows, and dynamic lighting).

### Alternatives Considered
| Option | Pros | Cons | Why Not Chosen |
|---|---|---|---|
| Full 3D | Immersive camera | High asset cost, thermal throttling on budget Android | Slows content production for 6 worlds |
| Flat 2D | Fastest to draw | Less sense of adventure depth | Feels less like an adventure game |

### Consequences
**Positive:** 60 FPS on mid-range mobile, faster asset pipeline, vibrant storybook look.  
**Negative/Trade-offs:** Fixed camera angles (no free 360° camera rotation).

---

## ADR-004: Offline-First Architecture
**Date:** 2026-11-26  
**Status:** Accepted  
**Deciders:** Game Architect, QA Engineer  

### Context
Target learners in Vietnam may play on tablets/phones with intermittent Wi-Fi.

### Decision
All MVP content (JSON + audio/images) is bundled/cached locally; all progress writes go to local storage first and sync to Supabase asynchronously when online.

### Alternatives Considered
- **Always-online:** Blocks play without internet; unacceptable for children's mobile games.

### Consequences
**Positive:** Instant load times, zero-lag mini-games, uninterrupted play.  
**Negative/Trade-offs:** Must handle delta sync and conflict resolution (solved via max-progress merge + idempotent quest IDs).

---

## ADR-005: Learning Engine Independence from Adventure Engine
**Date:** 2026-11-26  
**Status:** Accepted  
**Deciders:** Game Architect, Educational Game Designer  

### Context
If mini-games or quests hardcode vocabulary, adding Worlds 2–6 or reusing words across skills becomes unmaintainable.

### Decision
Strictly decouple the **Learning Engine** (`LearningModule`, `VocabularyModule`, `GrammarModule`, `AssessmentModule`, `ReviewModule`) from the **Adventure Engine** (`AdventureModule`, `QuestModule`, `CharacterModule`). Communication happens via `EventBus` signals and data DTOs.

### Consequences
**Positive:** One word (`apple`) works in all 5+ mini-games; Learning Engine can be unit-tested without loading a single map scene.  
**Negative/Trade-offs:** Slightly more upfront interface design (`MiniGameBase`, `QuestionData`).

---

## ADR-006: Content-Driven Vocabulary System (JSON + DB)
**Date:** 2026-11-26  
**Status:** Accepted  

### Decision
Store all learning content in validated JSON files (`data/`) synced with PostgreSQL, never in GDScript.

### Consequences
**Positive:** Educators can scale from 150 to 800+ words without programmer intervention.

---

## ADR-007: GDScript over C#
**Date:** 2026-11-26  
**Status:** Accepted  

### Decision
Use **GDScript** exclusively for game client code.

### Alternatives Considered
- **C#:** Faster raw compute, but Godot 4 Web/iOS C# export has extra friction and larger binary size.

### Consequences
**Positive:** Seamless Web/Mobile export, tightest Godot editor integration, faster prototyping.

---

## ADR-008: MVP Limited to 1 World (Alphabet Island)
**Date:** 2026-11-26  
**Status:** Accepted  

### Decision
Build only **World 1 (Alphabet Island)** with 26 letters, 100–150 words, 15–20 quests, and 5 mini-games for MVP, while keeping the 6-world architecture intact.

### Consequences
**Positive:** Proves engagement, retention, and extensibility within 4.5–5.5 months instead of over-scoping.

---

## ADR-009: Speaking MVP — Listen & Repeat with Self-Rating
**Date:** 2026-11-26  
**Status:** Accepted  

### Decision
In MVP, Speaking uses local record-and-playback + child self-rating rather than cloud AI pronunciation scoring.

### Consequences
**Positive:** Zero API cost, works offline, avoids frustrating false-negatives from noisy mics on 10-year-old voices. AI scoring is deferred to World 5 (Post-MVP).

---

## ADR-010: SM-2 Spaced Repetition Algorithm
**Date:** 2026-11-26  
**Status:** Accepted  

### Decision
Use a simplified **SM-2** algorithm (`ease_factor`, `interval_days`, `repetitions`, `next_review_at`) in `vocabulary_mastery`.

### Consequences
**Positive:** Proven memory retention, simple deterministic math, easy to tune intervals for children.

---

## ADR-011: Anonymous Guest Auth with Optional Email Registration
**Date:** 2026-11-26  
**Status:** Accepted  

### Decision
Allow immediate **Anonymous Guest** play via Supabase Anonymous Auth, with optional email linking later to save progress across devices.

### Consequences
**Positive:** Zero onboarding friction; respects child privacy until a parent chooses to register.

---

## ADR-012: Mobile First (Android/iOS), Desktop Web Responsive
**Date:** 2026-11-26  
**Status:** Accepted  

### Decision
Design primary touch UX for Mobile Portrait/Landscape, with dedicated multi-column/side-rail layouts for Tablet and Desktop Web (never stretched mobile).

---

## ADR-013: 17-Module Modular Architecture
**Date:** 2026-11-26  
**Status:** Accepted  

### Decision
Organize `scripts/` into 17 focused modules communicating via `EventBus` and explicit service interfaces.

---

## ADR-014: Pre-Recorded Audio over Runtime TTS
**Date:** 2026-11-26  
**Status:** Accepted  

### Decision
Use pre-recorded native `en-US` (and optional `en-GB`) `.mp3`/`.ogg` audio files rather than device TTS.

### Consequences
**Positive:** Consistent, warm, accurate pronunciation across all Android/iOS/Web devices—critical for beginner phonics.

---

## ADR-015: Data Minimization & Child Privacy (COPPA/GDPR-K)
**Date:** 2026-11-26  
**Status:** Accepted  

### Decision
Never collect real names, locations, photos, or raw voice recordings on servers. Never embed `service_role` keys or third-party ad SDKs in the client. Use synthetic data exclusively in dev/test environments.
