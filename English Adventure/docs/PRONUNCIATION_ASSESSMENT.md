# AI PRONUNCIATION ASSESSMENT — ENGLISH ADVENTURE

## 1. Kiến trúc Adapter & Backend Proxy (`PronunciationAssessmentManager`)

Luồng xử lý bảo mật (tuyệt đối không đặt API Key trong Godot client):

```
Godot Client (SpeakingPracticePanel -> PronunciationAssessmentManager)
  ──[User bấm "4. Gửi đánh giá phát âm"]──>
Supabase Edge Function (supabase/functions/pronunciation-assess/index.ts)
  ──[Xác thực JWT + Giới hạn <= 2MB / 30s]──>
Microsoft Azure AI Speech Pronunciation Assessment REST API
  ──[Chuẩn hóa PronunciationResult, giữ null cho chỉ số không hỗ trợ]──>
Godot Client -> PronunciationFeedbackManager -> UI & LearningProgressManager
```

## 2. Cấu trúc Dữ liệu `PronunciationResult`

```json
{
  "assessment_id": "pa_1764210000_1234",
  "player_id": "<profile_uuid>",
  "learning_content_id": "speak_02",
  "expected_text": "Ball",
  "recognized_text": "",
  "overall_score": null,
  "accuracy_score": null,
  "fluency_score": null,
  "completeness_score": null,
  "prosody_score": null,
  "word_feedback": [],
  "phoneme_feedback": [],
  "provider": "azure_speech",
  "assessment_status": "provider_unavailable",
  "is_mock": false,
  "created_at": "2026-11-27T00:00:00Z"
}
```

## 3. Trạng thái Hiện tại (Thành thật Kỹ thuật)

- **Godot Adapter + Supabase Edge Function + DB Migration `0006` + Dev Mock**: Đã hoàn thiện.
- **Kết nối Azure Speech thật trên Production**: Chưa gắn `AZURE_SPEECH_KEY` / `AZURE_SPEECH_RESOURCE` thực tế vào Supabase environment vì chưa có tài khoản/API key sản xuất được cấu hình.
- Trong trạng thái mặc định (`ProviderMode.DISABLED`), client trả về `assessment_status = "provider_unavailable"` với toàn bộ điểm số là `null`, KHÔNG giả lập điểm AI.
- Chế độ `MOCK_DEV_ONLY` bị khóa ở release build (`OS.is_debug_build()`), và khi dùng trong kiểm thử luôn gắn `is_mock = true` cùng banner `[MOCK KIỂM THỬ]`.
