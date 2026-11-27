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

*(Sẽ được điền kết quả xác minh trực tiếp sau khi push và GitHub Actions hoàn tất build Godot 4.3 WebGL2).*

| Test ID | Nội dung kiểm thử | Môi trường | Trạng thái | Ghi chú trung thực |
| :--- | :--- | :--- | :---: | :--- |
| TEST 01 | Audio Playback (Từ vựng, Nghe thường/Chậm, Câu mẫu, SFX/BGM) | WebGL2 Headless Chrome | Đang chờ chạy build mới | 11 WAV UI/SFX/BGM verified; từ vựng dùng OS/Web TTS fallback |
| TEST 02 | NPC Voice (Welcome Village, Professor Owl, Buddy, Phụ đề, Mouth Anim) | WebGL2 Headless Chrome | Đang chờ chạy build mới | Mouth anim dùng basic open/close placeholder rig |
| TEST 03 | Microphone (`SpeechRecorder` Web `MediaRecorder` / Windows `AudioEffectRecord`) | WebGL2 / Windows | Một phần (UI + capability verified; chưa kiểm trên Android/iOS thật) | Web headless không có mic phần cứng thật để thu giọng nói người thật |
| TEST 04 | Speech Recognition (`SpeechRecognitionManager`) | Adapter + Edge Function | Adapter sẵn sàng; chưa gọi dịch vụ thật | Chưa cấu hình `AZURE_SPEECH_KEY` trên Supabase Cloud |
| TEST 05 | AI Pronunciation Assessment (`PronunciationAssessmentManager`) | Adapter + Edge Function + MOCK | Adapter & Mock Dev Only sẵn sàng; dịch vụ thật Blocked thiếu credentials | Không có điểm AI giả trong bản phát hành |
| TEST 06 | Offline Mode | WebGL2 / Local Storage | Đã kiểm chứng logic + WAV bundled offline | Tiến trình học & ghi âm local không phụ thuộc mạng |
| TEST 07 | Cross-Platform (Windows, Android, iOS) | Windows Editor/Repo + WebGL2 | **Chưa kiểm thử trên thiết bị Android / iOS thật** | Logic `OS.request_permissions()` và `DisplayServer.tts_*` đã viết theo API chuẩn Godot 4.3 |
