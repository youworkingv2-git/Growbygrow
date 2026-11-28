# QUY CHUẨN DỮ LIỆU TỪ VỰNG & CỤM TỪ (VOCABULARY CONTENT SPEC)
# PROJECT: ENGLISH ADVENTURE

**Tệp dữ liệu chính:**
- `data/vocabulary/world_01_vocab.json` (**115 từ Pre-A1**)
- `data/vocabulary/world_02_a1_vocab.json` (**32 từ mẫu A1**)
- `data/phrases/common_phrases.json` (**48 cụm từ thông dụng**: 36 Pre-A1 + 12 A1)

---

## 1. Cấu trúc bản ghi từ vựng (`VocabularyRecord`)

Mỗi mục trong mảng `"vocabulary"` tuân thủ schema thống nhất:
- `id`: Mã duy nhất (`word_apple`, `word_library`, ...).
- `word`: Từ tiếng Anh viết chuẩn US mặc định (`"color"`, `"mom"`, `"favorite"`).
- `ipa_us` / `ipa_uk`: Phiên âm IPA tách biệt cho `en-US` và `en-GB` (VD: `water` = `/ˈwɔː.t̬ɚ/` US vs `/ˈwɔː.tə/` UK; `park` = `/pɑːrk/` US vs `/pɑːk/` UK).
- `meaning_vi`: Nghĩa tiếng Việt ngắn gọn, đúng lứa tuổi trẻ ~10 tuổi.
- `part_of_speech`: `noun`, `verb`, `adjective`, `adverb`, `number`, `interjection`.
- `topic` & `topics`: Chủ đề chính và mảng nhãn đa chủ đề (VD: `apple` mang `["fruits", "food"]`, `orange` mang `["fruits", "food", "colors"]`, `school` mang `["school", "places"]`).
- `world_id` & `cefr_level`: `world_01` (`Pre-A1`) hoặc `world_02` (`A1`).
- `difficulty`: `1` (cơ bản), `2` (trung bình), `3` (mở rộng A1).
- `image_path`: Đường dẫn `res://assets/learning/images/<word>.svg` (100% là hình vector riêng biệt, không dùng chung một hình cho nhiều nghĩa khác nhau).
- `audio_us_path` / `audio_uk_path` / `audio_status`: Hiện giữ trung thực `"missing_asset"` vì chưa thu file `.ogg`, phát âm trực tiếp qua TTS trong `VoiceManager`.
- `example_sentence` & `example_translation`: Câu ví dụ tự nhiên kèm bản dịch tiếng Việt.
- `syllables`, `phonemes`, `related_words`, `antonyms`, `synonyms`.
- `review_status`: `"approved"` (các trạng thái hợp lệ: `draft`, `under_review`, `approved`, `published`, `archived`).
- `asset_license`: `"Project Original Vector (CC0-1.0)"`.

---

## 2. Cấu trúc Cụm từ thông dụng (`common_phrases.json`)

Mỗi cụm từ (`phr_01`..`phr_48`) chứa: `id`, `phrase_en`, `meaning_vi`, `ipa_us`, `ipa_uk`, `cefr_level`, `topic`, `world_id`, `linked_vocab_ids`, `example_sentence`, `example_translation`, `audio_status`, `review_status`.

`VocabularyManager` và `QuestionManager` tái sử dụng trực tiếp cả từ vựng lẫn cụm từ cho Listening, Reading, Writing, Speaking, Mini-Games và Ôn tập Spaced Repetition mà không tạo bản sao dữ liệu.
