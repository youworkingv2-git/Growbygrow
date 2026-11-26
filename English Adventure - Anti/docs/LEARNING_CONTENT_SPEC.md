# Learning Content Data Model Specification
## English Adventure

| Field | Value |
|---|---|
| **Document Version** | 1.0 |
| **Date** | 2026-11-26 |
| **Target Scale** | MVP: 26 letters, 100–150 words \| Future: 600–800+ words |
| **Supported Accents** | `en-US` (MVP required), `en-GB` (supported in schema & pipeline) |

---

## 1. Design Principles

1. **Data-Driven & Code-Independent:** All learning content lives in structured JSON files (and mirrored in Supabase PostgreSQL). Mini-games and quests **never** hardcode words, letters, or answers.
2. **Single Source of Truth (Zero Duplication):** A single vocabulary entry (e.g., `word_001` = `"apple"`) is referenced by ID across Word Hunt, Listening Mission, Word Builder, Sentence Builder, and Reading Challenge.
3. **Strict Separation of Phonological Concepts:**
   - **Letter Name:** What the letter is called in the alphabet (e.g., `C` = *"see"* `/siː/`).
   - **Letter Sound:** The primary sound the letter makes in words (e.g., `C` = `/k/` as in *cat*).
   - **Phoneme:** Distinct unit of sound in IPA (e.g., `/æ/`, `/k/`, `/t/`).
   - **Word Pronunciation:** Full spoken word with stress and IPA (e.g., `/ˈæp.əl/`).
   > **Rule:** Instructional UI and audio must never conflate Letter Name with Letter Sound.
4. **Bilingual Scaffolding:** Every English item carries accurate Vietnamese (`meaning_vi`, `hint_vi`, `explanation_vi`) so 10-year-old beginners never feel lost.

---

## 2. Alphabet & Phonics Data Model

### 2.1 Letter Object Schema (`data/alphabet/alphabet_data.json`)

```json
{
  "id": "letter_A",
  "letter_uppercase": "A",
  "letter_lowercase": "a",
  "letter_name": "ay",
  "letter_name_phonetic": "/eɪ/",
  "letter_name_audio_us": "letter_name_A_us.mp3",
  "letter_name_audio_gb": "letter_name_A_gb.mp3",
  "primary_sound": "/æ/",
  "primary_sound_description_vi": "Âm ngắn như trong từ 'apple', 'ant' – miệng mở rộng",
  "primary_sound_audio_us": "letter_sound_A_short_us.mp3",
  "secondary_sound": "/eɪ/",
  "secondary_sound_description_vi": "Âm dài như trong từ 'cake', 'name'",
  "secondary_sound_audio_us": "letter_sound_A_long_us.mp3",
  "vowel_or_consonant": "vowel",
  "example_word_id": "word_001",
  "example_word": "apple",
  "example_image": "apple.png",
  "stroke_order_uppercase": ["stroke_A_1", "stroke_A_2", "stroke_A_3"],
  "stroke_order_lowercase": ["stroke_a_1", "stroke_a_2"],
  "difficulty": 1,
  "mvp_priority": 1,
  "teaching_tip_vi": "Chữ A là nguyên âm. Dạy trẻ phân biệt tên chữ 'ay' và âm '/æ/' trong 'apple'."
}
```

### 2.2 Phonics & Blending Schema (`data/phonics/phonics_rules.json`)

```json
{
  "id": "phonics_cvc_01",
  "pattern": "CVC",
  "blending_group": "short_a",
  "phonemes": ["/k/", "/æ/", "/t/"],
  "result_word_id": "word_003",
  "result_word": "cat",
  "audio_blending_us": "blend_c_a_t_us.mp3",
  "explanation_vi": "Ghép 3 âm /k/ + /æ/ + /t/ đọc nhanh thành 'cat'.",
  "difficulty": 1
}
```

---

## 3. Vocabulary Data Model (`data/vocabulary/world_1/*.json`)

### 3.1 Complete Vocabulary JSON Schema

| Field | Type | Required | Description |
|---|---|---|---|
| `id` | string | Yes | Unique ID (`word_001` .. `word_999`) |
| `word` | string | Yes | English word (lowercase unless proper noun) |
| `phonetic_ipa` | string | Yes | Standard IPA in `/.../` |
| `phonetic_simple` | string | No | Child-friendly pronunciation guide |
| `meaning_vi` | string | Yes | Clear Vietnamese translation |
| `category` | string | Yes | Top-level taxonomy (`food`, `animals`, `colors`, etc.) |
| `sub_category` | string | No | Finer grouping (`fruits`, `pets`, etc.) |
| `difficulty` | int (1–5) | Yes | 1 = Basic MVP, 5 = Advanced |
| `world_id` | string | Yes | Primary world (`world_1` .. `world_6`) |
| `lesson_ids` | string[] | Yes | Lessons introducing this word |
| `image` | string | Yes | Filename in `assets/icons/` or `assets/ui/` |
| `audio_us` | string | Yes | `en-US` audio filename (MVP required) |
| `audio_gb` | string | No | `en-GB` audio filename (optional in MVP) |
| `example_sentence` | string | Yes | Simple English sentence using the word |
| `example_meaning_vi` | string | Yes | Vietnamese translation of example |
| `example_audio_us` | string | Yes | Audio for example sentence |
| `related_words` | string[] | No | Semantic links for distractors/hints |
| `antonyms` | string[] | No | Opposite words |
| `tags` | string[] | No | Search/filter tags (`cvc_word`, `mvp`, etc.) |
| `skills` | string[] | Yes | Subset of `["listening", "speaking", "reading", "writing"]` |
| `mini_game_types` | string[] | Yes | Compatible mini-games |
| `review_eligible` | bool | Yes | Whether included in SRS review |
| `srs_eligible` | bool | Yes | Tracks mastery level (0–5) |

### 3.2 Sample MVP Vocabulary (Representative Entries)

```json
{
  "id": "word_001",
  "word": "apple",
  "phonetic_ipa": "/ˈæp.əl/",
  "meaning_vi": "Quả táo",
  "category": "food",
  "sub_category": "fruits",
  "difficulty": 1,
  "world_id": "world_1",
  "lesson_ids": ["lesson_w1_food_01"],
  "image": "apple.png",
  "audio_us": "apple_us.mp3",
  "audio_gb": "apple_gb.mp3",
  "example_sentence": "I eat an apple.",
  "example_meaning_vi": "Tôi ăn một quả táo.",
  "example_audio_us": "example_apple_us.mp3",
  "related_words": ["fruit", "red", "green"],
  "antonyms": [],
  "skills": ["listening", "speaking", "reading", "writing"],
  "mini_game_types": ["word_hunt", "listening_mission", "word_builder", "sentence_builder", "reading_challenge"],
  "review_eligible": true,
  "srs_eligible": true
}
```

> Full sample dataset of 8+ words is stored in `data/vocabulary/world_1/vocab_world1_sample.json`.

---

## 4. Grammar Content Model (`data/grammar/grammar_world1.json`)

```json
{
  "id": "gram_001",
  "world_id": "world_1",
  "topic_key": "i_have_a",
  "name_en": "I have a/an...",
  "name_vi": "Tôi có một...",
  "pattern": "I + have + a/an + [Noun]",
  "explanation_vi": "Dùng 'I have a...' để nói mình có một đồ vật hoặc con vật. Dùng 'an' trước nguyên âm (a, e, i, o, u).",
  "examples": [
    { "en": "I have a dog.", "vi": "Tôi có một con chó.", "audio_us": "gram_001_ex1_us.mp3" },
    { "en": "I have an apple.", "vi": "Tôi có một quả táo.", "audio_us": "gram_001_ex2_us.mp3" }
  ],
  "difficulty": 1
}
```

MVP includes 5 core structures: `I am [Name]`, `It is a [Noun]`, `I have a/an [Noun]`, `I can [Verb]`, `There is a [Noun]`.

---

## 5. Question Data Model

Supported `question_type` enums:
1. `image_choice` — Show image, pick matching English word.
2. `audio_choice` — Play English audio, pick matching image/word.
3. `word_match` — Pair English words with images.
4. `fill_blank` — Complete a sentence (`The ___ is red.`).
5. `sentence_arrange` — Reorder scrambled word tiles.
6. `word_spell` — Build word from letter tiles (Word Builder).
7. `listen_repeat` — Listen to model audio, record & self-rate (Speaking MVP).

```json
{
  "question_id": "q_word_001_audio",
  "question_type": "audio_choice",
  "skill": "listening",
  "mini_game_type": "listening_mission",
  "content_ref_id": "word_001",
  "content_ref_type": "vocabulary",
  "prompt_text": "Nghe và chọn hình đúng!",
  "prompt_audio_us": "apple_us.mp3",
  "correct_answer": "apple",
  "wrong_answers": ["ball", "cat"],
  "hint_vi": "Đây là một loại trái cây màu đỏ.",
  "difficulty": 1,
  "points": 20
}
```

---

## 6. Spaced Repetition (SRS) Model

- Algorithm: **SM-2 (Simplified for Children)** stored in `vocabulary_mastery`.
- Quality Ratings mapped from mini-game performance:
  - `0 (Again)` — Incorrect or >2 hints used → reset `interval_days = 1`, `repetitions = 0`.
  - `1 (Hard)` — Correct on 2nd try or slow response → `interval_days = max(1, interval * 1.2)`.
  - `2 (Good)` — Correct on 1st try → standard SM-2 progression (`1d → 3d → 7d → 14d → 30d`).
  - `3 (Easy)` — Correct on 1st try + fast response across ≥2 skills → `ease_factor + 0.15`.
- `mastery_level` (0–5) advances only when `repetitions` and `interval_days` cross thresholds AND the word has been answered correctly in at least **2 different skills** (e.g., Listening + Writing).

---

## 7. Content Validation Rules & Asset Naming

### Naming Conventions
- **Word Audio:** `[word]_us.mp3`, `[word]_gb.mp3` (lowercase, underscores for spaces, e.g., `ice_cream_us.mp3`).
- **Letter Audio:** `letter_name_[A-Z]_us.mp3` vs. `letter_sound_[A-Z]_[short|hard]_us.mp3`.
- **Images:** `[word].png` (512x512px transparent PNG recommended).

### Automated Validation Checks (`tools/content_validator/`)
1. **Schema Completeness:** All required fields non-null and non-empty.
2. **Unique IDs:** No duplicate `id` across JSON files.
3. **IPA Format:** Must start/end with `/` and contain valid Unicode IPA characters.
4. **Asset Existence:** Every referenced `.png` and `.mp3` exists in `assets/`.
5. **Letter Name ≠ Letter Sound:** Automated check ensuring `letter_name_audio` and `primary_sound_audio` do not point to the same file.
6. **Difficulty Bounds:** `difficulty` strictly integer `1..5`.

---

## 8. Content Addition Workflow (Scaling to 600–800 Words)

1. Author adds vocabulary entries to `data/vocabulary/world_X/vocab_worldX.json`.
2. Add matching `.png` and `_us.mp3` (and optional `_gb.mp3`) assets to `assets/`.
3. Run `python tools/content_validator/validate_vocabulary.py data/vocabulary/`.
4. Upload new assets to Supabase Storage bucket (`learning-assets`).
5. Run seed/upsert migration script to sync JSON into Supabase `vocabulary` table.
6. **Zero GDScript or Godot scene changes required.**
