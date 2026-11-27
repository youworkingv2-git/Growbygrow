# REGRESSION TEST REPORT – ENGLISH ADVENTURE (PROMPT 08)

**Phiên bản kiểm thử sau sửa lỗi:** Commit `fe809d9` (Live WebGL2 trên GitHub Pages + toàn bộ Python Validators)  
**Ngày kiểm thử lại:** 27/11/2026  

---

## 1. Kết quả kiểm thử hồi quy cho 12 lỗi đã sửa (BUG-01 .. BUG-12)

| Mã lỗi | Mô tả ngắn | Phương pháp kiểm thử lại | Kết quả sau sửa |
|---|---|---|---|
| **BUG-01** | `SaveLoadManager.is_online` + backup `.bak.json` + schema type validation | `validate_prompt_08.py` + `test_p8_regression_suite.gd` (spec) + Live Chrome reload persistence (`17`/`18`) | **PASS** |
| **BUG-02** | Xóa toast thành tựu trùng trong `RewardManager` | `validate_prompt_08.py` (kiểm tra không emit `toast_requested` trùng) | **PASS** |
| **BUG-03** | Xóa toast quest start/complete trùng trong `QuestNotificationManager` | `validate_prompt_08.py` + kiểm tra mã nguồn `QuestManager` / `QuestNotificationManager` | **PASS** |
| **BUG-04** | Khóa input choice & phím tắt khi panel feedback mini-game đang mở | `validate_prompt_08.py` (kiểm tra `_input_locked` trên 5 mini-games + `MiniGameUI`) | **PASS** |
| **BUG-05** | Dừng speech & dọn recorder khi đóng Learning Hub / chuyển tab / đóng Mini-game | `validate_prompt_08.py` + kiểm tra trực tiếp khi mở/thoát Learning Hub & Listen and Find trên WebGL2 | **PASS** |
| **BUG-06** | `GameSpeakingHero` ghi `spoken_text_en` thay vì `target_text_en` vào `transcript_en` | `validate_prompt_08.py` | **PASS** |
| **BUG-07** | Đồng bộ vật thể nhặt trước (`lost_letter`, `obj_lake_crystal`) khi nhận Quest 02/03 | `validate_prompt_08.py` + `test_p8_regression_suite.gd` | **PASS** |
| **BUG-08** | Cache kích thước/tọa độ nút bản đồ trong `WorldMapUI._process()` | `validate_prompt_08.py` + mở World Map trên WebGL2 (`12_world_map.png`) | **PASS** |
| **BUG-09** | Cache Material/Mesh 3D tĩnh & đổi mật độ hạt theo Quality `low`/`medium`/`high` | `validate_prompt_08.py` + kiểm tra Welcome Village 3D trên WebGL2 (`05`/`06`) | **PASS** |
| **BUG-10** | Dừng speech & dọn recorder trong `SceneRouter._transition_to()` | `validate_prompt_08.py` + chuyển cảnh Village ↔ World Map trên WebGL2 | **PASS** |
| **BUG-11** | Scale & bố cục Mobile Portrait (`390x844`) trên `MainMenuUI` & `AdventureHUD` | Live Chrome `390x844` (`01b_mobile_portrait_main_menu.png`, `14_mobile_portrait_village.png`, `19_reload_mobile_portrait_hud.png`) | **PASS** |
| **BUG-12** | Lỗi `look_at()` trước `add_child(_camera)` trong `AlphabetIsland3DMap` | Live Chrome mở World Map & quay lại Village (`12_world_map.png`, `13_back_to_village.png`) — `0` console error | **PASS** |

## 2. Kết quả chạy lại toàn bộ Bộ kiểm thử tự động

| Script kiểm thử | Phạm vi | Exit Code |
|---|---|---|
| `tests/content_validation/validate_prompt_02.py` | Cấu trúc thế giới, nhân vật, khu vực, NPC, Quest khung | `0` (PASS) |
| `tests/content_validation/validate_3d_visual_direction.py` | Scene 3D, camera, lighting, asset 3D slots | `0` (PASS) |
| `tests/content_validation/validate_prompt_03.py` | UI Design System, Responsive, Settings, Localization | `0` (PASS) |
| `tests/content_validation/validate_prompt_04.py` | Learning Engine, 26 chữ cái, 38 từ, 15 phonics, 15 mẫu câu | `0` (PASS) |
| `tests/content_validation/validate_prompt_05.py` | 8 Mini-games, liên kết LearningEngine, câu hỏi & đáp án | `0` (PASS) |
| `tests/content_validation/validate_prompt_06.py` | 8 Quests, 5 Chapters, Items, Achievements, Rewards, Save v2 | `0` (PASS) |
| `tests/content_validation/validate_prompt_07.py` | 11 WAV assets, Audio manifest, Voice profiles, Edge Functions | `0` (PASS) |
| `tests/content_validation/validate_prompt_08.py` | Toàn bộ quy tắc nội dung, bảo mật, RLS & hồi quy P8 | `0` (PASS) |
| `tests/integration/run_webgl2_e2e_qa.py` | Chạy thật WebGL2 trên Chrome CDP (TC01–TC10 + Reload + Offline + Mobile) | `0` (PASS, `0` lỗi console/reload) |
