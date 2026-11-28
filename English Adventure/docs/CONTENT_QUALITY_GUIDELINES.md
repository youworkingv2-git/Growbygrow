# QUY CHUẨN KIỂM DUYỆT CHẤT LƯỢNG NỘI DUNG (CONTENT QUALITY GUIDELINES)
# PROJECT: ENGLISH ADVENTURE

---

## 1. Quy trình Trạng thái Kiểm duyệt (`review_status`)
Mọi mục nội dung trong JSON và database bắt buộc mang trường `review_status` thuộc 5 trạng thái:
1. `draft` — Đang biên soạn, **không** tải vào game.
2. `under_review` — Đang chờ rà soát ngôn ngữ/âm thanh/hình ảnh, **không** phát hành.
3. `approved` — Đã qua rà soát và kiểm định tự động (`validate_prompt_09.py`).
4. `published` — Đã phát hành chính thức.
5. `archived` — Đã lưu trữ/thay thế.

`LearningContentRepository._is_publishable()` chỉ cho phép các mục ở trạng thái `approved` hoặc `published` hiển thị trong `LearningHubModal` và mini-game.

---

## 2. Tiêu chuẩn Ngôn ngữ học (English & Vietnamese)
1. **Giọng chuẩn mặc định:** `en-US` (có mở rộng `en-GB`), **tuyệt đối không trộn lẫn chính tả** Mỹ–Anh trong cùng một mục từ (VD: dùng thống nhất `color`, `favorite`, `gray`/`grey` được tách rõ variant hoặc ưu tiên US nhất quán).
2. **IPA chính xác:** Bắt buộc đúng cú pháp `/.../` và phân biệt rõ **tên chữ cái** (`/eɪ/`) với **âm chữ cái** (`/æ/`).
3. **Phù hợp trẻ ~10 tuổi:** Từ vựng gần gũi (động vật, đồ ăn, gia đình, trường học, thiên nhiên, thói quen). Không dùng ngôn ngữ bạo lực, phức tạp hoặc trừu tượng vượt mức Pre-A1/A1.
4. **Tính trung thực CEFR & AI:**
   - Pre-A1/A1 chỉ là **khung tham chiếu độ khó nội bộ**, không tuyên bố chứng nhận chính thức.
   - Không gắn `audio_status: "ready"` nếu thiếu file `.ogg` vật lý.
   - Không bật điểm AI giả khi `ai_scoring_status == "not_integrated_experimental"`.

---

## 3. Kiểm tra tự động bắt buộc (`tests/content_validation/validate_prompt_09.py`)
Chạy trước mỗi commit/build:
- Không trùng `id` và không trùng `word` (case-insensitive) giữa Pre-A1 và A1.
- Không thiếu `meaning_vi`, `cefr_level`, `topic`, `example_sentence`, `example_translation`.
- Mọi liên kết `word_id`, `anchor_word_ids`, `linked_vocab_ids`, `source_id` phải trỏ tới bản ghi có thật.
- Mọi câu hỏi trắc nghiệm phải có **duy nhất 1** `is_correct: true` và không trùng nhãn lựa chọn.
- Kiểm tra bẫy biên dịch `GDScript 4.3` (`var x := dict.get(...)` không có kiểu tường minh).
