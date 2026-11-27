# TTS INTEGRATION — ENGLISH ADVENTURE

## 1. Giải pháp Text-to-Speech Đa Nền tảng (`TextToSpeechManager`)

Trong `project.godot`, cấu hình `[audio] general/text_to_speech=true` đã được bật để kích hoạt hệ thống TTS gốc của Godot 4.3:

- **Windows**: Dùng Microsoft SAPI / OneCore Voices cài trên máy (hoạt động **offline** nếu máy đã có gói giọng English).
- **Android**: Dùng Android `TextToSpeech` engine của hệ thống.
- **iOS**: Dùng `AVSpeechSynthesizer` tích hợp sẵn trên iOS.
- **WebGL2 (Browser)**: Dùng `window.speechSynthesis` qua `JavaScriptBridge` với chọn lọc `voice.lang` theo `en-US` / `en-GB`, điều chỉnh `rate`, `pitch`, `volume`, cùng hỗ trợ `pause()`, `resume()`, `cancel()`.

## 2. API Hợp nhất (`TextToSpeechManager.speak`)

- Tự động phát hiện khả năng TTS thực tế (`is_available()`, `get_capability_summary()`) trước khi gọi, tránh lỗi trên môi trường headless/CI không có audio driver.
- Chuẩn hóa đọc đặc thù phương ngữ (ví dụ chữ cái `Z` đọc là `"Zed"` khi `en-GB`).
- Phát sự kiện `speech_started` / `speech_finished` để đồng bộ animation nhân vật và phục hồi âm lượng nhạc nền.

## 3. Mở rộng Tương lai (Cloud Neural TTS / Voice Acting)

Kiến trúc `AudioPlaybackManager` cho phép chèn thêm asset `.ogg` thu âm bởi diễn viên lồng tiếng hoặc file tạo trước từ dịch vụ TTS có bản quyền thương mại vào `data/audio/audio_manifest.json` hoặc `user://audio_cache/` mà không cần sửa code Gameplay, Learning Hub hay Dialogue System.
