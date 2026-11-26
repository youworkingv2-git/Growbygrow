# LEARNING CONTENT DATA MODEL SPECIFICATION
# PROJECT: ENGLISH ADVENTURE

Tài liệu này quy định cấu trúc dữ liệu học tập **độc lập hoàn toàn với code game**, cho phép đội ngũ sư phạm bổ sung từ 100–150 từ MVP lên **600–800+ từ vựng** và **6 Worlds** mà không cần sửa GDScript.

---

## 1. NGUYÊN TẮC SƯ PHẠM & KỸ THUẬT CỐT LÕI

1. **Tách biệt tuyệt đối 4 lớp phát âm (Phonics Separation Rule):**
   - **Letter Name:** Tên gọi chữ cái trong bảng chữ cái (VD: `A` đọc là `/eɪ/`).
   - **Letter Sound:** Âm đại diện cơ bản khi ghép từ (VD: `a` trong `apple` đọc là `/æ/`).
   - **Phoneme:** Ký hiệu âm vị chuẩn IPA độc lập (`/æ/`, `/b/`, `/k/`).
   - **Word Pronunciation:** Phát âm đầy đủ của cả từ (`apple` = `/ˈæp.əl/`).
   > **Cấm tuyệt đối** việc dùng file âm thanh của *Letter Name* (`/eɪ/`) để dạy *Letter Sound* trong các bài ghép vần Phonics (`/æ/`).
2. **Chuẩn hóa đa giọng (`en-US` và `en-GB`):**
   - Mọi bản ghi âm hỗ trợ dictionary `audio_accents` với key `"en-US"` và `"en-GB"`.
   - Trong MVP, bắt buộc có `"en-US"`; `"en-GB"` là optional và `AudioModule` tự động fallback về `"en-US"` nếu thiếu.
3. **Tái sử dụng đa kỹ năng (Single Source of Truth):**
   - Một đối tượng từ vựng chứa đủ metadata (`image`, `audio`, `ipa`, `meaning_vi`, `example`, `skills`) để sinh tự động câu hỏi cho cả 4 kỹ năng và toàn bộ 5+ mini-games.

---

## 2. ĐẶC TẢ 10 ĐỐI TƯỢNG DỮ LIỆU HỌC TẬP

### 2.1. Vocabulary (Từ vựng)

```json
{
  "id": "word_001",
  "word": "apple",
  "part_of_speech": "noun",
  "phonetic": "/ˈæp.əl/",
  "phonetic_uk": "/ˈæp.əl/",
  "meaning_vi": "Quả táo",
  "category": "food",
  "world_id": "world_01",
  "difficulty": 1,
  "cefr_level": "Pre-A1",
  "image": "res://assets/learning/images/food/apple.webp",
  "audio": {
    "en-US": "res://assets/audio/voices/en-US/words/apple.ogg",
    "en-GB": "res://assets/audio/voices/en-GB/words/apple.ogg"
  },
  "syllables": ["ap", "ple"],
  "phonics_tags": ["short_a", "double_p"],
  "example": "I eat an apple.",
  "example_meaning": "Tôi ăn một quả táo.",
  "example_audio": {
    "en-US": "res://assets/audio/voices/en-US/examples/word_001_ex.ogg"
  },
  "related_words": ["word_002", "word_015"],
  "confusable_words": ["word_044"],
  "skills": ["listening", "speaking", "reading", "writing"],
  "review_metadata": {
    "initial_interval_days": 1,
    "ease_factor_default": 2.5,
    "priority_weight": 1.0,
    "is_core_anchor": true
  }
}
```

**Giải thích trường mở rộng để nâng lên 600–800 từ:**
- `world_id` & `category`: Giúp phân nhóm tải Content Pack theo World và chọn distractor cùng/khác chủ đề thông minh.
- `confusable_words`: Danh sách các từ dễ nhầm về âm hoặc mặt chữ (dùng để tăng độ khó thích ứng ở Level cao).
- `audio`: Hỗ trợ `en-US` bắt buộc ở MVP, `en-GB` tùy chọn và sẵn sàng mở rộng.

---

### 2.2. Phonics (Bảng chữ cái & Ngữ âm)

Tách riêng **Letter Name**, **Letter Sound**, **Phoneme** và **Blending Examples**:

```json
{
  "id": "phonics_a_short",
  "letter": "A",
  "lowercase": "a",
  "letter_type": "vowel",
  "order_index": 1,
  "world_id": "world_01",
  "letter_name": {
    "ipa": "/eɪ/",
    "audio": {
      "en-US": "res://assets/audio/voices/en-US/letters/name_a.ogg",
      "en-GB": "res://assets/audio/voices/en-GB/letters/name_a.ogg"
    }
  },
  "letter_sound": {
    "phoneme": "æ",
    "ipa": "/æ/",
    "mouth_hint_vi": "Mở miệng hơi rộng như chuẩn bị nói 'e' nhưng kéo sang âm 'a'.",
    "audio": {
      "en-US": "res://assets/audio/voices/en-US/phonemes/sound_short_a.ogg",
      "en-GB": "res://assets/audio/voices/en-GB/phonemes/sound_short_a.ogg"
    }
  },
  "blending_examples": [
    {
      "pattern": "c-a-t",
      "segments": ["k", "æ", "t"],
      "word_id": "word_012",
      "blended_word": "cat"
    }
  ],
  "anchor_word_ids": ["word_001", "word_002", "word_012"],
  "difficulty": 1
}
```

---

### 2.3. Grammar (Cấu trúc câu & Ngữ pháp)

```json
{
  "id": "gram_001",
  "world_id": "world_01",
  "title_en": "It is a / an + Noun",
  "title_vi": "Giới thiệu một đồ vật / con vật",
  "explanation_vi": "Dùng 'an' trước từ bắt đầu bằng nguyên âm (a, e, i, o, u), và 'a' cho các từ còn lại.",
  "pattern_template": "{pronoun} {be_verb} {article} {noun}.",
  "slots": [
    { "slot": "pronoun", "fixed_options": ["It", "This"] },
    { "slot": "be_verb", "fixed_options": ["is"] },
    { "slot": "article", "rule": "a_or_an_by_next_word" },
    { "slot": "noun", "vocab_categories": ["food", "animals", "school"], "max_difficulty": 2 }
  ],
  "examples": [
    {
      "sentence_en": "It is an apple.",
      "sentence_vi": "Đó là một quả táo.",
      "audio": { "en-US": "res://assets/audio/voices/en-US/sentences/sent_001.ogg" },
      "word_ids": ["word_001"]
    }
  ],
  "difficulty": 1
}
```

---

### 2.4. Listening (Bài nghe & Nhiệm vụ nghe)

```json
{
  "id": "list_001",
  "world_id": "world_01",
  "listening_type": "word",
  "prompt_vi": "Nghe âm thanh và chọn hình đúng nhé!",
  "target_word_id": "word_001",
  "audio_override": null,
  "transcript_en": "apple",
  "translation_vi": "Quả táo",
  "supports_slow_speed": true,
  "slow_rate": 0.82,
  "distractor_strategy": "different_category_easy",
  "option_count": 3,
  "difficulty": 1
}
```
*(Hỗ trợ `listening_type`: `"phoneme"`, `"word"`, `"phrase"`, `"sentence"`, `"short_conversation"` cho World 1–6).*

---

### 2.5. Speaking (Luyện nói / Repeat-After-Me & Prompt hội thoại)

```json
{
  "id": "speak_001",
  "world_id": "world_01",
  "speaking_mode": "repeat_word",
  "prompt_vi": "Nghe Buddy đọc mẫu rồi nói to theo nhé!",
  "target_text_en": "apple",
  "ipa": "/ˈæp.əl/",
  "reference_word_id": "word_001",
  "audio": {
    "en-US": "res://assets/audio/voices/en-US/words/apple.ogg"
  },
  "mvp_self_check_enabled": true,
  "post_mvp_asr_config": {
    "target_phonemes": ["æ", "p", "ə", "l"],
    "min_confidence": 0.72
  },
  "difficulty": 1
}
```

---

### 2.6. Reading (Bài đọc hiểu)

```json
{
  "id": "read_001",
  "world_id": "world_01",
  "reading_type": "single_sentence_picture_match",
  "title_vi": "Đọc câu và chọn bức tranh đúng",
  "passage_en": "I see a red apple.",
  "passage_vi": "Tôi thấy một quả táo đỏ.",
  "clickable_word_ids": ["word_001", "word_color_red"],
  "passage_audio": {
    "en-US": "res://assets/audio/voices/en-US/reading/read_001.ogg"
  },
  "comprehension_questions": [
    {
      "question_id": "rq_001",
      "question_type": "image_match",
      "prompt_vi": "Bức tranh nào đúng với câu trên?",
      "correct_image": "res://assets/learning/images/scenes/red_apple.webp",
      "distractor_images": [
        "res://assets/learning/images/scenes/green_ball.webp",
        "res://assets/learning/images/scenes/blue_cat.webp"
      ]
    }
  ],
  "difficulty": 1
}
```

---

### 2.7. Writing (Ghép chữ & Ghép câu)

```json
{
  "id": "write_001",
  "world_id": "world_01",
  "writing_type": "word_spelling",
  "target_word_id": "word_001",
  "target_text": "apple",
  "hint_image": "res://assets/learning/images/food/apple.webp",
  "hint_meaning_vi": "Quả táo",
  "prefilled_indices": [0],
  "extra_distractor_letters": ["o", "b"],
  "difficulty": 1
}
```
*(Với `writing_type: "sentence_ordering"`, `tokens` chứa mảng từ đúng thứ tự và `distractor_tokens` chứa từ nhiễu).*

---

### 2.8. Learning Questions (Câu hỏi chuẩn hóa dùng chung)

```json
{
  "id": "q_w01_001",
  "lesson_id": "lesson_01_01",
  "skill": "listening",
  "question_type": "audio_to_image",
  "target_ref_type": "vocabulary",
  "target_ref_id": "word_001",
  "prompt_vi": "Bé nghe thấy từ nào?",
  "prompt_en": "Which one do you hear?",
  "difficulty": 1,
  "buddy_hint_vi": "Màu đỏ, giòn và ngọt — quả gì nhỉ?",
  "buddy_wrong_feedback_vi": "Âm đầu là /æ/ – 'apple' là quả táo đó!",
  "options": [
    { "id": "opt_1", "label_en": "apple", "vocab_id": "word_001", "is_correct": true },
    { "id": "opt_2", "label_en": "ball", "vocab_id": "word_005", "is_correct": false },
    { "id": "opt_3", "label_en": "cat", "vocab_id": "word_012", "is_correct": false }
  ]
}
```

---

### 2.9. Learning Examples (Câu ví dụ độc lập)

```json
{
  "id": "ex_001",
  "word_id": "word_001",
  "grammar_topic_id": "gram_001",
  "sentence_en": "I eat an apple.",
  "sentence_vi": "Tôi ăn một quả táo.",
  "highlight_word": "apple",
  "audio": {
    "en-US": "res://assets/audio/voices/en-US/examples/word_001_ex.ogg"
  },
  "difficulty": 1
}
```

---

### 2.10. Review Items (Đối tượng Ôn tập & Spaced Repetition)

```json
{
  "item_type": "vocabulary",
  "target_id": "word_001",
  "mastery_score": 68.5,
  "mastery_level": 3,
  "skills_verified": ["listening", "writing"],
  "last_reviewed_at": "2026-11-25T10:00:00Z",
  "next_review_at": "2026-11-27T10:00:00Z",
  "interval_days": 2,
  "ease_factor": 2.35,
  "consecutive_first_try_correct": 2,
  "mistake_count_recent": 1,
  "recommended_mini_games": ["sentence_builder", "reading_challenge"]
}
```
*(Chú ý `recommended_mini_games` ưu tiên chọn kỹ năng trẻ **chưa** kiểm chứng để hoàn thành yêu cầu đa kỹ năng trước khi đạt Mastery Level 4–5).*

---

## 3. TỔ CHỨC FILE DỮ LIỆU ĐỂ MỞ RỘNG 600–800+ TỪ VỰNG

Để tránh file JSON khổng lồ khó bảo trì và tải chậm trên Web/Mobile, dữ liệu được tách theo **World / Topic Pack**:

```text
data/
├── manifest.json                      # Danh mục tất cả content packs + content_version + checksum
├── schemas/                           # JSON Schemas kiểm tra tự động
│   ├── vocabulary.schema.json
│   ├── phonics.schema.json
│   ├── grammar.schema.json
│   └── quest.schema.json
├── alphabet/
│   └── letters_a_z.json               # 26 chữ cái chuẩn hóa (letter_name + letter_sound)
├── phonics/
│   └── world_01_phonics.json          # Nhóm âm & quy tắc ghép vần CVC
├── vocabulary/
│   ├── world_01_vocab_core.json       # 100–150 từ MVP (Alphabet Island)
│   └── ...                            # world_02_animals.json, world_02_food.json (Post-MVP)
├── grammar/
│   └── world_01_patterns.json         # 10–15 cấu trúc câu MVP
├── listening/
│   └── world_01_listening.json
├── reading/
│   └── world_01_reading.json
└── quests/
    └── world_01_quests.json           # 18 Quests của Alphabet Island
```

**Quy tắc đánh ID thống nhất:**
- Từ vựng: `word_001` .. `word_999` (hoặc `w01_apple` nếu theo slug, **nhất quán 1 quy ước `word_NNN` để giữ ổn định tham chiếu kể cả khi đổi chính tả/câu ví dụ**).
- Phonics: `phonics_<letter>_<variant>` (ví dụ `phonics_a_short`, `phonics_b`).
- Grammar: `gram_NNN`.
- Quests: `quest_w01_01` .. `quest_w01_18`.

---

## 4. HỆ THỐNG KIỂM TRA TÍNH HỢP LỆ DỮ LIỆU (CONTENT VALIDATION SYSTEM)

Mọi dữ liệu trước khi đóng gói vào game hoặc import lên Supabase phải vượt qua **Content Validator** (chạy được cả dưới dạng CLI/CI script và Editor/Test check trong Godot `tests/`):

| Kiểm tra | Quy tắc Validate bắt buộc |
|---|---|
| **Schema & Kiểu dữ liệu** | Đầy đủ các field bắt buộc (`id`, `word`, `phonetic`, `meaning_vi`, `category`, `difficulty`, `image`, `audio.en-US`, `example`, `example_meaning`, `skills`). Không có chuỗi rỗng. |
| **Tính duy nhất ID** | Không trùng lặp `id` giữa các file vocabulary/phonics/grammar/quest. |
| **Kiểm tra IPA** | Trường `phonetic` phải bắt đầu và kết thúc bằng `/` (ví dụ `/ˈæp.əl/`), chỉ chứa ký tự IPA/dấu trọng âm hợp lệ, không chứa chữ số hoặc ký tự lỗi font. |
| **Kiểm tra Nghĩa tiếng Việt** | `meaning_vi` và `example_meaning` phải hợp lệ UTF-8, không trùng y nguyên chuỗi tiếng Anh (trừ danh từ riêng/từ mượn cho phép whitelist), không để `"TODO"` hay placeholder. |
| **Kiểm tra Tài nguyên Hình ảnh** | File tại `image` phải tồn tại thực tế trong `assets/`, đúng định dạng cho phép (`.webp`, `.png`), dung lượng <= 250 KB/ảnh và kích thước chuẩn (tối thiểu 256x256 px). |
| **Kiểm tra Tài nguyên Âm thanh** | File tại `audio["en-US"]` (và `"en-GB"` nếu khai báo) phải tồn tại, định dạng `.ogg` hoặc `.mp3`, thời lượng hợp lý (`0.25s – 10s`), không file 0 byte. |
| **Kiểm tra Phonics Separation** | `letter_name.audio` và `letter_sound.audio` không được trỏ tới cùng một file âm thanh (trừ trường hợp đặc biệt được whitelist rõ ràng). |
| **Kiểm tra Câu ví dụ & Đáp án** | Với câu ví dụ của `word_X`, chuỗi `example` (không phân biệt hoa thường) phải chứa từ mục tiêu (hoặc biến thể hợp lệ trong `word_forms`). Mỗi `question` phải có **đúng 1** đáp án `is_correct: true` (hoặc >= 1 với multi-select) và tối thiểu 2 `options` không trùng nhau. |
| **Tham chiếu chéo (Referential Integrity)** | Mọi `word_id` trong `quests`, `phonics.anchor_word_ids`, `reading`, `writing`, `related_words` đều phải tồn tại trong kho `vocabulary`. |
