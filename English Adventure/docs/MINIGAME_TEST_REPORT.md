# MINI-GAME TEST REPORT (PROMPT 05)

## 1. Kiểm thử tự động (Static & Integrity Validators)
- `tests/content_validation/validate_prompt_02.py` — Kiểm tra thế giới 3D, Quest 01/02/03, NPCs, Objects, Area unlocks.
- `tests/content_validation/validate_prompt_03.py` — Kiểm tra UI/UX, autoloads, cân bằng VI/EN localization, bẫy Variant GDScript 4.3.
- `tests/content_validation/validate_3d_visual_direction.py` — Kiểm tra hướng mỹ thuật 3D.
- `tests/content_validation/validate_prompt_04.py` — Kiểm tra Learning Engine, Curriculum, Vocab, Phonics, Grammar, 4-Skill JSON.
- `tests/content_validation/validate_prompt_05.py` — Kiểm tra Registry (8 core + 8 template), `dialogue_adventures.json`, tất cả script `MiniGameSystem`, migration `0004`, và không trùng lặp từ vựng cứng.

## 2. Kiểm thử thực tế trên trình duyệt WebGL2 / Windows
- Mở Arcade Mini-Games từ HUD (`Trò chơi [G]`) và `LearningHubModal`.
- Mở từ NPC (`professor_owl`, `lily`, `rocky`, `crystal_guardian`), Quest Log, và Vật thể 3D (`obj_village_chest`, `obj_meadow_chest`, `obj_cave_sign`, `obj_lake_chest`, `obj_shadow_gate_seal`).
- Chơi thử 4 mini-game ưu tiên (`listen_and_find`, `word_builder`, `word_matching`, `sentence_builder`) và 4 mini-game mở rộng (`sound_detective`, `speaking_hero`, `memory_quest`, `dialogue_adventure`): xác nhận nhận dữ liệu từ Learning Engine, trả lời đúng/sai đều có phản hồi tiếng Việt đầy đủ, gợi ý hoạt động, nhận EXP/Gold/Crystal không trùng thưởng, quay về đúng vị trí 3D và lưu `active_profile.json` + `learning_progress.json`.

## 3. Đánh giá Android / iOS
- **Thiết kế tương thích cảm ứng:** Nút bấm kích thước tối thiểu `48–68px`, chọn chạm trực tiếp (không đòi hỏi kéo thả pixel chính xác), bố cục `CanvasLayer` responsive co giãn theo viewport.
- **Lưu ý trung thực:** Chưa chạy build APK/IPA trực tiếp trên thiết bị Android/iOS vật lý trong phiên này; mới kiểm thử thực tế trên môi trường Windows/WebGL2.
