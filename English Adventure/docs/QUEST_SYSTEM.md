# QUEST SYSTEM SPECIFICATION (PROMPT 02)
# PROJECT: ENGLISH ADVENTURE

---

## 1. KHUNG HỆ THỐNG NHIỆM VỤ (`QuestManager`)

- **Autoload:** `QuestManager` (`scripts/quest/quest_manager.gd`)
- **Dữ liệu:** `data/quests/world_01_quests.json`
- **Bốn trạng thái chuẩn:** `locked`, `available`, `active`, `completed`.
- **Cơ chế chống nhận thưởng trùng lặp:** `GameStateManager.rewarded_quests` lưu danh sách `quest_id` đã nhận thưởng; hàm `_complete_quest()` từ chối trao lại EXP/Gold/Items nếu ID đã tồn tại.
- **Điểm nối cho Prompt 03 (`learning_hook`):** Mỗi nhiệm vụ có trường `learning_hook` (`future_lesson_id`, `skills`) và hàm `trigger_learning_hook_for_quest()` phát signal `EventBus.learning_hook_requested` để gắn kết mượt với `LearningEngine` & Mini-games ở Prompt 03+.

---

## 2. BA NHIỆM VỤ MẪU ĐÃ TRIỂN KHAI (PROMPT 02)

### Quest 01 – A New Adventure (`quest_01_new_adventure`)
- **Người giao:** `professor_owl` tại `welcome_village`.
- **Các bước:**
  1. `talk_to_npc: professor_owl` (Nói chuyện với Giáo sư Cú Mèo).
  2. `talk_to_npc: lily` (Gặp bé Lily ở quảng trường).
  3. `interact_object: obj_village_sign` (Kiểm tra biển chỉ dẫn trung tâm).
- **Phần thưởng:** `+50 EXP`, `+25 Gold`, mở khóa **Alphabet Meadow** (`alphabet_meadow`).

### Quest 02 – Find the Lost Letters (`quest_02_lost_letters`)
- **Người giao:** `lily` (hoặc tự đề xuất khi bước vào `alphabet_meadow` sau khi xong Quest 01).
- **Các bước:**
  1. `visit_area: alphabet_meadow` (Đi tới Đồng Cỏ Bảng Chữ Cái).
  2. `collect_tag: lost_letter_meadow` (`required_count: 3` — thu thập A, B, C).
  3. `interact_object: obj_meadow_chest` (Mở Rương Kho Báu đồng cỏ).
- **Phần thưởng:** `+80 EXP`, `+40 Gold`, item `lost_letters_abc`, mở khóa **Letter Cave** (`letter_cave`).

### Quest 03 – The Mysterious Gate (`quest_03_mysterious_gate`)
- **Người giao:** `rocky` tại `letter_cave`.
- **Các bước:**
  1. `talk_to_npc: rocky` (Hỏi manh mối từ Rocky — đồng thời bật flag `rocky_clue_found` mở **Crystal Lake**).
  2. `talk_to_npc: crystal_guardian` (Gặp Crystal Guardian ở Hồ Pha Lê).
  3. `interact_object: obj_lake_crystal` (Thu thập Mảnh Pha Lê Phép Thuật).
- **Phần thưởng:** `+120 EXP`, `+60 Gold`, item `magic_crystal_shard`, mở khóa **The Shadow Gate** (`shadow_gate`).

---

## 4. KẾT NỐI MINI-GAME SYSTEM (PROMPT 05)

- `QuestManager` lắng nghe `EventBus.minigame_completed` và hỗ trợ step type `minigame_completed`, đồng thời đọc `learning_hook.future_minigame_id` (`listen_and_find`, `word_builder`, `sentence_builder`) để hiển thị nút **"Chơi thử thách Mini-Game của nhiệm vụ"** ngay trong `QuestLogModal`.
- Các NPC & Vật thể 3D gắn liền nhiệm vụ (`professor_owl`, `lily`, `rocky`, `crystal_guardian`, `obj_village_chest`, `obj_meadow_chest`, `obj_cave_sign`, `obj_lake_chest`, `obj_shadow_gate_seal`) tự động mở mini-game phù hợp sau hội thoại mà không phá vỡ luồng Quest 01/02/03.

---

## 5. MỞ RỘNG KIẾN TRÚC TÍCH HỢP (PROMPT 06)

- Phân rã `QuestManager` thành 10 thành phần (`QuestRepository`, `QuestRegistry`, `QuestInstance`, `QuestStateManager`, `QuestObjectiveManager`, `QuestConditionEvaluator`, `QuestProgressTracker`, `QuestRewardManager`, `QuestNotificationManager`, `QuestEventHandler`).
- Hỗ trợ 6 trạng thái (`locked`, `available`, `accepted`, `in_progress`, `completed`, `claimed`), 12 loại objective, chế độ `sequential` / `parallel` / `optional` / `repeatable` / `hidden`, và tiến độ số (`3/5`).
- Bổ sung `quest_04_crystal_guardian`, `quest_05_shadow_gate`, 3 Side Quests và 5 Chapters (`chapters.json`). Xem thêm `docs/QUEST_INTEGRATION.md`.
