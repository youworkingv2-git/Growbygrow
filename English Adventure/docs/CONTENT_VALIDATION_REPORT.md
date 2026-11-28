# BÁO CÁO KIỂM TRA DỮ LIỆU NỘI DUNG (CONTENT VALIDATION REPORT)
# PROJECT: ENGLISH ADVENTURE — PROMPT 09

**Ngày kiểm tra:** 2026-11-27  
**Bộ công cụ kiểm định:** `tests/content_validation/validate_prompt_02.py` .. `validate_prompt_09.py` & `validate_3d_visual_direction.py`.

---

## 1. Tổng hợp kết quả kiểm tra tự động

| Bộ kiểm tra | Kết quả | Chi tiết chính |
|---|---|---|
| `validate_prompt_02.py` – `08.py` | **PASSED (0 errors)** | Toàn bộ cấu trúc P2–P8 (World 3D, UI, Quest, Minigame, Audio/Voice, Supabase Auth/Sync) giữ nguyên tương thích 100%. |
| `validate_3d_visual_direction.py` | **PASSED (0 errors)** | Đảm bảo không làm hỏng quy chuẩn 3D Low-Poly / PBR. |
| `validate_prompt_09.py` | **PASSED (0 errors)** | Kiểm tra toàn bộ kho dữ liệu mở rộng P9 & tương thích GDScript 4.3. |

---

## 2. Số liệu chất lượng dữ liệu đã xác minh

| Hạng mục kiểm tra | Số lượng / Kết quả | Ghi chú |
|---|---|---|
| Dữ liệu trùng ID / trùng từ | **0** | Không có `id` hoặc `word` trùng lặp trên 147 từ, 48 cụm, 32 mẫu câu, 116 bài 4 kỹ năng, 14 hội thoại, 20 câu hỏi. |
| Thiếu nghĩa tiếng Việt / Topic / Level | **0** | 100% có `meaning_vi`, `cefr_level`, `topic`, `example_sentence`, `example_translation`. |
| IPA sai cú pháp `/.../` | **0** | 100% từ vựng, cụm từ và bảng chữ cái có `ipa_us` & `ipa_uk` đúng định dạng. |
| Lỗi liên kết hình ảnh (`image_path`) | **0 thiếu** | **147/147** từ vựng có SVG tồn tại trên đĩa (`assets/learning/images/*.svg`). |
| Audio `.ogg` chưa có (khai báo trung thực) | **147 từ + 48 cụm + 116 kỹ năng** | Toàn bộ khai báo trung thực `audio_status: "missing_asset"`; chạy thực tế qua `VoiceManager` TTS `en-US`/`en-GB`. |
| Câu hỏi thiếu đáp án / >1 đáp án đúng | **0** | 100% bài tập trắc nghiệm có **duy nhất 1** `is_correct: true` và không trùng nhãn lựa chọn. |
| Trạng thái kiểm duyệt (`review_status`) | **100% `approved`** | Đã qua kiểm tra cấu trúc tự động + rà soát chính tả/ngữ nghĩa nội bộ (chưa qua chuyên gia sư phạm bên ngoài). |
| Bẫy `Variant` GDScript 4.3 | **0** | Không có khai báo `var x := dict.get(...)` thiếu kiểu tường minh. |
