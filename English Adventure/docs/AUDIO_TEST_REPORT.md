# AUDIO TEST REPORT — ENGLISH ADVENTURE (Prompt 07)

Báo cáo kiểm thử trung thực hệ thống Âm thanh, Giọng nói, Ghi âm và Đánh giá Phát âm (cập nhật 2026-11-27).

## 1. Kết quả Kiểm thử Tự động Content & Code Integrity (Python Validators)

- `validate_prompt_02.py` (JSON schemas, `res://` integrity, `.tscn` references, quest/area graph): **PASS**
- `validate_prompt_03.py` (UI/UX, localization parity, GDScript 4.3 Variant checks): **PASS**
- `validate_prompt_04.py` (Learning Engine, 26 letters, 38 vocab + SVGs, 15 grammar, 4-skills): **PASS**
- `validate_prompt_05.py` (Mini-game registry, 8 core mini-games, Speaking honesty): **PASS**
- `validate_prompt_06.py` (Quests, Chapters, Items, Achievements, Interactive Dialogues): **PASS**
- `validate_prompt_07.py` (14 AudioVoiceSystem modules, 11 WAV integrity, 6 Voice Profiles, EventBus signals, zero client secrets, non-faked AI default): **PASS**

## 2. Kết quả Kiểm thử Runtime Thực tế (WebGL2 Live Build via Headless Chrome CDP)

Đã kiểm thử trực tiếp trên bản build Godot 4.3 WebGL2 triển khai từ commit `779bbd6` (GitHub Actions run `45938405744` — `success`, URL `https://youworkingv2-git.github.io/Growbygrow/`) bằng Chromium Headless + CDP (`--autoplay-policy=no-user-gesture-required`, `--use-fake-ui-for-media-stream`, `--use-fake-device-for-media-stream`):

- Console log khởi tạo xác nhận: `[AudioManager] AudioVoiceSystem initialized: 11 bundled WAV assets, TTS=true`, `[LearningEngine] Initialized: 26 letters, 38 vocab, 15 phonics units, 15 grammar structures, 8 lessons`, `[MiniGameManager] Initialized with 16 registered mini-games (8 playable).`
- Tổng số lỗi JS Runtime (`Runtime.exceptionThrown`) và lỗi GDScript (`SCRIPT ERROR` / `USER ERROR`): **0 lỗi** xuyên suốt từ Main Menu → Character Selection → World Intro → Welcome Village → Learning Hub (Phonics & Vocab) → Speaking Hero (`SpeakingPracticePanel` + Mic Recording/Pause) → Offline Network Emulation → Professor Owl Dialogue.

| Test ID | Nội dung kiểm thử | Môi trường | Trạng thái | Ghi chú trung thực |
| :--- | :--- | :--- | :---: | :--- |
| TEST 01 | Audio Playback (Từ vựng, Nghe thường/Chậm, Câu mẫu, SFX/BGM) | WebGL2 Headless Chrome | **PASS (WebGL2 TTS + Bundled WAV)** | Đã xác minh hiển thị và thao tác `SettingsUI` (5 thanh âm lượng, tốc độ nói, chọn giọng `en-US`/`en-GB`, nút khôi phục mặc định), Phonics tab (`Nghe tên chữ (A)` vs `Nghe âm qua từ 'apple'`), Vocab tab (`Nghe`, `Chậm`, `Câu`, `Luyện`). 11 WAV UI/SFX/BGM là file thật; giọng đọc từ vựng dùng OS/Web TTS fallback (chưa có file `.ogg` thu sẵn). |
| TEST 02 | NPC Voice (Welcome Village, Professor Owl, Buddy, Phụ đề, Mouth Anim) | WebGL2 Headless Chrome | **PASS (Dialogue + Voice UI)** | Đã xác minh đối thoại với `Giáo sư Cú Mèo` (`DialogueBoxUI`) trong Welcome Village hiển thị câu tiếng Anh + bản dịch tiếng Việt + lựa chọn + các nút `Nghe thoại`, `Tạm dừng`, `Tiếng Việt: BẬT`, `Bỏ qua`. Mouth animation là chuyển động mở/khép cơ bản (`CharacterRig3D.set_speaking()`), chưa có viseme/blend shape. |
| TEST 03 | Microphone (`SpeechRecorder` Web `MediaRecorder` / Windows `AudioEffectRecord`) | WebGL2 Headless Chrome (Fake Mic Device) | **PASS (Web MediaRecorder UI & Timer)** | Đã xác minh nút `Bật Micro` → `2. Ghi âm` → bộ đếm `0.9s / 15.0s` (`Đang ghi âm...`) → `Tạm dừng` (`1.5s / 15.0s`, `Đã tạm dừng ghi âm.`, nút `Tiếp tục` & `Dừng` & `Hủy bản ghi`). Dùng fake media stream trong headless Chrome; chưa kiểm mic phần cứng trên Android/iOS thật hoặc bản build Windows `.exe` độc lập. |
| TEST 04 | Speech Recognition (`SpeechRecognitionManager`) | Adapter + Edge Function | **Adapter sẵn sàng; chưa gọi dịch vụ thật (Blocked thiếu credentials)** | Đã triển khai adapter + `supabase/functions/speech-recognize/index.ts`; chưa cấu hình `AZURE_SPEECH_KEY` trên Supabase Cloud nên chưa test nhận diện thật. |
| TEST 05 | AI Pronunciation Assessment (`PronunciationAssessmentManager`) | Adapter + Edge Function + MOCK | **Adapter & Mock Dev Only sẵn sàng; dịch vụ thật Blocked thiếu credentials** | Trong UI thực tế nút `4. Gửi đánh giá phát âm` bị vô hiệu hóa đúng quy tắc và ghi rõ *"AI chấm phát âm (Pronunciation Assessment) đang chờ kết nối dịch vụ — không chấm điểm giả"*. Không có điểm AI giả trong bản phát hành. |
| TEST 06 | Offline Mode | WebGL2 Headless Chrome (`Network.emulateNetworkConditions offline=true`) | **PASS (Không khóa học tập)** | Khi ngắt mạng ngay trong `Speaking Hero`, game không lỗi, không treo, vẫn giữ nguyên luồng nghe mẫu/ghi âm local và hoàn thành luyện tập (`Mình đã nói to, rõ rồi!`). |
| TEST 07 | Cross-Platform (Windows, Android, iOS) | Windows Repo Validators + WebGL2 Chrome | **Chưa kiểm thử trên thiết bị Android / iOS / Windows binary thật** | Code đã xử lý `OS.request_permissions()` (Android/iOS), `AudioEffectRecord` (Native), `DisplayServer.tts_*` (Native) và `JavaScriptBridge` (Web), nhưng chưa chạy trực tiếp trên máy Android/iOS vật lý. |
