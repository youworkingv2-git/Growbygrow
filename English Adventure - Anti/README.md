[Status: In Development] [Engine: Godot 4] [Platforms: Android | iOS | Web] [Language: GDScript]

# 🐉 English Adventure

> *A magical world has been silenced. Only YOU can restore it – one word at a time.*

---

## About the Game

**English Adventure** is a 3D/2.5D cartoon adventure game designed for Vietnamese-speaking children around age 10 who are just beginning to learn English. The world of Linguara was once filled with sound, colour, and life — until **The Silent Shadow** swept through and drained every word, every voice, and every letter from existence. As the chosen hero, the player must journey across six magical worlds, mastering English skills to break the Shadow's curse and restore the world to life.

Unlike flashcard apps or drill-based tools, English Adventure wraps every learning moment inside a living story. Vocabulary is not memorised in isolation — it is discovered, used to solve puzzles, spoken aloud to unlock doors, and read to uncover secrets. The player earns their progress the way adventurers always have: by being brave enough to try.

What sets English Adventure apart is its **independent Learning Engine** — the educational logic is completely decoupled from the game engine. This means vocabulary, quests, and mini-game content are fully data-driven and can be updated or expanded without touching a single line of game code. Every spelling quiz, listening challenge, and sentence puzzle is powered by the same shared vocabulary database, ensuring consistency and eliminating content duplication across the entire game.

---

## ✨ Features (MVP)

- 🏝️ **World 1 – Alphabet Island** fully playable with story quests and progression
- 🔤 **26 Letters** introduced through exploration and character interactions
- 📚 **100–150 vocabulary words** organised by theme and difficulty
- 🎮 **5 Mini-Games** covering all 4 English skills:
  - **Word Hunt** – find hidden words in the environment (Reading / Vocabulary)
  - **Listening Mission** – hear a word or sentence and choose the right object (Listening)
  - **Word Builder** – drag letters to spell words (Writing / Spelling)
  - **Sentence Builder** – arrange word tiles into correct sentences (Writing / Grammar)
  - **Reading Challenge** – read a short passage and answer questions (Reading / Comprehension)
- 🐲 **Buddy the Dragon** – AI companion that guides, encourages, and hints without spoiling
- 🦉 **Professor Owl** – in-world teacher character who explains new words and grammar concepts
- 🗺️ **15–20 quests** with branching dialogue and meaningful English-language objectives
- 🎵 **Speaking MVP** – listen-and-repeat exercises with self-rating (no AI grading required)
- 📡 **Offline-first** gameplay with background sync to Supabase when online
- 🔒 **Secure backend** – no API keys ever stored in the client
- 🎨 **2.5D Cartoon UI** – 2D sprites with parallax depth layers, colourful and age-appropriate

---

## 🗺️ Game Worlds

| # | World | Theme | English Focus | Status |
|---|-------|-------|---------------|--------|
| 1 | 🏝️ Alphabet Island | Tropical adventure, ancient ruins | Letters A–Z, Phonics, Basic Vocabulary | ✅ MVP Built |
| 2 | 🌲 Vocabulary Forest | Enchanted woodland, talking animals | Nouns, Verbs, Adjectives (300+ words) | 🔜 Post-MVP |
| 3 | 🏰 Sentence Kingdom | Medieval castle, royal court | Sentence structure, Grammar basics | 🔜 Post-MVP |
| 4 | 🌊 Listening Ocean | Underwater kingdom, sirens | Listening comprehension, Phonics patterns | 🔜 Post-MVP |
| 5 | 🏙️ Speaking City | Futuristic city, radio stations | Speaking, Pronunciation, Conversation | 🔜 Post-MVP |
| 6 | 👑 Challenge Kingdom | Final dungeon, The Silent Shadow | All 4 skills combined, Final boss | 📋 Planned |

---

## 🛠️ Tech Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| [Godot Engine](https://godotengine.org/) | 4.x | Game engine – rendering, physics, scene management |
| GDScript | Built-in | Primary scripting language |
| Supabase | Latest | Backend-as-a-service – auth, database, storage, realtime |
| PostgreSQL | 15+ | Relational database via Supabase |
| Supabase CLI | Latest | Local development, migrations, edge functions |
| Git | Latest | Version control |
| Android SDK | API 21+ | Android export target |
| Xcode / iOS SDK | Latest | iOS export target |

---

## 📁 Project Structure

```
English Adventure - Anti/
│
├── README.md                   # This file
├── ARCHITECTURE.md             # System architecture deep-dive
├── .env.example                # Environment variable template (never commit .env)
├── .gitignore                  # Excludes secrets, build artefacts, OS junk
│
├── docs/                       # All project documentation
│   ├── game-design.md          # Game design document (GDD)
│   ├── learning-engine.md      # Learning engine specification
│   ├── worlds/                 # Per-world design docs
│   ├── minigames/              # Per-mini-game specs
│   └── api/                    # Supabase schema & API reference
│
├── project.godot               # Godot project file
├── export_presets.cfg          # Platform export configurations
│
├── scenes/                     # Godot scenes (.tscn)
│   ├── main/                   # Main menu, loading, settings
│   ├── worlds/                 # World scenes (one folder per world)
│   ├── minigames/              # Mini-game scenes
│   ├── ui/                     # Shared HUD, dialogue, inventory UI
│   └── characters/             # Player, Buddy, NPCs, bosses
│
├── scripts/                    # GDScript source files (.gd)
│   ├── core/                   # Autoloads, singletons, event bus
│   ├── learning_engine/        # INDEPENDENT learning subsystem
│   │   ├── vocabulary_db.gd    # Shared vocabulary data layer
│   │   ├── progress_tracker.gd # Per-player skill & word progress
│   │   └── content_loader.gd   # Data-driven content loading (no hardcoding)
│   ├── adventure_engine/       # Game world, quests, NPCs, physics
│   ├── minigames/              # Mini-game controllers (1 per game)
│   └── backend/                # Supabase client wrapper (secrets-safe)
│
├── assets/                     # All game assets
│   ├── audio/                  # Music, SFX, voice lines
│   ├── fonts/                  # Kid-friendly, Unicode-compatible fonts
│   ├── images/                 # UI sprites, icons, backgrounds
│   ├── models/                 # 3D models (characters, props, environments)
│   ├── animations/             # Skeletal & sprite animations
│   └── shaders/                # Custom Godot shaders (parallax, glow, etc.)
│
├── data/                       # Game content data (JSON / CSV)
│   ├── vocabulary/             # Word lists, definitions, audio refs
│   ├── quests/                 # Quest definitions, dialogue trees
│   ├── minigame_configs/       # Mini-game level configs (data-driven)
│   └── worlds/                 # World layout, NPC placement data
│
├── supabase/                   # Supabase project configuration
│   ├── config.toml             # Supabase CLI config
│   ├── migrations/             # SQL migration files (versioned)
│   ├── seed.sql                # Development seed data (no real user data)
│   └── functions/              # Supabase Edge Functions
│
└── tests/                      # Automated tests
    ├── unit/                   # GDScript unit tests
    └── integration/            # Backend integration tests
```

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **[Godot Engine 4.x](https://godotengine.org/download)** – Standard version (not Mono/C#)
- **[Supabase CLI](https://supabase.com/docs/guides/cli)** – For local backend development
- **[Git](https://git-scm.com/)** – Version control
- **[Docker](https://www.docker.com/)** – Required by Supabase CLI for local emulation
- **Android SDK** (optional) – Only needed for Android export
- **Xcode** (optional, macOS only) – Only needed for iOS export

---

### Setup

**1. Clone the repository**

```bash
git clone https://github.com/your-org/english-adventure.git
cd "English Adventure - Anti"
```

**2. Configure environment variables**

```bash
cp .env.example .env
# Open .env in your editor and fill in your values
# ⚠️  NEVER commit the .env file — it is in .gitignore
```

**3. Start the local Supabase backend**

```bash
supabase start
# This spins up a local PostgreSQL + Auth + Storage stack via Docker
```

**4. Run database migrations**

```bash
supabase db reset
# Applies all migrations in supabase/migrations/ and seeds dev data
```

**5. Import the project in Godot 4**

- Open **Godot 4**
- Click **Import** → navigate to the project root → select `project.godot`
- Wait for the import to complete

**6. Run the game**

- Press **F5** (or the Play button) in the Godot editor
- The game will start from the main menu scene

---

### Environment Variables

Copy `.env.example` to `.env` and fill in your Supabase project values. **Never commit real credentials to version control.**

```env
# .env.example
# Copy this file to .env and fill in your values.
# The .env file is listed in .gitignore and must NEVER be committed.

SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# For local development (supabase start), use the values printed by the CLI:
# SUPABASE_URL=http://localhost:54321
# SUPABASE_ANON_KEY=<local-anon-key-from-supabase-start>

# Never commit real keys to version control
```

> **Security note:** The game client only ever uses the `SUPABASE_ANON_KEY` (a public, row-level-security-protected key). Service role keys and secrets live exclusively in Supabase Edge Functions and never touch the client.

---

## 📖 Documentation

All project documentation lives in the [`docs/`](docs/) folder:

| Document | Description |
|----------|-------------|
| [`docs/game-design.md`](docs/game-design.md) | Full Game Design Document (GDD) – story, mechanics, progression |
| [`docs/learning-engine.md`](docs/learning-engine.md) | Learning Engine specification – how education integrates with gameplay |
| [`docs/worlds/alphabet-island.md`](docs/worlds/alphabet-island.md) | World 1 design: quests, NPCs, mini-game placement |
| [`docs/minigames/`](docs/minigames/) | Individual mini-game specs (rules, scoring, difficulty curves) |
| [`docs/api/`](docs/api/) | Supabase schema reference and RLS policy documentation |
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | System architecture – module map, data flows, key decisions |

---

## 🏗️ Architecture

English Adventure is built on a **modular, 17-module architecture** with one foundational principle:

> **The Learning Engine is completely independent from the Adventure Engine.**

This means:
- Educational logic (vocabulary, scoring, progress) has zero dependency on world geometry, quest state, or character physics
- Mini-games pull from a **single shared Vocabulary Database** — no content duplication across the 5 mini-games
- All learning content is **data-driven**: add new words, quests, or mini-game levels by editing JSON/CSV data files, not GDScript
- The adventure engine calls into the learning engine via a clean API boundary — they never reach into each other's internals

```
┌─────────────────────────────────────────────────────┐
│                   GODOT GAME CLIENT                 │
│  ┌─────────────────┐    ┌────────────────────────┐  │
│  │ Adventure Engine│◄──►│    Learning Engine     │  │
│  │ (worlds, quests,│    │  (vocab DB, progress,  │  │
│  │  NPCs, physics) │    │   mini-game logic,     │  │
│  │                 │    │   content loader)      │  │
│  └────────┬────────┘    └──────────┬─────────────┘  │
│           │                        │                 │
│           └──────────┬─────────────┘                 │
│                      ▼                               │
│              Supabase Client (secrets-safe)          │
└──────────────────────┬──────────────────────────────┘
                       │  HTTPS (anon key only)
                       ▼
        ┌──────────────────────────┐
        │       SUPABASE           │
        │  Auth | PostgreSQL       │
        │  Storage | Edge Funcs   │
        └──────────────────────────┘
```

For the full module map, data flow diagrams, and key architectural decisions, see **[ARCHITECTURE.md](ARCHITECTURE.md)**.

---

## 📋 MVP Scope

### ✅ In Scope (MVP)

- World 1: Alphabet Island — complete with story, quests, and all 5 mini-games
- 26 letters of the English alphabet
- 100–150 curated vocabulary words (nouns, verbs, common adjectives)
- 15–20 story quests with NPC dialogue
- Main player character (boy or girl choice at start)
- Buddy the Dragon companion with hint system
- Professor Owl tutorial and word-explanation system
- Speaking: listen-and-repeat with player self-rating (thumbs up / thumbs down)
- Offline-first with Supabase sync
- Player progress persistence (words learned, quests completed, stars earned)
- Android + iOS + Web/Desktop export

### 🔜 Post-MVP (Future Worlds)

- Worlds 2–6 (Vocabulary Forest → Challenge Kingdom)
- 300+ additional vocabulary words per world
- Advanced grammar mini-games
- AI-assisted pronunciation grading (Speaking City, World 5)
- Multiplayer / co-op quest modes
- Parent / teacher dashboard (Supabase-backed)
- Localisation beyond Vietnamese ↔ English

---

## ⚠️ Important Rules

These rules apply to **all contributors** and must never be broken:

| Rule | Why It Matters |
|------|---------------|
| 🚫 **No real children's data in development** | Legal (COPPA/GDPR-K) and ethical obligation — use only synthetic seed data |
| 🔑 **No hardcoded API keys — ever** | Keys in source code get leaked; use `.env` and Supabase Edge Functions |
| 📦 **Content is data-driven** | New vocab, quests, and levels must be added via data files, not code changes |
| 🧩 **Learning engine stays independent** | Never import adventure engine modules into learning engine scripts |
| 🔒 **Service role key never touches the client** | Only the anon key (protected by RLS) is used in the Godot client |
| 🧪 **Seed data only for local dev** | `supabase/seed.sql` contains fictional characters — never real users |

---

## 📄 License

```
MIT License

Copyright (c) 2024 English Adventure Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🙏 Acknowledgments

- **[Godot Engine](https://godotengine.org/)** – The free, open-source game engine that made this project possible
- **[Supabase](https://supabase.com/)** – Open-source Firebase alternative powering our backend
- **Vietnamese educators and EFL teachers** whose insights shaped the learning progression and difficulty curve
- **Children's game design research** – including principles from games like Duolingo, Reading Eggs, and Khan Academy Kids that informed our engagement model
- Every parent who wants their child to discover English as an adventure, not a chore 🐉

---

*English Adventure – Restore the world. Learn English. One word at a time.*
