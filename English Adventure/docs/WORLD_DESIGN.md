# WORLD DESIGN DOCUMENT (PROMPT 02)
# PROJECT: ENGLISH ADVENTURE

---

## 1. TỔNG QUAN THẾ GIỚI & CỐT TRUYỆN

**Lingua Realm** là thế giới phép thuật nơi ngôn ngữ mang lại ánh sáng và sự kết nối. Thế lực **The Silent Shadow** đã đánh cắp chữ cái, làm sách trống rỗng, biển chỉ dẫn mờ chữ và phong ấn các vùng đất. Người chơi nhập vai Nhà Thám Hiểm Trẻ Tuổi cùng rồng nhỏ **Buddy** khôi phục ngôn ngữ và thu thập **Magic Crystals**.

### Kiến trúc mở rộng 6 Worlds (`data/worlds/worlds.json`)
- **World 1 – Alphabet Island** (`is_mvp_active: true`): Đã xây dựng khung thế giới & 5 khu vực.
- **Worlds 2–6** (`Vocabulary Forest`, `Sentence Kingdom`, `Listening Ocean`, `Speaking City`, `Challenge Kingdom`): Đã khai báo cấu trúc dữ liệu, điều kiện mở khóa tuần tự và hiển thị trạng thái *Sắp ra mắt* trên World Map.

---

## 2. THIẾT KẾ 5 KHU VỰC 3D TRÊN ALPHABET ISLAND

Dữ liệu khu vực lưu độc lập tại `data/areas/alphabet_island_areas.json` và gắn với các scene 3D (`Node3D` + `AreaEnvironment3D` + `WorldEnvironment3DController`) tại `scenes/world/areas/`. Bản đồ chuyển đổi tọa độ JSON 2D ↔ 3D thông qua `Coord3D` (`32 px = 1 m`):

| STT | Area ID | Tên khu vực | Scene | Nội dung & Đặc điểm 3D | Điều kiện mở khóa (Data-driven) |
|---|---|---|---|---|---|
| 1 | `welcome_village` | **Welcome Village** (Làng Khởi Đầu) | `welcome_village.tscn` | **Khu vực 3D trọng điểm:** Đồi cỏ nhiều tầng, quảng trường đá, đường mòn uốn lượn, Học viện Cú Mèo, nhà Lily, đài phun nước có shader nước động, đèn đường phát sáng, cây xanh, hàng rào, hoa & hạt đom đóm. | `always_unlocked` (Khu vực xuất phát) |
| 2 | `alphabet_meadow` | **Alphabet Meadow** (Đồng Cỏ Bảng Chữ Cái) | `alphabet_meadow.tscn` | Đồng cỏ 3D tươi sáng, đường mòn dẫn tới 3 chữ cái phép thuật phát sáng xoay trên bệ đá (`A`, `B`, `C`), rương kho báu, cây & đá tảng 3D. | Hoàn thành `quest_01_new_adventure` |
| 3 | `letter_cave` | **Letter Cave** (Hang Động Chữ Cái) | `letter_cave.tscn` | Hang đá vòm 3D với sương mù xanh lam, cụm pha lê phát sáng, NPC **Rocky** 3D đội mũ đèn, chữ `E` thất lạc. | Hoàn thành `quest_02_lost_letters` |
| 4 | `crystal_lake` | **Crystal Lake** (Hồ Pha Lê) | `crystal_lake.tscn` | Hồ nước 3D dùng shader gợn sóng phản chiếu ánh sáng (`LakeWaterSurface`), bờ cát vàng, NPC **Crystal Guardian** 3D bay lơ lửng, Mảnh Pha Lê Phép Thuật. | Flag `rocky_clue_found` (gặp Rocky) |
| 5 | `shadow_gate` | **The Shadow Gate** (Cổng Bóng Tối) | `shadow_gate.tscn` | Đấu trường đá tím huyền bí, cổng vòm Obsidian phát sáng rune tím, hai trụ đá cổ và phong ấn Cổng Bóng Tối. | Hoàn thành `quest_03_mysterious_gate` + có item `magic_crystal_shard` |

---

## 3. CƠ CHẾ MỞ KHÓA & CHUYỂN CẢNH AN TOÀN

- Bộ đánh giá `UnlockEvaluator` (`scripts/adventure/unlock_evaluator.gd`) kiểm tra điều kiện thuần dữ liệu (`always_unlocked`, `quests_completed`, `flags_required`, `quests_and_items`, `area_unlocked`).
- **Bảo vệ chuyển cảnh (`SceneRouter.enter_area`):** Mọi yêu cầu vào khu vực (qua Portal trên bản đồ, bấm nút trên World Map, hoặc gọi trực tiếp) đều bắt buộc qua kiểm tra `GameStateManager.is_area_unlocked(area_id)`. Nếu chưa mở, hệ thống chặn chuyển cảnh và phát signal `area_locked_attempted` hiển thị popup **Area Locked**.
- Khi rời khu vực hoặc tự động mỗi 8 giây, `AreaExplorationController` lưu `current_area_id` và `area_positions[area_id]`.
