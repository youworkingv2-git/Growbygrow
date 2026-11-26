# NPC SYSTEM SPECIFICATION (PROMPT 02)
# PROJECT: ENGLISH ADVENTURE

---

## 1. KIẾN TRÚC NPC MỞ RỘNG

Mọi NPC dùng chung một scene mẫu `scenes/characters/npcs/npc.tscn` gắn script `NpcController` (`scripts/character/npc_controller.gd`) và được spawn động theo dữ liệu trong `data/npcs/alphabet_island_npcs.json`.

Mỗi bản ghi NPC gồm:
- `id`: Định danh duy nhất.
- `name_vi` / `name_en`: Tên hiển thị song ngữ.
- `role`: `mentor` / `npc` / `boss`.
- `description_vi`: Mô tả vai trò.
- `sprite_path`: Đường dẫn hình đại diện.
- `area_id` & `spawn_pos`: Khu vực và tọa độ xuất hiện.
- `appear_condition`: Điều kiện xuất hiện đánh giá qua `UnlockEvaluator`.
- `related_quest_ids` & `default_dialogue_id`: Liên kết nhiệm vụ và hội thoại.
- `on_talk_set_flag` (tùy chọn): Bật cờ trạng thái thế giới ngay khi người chơi trò chuyện.

---

## 2. DANH SÁCH NPC TRÊN ALPHABET ISLAND (PROMPT 02)

| NPC ID | Tên | Khu vực | Vai trò & Nhiệm vụ liên quan | Điều kiện xuất hiện |
|---|---|---|---|---|
| `professor_owl` | **Giáo sư Cú Mèo (Professor Owl)** | `welcome_village` | Mentor chính, giao `quest_01_new_adventure`. | Luôn xuất hiện |
| `lily` | **Bé Lily** | `welcome_village` | Cư dân làng mất chữ cái, tham gia `quest_01` & giao `quest_02_lost_letters`. | Luôn xuất hiện |
| `rocky` | **Rocky** | `letter_cave` | Sinh vật đá thân thiện, bật cờ `rocky_clue_found` mở `crystal_lake` & giao `quest_03_mysterious_gate`. | Luôn xuất hiện trong Hang Động |
| `crystal_guardian` | **Crystal Guardian** | `crystal_lake` | Người bảo vệ Hồ Pha Lê, hướng dẫn tìm `magic_crystal_shard` cho `quest_03`. | `area_unlocked: crystal_lake` |

---

## 3. CHỈ BÁO TRẠNG THÁI TRÊN ĐẦU NPC

- `!` (vàng): NPC đang có nhiệm vụ `available` có thể nhận.
- `?` (xanh lá): NPC là mục tiêu bước hiện tại của một nhiệm vụ `active`.
- Không hiện badge: Đang rảnh hoặc chỉ hội thoại thường.
