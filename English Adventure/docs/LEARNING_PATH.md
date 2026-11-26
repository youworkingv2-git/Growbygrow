# LEARNING PATH & CURRICULUM STRUCTURE
# PROJECT: ENGLISH ADVENTURE (Prompt 04)

## 1. Cấu trúc phân cấp 7 tầng

`Learning Path -> Level -> World -> Topic -> Lesson -> Learning Activity -> Question`

Được lưu hoàn toàn trong `data/curriculum/learning_curriculum.json` và điều phối bởi `LearningPathManager` (`scripts/learning/learning_path_manager.gd`).

## 2. Lộ trình 4 Giai đoạn

| Giai đoạn | Mã CEFR | Nội dung trọng tâm | Trạng thái hiện tại |
|---|---|---|---|
| Giai đoạn 1 | `Pre-A1` | Làm quen chữ cái A–Z, âm cơ bản, 32 từ vựng nền tảng, 15 cấu trúc câu đơn giản | **Đang hoạt động** |
| Giai đoạn 2 | `A1 Cơ bản` | Từ vựng mở rộng, mẫu câu và giao tiếp hàng ngày | Khung mở rộng (Planned) |
| Giai đoạn 3 | `A1 Mở rộng` | Hội thoại và tình huống thực tế | Khung mở rộng (Planned) |
| Giai đoạn 4 | `A2 Bước đầu` | Đọc hiểu, diễn đạt và giao tiếp mở rộng | Khung mở rộng (Planned) |

## 3. Cây Chủ đề & Bài học của `world_01` (Alphabet Island)

- **Topic 01: Alphabet A–Z** (`topic_01_alphabet`)
  - `lesson_01_00_intro` (gắn với `quest_01_new_adventure`): Chào hỏi & chữ cái đầu tiên
  - `lesson_01_01_abc` (gắn với `quest_02_lost_letters`): Chữ cái A, B, C & Âm cơ bản
  - `lesson_01_02_alphabet_all`: Khám phá đủ 26 chữ cái A–Z
- **Topic 02: Basic Vocabulary** (`topic_02_basic_vocab`)
  - `lesson_02_01_food_animals`: Đồ ăn & Động vật
  - `lesson_02_02_colors_numbers_family`: Màu sắc, Số đếm, Gia đình & Đồ vật
- **Topic 03: Basic Pronunciation & Blending** (`topic_03_basic_phonics`)
  - `lesson_03_01_digraphs_blending`: Tổ hợp SH, CH, TH & Ghép âm tạo từ
- **Topic 04: Basic Words in Context** (`topic_04_basic_words`)
  - `lesson_04_01_context`: Đọc & Nghe từ trong ngữ cảnh
- **Topic 05: Simple Sentences & Gate Challenge** (`topic_05_simple_sentences`)
  - `lesson_01_18_gate` (gắn với `quest_03_mysterious_gate`): Tổng hợp 4 kỹ năng & Mẫu câu cơ bản

## 4. Khả năng mở rộng không cần sửa code

Để thêm World mới hoặc Topic mới, chỉ cần bổ sung pack JSON và đăng ký qua `LearningContentRepository.register_curriculum_pack(path)` hoặc thêm vào `learning_curriculum.json`.
