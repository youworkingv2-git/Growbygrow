# QA TEST PLAN – ENGLISH ADVENTURE (PROMPT 08)

**Dự án:** English Adventure (`Alphabet Island` – Godot 4.3 `gl_compatibility` + Supabase)  
**Giai đoạn:** P8 – Complete Game Testing, Bug Fixing & Performance Optimization  
**Ngày lập:** 27/11/2026  

---

## 1. Mục tiêu kiểm thử

Đảm bảo phạm vi MVP hiện tại (P1–P7) đạt trạng thái ổn định, chơi được thực tế từ đầu đến cuối, không có lỗi nghiêm trọng (P0) hoặc lỗi chặn luồng gameplay chính (P1), dữ liệu học tập chính xác và bảo mật an toàn cho trẻ em ~10 tuổi trước khi mở rộng nội dung và phát hành.

## 2. Phạm vi kiểm thử

| Nhóm hệ thống | Hạng mục kiểm thử | Phương pháp |
|---|---|---|
| **Core & World** | Startup, Main Menu, Character Select (Boy/Girl), World Intro, 5 khu vực Alphabet Island, 3D Movement, Camera SpringArm3D | Live WebGL2 E2E (Headless Chrome) + Static/Unit Suite |
| **NPC & Quest** | 4 NPCs (`professor_owl`, `lily`, `rocky`, `crystal_guardian`), Buddy, Dialogue song ngữ, Quest 01–05 + 3 Side Quests, các trạng thái `Locked`..`Claimed` | Live WebGL2 E2E + `test_p8_regression_suite.gd` + Python Validators |
| **Learning Engine** | 26 chữ cái, 38 từ vựng, 15 phonics, 15 mẫu câu, 8 bài học, 4 kỹ năng, Spaced Repetition, chất lượng nội dung & IPA | `validate_prompt_04.py`, `validate_prompt_08.py`, Live Learning Hub |
| **Mini-Games** | 8 mini-game đã triển khai (`listen_and_find`, `word_builder`, `word_matching`, `sentence_builder`, `sound_detective`, `speaking_hero`, `memory_quest`, `dialogue_adventure`) + khóa input sau đáp án sai | Live WebGL2 E2E + `validate_prompt_05.py` + `validate_prompt_08.py` |
| **Audio, Voice & AI** | 11 file `.wav` BGM/SFX/UI, Web Speech API TTS (`en-US`/`en-GB`), ghi âm `SpeechRecorder`, xử lý thiếu mic/từ chối quyền, trạng thái AI Pronunciation (`Cloud/Azure` vs `Not Configured`) | Live WebGL2 E2E (`speechSynthesis` hook) + `validate_prompt_07.py` |
| **Reward, Save & Backend** | EXP, Gold, Magic Crystal, Inventory, Achievements, Local Save + backup `.bak.json`, Offline Mode, Supabase RLS & Edge Functions | Live Chrome profile persistence + CDP Offline + SQL/Edge Function Audit |
| **3D Performance & UI/UX** | FPS, frame time, thời gian tải tài nguyên, JS Heap, tối ưu material/mesh/particle cache, Quality `Low`/`Medium`/`High`, Desktop + Mobile Portrait/Landscape | Chrome CDP `Performance.getMetrics` + `requestAnimationFrame` + Viewport Emulation |

## 3. Môi trường & Công cụ kiểm thử thực tế

- **Live WebGL2 Browser Environment:** Windows 11 (`win32 10.0.26300`), Google Chrome (`--headless=new --use-gl=angle --use-angle=swiftshader --enable-webgl`) kết nối qua Chrome DevTools Protocol (`tests/integration/run_webgl2_e2e_qa.py`), kiểm thử bản build triển khai trên GitHub Pages (`https://youworkingv2-git.github.io/Growbygrow/`).
- **Automated Static & Content Validators:** Python 3 (`tests/content_validation/validate_prompt_02.py` .. `validate_prompt_08.py`, `validate_3d_visual_direction.py`).
- **GDScript Unit/Integration Suite:** `tests/unit/test_p8_regression_suite.gd` (và `test_quest_reward_integration.gd`, `test_learning_engine.gd`, `test_minigames.gd`, `test_audio_voice_system.gd`).
- **Giới hạn môi trường đã ghi nhận trung thực:** Máy trạm hiện tại không cài sẵn binary `godot` CLI và không có thiết bị Android/iOS vật lý hoặc Supabase Cloud project gắn `AZURE_SPEECH_KEY`, nên native Windows `.exe` export, Android APK, iOS build và Azure AI Pronunciation live API được đánh dấu rõ ràng là `NOT TESTED` / `BLOCKED`.

## 4. Tiêu chí đạt / không đạt (Exit Criteria)

1. `0` lỗi P0 (crash khi khởi động, mất dữ liệu save nghiêm trọng, lộ API key/secret).
2. `0` lỗi P1 chặn luồng gameplay chính (chọn nhân vật → khám phá → gặp NPC → nhận/làm quest → học & mini-game → nhận thưởng → lưu/tải lại).
3. Không có tính năng giả: không chấm điểm phát âm ngẫu nhiên, không giả lập đồng bộ Supabase thành công, không báo đã test thiết bị khi chưa chạy.
4. Toàn bộ 8 bộ kiểm thử tự động Python đạt exit code `0`, và phiên bản WebGL2 chạy qua `TC01–TC10` không còn `USER ERROR` / console error.
