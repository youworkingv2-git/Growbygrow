# QUY CHUẨN NỘI DUNG LUYỆN NÓI (SPEAKING CONTENT SPEC)
# PROJECT: ENGLISH ADVENTURE

**Tệp dữ liệu:** `data/speaking/world_01_speaking.json` (**12 bài nói Pre-A1**) & `data/speaking/world_02_a1_speaking.json` (**4 bài nói A1**). Tổng: **16 bài nói**.

---

## 1. Lộ trình bài tập nói
- **Pre-A1 (`speak_01`..`speak_12`):** Phát âm âm chữ cái (`A - /æ/ - Apple`), đọc từ đơn (`Ball`, `Cat`, `Ship`, `Star`, `Rabbit`), chào hỏi (`Hello! I am happy.`, `Good morning! Nice to meet you.`), nói câu ngắn về màu sắc, số đếm và phép lịch sự (`Thank you! See you later.`).
- **A1 (`speak_a1_01`..`speak_a1_04`):** Giới thiệu bản thân & bạn thân, nói về thói quen buổi sáng, nói về sở thích (`draw pictures and listen to music`), hỏi giá & mua đồ lịch sự.

---

## 2. Tích hợp với Hệ thống Âm thanh & Ghi âm (P7)
- Mỗi bài nói hiển thị: `target_text_en`, `meaning_vi`, `ipa`, `mouth_hint_vi` (hướng dẫn đặt miệng thân thiện cho trẻ) và tích hợp `SpeakingPracticePanel`:
  - Nghe mẫu thường / Nghe chậm (`en-US` hoặc `en-GB`).
  - Ghi âm giọng trẻ qua micro (lưu cục bộ tạm thời, không tự động tải file ghi âm trẻ lên server).
  - Nghe lại bản ghi và ghi âm lại thoải mái.
  - Gửi đánh giá phát âm qua Supabase Edge Function (`pronunciation-assess`) chỉ khi dịch vụ thật được cấu hình.
- **Quy tắc trung thực & không phạt trẻ:** Toàn bộ 16 bài giữ `ai_scoring_status: "not_integrated_experimental"`. Khi chưa có micro hoặc chưa cấu hình AI key, trẻ vẫn hoàn thành luyện tập bằng chế độ tự luyện an toàn mà không bị trừ điểm hay báo lỗi giả.
