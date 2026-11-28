# QUY CHUẨN NỘI DUNG LUYỆN NGHE (LISTENING CONTENT SPEC)
# PROJECT: ENGLISH ADVENTURE

**Tệp dữ liệu:** `data/listening/world_01_listening.json` (**22 bài nghe Pre-A1**) & `data/listening/world_02_a1_listening.json` (**6 bài nghe A1**). Tổng: **28 bài nghe**.

---

## 1. Các dạng bài Listening đã triển khai
1. `listen_word_choose_image` (Pre-A1 & A1): Nghe từ/cụm từ và chọn hình ảnh tương ứng.
2. `listen_word_choose_meaning`: Nghe từ hoặc cụm từ thông dụng và chọn nghĩa tiếng Việt.
3. `listen_sentence_choose_answer`: Nghe câu ngắn (`A red ball.`, `I ride my blue bike in the park.`, `Can you swim or draw?`) và chọn đáp án đúng.
4. `listen_short_dialogue`: Nghe câu hỏi giao tiếp (`What color is the lemon?`, `How much is this science book?`) và chọn câu đáp tự nhiên.
5. `listen_identify_detail`: Nghe chỉ dẫn hoặc đoạn mô tả thói quen/chỉ đường (A1: `list_a1_03`, `list_a1_04`) để tìm chi tiết.
6. `listen_arrange_sentence`: Nghe câu mẫu và sắp xếp lại các từ theo đúng thứ tự.

---

## 2. Quy chuẩn bản ghi & Trải nghiệm nghe lại
- Mọi bản ghi có: `id`, `activity_type`, `prompt_vi`, `transcript_en`, `translation_vi` (cho nội dung mới), `ipa`, `word_id`, `options` (duy nhất 1 `is_correct: true`), `explanation_vi`, `audio_status` (`"missing_asset"` trung thực khi chưa có `.ogg`), `difficulty`, `cefr_level`, `review_status`.
- Giao diện `LearningHubModal` & Mini-game **luôn cung cấp cả 2 nút "Nghe âm thanh mẫu" (tốc độ thường) và "Nghe chậm" (0.85x)**, cho phép trẻ nghe lại không giới hạn số lần qua `VoiceManager` (TTS `en-US`/`en-GB`).
