# VOCABULARY SYSTEM
# PROJECT: ENGLISH ADVENTURE (Prompt 04)

## 1. Nguồn dữ liệu & Single Source of Truth

Kho từ vựng Pre-A1 nằm tại `data/vocabulary/world_01_vocab.json` (32 từ, 6 nhóm chủ đề) và được quản lý bởi `VocabularyManager` (`scripts/learning/vocabulary_manager.gd`).

Mỗi từ vựng **chỉ tồn tại một bản ghi duy nhất**, có thể tái sử dụng cho Nghe, Nói, Đọc, Viết, Flashcard, Ôn tập và các Mini-Game Prompt 05 thông qua `QuestionManager.build_reusable_vocab_question(word_id, skill)`.

## 2. Trường dữ liệu bắt buộc của mỗi từ

- `id` (Word ID, ví dụ `word_apple`)
- `word` (`apple`)
- `ipa_us` (`/ˈæp.əl/`), `ipa_uk` (`/ˈæp.əl/`)
- `meaning_vi` (`Quả táo`)
- `part_of_speech` (`noun`, `adjective`, `number`)
- `audio_us_path`, `audio_uk_path`, `audio_status` (hiện đánh dấu `"missing_asset"` vì chưa có file `.ogg` thật, không tạo đường dẫn giả)
- `image_path` (`res://assets/learning/images/apple.svg` — 32/32 file SVG tồn tại thực tế)
- `example_sentence`, `example_translation`
- `topic` (`food`, `animals`, `colors`, `numbers`, `family`, `objects`), `difficulty`, `cefr_level`
- `related_words`
- `learning_status` & `mastery_score` (ghép động từ `LearningProgressManager`)

## 3. Bộ 32 từ vựng mẫu đã triển khai

- **Food (6):** `apple, banana, orange, milk, cake, water`
- **Animals (6):** `cat, dog, bird, fish, duck, elephant`
- **Colors (5):** `red, blue, green, yellow, pink`
- **Numbers (5):** `one, two, three, four, five`
- **Family (4):** `mom, dad, sister, brother`
- **Objects (6):** `ball, book, pen, bag, chair, ship`
