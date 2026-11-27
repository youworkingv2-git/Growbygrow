# FOUR SKILLS SYSTEM (LISTENING, SPEAKING, READING, WRITING)
# PROJECT: ENGLISH ADVENTURE (Prompt 04)

## 1. Listening (`ListeningManager` + `world_01_listening.json` — 12 bài)

Hỗ trợ đầy đủ 6 dạng hoạt động:
- `listen_word_choose_image` (Nghe từ và chọn hình)
- `listen_word_choose_meaning` (Nghe từ và chọn nghĩa)
- `listen_sentence_choose_answer` (Nghe câu và chọn đáp án)
- `listen_short_dialogue` (Nghe hội thoại ngắn)
- `listen_arrange_sentence` (Nghe và sắp xếp từ thành câu)
- `listen_identify_detail` (Nghe và xác định thông tin chi tiết)

**Trạng thái âm thanh trung thực:** Khi chưa có file `.ogg` thu sẵn (`audio_status: "missing_asset"`), UI hiển thị rõ trạng thái chờ asset; trên trình duyệt WebGL2 và Native Windows/Android/iOS hỗ trợ nghe qua `AudioManager.voice_manager` (`TextToSpeechManager`, bao gồm chế độ nghe thường & nghe chậm).

## 2. Speaking (`SpeakingManager` + `world_01_speaking.json` — 6 bài)

- Hỗ trợ hiển thị chữ, IPA, âm tiết (`syllables`), hướng dẫn khẩu hình tiếng Việt (`mouth_hint_vi`), ghi âm bằng `SpeechRecorder`, nghe lại bản ghi của chính mình và `SpeakingPracticePanel`.
- **Minh bạch tính năng AI (Prompt 07):** Kiến trúc `PronunciationAssessmentManager` + Supabase Edge Function (`Azure AI Speech`) đã sẵn sàng, mặc định ở trạng thái `provider_unavailable` khi chưa gắn API key server. Hệ thống **không** tạo điểm AI giả lập và luôn cho phép bé hoàn thành tự luyện ngay cả khi offline hoặc từ chối quyền Micro.

## 3. Reading (`ReadingManager` + `world_01_reading.json` — 12 bài)

Hỗ trợ:
- `read_word_choose_meaning`, `read_word_choose_image`, `match_word_image`
- `read_short_sentence`, `fill_blank_sentence` (có giải thích ngữ pháp/nghĩa tiếng Việt)
- `arrange_words_sentence`, `read_short_passage`

## 4. Writing (`WritingManager` + `world_01_writing.json` — 12 bài)

Ưu tiên thao tác chạm / ghép thẻ phù hợp trẻ 10 tuổi:
- `fill_missing_letter` (VD: `A P P _ E` -> `L`)
- `assemble_letters_word` (chạm ghép chữ thành từ)
- `fill_word_in_sentence`, `arrange_words_sentence`
- `type_simple_sentence` (kèm chip gợi ý từ đầu câu)
