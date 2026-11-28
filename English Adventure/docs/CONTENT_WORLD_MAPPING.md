# PHÂN BỔ NỘI DUNG VÀO THẾ GIỚI 3D (CONTENT WORLD MAPPING)
# PROJECT: ENGLISH ADVENTURE

**Tệp cấu hình:** `data/curriculum/learning_curriculum.json` & `data/curriculum/a1_sample_curriculum.json`.

---

## 1. Lộ trình dài hạn 6 Thế Giới (Lingua Realm)

| World ID | Tên thế giới | Cấp độ tham chiếu | Trạng thái | Trọng tâm nội dung |
|---|---|---|---|---|
| `world_01` | **Alphabet Island** | Pre-A1 | **Active (Playable hoàn chỉnh)** | 26 chữ cái, Phonics, 115 từ vựng nền tảng, 36 cụm từ, 22 mẫu câu, 10 bài học 4 kỹ năng |
| `world_02` | **Vocabulary Forest** | A1 Cơ bản | **Sample Playable + Mở khóa theo điều kiện** | 8 chủ đề mẫu A1 (32 từ, 12 cụm từ, 10 mẫu câu, 2 bài học mẫu, 4 hội thoại A1) |
| `world_03` | **Sentence Kingdom** | A1 Cơ bản | `planned_extensible` | Mở rộng mẫu câu giao tiếp & ngữ pháp A1 |
| `world_04` | **Listening Ocean** | A1 Mở rộng | `planned_extensible` | Hội thoại ngắn, mô tả & chỉ dẫn |
| `world_05` | **Speaking City** | A1 Mở rộng | `planned_extensible` | Nhập vai giao tiếp tình huống |
| `world_06` | **Challenge Kingdom** | A2 Bước đầu | `planned_extensible` | Thử thách tổng hợp 4 kỹ năng |

---

## 2. Phân bổ chi tiết trên 5 Khu Vực của Alphabet Island (`world_01`)

| Khu vực 3D | Chủ đề / Bài học gắn kết | NPC chính | Nội dung học trọng tâm |
|---|---|---|---|
| **1. Welcome Village** (`welcome_village`) | `topic_01_alphabet` (`lesson_01_00_intro`), `topic_06_greetings_numbers` (`lesson_06_01_shapes_numbers`) | Professor Owl & Buddy | Chào hỏi, giới thiệu bản thân, số đếm 1–10, hình dạng, mệnh lệnh lớp học |
| **2. Alphabet Meadow** (`alphabet_meadow`) | `topic_01_alphabet` (`lesson_01_01_abc`, `lesson_01_02_alphabet_all`), `topic_02_basic_vocab` | Lily | 26 chữ cái hoa/thường, Letter Name vs Letter Sound, âm đầu, từ vựng đồ ăn/động vật/màu sắc |
| **3. Letter Cave** (`letter_cave`) | `topic_03_basic_phonics` (`lesson_03_01_digraphs_blending`) | Rocky | Short/Long Vowels, Consonants, Digraphs (`sh`, `ch`, `th`, `wh`), ghép vần CVC & đánh vần |
| **4. Crystal Lake** (`crystal_lake`) | `topic_04_basic_words` (`lesson_04_01_context`), `topic_07_world_around_us` (`lesson_07_01_body_weather`, `lesson_07_02_toys_places_stories`) | Crystal Guardian | Màu sắc, hình dạng, bộ phận cơ thể, quần áo, thời tiết, cảm xúc, đồ chơi, địa điểm, câu ngắn |
| **5. The Shadow Gate** (`shadow_gate`) | `topic_05_simple_sentences` (`lesson_01_18_gate`) | Professor Owl & Buddy | Ôn tập tổng hợp Listening, Reading, Writing, Speaking & thử thách mở cổng |
