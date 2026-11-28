# QUY CHUẨN NỘI DUNG LUYỆN ĐỌC (READING CONTENT SPEC)
# PROJECT: ENGLISH ADVENTURE

**Tệp dữ liệu:** `data/reading/world_01_reading.json` (**22 bài đọc Pre-A1**) & `data/reading/world_02_a1_reading.json` (**6 bài đọc A1**). Tổng: **28 bài đọc**.

---

## 1. Tiến trình độ khó bài đọc
- **Pre-A1 (`read_01`..`read_22`):**
  - Đọc từ đơn -> chọn nghĩa hoặc hình ảnh (`read_word_choose_meaning`, `read_word_choose_image`, `match_word_image`).
  - Điền khuyết câu ngắn: mạo từ `a/an`, giới từ `in/on/under` (`fill_blank_sentence`).
  - Đọc câu ngắn và ghép nghĩa (`read_short_sentence`).
  - Đọc đoạn văn ngắn 1–3 câu có hình ảnh/từ vựng quen thuộc (`read_19`, `read_20`, `read_21`) và sắp xếp từ thành câu (`read_22`).
- **A1 (`read_a1_01`..`read_a1_06`):**
  - Đoạn văn 30–50 từ theo chủ đề rõ ràng: *Bạn thân & Thói quen sau giờ học* (`read_a1_03`), *Một ngày ở trường & Thư viện* (`read_a1_04`), *Đi chợ nấu ăn cùng Dì* (`read_a1_05`).
  - Kèm bản dịch tiếng Việt (`translation_vi`), từ khóa mục tiêu (`word_id`), câu hỏi đọc hiểu và giải thích đáp án (`explanation_vi`).

Mọi bài trắc nghiệm trong `world_01_reading.json` và `world_02_a1_reading.json` đều được kiểm định chỉ có **1 đáp án đúng** và không trùng nhãn lựa chọn.
