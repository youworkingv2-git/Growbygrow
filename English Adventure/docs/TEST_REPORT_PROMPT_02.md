# TEST REPORT – PROMPT 02 (WORLD & CHARACTER SYSTEM)
# PROJECT: ENGLISH ADVENTURE

**Ngày kiểm thử:** 2026-11-26  
**Môi trường kiểm thử:** Windows PowerShell + Python Verification Suite (`tests/content_validation/validate_prompt_02.py`).  
**Lưu ý quan trọng về Runtime Engine:** Máy hiện tại **chưa cài đặt `godot` CLI / Godot Editor**, do đó việc mở cửa sổ chạy game tương tác trực quan cần thực hiện trong Godot 4.3+ Editor theo hướng dẫn. Toàn bộ cấu trúc dữ liệu, tham chiếu `res://`, cú pháp `.tscn`, ánh xạ `@onready` và luồng mở khóa 3 nhiệm vụ đã được kiểm thử tự động thành công.

---

## 1. KẾT QUẢ KIỂM THỬ TỰ ĐỘNG (ĐÃ CHẠY & ĐẠT)

| Hạng mục | Phương pháp | Kết quả | Chi tiết |
|---|---|---|---|
| **JSON Data Integrity** | `validate_prompt_02.py` | **PASS (9/9 files)** | Toàn bộ 9 file JSON (`worlds`, `areas`, `characters`, `npcs`, `dialogues`, `quests`, `objects`, `vi`, `en`) hợp lệ UTF-8 & cấu trúc. |
| **`res://` Asset & Script Paths** | `validate_prompt_02.py` | **PASS (129/129 refs)** | Mọi đường dẫn `res://` trong `project.godot`, `.tscn`, `.gd`, `.json` đều trỏ tới file tồn tại thực tế. |
| **Scene `@onready` & Resource Bindings** | `validate_prompt_02.py` | **PASS (109/109 paths)** | Kiểm tra chéo 109 biến `@onready` trong các script UI/Controller đều khớp chính xác tên node trong `.tscn` tương ứng; không thiếu `ExtResource`/`SubResource`. |
| **Quest & Area Unlock Graph** | Mô phỏng logic `UnlockEvaluator` | **PASS** | Xác nhận chuỗi `Welcome Village` → `Quest 01` → `Alphabet Meadow` → `Quest 02` → `Letter Cave` → `Rocky flag` → `Crystal Lake` → `Quest 03` → `The Shadow Gate` hoạt động thông suốt không deadlock. |

---

## 2. MA TRẬN KIỂM THỬ THEO TIÊU CHÍ MỤC 17 (PROMPT 02)

| Nhóm kiểm thử | Trạng thái triển khai | Trạng thái kiểm thử |
|---|---|---|
| **A. Character Selection** | Đã code đầy đủ (`character_selection.tscn` + `character_selection_ui.gd`) | Đã kiểm tra cấu trúc scene/node/save; *chờ chạy thủ công trong Godot 4.3+* |
| **B. World Map (5 Areas & Locking)** | Đã code đầy đủ (`world_map.tscn` + `world_map_ui.gd` + `SceneRouter.enter_area`) | Đã kiểm chứng logic unlock bằng script; *chờ kiểm thử bấm trực tiếp trên Godot* |
| **C. Character Movement (PC + Mobile)** | Đã code đầy đủ (`PlayerController`, `CharacterAnimator`, `VirtualJoystick`) | Đã kiểm tra binding scene & collision layer; *chờ kiểm thử cảm giác di chuyển trên Godot* |
| **D. Buddy & NPCs** | Đã code đầy đủ (`BuddyController`, `NpcController`, 4 NPCs, `DialogueManager`) | Đã kiểm tra mapping NPC → Dialogue JSON; *chờ chạy thử hội thoại trên Godot* |
| **E. Quest System (3 Sample Quests)** | Đã code đầy đủ (`QuestManager` + chống thưởng trùng `rewarded_quests`) | Đã kiểm chứng logic tiến bước & unlock; viết sẵn `tests/unit/test_world_quest_unlocks.gd` |
| **F. Save/Load** | Đã code đầy đủ (`SaveLoadManager` atomic write + sanitize + outbox) | Đã viết unit test round-trip trong `tests/unit/test_world_quest_unlocks.gd` |
| **G. Cross-platform Responsive** | Đã code `SceneRouter` Breakpoints + `BoxContainer.vertical` + Touch controls | *Chờ kiểm tra visual thực tế khi co giãn cửa sổ trong Godot 4.3+* |

---

## 3. CÁC HẠNG MỤC CHƯA THỂ CHẠY TRỰC TIẾP & NGUYÊN NHÂN

- **Chạy thử Runtime & Visual Playtest trong Godot Engine:** Chưa thực hiện được trong môi trường agent hiện tại vì máy chưa cài `Godot 4.3+` executable (`godot` không tồn tại trên hệ thống).
- **Âm thanh giọng nói Buddy & SFX:** Chưa tích hợp file âm thanh vì chưa có asset audio chính thức (đã chừa hook mở rộng tại `BuddyController.speak_tip()`).
