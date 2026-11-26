# Product Requirements Document (PRD)
## English Adventure

| Field | Value |
|---|---|
| **Document Version** | 1.0 |
| **Date** | 2026-11-26 |
| **Status** | Draft |
| **Engine** | Godot 4.x + GDScript |
| **Backend** | Supabase + PostgreSQL |
| **Platforms** | Android, iOS, Web/Desktop |

---

## Table of Contents

1. [Product Overview](#1-product-overview)
2. [Product Vision](#2-product-vision)
3. [Target Audience](#3-target-audience)
4. [Learning Objectives](#4-learning-objectives)
5. [Game Objectives](#5-game-objectives)
6. [Core Features](#6-core-features)
7. [Functional Requirements](#7-functional-requirements)
8. [Non-Functional Requirements](#8-non-functional-requirements)
9. [Platform Requirements](#9-platform-requirements)
10. [User Stories](#10-user-stories)
11. [MVP Scope](#11-mvp-scope)
12. [Future Development Scope](#12-future-development-scope)
13. [Acceptance Criteria](#13-acceptance-criteria)

---

## 1. Product Overview

**English Adventure** is a 3D/2.5D cartoon adventure educational game designed for Vietnamese-speaking children aged approximately 10 years old who are beginners in English. Set in a vibrant fantasy world, the game integrates structured English language learning — covering Listening, Speaking, Reading, and Writing — directly into an engaging adventure narrative.

The game is built on **Godot 4.x** with **GDScript**, backed by **Supabase + PostgreSQL**, and targets **Android, iOS, and Web/Desktop** platforms simultaneously. Its architecture separates the **Learning Engine** from the **Adventure Engine**, ensuring that educational content can be updated and reused independently of gameplay mechanics.

### High-Level Summary

| Attribute | Detail |
|---|---|
| **Genre** | 3D/2.5D Cartoon Adventure (Fantasy) |
| **Learning Level** | Pre-A1 → A1 (CEFR) |
| **Language Target** | English (learner L1: Vietnamese) |
| **MVP Content** | 1 World, 5 mini-games, 26 letters, 100–150 vocabulary words, 15–20 quests |
| **Full Game Content** | 6 Worlds, 4 integrated skills, expanding vocabulary and grammar |
| **Architecture Style** | Modular (17 modules), Offline-First, No hardcoded content |

---

## 2. Product Vision

> *"To make English feel like an adventure, not a lesson — so every Vietnamese child can unlock a world of language through play."*

**English Adventure** envisions a world where learning English is inseparable from exciting gameplay. Players explore magical lands silenced by **The Silent Shadow** — an antagonist that has stolen the voice of the world. Only by learning to speak, read, listen to, and write English can the player restore sound, light, and life to each region of this enchanted realm.

### Vision Pillars

| Pillar | Description |
|---|---|
| **Learning-First** | Every gameplay mechanic is rooted in a measurable learning outcome. |
| **Story-Driven** | Narrative motivation drives progression; learning is the heroic act. |
| **Accessible** | Designed for children with zero English background and limited reading ability in any language. |
| **Safe & Trustworthy** | No ads, no in-app purchases that bypass learning, no external links. |
| **Scalable** | A modular platform that can grow from 1 world to 6 without architectural rewrites. |

---

## 3. Target Audience

### Primary Users

| Attribute | Detail |
|---|---|
| **Age** | ~10 years old (primary school, grades 4–5) |
| **Native Language** | Vietnamese |
| **English Level** | Absolute beginner (Pre-A1); no prior formal English instruction assumed |
| **Device Comfort** | Comfortable with touch-screen phones/tablets; some have access to desktop/web |
| **Play Context** | Home, after school; sessions of 15–30 minutes |
| **Motivation** | Curiosity, play, parental encouragement; not intrinsically motivated to study |

### Secondary Users

| Role | Relationship | Needs |
|---|---|---|
| **Parents / Guardians** | Approve, monitor, pay | Progress visibility, safe environment, educational value |
| **Teachers** | May assign or recommend | Curriculum alignment, progress reports |

### User Personas

**Persona A — Minh (Age 10, Ho Chi Minh City)**
Minh plays mobile games daily. He attends a Vietnamese public school and has just started English class. He loves cartoon characters and adventure stories. He gets bored with textbook drills quickly but stays engaged when there is a reward loop.

**Persona B — Linh (Age 10, Da Nang)**
Linh is curious and reads Vietnamese children's books. Her parents want her to learn English but cannot afford a private tutor. She uses a tablet shared with her siblings. She responds well to character relationships and story.

**Persona C — Parent / Mrs. Hoa (Age 38)**
Mrs. Hoa wants her child to learn English in a safe, screen-time-justified way. She is skeptical of games but will accept them if she can see measurable progress. She needs simple, clear feedback in Vietnamese.

---

## 4. Learning Objectives

### CEFR Alignment

The MVP targets **Pre-A1** competencies, with the full 6-world game expanding to solid **A1** across all four skills.

| World | CEFR Target | Focus |
|---|---|---|
| World 1 — Alphabet Island (MVP) | Pre-A1 | Letters, phonics, 100–150 core words |
| World 2 — Vocabulary Forest | Pre-A1 | Thematic vocabulary (animals, food, colors) |
| World 3 — Sentence Kingdom | A1 approaching | Simple sentences, subject-verb-object |
| World 4 — Listening Ocean | A1 | Comprehension of short spoken phrases |
| World 5 — Speaking City | A1 | Spoken output, basic conversation |
| World 6 — Challenge Kingdom | A1 | Integrated skills, review, assessment |

### Four-Skill Learning Objectives

#### 4.1 Listening
- Recognize individual letters and their sounds (phonics).
- Understand simple English words when spoken clearly and slowly.
- Follow single-step spoken instructions in English.
- Identify familiar vocabulary in short audio clips.

#### 4.2 Speaking *(MVP: Listen & Repeat + Self-Rating)*
- Repeat words and simple phrases with awareness of pronunciation.
- Self-assess own pronunciation against a model using a simple rating scale.
- Build confidence in producing English sounds in a low-stakes environment.

> **Post-MVP:** AI-assisted pronunciation grading will evaluate spoken output automatically.

#### 4.3 Reading
- Recognize all 26 uppercase and lowercase letters.
- Read and match simple words (CVC pattern and sight words).
- Read short, illustrated sentences (3–5 words) in context.

#### 4.4 Writing *(interpreted as productive word-assembly in MVP)*
- Arrange given letters to spell a word correctly (Word Builder).
- Arrange given words to form a simple sentence (Sentence Builder).
- Match written words to images.

### Vocabulary Targets

| Phase | Vocabulary Count | Category Examples |
|---|---|---|
| MVP (World 1) | 100–150 words | Alphabet names, phonics words, body parts, colors, numbers 1–10 |
| Post-MVP (Worlds 2–6) | 500–1000+ words | Animals, food, family, school, nature, daily routines |

---

## 5. Game Objectives

### Narrative Goal
The player's character (a customizable boy or girl) has arrived in a once-vibrant magical world now silenced by **The Silent Shadow**. The world's creatures have lost their voices; signs are blank; music has stopped. Only by learning English — the ancient language of the world — can the player cast "Voice Spells" to restore each region.

### Player Goals (MVP)
1. **Explore** Alphabet Island — a colorful archipelago themed around the 26 letters.
2. **Complete quests** given by NPCs (Professor Owl, Buddy the dragon, etc.) that require solving English mini-games.
3. **Defeat/neutralize** the Silent Shadow's influence zone by zone (one per letter cluster).
4. **Collect** Stars, Voice Gems, and Letter Badges as progression rewards.
5. **Unlock** the full Alphabet Song as the final MVP milestone.

### Companion: Buddy the Dragon
Buddy is the player's permanent dragon companion. Buddy:
- Provides in-game hints in Vietnamese (MVP) transitioning to bilingual (post-MVP).
- Reacts emotionally to player performance (encouragement on failure, celebration on success).
- Levels up alongside the player, gaining new visual accessories.

---

## 6. Core Features

### 6.1 Feature Overview

| Feature | MVP | Post-MVP |
|---|---|---|
| Customizable player character | ✅ | Enhanced |
| Buddy dragon companion | ✅ | Evolved forms |
| Adventure world map | ✅ (1 world) | 6 worlds |
| Quest system | ✅ (15–20 quests) | Expanding |
| Word Hunt mini-game | ✅ | More themes |
| Listening Mission mini-game | ✅ | More content |
| Word Builder mini-game | ✅ | More words |
| Sentence Builder mini-game | ✅ | Grammar expansion |
| Reading Challenge mini-game | ✅ | Longer texts |
| Spaced Repetition Review | ✅ | Full SRS |
| Offline-first gameplay | ✅ | — |
| Cloud save & sync | ✅ | — |
| Parent Dashboard | ❌ | ✅ |
| AI Speaking Grader | ❌ | ✅ |
| Multiplayer / Co-op | ❌ | ✅ |
| Teacher Dashboard | ❌ | ✅ |
| Leaderboards | ❌ | ✅ |

### 6.2 Architecture Core Features

| Feature | Description |
|---|---|
| **Learning Engine (independent)** | A self-contained module that manages vocabulary, exercises, scoring, and spaced repetition. No dependency on world/quest state. |
| **Adventure Engine** | Handles world map, NPCs, quests, cutscenes, player movement, and narrative state. Calls into Learning Engine for mini-game sessions. |
| **Vocabulary Data Layer** | Single source of truth for all word data. Mini-games query this layer; words are never duplicated or hardcoded in game logic. |
| **Content Management** | All learning content (words, audio, images, sentences) is data-driven and loaded from Supabase; no hardcoded strings in game code. |
| **Offline-First** | Full gameplay available offline; progress syncs to Supabase when connection is restored. |
| **No Client API Keys** | All Supabase credentials and secrets are managed server-side; the client uses anonymous/JWT tokens only. |
| **17-Module Architecture** | The codebase is organized into 17 clearly bounded modules (see Section 7). |

---

## 7. Functional Requirements

### Module Map (17 Modules)

| # | Module | Responsibility |
|---|---|---|
| 1 | `AuthModule` | User registration, login, session management, anonymous play |
| 2 | `PlayerProfileModule` | Character customization, persistent player state |
| 3 | `BuddyModule` | Dragon companion logic, emotion states, progression |
| 4 | `WorldMapModule` | World and region navigation, map unlock logic |
| 5 | `QuestModule` | Quest definitions, triggers, completion tracking |
| 6 | `NPCModule` | NPC dialogue trees, interaction logic |
| 7 | `VocabularyDataModule` | Canonical vocabulary store, metadata, audio refs |
| 8 | `LearningEngineModule` | Exercise generation, scoring, session management |
| 9 | `SpacedRepetitionModule` | SRS scheduling, word mastery tracking |
| 10 | `MiniGameModule` | Mini-game session controller; delegates to game-specific scenes |
| 11 | `WordHuntGame` | Word Hunt mini-game logic |
| 12 | `ListeningMissionGame` | Listening Mission mini-game logic |
| 13 | `WordBuilderGame` | Word Builder mini-game logic |
| 14 | `SentenceBuilderGame` | Sentence Builder mini-game logic |
| 15 | `ReadingChallengeGame` | Reading Challenge mini-game logic |
| 16 | `ProgressModule` | XP, stars, badges, achievement tracking |
| 17 | `SyncModule` | Offline queue, Supabase sync, conflict resolution |

---

### FR-1: Authentication & Accounts

| ID | Requirement | Priority |
|---|---|---|
| FR-1.1 | The system SHALL allow a child to play as a guest (anonymous) without creating an account. | MVP |
| FR-1.2 | The system SHALL allow optional account registration via email/password. | MVP |
| FR-1.3 | The system SHALL allow optional account registration via Google OAuth. | MVP |
| FR-1.4 | Guest progress SHALL be migrated to a named account upon registration. | MVP |
| FR-1.5 | No API keys or service-role Supabase credentials SHALL be present in the client binary. | MVP |
| FR-1.6 | Sessions SHALL use short-lived JWTs refreshed automatically. | MVP |
| FR-1.7 | The system SHALL support a parent-managed child account with PIN protection. | Post-MVP |

---

### FR-2: Player Profile & Customization

| ID | Requirement | Priority |
|---|---|---|
| FR-2.1 | The player SHALL choose a character appearance (boy or girl) at game start. | MVP |
| FR-2.2 | The player SHALL be able to name their character (default names provided). | MVP |
| FR-2.3 | Character cosmetics (outfits, accessories) SHALL be unlockable through gameplay only (no paywalled progression items). | MVP |
| FR-2.4 | Player profile data SHALL be persisted locally and synced to Supabase when online. | MVP |

---

### FR-3: Buddy the Dragon

| ID | Requirement | Priority |
|---|---|---|
| FR-3.1 | Buddy SHALL appear on-screen throughout gameplay as a persistent companion. | MVP |
| FR-3.2 | Buddy SHALL provide hints and instructions in Vietnamese during MVP. | MVP |
| FR-3.3 | Buddy SHALL display contextually appropriate emotional animations (happy, sad, surprised, encouraging). | MVP |
| FR-3.4 | Buddy SHALL level up and gain new visual states as the player progresses. | MVP |
| FR-3.5 | Buddy SHALL offer bilingual (Vietnamese + English) dialogue in post-MVP. | Post-MVP |

---

### FR-4: World Map & Navigation

| ID | Requirement | Priority |
|---|---|---|
| FR-4.1 | The game SHALL display an overworld map of Alphabet Island divided into letter zones. | MVP |
| FR-4.2 | Zones SHALL unlock sequentially as the player completes prerequisite quests. | MVP |
| FR-4.3 | The map SHALL visually represent the "silenced" (gray/dark) vs. "restored" (bright/colorful) state of each zone. | MVP |
| FR-4.4 | Tapping a zone SHALL navigate the player into that zone's scene. | MVP |
| FR-4.5 | Worlds 2–6 SHALL appear on a global world map but be locked in MVP. | MVP |
| FR-4.6 | World unlock animations SHALL play when a new world opens (post-MVP). | Post-MVP |

---

### FR-5: Quest System

| ID | Requirement | Priority |
|---|---|---|
| FR-5.1 | The MVP SHALL contain 15–20 quests distributed across Alphabet Island. | MVP |
| FR-5.2 | Each quest SHALL have: a title, an NPC giver, a Vietnamese description, one or more learning tasks, and a completion reward. | MVP |
| FR-5.3 | Quests SHALL be data-driven (defined in Supabase, loaded at runtime; not hardcoded in scripts). | MVP |
| FR-5.4 | Quest completion SHALL trigger narrative feedback (Buddy reaction, zone restoration animation). | MVP |
| FR-5.5 | The system SHALL track quest state (not started / in progress / completed) persistently. | MVP |
| FR-5.6 | Optional side-quests for bonus vocabulary practice SHALL be available. | Post-MVP |

---

### FR-6: NPC System

| ID | Requirement | Priority |
|---|---|---|
| FR-6.1 | NPCs SHALL include at minimum: Professor Owl (tutorial/guide), zone-specific creature NPCs, and Boss NPCs (one per major zone). | MVP |
| FR-6.2 | NPC dialogue SHALL be data-driven (not hardcoded), supporting Vietnamese text. | MVP |
| FR-6.3 | Dialogue trees SHALL support simple branching (player selects a response). | MVP |
| FR-6.4 | Dialogue SHALL be accompanied by character portrait and optional audio. | MVP |
| FR-6.5 | NPCs SHALL react visually when the player completes a mini-game in their quest. | MVP |

---

### FR-7: Vocabulary Data Layer

| ID | Requirement | Priority |
|---|---|---|
| FR-7.1 | All vocabulary SHALL be stored in a single canonical table in Supabase (`vocabulary`). | MVP |
| FR-7.2 | Each vocabulary entry SHALL include: English word, Vietnamese translation, phonetic transcription (IPA or simple), audio file reference, image reference, word category, and difficulty tag. | MVP |
| FR-7.3 | Mini-games SHALL query vocabulary from this layer; they SHALL NOT maintain their own word lists. | MVP |
| FR-7.4 | Vocabulary data SHALL be cached locally for offline use. | MVP |
| FR-7.5 | MVP vocabulary set SHALL cover 100–150 words appropriate for Pre-A1 learners. | MVP |
| FR-7.6 | Audio for all 100–150 MVP words SHALL be recorded by a native English speaker (clear, slow, child-appropriate). | MVP |

---

### FR-8: Learning Engine

| ID | Requirement | Priority |
|---|---|---|
| FR-8.1 | The Learning Engine SHALL be a self-contained module with no dependency on world/quest state. | MVP |
| FR-8.2 | The Learning Engine SHALL expose a clean API for the Adventure Engine to request mini-game sessions with specific vocabulary filters. | MVP |
| FR-8.3 | The Learning Engine SHALL score each exercise attempt and emit a result event. | MVP |
| FR-8.4 | The Learning Engine SHALL track per-word mastery level (0–5 scale). | MVP |
| FR-8.5 | The Learning Engine SHALL implement basic spaced repetition to schedule word reviews. | MVP |
| FR-8.6 | The Learning Engine SHALL generate hint sequences for failed attempts (3-hint system: audio → image → reveal). | MVP |

---

### FR-9: Mini-Games

All five mini-games are **MVP required**. Each is a scene managed by `MiniGameModule` and delegates to its own game-specific script.

#### FR-9.1: Word Hunt
| ID | Requirement |
|---|---|
| FR-9.1.1 | Display a visual scene containing hidden words (letters or words embedded in the environment). |
| FR-9.1.2 | Player taps/clicks on a word when they hear or see the target. |
| FR-9.1.3 | Vocabulary is pulled from the Learning Engine for the current quest context. |
| FR-9.1.4 | The game SHALL provide audio pronunciation when the player selects a word. |
| FR-9.1.5 | A round consists of finding 5–10 target items within a time limit or attempt limit. |

#### FR-9.2: Listening Mission
| ID | Requirement |
|---|---|
| FR-9.2.1 | Play an audio clip of a word or short phrase. |
| FR-9.2.2 | Player selects the correct image or word from 3–4 options. |
| FR-9.2.3 | Audio clips SHALL be native-speaker recordings from the vocabulary data layer. |
| FR-9.2.4 | A retry option replays the audio. |
| FR-9.2.5 | Difficulty scales from single words to short phrases across quest progression. |

#### FR-9.3: Word Builder
| ID | Requirement |
|---|---|
| FR-9.3.1 | Display a target image and an audio cue of the target word. |
| FR-9.3.2 | Present shuffled letter tiles; player arranges them to spell the word. |
| FR-9.3.3 | Tiles SHALL snap into position slots; correct placement gives positive audio-visual feedback. |
| FR-9.3.4 | A hint reveals the first letter if the player is stuck. |
| FR-9.3.5 | Words are sourced from the Learning Engine vocabulary pool for the current session. |

#### FR-9.4: Sentence Builder
| ID | Requirement |
|---|---|
| FR-9.4.1 | Display a scene image representing a simple sentence situation. |
| FR-9.4.2 | Present 3–6 word cards; player arranges them into the correct sentence order. |
| FR-9.4.3 | A "Listen" button plays the full sentence audio. |
| FR-9.4.4 | Sentences SHALL follow subject-verb-object patterns appropriate to Pre-A1. |
| FR-9.4.5 | Sentence data SHALL be stored in Supabase and loaded at runtime (not hardcoded). |

#### FR-9.5: Reading Challenge
| ID | Requirement |
|---|---|
| FR-9.5.1 | Display a short illustrated text (1–3 sentences, 10–20 words total). |
| FR-9.5.2 | Player answers 2–3 comprehension questions (multiple choice or word-match). |
| FR-9.5.3 | Individual words SHALL be tappable to hear pronunciation. |
| FR-9.5.4 | Text and questions are data-driven from Supabase. |
| FR-9.5.5 | Font size and line spacing SHALL be optimized for 10-year-old reading. |

---

### FR-10: Progress & Rewards

| ID | Requirement | Priority |
|---|---|---|
| FR-10.1 | The player SHALL earn XP for every completed exercise and quest. | MVP |
| FR-10.2 | XP SHALL accumulate to a visible player level (1–∞). | MVP |
| FR-10.3 | Stars (1–3 per mini-game session) SHALL reflect performance quality. | MVP |
| FR-10.4 | Letter Badges SHALL be awarded upon mastering a letter cluster. | MVP |
| FR-10.5 | Voice Gems SHALL be awarded for quest completion and used as a narrative currency (restoring the world). | MVP |
| FR-10.6 | A progress screen SHALL show: current level, stars, badges, vocabulary mastered count, and quests completed. | MVP |
| FR-10.7 | A parent-facing progress summary (email or in-app) SHALL be available post-MVP. | Post-MVP |
| FR-10.8 | Achievements/trophies (e.g., "First Word!", "Letter Master A–E") SHALL be unlockable. | Post-MVP |

---

### FR-11: Offline & Sync

| ID | Requirement | Priority |
|---|---|---|
| FR-11.1 | The game SHALL be fully playable without an internet connection after initial asset download. | MVP |
| FR-11.2 | All progress made offline SHALL be queued locally (SQLite or Godot's built-in storage). | MVP |
| FR-11.3 | The SyncModule SHALL detect connectivity and push offline progress to Supabase. | MVP |
| FR-11.4 | Conflict resolution SHALL favor the most-recent timestamp with server as final authority. | MVP |
| FR-11.5 | Vocabulary and content updates SHALL be downloadable as background asset patches. | Post-MVP |

---

### FR-12: Speaking (MVP Scope)

| ID | Requirement | Priority |
|---|---|---|
| FR-12.1 | The game SHALL present a "Listen & Repeat" exercise for target words. | MVP |
| FR-12.2 | The player taps a microphone button, records their pronunciation attempt, and plays it back. | MVP |
| FR-12.3 | The player self-rates their attempt on a simple 3-point scale (😕 / 😊 / 😄). | MVP |
| FR-12.4 | Self-rating data SHALL be stored for future AI grading integration. | MVP |
| FR-12.5 | No AI pronunciation scoring SHALL be performed in MVP. | MVP (exclusion) |
| FR-12.6 | AI-based pronunciation grading SHALL be integrated in a post-MVP release. | Post-MVP |

---

## 8. Non-Functional Requirements

### NFR-1: Performance

| ID | Requirement | Target |
|---|---|---|
| NFR-1.1 | App cold start time (to main menu) | ≤ 4 seconds on mid-range Android (2GB RAM) |
| NFR-1.2 | Mini-game scene load time | ≤ 2 seconds |
| NFR-1.3 | Frame rate during gameplay | ≥ 30 FPS on target devices; 60 FPS on modern hardware |
| NFR-1.4 | Memory footprint | ≤ 300 MB RAM during active gameplay |
| NFR-1.5 | Initial install size | ≤ 150 MB (Android APK/AAB); additional assets streamed |
| NFR-1.6 | Audio latency (button press to sound) | ≤ 100 ms |
| NFR-1.7 | Supabase API response time (online operations) | ≤ 1 second for profile sync |

### NFR-2: Security

| ID | Requirement |
|---|---|
| NFR-2.1 | No API keys, service-role keys, or secrets SHALL be embedded in the client binary or assets. |
| NFR-2.2 | All communication with Supabase SHALL use HTTPS/TLS 1.2+. |
| NFR-2.3 | User passwords SHALL never be stored locally; only tokens (JWTs). |
| NFR-2.4 | Child user data SHALL comply with applicable child privacy regulations (COPPA principles; local Vietnamese data privacy laws). |
| NFR-2.5 | The game SHALL contain no third-party advertising SDKs. |
| NFR-2.6 | The game SHALL contain no external hyperlinks that could navigate a child out of the app. |
| NFR-2.7 | Supabase Row Level Security (RLS) SHALL be enabled on all tables containing user data. |
| NFR-2.8 | Audio recordings from the Speaking feature SHALL be stored with user consent and SHALL be deletable. |

### NFR-3: Scalability

| ID | Requirement |
|---|---|
| NFR-3.1 | The architecture SHALL support adding new worlds, mini-games, and vocabulary without engine code changes. |
| NFR-3.2 | The vocabulary data layer SHALL support 10,000+ entries without client-side performance degradation. |
| NFR-3.3 | Supabase infrastructure SHALL be designed to handle up to 100,000 concurrent users. |
| NFR-3.4 | Content (words, audio, images, quests) SHALL be updatable via backend push without an app store update. |

### NFR-4: Accessibility

| ID | Requirement |
|---|---|
| NFR-4.1 | All instructional text SHALL be in Vietnamese during MVP. |
| NFR-4.2 | Font size for in-game text SHALL be ≥ 18pt on a 5-inch mobile screen. |
| NFR-4.3 | Touch targets SHALL be ≥ 44×44 dp on mobile. |
| NFR-4.4 | The game SHALL not rely solely on color to convey information (shape/icon differentiation also used). |
| NFR-4.5 | Audio cues SHALL accompany all critical feedback (correct/incorrect). |

### NFR-5: Reliability

| ID | Requirement |
|---|---|
| NFR-5.1 | The game SHALL not lose locally stored progress under any network condition. |
| NFR-5.2 | Crashes SHALL be logged (using Godot's crash reporter or a Supabase function) and reported to the dev team. |
| NFR-5.3 | The app SHALL recover gracefully from unexpected interruptions (phone call, app backgrounding). |
| NFR-5.4 | Target uptime for Supabase backend: 99.5% monthly. |

### NFR-6: Maintainability

| ID | Requirement |
|---|---|
| NFR-6.1 | Each of the 17 modules SHALL have a clearly defined interface (API); no cross-module direct state access. |
| NFR-6.2 | All learning content SHALL be data-driven; no English words, sentences, or audio file names SHALL appear as hardcoded strings in GDScript. |
| NFR-6.3 | The codebase SHALL include inline documentation for all public module APIs. |
| NFR-6.4 | A content update pipeline (admin tool or Supabase Studio workflow) SHALL exist to add vocabulary without a developer. |

---

## 9. Platform Requirements

### 9.1 Android

| Attribute | Requirement |
|---|---|
| **Minimum API Level** | Android 7.0 (API 24) |
| **Target API Level** | Android 14 (API 34) or latest stable |
| **Architecture** | ARM64-v8a (primary); ARMv7 (secondary support) |
| **Screen Sizes** | Phones (5–6.5") and tablets (7–12"); adaptive layout required |
| **Orientation** | Landscape primary; portrait support optional |
| **Input** | Touch (primary); physical keyboard supported |
| **Audio** | Hardware speaker + headphone jack/Bluetooth |
| **Distribution** | Google Play Store (AAB format) |
| **Permissions** | Microphone (Speaking feature, user-granted), Internet (optional for sync), Storage (local save) |
| **UI Adaptation** | Native Android back gesture handled; navigation bar overlaps handled |
| **Performance Target** | Smooth on a device with Snapdragon 450 / 2GB RAM (e.g., Redmi 9A) |

> **Note:** Android UI is NOT simply a scaled-down desktop UI. Touch targets, font sizes, control layouts, and interaction patterns are designed mobile-first.

### 9.2 iOS

| Attribute | Requirement |
|---|---|
| **Minimum iOS Version** | iOS 14.0 |
| **Target iOS Version** | iOS 17+ |
| **Devices** | iPhone (all sizes from SE to Pro Max); iPad (all sizes) |
| **Orientation** | Landscape primary |
| **Input** | Touch (primary); Apple Pencil optional future support |
| **Distribution** | Apple App Store |
| **Permissions** | Microphone (Speaking feature, explicit NSMicrophoneUsageDescription), Network (Supabase sync) |
| **Privacy** | App Tracking Transparency (ATT) framework NOT required (no ads/tracking) |
| **In-App Purchase** | Handled via StoreKit if premium features added (post-MVP) |
| **UI Adaptation** | Safe area insets (notch, Dynamic Island, home indicator) handled; no UI elements hidden behind system chrome |
| **Audio** | AVAudioSession managed for background/foreground transitions; respects silent switch |
| **Review Compliance** | No external payment links; content age-rating: 4+ |

### 9.3 Web / Desktop

The Web/Desktop version is a **distinct experience**, not a resized mobile UI. It has its own layout, control scheme, and feature profile.

#### Web (HTML5 via Godot Export)

| Attribute | Requirement |
|---|---|
| **Browsers Supported** | Chrome 100+, Firefox 100+, Edge 100+, Safari 15+ |
| **Rendering** | WebGL 2.0 (Godot 4 GLES3 compatibility mode) |
| **Layout** | Wider aspect ratio (16:9 / 16:10) with expanded HUD, side panels for vocabulary reference |
| **Input** | Mouse + keyboard primary; touch on touch-screen laptops |
| **Audio** | Web Audio API; autoplay policy handled (first user interaction required) |
| **Offline** | Service Worker for asset caching; limited offline capability (no native SQLite; use IndexedDB) |
| **Distribution** | Hosted on a CDN (e.g., Cloudflare Pages or Supabase Storage) |
| **Performance** | ≥ 30 FPS on a mid-range 2020 laptop (Intel UHD 620) |

#### Desktop (Windows / macOS — Export)

| Attribute | Requirement |
|---|---|
| **Windows** | Windows 10 / 11 (64-bit) |
| **macOS** | macOS 12 Monterey+ |
| **Input** | Mouse + keyboard; gamepad optional (post-MVP) |
| **Layout** | 1280×720 minimum; 1920×1080 recommended; resizable window with correct aspect-ratio letterboxing |
| **Features Unique to Desktop** | Keyboard shortcuts for mini-game interactions; expanded vocabulary sidebar during reading; full-screen mode |
| **Audio** | Full stereo mix; headphone support |
| **Distribution** | Direct download (itch.io or website); future: Steam (post-MVP) |

#### Desktop-Specific UI Distinctions from Mobile

| Element | Mobile | Web/Desktop |
|---|---|---|
| Navigation | Tap-based map | Mouse click + keyboard arrow keys |
| Mini-game controls | Drag tiles with touch | Drag with mouse OR keyboard shortcuts |
| HUD layout | Compact, bottom-anchored | Expanded side panel with quest log visible |
| Vocabulary reference | Hidden, accessed via Buddy | Always-visible sidebar panel |
| Font size | Large (18pt+) for small screen | Standard (14–16pt) at desktop resolution |
| Dialogue | Fullscreen overlay | Dialogue box in lower panel; world visible above |

---

## 10. User Stories

### Children (Primary User)

| ID | Story | Priority |
|---|---|---|
| US-01 | As a **child player**, I want to pick a character that looks like me so that I feel personally connected to the adventure. | MVP |
| US-02 | As a **child player**, I want Buddy the dragon to explain things to me in Vietnamese so that I understand what I need to do. | MVP |
| US-03 | As a **child player**, I want to hear how a word sounds when I tap it so that I know how to say it in English. | MVP |
| US-04 | As a **child player**, I want to earn stars and gems after finishing a mini-game so that I feel rewarded for my effort. | MVP |
| US-05 | As a **child player**, I want to see the world become colorful again after I complete a quest so that my learning feels meaningful. | MVP |
| US-06 | As a **child player**, I want to replay a mini-game if I did not get a perfect score so that I can improve and earn more stars. | MVP |
| US-07 | As a **child player**, I want the game to work without internet at home so that I can keep playing even when the Wi-Fi is off. | MVP |
| US-08 | As a **child player**, I want to build words by dragging letters so that spelling feels like a puzzle game. | MVP |
| US-09 | As a **child player**, I want to listen to a word and then pick the right picture so that I practice understanding English by ear. | MVP |
| US-10 | As a **child player**, I want to record myself saying a word and hear it back so that I can practice speaking out loud. | MVP |
| US-11 | As a **child player**, I want to see how many letters I have learned so that I feel proud of my progress. | MVP |
| US-12 | As a **child player**, I want Professor Owl to give me a new quest so that I always know what to do next in the adventure. | MVP |
| US-13 | As a **child player**, I want the game to remember where I stopped so that I do not have to start over when I come back. | MVP |
| US-14 | As a **child player**, I want to read a short story and answer questions about it so that I practice understanding English sentences. | MVP |
| US-15 | As a **child player**, I want to put words in the right order to make a sentence so that I learn how English sentences are built. | MVP |

### Parents / Guardians (Secondary User)

| ID | Story | Priority |
|---|---|---|
| US-16 | As a **parent**, I want to see how many words my child has learned this week so that I can know the game is effective. | Post-MVP |
| US-17 | As a **parent**, I want to set a daily play-time limit so that the game does not replace study time. | Post-MVP |
| US-18 | As a **parent**, I want to know my child's data is safe and not shared with advertisers so that I trust the app. | MVP |

### Teachers (Tertiary User)

| ID | Story | Priority |
|---|---|---|
| US-19 | As a **teacher**, I want to assign specific vocabulary sets to my students so that the game reinforces what we covered in class. | Post-MVP |
| US-20 | As a **teacher**, I want to see a class-level vocabulary report so that I can identify common gaps. | Post-MVP |

---

## 11. MVP Scope

> **This section defines the strict boundary of the Minimum Viable Product. Features listed here and ONLY here will be built for the first release.**

### MVP Summary

| Dimension | MVP Value |
|---|---|
| Worlds | **1** — Alphabet Island only |
| Mini-games | **5** — Word Hunt, Listening Mission, Word Builder, Sentence Builder, Reading Challenge |
| Letters covered | **26** — Full English alphabet (A–Z) |
| Vocabulary | **100–150 words** — Pre-A1 core set |
| Quests | **15–20 quests** — distributed across Alphabet Island zones |
| Skills | Listening ✅ \| Speaking (listen & repeat, self-rate) ✅ \| Reading ✅ \| Writing (tile-based) ✅ |
| Platforms | Android ✅ \| iOS ✅ \| Web ✅ \| Desktop ✅ |
| Characters | Main character (boy/girl), Buddy, Professor Owl, zone NPCs, zone bosses |
| Backend | Supabase + PostgreSQL; authentication, vocabulary, quest data, progress sync |
| Offline | Full offline gameplay; sync on reconnect |

### MVP Inclusions (Explicit)

- [x] Character selection and naming
- [x] Buddy the dragon companion (Vietnamese hints, emotional reactions)
- [x] Alphabet Island world map with 26-letter zone structure
- [x] 15–20 quests with NPC dialogue (Vietnamese)
- [x] All 5 mini-games fully playable
- [x] 100–150 vocabulary words with audio (native speaker recordings)
- [x] XP, Stars, Letter Badges, Voice Gems reward system
- [x] Progress screen (level, stars, vocab mastered, quests done)
- [x] Offline-first save with Supabase sync
- [x] Anonymous play (no forced account creation)
- [x] Optional account registration (email or Google)
- [x] Spaced repetition scheduling (basic)
- [x] Vocabulary data layer (single source of truth, no duplication)
- [x] No API keys in client
- [x] No hardcoded learning content in game scripts
- [x] Speaking: listen & repeat + self-rating (no AI grading)
- [x] 2.5D cartoon art style (2D sprites + parallax/depth)

### MVP Exclusions (Explicit — Not In Scope for v1.0)

- [ ] Worlds 2–6 (Vocabulary Forest, Sentence Kingdom, Listening Ocean, Speaking City, Challenge Kingdom)
- [ ] AI pronunciation grading
- [ ] Parent dashboard / parent controls
- [ ] Teacher dashboard / class management
- [ ] Multiplayer or co-op
- [ ] Leaderboards
- [ ] Achievements system (beyond basic badge unlocks)
- [ ] Gamepad support
- [ ] Apple Pencil support
- [ ] Steam distribution
- [ ] In-app purchases / premium tier
- [ ] Push notifications
- [ ] Bilingual (EN + VI) Buddy dialogue
- [ ] Background content updates / asset patches
- [ ] Class assignment features
- [ ] Any content beyond 100–150 words

---

## 12. Future Development Scope

### Phase 2 — World Expansion (Worlds 2–6)

| World | Theme | Key Learning |
|---|---|---|
| World 2 — Vocabulary Forest | Enchanted forest | Thematic vocabulary clusters (animals, food, colors, nature, numbers) |
| World 3 — Sentence Kingdom | Medieval castle | Simple sentence construction; subject-verb-object; adjective placement |
| World 4 — Listening Ocean | Underwater realm | Listening comprehension; following instructions; short dialogues |
| World 5 — Speaking City | Animated city | Conversational speaking; greetings, questions, basic discourse |
| World 6 — Challenge Kingdom | Final realm | Integrated skills review; grammar mini-challenges; boss narrative finale |

### Phase 3 — AI Speaking Grader

- Integrate a speech recognition API (e.g., Google Cloud Speech-to-Text, Whisper) for automatic pronunciation evaluation.
- Provide a phoneme-level score and visual feedback (which sounds were correct/off).
- Self-rating data collected in MVP feeds the training/calibration baseline.
- Privacy: audio processed server-side; not stored beyond session unless consented.

### Phase 4 — Parent Dashboard

- In-app parent zone protected by PIN.
- Weekly vocabulary progress summary.
- Play-time tracking and limit setting.
- Subject area heat map (which skills need more work).
- Optional weekly email report.

### Phase 5 — Teacher Dashboard

- Class creation and student invite codes.
- Vocabulary set assignment aligned to curriculum units.
- Class-level and individual student progress reports.
- Export to CSV / PDF.

### Phase 6 — Social & Multiplayer

- Buddy appearance sharing (cosmetic).
- Co-op quest mode: two players on the same local network solve a mini-game together.
- Leaderboards (class-scoped, not global, to avoid pressure).
- Trading card collectibles (in-world, earned through gameplay).

### Phase 7 — Platform Expansion

- Steam distribution (Windows/macOS/Linux).
- Chromebook (Chrome OS) optimized build.
- TV / Android TV support.
- Gamepad (Xbox/PS controller) full support.

### Technical Roadmap Items (Post-MVP)

| Item | Description |
|---|---|
| Dynamic content updates | Push new vocabulary packs, quests, and worlds without app store updates |
| Grammar engine | Rule-based sentence validation for open-ended writing exercises |
| Adaptive difficulty | Learning Engine adjusts word frequency and exercise difficulty per learner model |
| Analytics pipeline | Learning analytics dashboard for internal QA and content improvement |
| Localization | Additional L1 support (e.g., Khmer, Thai) for regional expansion |

---

## 13. Acceptance Criteria

### AC-1: Gameplay & Core Loop

| ID | Criterion | Measurement Method |
|---|---|---|
| AC-1.1 | A new player can reach their first completed mini-game within **5 minutes** of first launch without reading any external instructions. | Usability test with 5 target-age children |
| AC-1.2 | All 5 mini-games are playable end-to-end without crashes on a mid-range Android device (2GB RAM). | QA test run on Redmi 9A |
| AC-1.3 | A quest can be accepted, its mini-game completed, and the reward collected in a single uninterrupted flow. | Manual test of all 15–20 MVP quests |
| AC-1.4 | The world map correctly reflects zone state (silenced vs. restored) after quest completion. | Automated integration test |

### AC-2: Learning Content

| ID | Criterion | Measurement Method |
|---|---|---|
| AC-2.1 | All 26 letters of the alphabet are introduced and practised across the MVP quest set. | Content coverage audit |
| AC-2.2 | Exactly 100–150 vocabulary words are present in the Supabase vocabulary table, each with English word, Vietnamese translation, audio reference, and image reference. | Database row count and completeness query |
| AC-2.3 | Every vocabulary word has a correctly linked audio file recorded by a native English speaker. | Audio playback QA for all 100–150 entries |
| AC-2.4 | No English words or vocabulary strings are hardcoded in GDScript source files. | Static code analysis / grep audit |
| AC-2.5 | The Learning Engine correctly schedules a word for review after 3+ correct answers using spaced repetition logic. | Unit test: LearningEngineModule |

### AC-3: Architecture

| ID | Criterion | Measurement Method |
|---|---|---|
| AC-3.1 | The LearningEngineModule has no direct imports from WorldMapModule, QuestModule, or any adventure-layer module. | Dependency analysis tool / code review |
| AC-3.2 | The VocabularyDataModule is the sole source of vocabulary for all 5 mini-games; no mini-game defines its own word list. | Code review: grep for hardcoded word arrays in mini-game scripts |
| AC-3.3 | No Supabase service-role key or any secret API key is present in any client-side file (GDScript, JSON, .env checked into repo). | Security scan on exported build + repository audit |
| AC-3.4 | Supabase RLS policies are enabled and tested on all user-data tables (profiles, progress, quest_state). | Supabase RLS policy review + penetration test with unauthorized JWT |

### AC-4: Offline & Sync

| ID | Criterion | Measurement Method |
|---|---|---|
| AC-4.1 | The game launches and allows full gameplay with airplane mode enabled after initial setup. | Manual test: disable network, play full session |
| AC-4.2 | Progress made offline (XP, stars, quest completion) syncs correctly to Supabase within 30 seconds of restoring connectivity. | Integration test: offline play → reconnect → verify Supabase rows |
| AC-4.3 | No progress data is lost during a simulated network interruption mid-sync. | Stress test: cut network during sync operation 20 times |

### AC-5: Performance

| ID | Criterion | Measurement Method |
|---|---|---|
| AC-5.1 | Cold start time ≤ 4 seconds on a Redmi 9A (Android 7, 2GB RAM). | Measured with Android Studio Profiler (10 runs, median) |
| AC-5.2 | Mini-game scene loads in ≤ 2 seconds on target devices. | In-game timer logged for each scene transition |
| AC-5.3 | Frame rate stays ≥ 30 FPS during all mini-game scenes on target devices. | Android GPU Monitor / Godot debugger |
| AC-5.4 | Audio plays within 100 ms of a tap/click on a word. | Measured via script timing test (20 trials) |

### AC-6: Platforms

| ID | Criterion | Measurement Method |
|---|---|---|
| AC-6.1 | The game passes Google Play internal testing on Android 7 through Android 14 without crashes. | Play Console pre-launch report |
| AC-6.2 | The game passes Apple TestFlight testing on iOS 14 and iOS 17 without crashes. | TestFlight QA session |
| AC-6.3 | The Web build runs in Chrome 100+, Firefox 100+, and Safari 15+ without rendering artifacts or audio failures. | Manual browser QA matrix |
| AC-6.4 | Desktop (Windows 10 64-bit) build launches, runs all mini-games, and responds to mouse+keyboard input correctly. | Manual QA session |
| AC-6.5 | The Web/Desktop UI presents expanded layouts (sidebar, keyboard controls) distinct from the mobile layout. | Visual QA against design spec |

### AC-7: Security & Privacy

| ID | Criterion | Measurement Method |
|---|---|---|
| AC-7.1 | The exported Android APK/AAB contains no hardcoded API keys (confirmed via APK decompile scan). | `apktool` decompile + string search |
| AC-7.2 | All Supabase API calls use HTTPS; no HTTP calls observed in network traffic. | Charles Proxy / mitmproxy intercept test |
| AC-7.3 | A user's speaking recordings are deletable on request and do not appear in Supabase storage after deletion. | Manual test: record, delete, verify via Supabase Studio |

### AC-8: Usability (Child UX)

| ID | Criterion | Measurement Method |
|---|---|---|
| AC-8.1 | 80% of test children aged 9–11 can complete a mini-game without adult help. | Usability test with n=10 children |
| AC-8.2 | 80% of test children understand what Buddy is saying (Vietnamese hints). | Post-session interview: "Did you understand Buddy?" |
| AC-8.3 | No child tester expresses frustration with font size or touch target size during a 20-minute session. | Observation notes from usability test |
| AC-8.4 | All in-game instructional text is in Vietnamese (no unexplained English-only UI). | Full UI text audit |

---

## Appendix A: Glossary

| Term | Definition |
|---|---|
| **Adventure Engine** | The Godot modules managing world navigation, NPCs, quests, and narrative state. |
| **Buddy** | The player's dragon companion character. |
| **CEFR** | Common European Framework of Reference for Languages (Pre-A1, A1, A2, etc.). |
| **CVC** | Consonant-Vowel-Consonant word pattern (e.g., "cat", "dog"). |
| **L1** | A learner's first (native) language. Here: Vietnamese. |
| **Learning Engine** | The independent module managing vocabulary, exercises, scoring, and spaced repetition. |
| **Offline-First** | A design approach where the app functions fully without internet and syncs when connectivity is available. |
| **Pre-A1** | Below the A1 CEFR level; learners with minimal exposure to the target language. |
| **RLS** | Row Level Security — a Supabase/PostgreSQL feature that restricts data access per user. |
| **SRS** | Spaced Repetition System — an algorithm that schedules reviews at increasing intervals to maximize retention. |
| **The Silent Shadow** | The game's main antagonist; a narrative device representing lost language. |
| **Voice Gem** | In-game reward currency earned by completing quests; used narratively to restore the world. |

---

## Appendix B: Out-of-Scope Items (Confirmed)

The following items have been explicitly reviewed and confirmed as **not in scope** for the English Adventure product at any phase unless otherwise decided by the product owner:

- Mandarin, Korean, Japanese, or other non-English target languages.
- Grammar explanation videos or lecture-style content.
- Social media integration or sharing.
- Real-money purchases that bypass learning progression.
- Advertising of any kind.
- Use of real children's photos or faces.
- Real-time voice chat between players.

---

*Document maintained by the English Adventure product team. For questions, contact the Product Owner.*
