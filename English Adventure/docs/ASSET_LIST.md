# ASSET LIST & PLACEHOLDER INVENTORY (PROMPT 02)
# PROJECT: ENGLISH ADVENTURE

Tài liệu này liệt kê trung thực toàn bộ tài nguyên đồ họa đã tạo ở Prompt 02 và danh sách tài nguyên cần nâng cấp/bổ sung ở các giai đoạn sản xuất tiếp theo.

---

## 1. TÀI NGUYÊN VECTOR SVG ĐÃ TẠO (MVP STYLIZED CARTOON PLACEHOLDERS)

Tất cả tài nguyên bên dưới là **file SVG tự tạo có chủ đích** (phong cách cartoon thống nhất, sắc nét ở mọi độ phân giải, hợp lệ bản quyền), dùng cho giai đoạn Prompt 02 và có thể thay thế bằng sprite sheet/animation chuyên nghiệp ở giai đoạn hoàn thiện mỹ thuật:

| Nhóm | File đã có (`assets/...`) | Trạng thái |
|---|---|---|
| **Nhân vật chính** | `characters/player/boy/boy_adventurer.svg`, `characters/player/girl/girl_adventurer.svg` | MVP Vector Art (tĩnh + hoạt ảnh procedural `CharacterAnimator`) |
| **Buddy** | `characters/buddy/buddy_dragon.svg` | MVP Vector Art (dùng chung kèm MoodBadge & procedural bobbing) |
| **NPCs** | `characters/npcs/professor_owl.svg`, `lily.svg`, `rocky.svg`, `crystal_guardian.svg` | MVP Vector Art |
| **Môi trường Alphabet Island** | `environments/alphabet_island/owl_house.svg`, `village_tree.svg`, `signpost.svg`, `stone_rock.svg`, `cave_arch.svg`, `lost_letter_glow.svg`, `treasure_chest_closed.svg`, `treasure_chest_open.svg`, `magic_crystal.svg`, `shadow_gate.svg`, `portal_pad.svg` | MVP Vector Art |
| **Icons** | `icons/quest_icon.svg`, `map_icon.svg`, `backpack_icon.svg`, `crystal_icon.svg`, `gold_icon.svg`, `lock_icon.svg`, `icon.svg` | MVP Vector Art |

---

## 2. DANH SÁCH ASSET CÒN THIẾU / CẦN BỔ SUNG CHO SẢN PHẨM HOÀN CHỈNH

1. **Sprite Sheets / Skeletal Animations (Spine / Godot AnimationPlayer):**
   - Bộ frame riêng cho 7 trạng thái của Boy & Girl (`idle`, `walk`, `run`, `jump`, `interact`, `celebrate`, `hurt`) nhìn từ 4 hướng.
   - Bộ biểu cảm gương mặt riêng của Buddy cho 7 moods (`idle`, `happy`, `sad`, `surprised`, `thinking`, `talking`, `celebrating`).
2. **Tilesets & Props chi tiết cho 5 khu vực:**
   - Mặt đất tilemap cỏ, đường lát đá, mặt hồ động, tường hang động có chiều sâu 2.5D, bụi hoa, hàng rào làng.
3. **Font tiếng Việt & IPA tùy chỉnh:**
   - Nhúng `Nunito` / `Quicksand` và `Andika` vào `assets/fonts/` (hiện dùng font hệ thống mặc định của Godot).
4. **Âm thanh & Lồng tiếng (Prompt 03+):**
   - BGM cho từng khu vực trên Alphabet Island.
   - SFX (bước chân, mở rương, nhặt chữ cái, hoàn thành nhiệm vụ, mở khóa khu vực).
   - Giọng đọc tiếng Anh (`en-US`, `en-GB`) cho 26 chữ cái + 100–150 từ vựng + giọng tiếng Việt thân thiện của Buddy.
