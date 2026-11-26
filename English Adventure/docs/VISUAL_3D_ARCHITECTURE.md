# 3D VISUAL ARCHITECTURE (ADDENDUM)
# PROJECT: ENGLISH ADVENTURE – STYLIZED 3D FANTASY CARTOON

---

## 1. ĐÁNH GIÁ KIẾN TRÚC & NGUYÊN TẮC CHUYỂN ĐỔI 2D → 3D

Trước khi chuyển hệ thống hiển thị chính sang 3D, toàn bộ kiến trúc từ Prompt 01 (Core Systems), Prompt 02 (Alphabet Island Exploration & Quests) và Prompt 03 (UI/UX System) đã được giữ nguyên vẹn và bảo toàn:

- **Không xóa chức năng cũ, không tạo dự án mới:** Tất cả autoload (`EventBus`, `GameStateManager`, `QuestManager`, `SaveLoadManager`, `DataRepository`, `LocalizationManager`, `SceneRouter`, `SettingsManager`, `AudioManager`, `UIManager`) và dữ liệu JSON (`data/*.json`) tiếp tục hoạt động nguyên bản.
- **Tương thích tọa độ (`Coord3D` – `scripts/core/coord_3d.gd`):** Các tệp dữ liệu Prompt 02 (`alphabet_island_areas.json`, `alphabet_island_npcs.json`) và save file người chơi lưu tọa độ phẳng `(0..1280, 0..720)`. Lớp cầu nối `Coord3D.to_3d()` / `Coord3D.to_2d()` quy đổi mượt mà theo tỷ lệ `32 px = 1.0 m` quanh tâm `(0, 0, 0)` trên mặt phẳng XZ, giúp:
  - Không làm hỏng bất kỳ dữ liệu save hoặc bộ kiểm tra cốt truyện nào.
  - Tự động định vị chính xác Player, Buddy, NPC, Interactable Objects và Portals trong thế giới 3D.
- **Renderer tương thích đa nền tảng (`gl_compatibility`):** `project.godot` giữ nguyên `gl_compatibility` để xuất bản ổn định trên **Windows, Android, iOS và WebGL2**.

---

## 2. CAMERA GÓC NHÌN THỨ BA (THIRD-PERSON CAMERA) & WORLD MAP 3D

### Gameplay Third-Person Camera (`scenes/characters/player/player.tscn`, `scripts/character/player_controller.gd`)
- Cấu trúc phân cấp: `Player (CharacterBody3D)` → `CameraPivot (Node3D)` → `SpringArm3D (collision_mask = 2, spring_length = 6.8, margin = 0.35)` → `Camera3D (fov = 52°)`.
- **Chống xuyên vật thể:** `SpringArm3D` tự động thu ngắn khoảng cách khi gặp công trình, cây cối, đá hoặc tường biên (`collision_layer = 2`).
- **Điều khiển góc nhìn:**
  - Chuột phải / chuột giữa kéo để xoay ngang-dọc (`pitch` giới hạn `[-0.92, -0.18]` rad tránh xuyên đất).
  - Cuộn chuột để thu phóng (`4.0 m` – `10.5 m`).
  - Phím `Q` / `C` hỗ trợ xoay camera nhanh trên laptop.
  - Di chuyển nhân vật theo hướng nhìn hiện tại của camera (Camera-relative `WASD` / Phím mũi tên / Touch Virtual Joystick).
- **Khung hình hội thoại (Dialogue Framing):** Khi nói chuyện với NPC, `PlayerController.set_dialogue_focus(npc_pos)` quay nhân vật hướng về NPC và đưa camera vào góc trung cảnh êm ái, giữ khung hội thoại 2D nằm gọn phía dưới không che nhân vật.

### World Map 3D (`scripts/visual3d/alphabet_island_3d_map.gd`, `scenes/world/world_map/world_map.tscn`)
- Sử dụng `SubViewportContainer` (`own_world_3d = true`) với góc nhìn 3D trên cao / isometric nhìn toàn cảnh **Alphabet Island**:
  - Đại dương hoạt ảnh gợn sóng bao quanh bờ cát và cao nguyên đảo xanh.
  - 5 địa danh 3D đại diện cho 5 khu vực và các điểm sáng dẫn đường nối liền nhau.
  - Vòng sương tím *The Silent Shadow* xoay quanh các khu vực đang bị khóa.
  - Các nút bấm HUD đồng bộ vị trí bằng `Camera3D.unproject_position()`.

---

## 3. ÁNH SÁNG, HIỆU ỨNG & PHÂN TẦNG CHẤT LƯỢNG (`Low` / `Medium` / `High`)

Quản lý tập trung tại `WorldEnvironment3DController` (`scripts/visual3d/world_environment_3d.gd`) kết nối với `SettingsManager.graphics_quality`:

| Mức cấu hình | Bóng đổ (`DirectionalLight3D`) | MSAA 3D | Render Scale | Glow / Bloom | Sương mù (Fog) | SSAO | Hạt phép thuật (`CPUParticles3D`) |
|---|---|---|---|---|---|---|---|
| **Low** (Mobile / Tiết kiệm pin) | Tắt (dùng GroundShadow disc nhẹ) | Tắt | `0.85x` | Tắt | Tắt | Tắt | Giảm/tắt hạt môi trường |
| **Medium** (Web / Cân bằng) | Bật (2-split, 40m) | `2x` | `1.0x` | Nhẹ (`0.35`) | Bật | Tắt | Số lượng trung bình |
| **High** (Desktop / Full) | Bật (4-split, 55m) | `4x` | `1.0x` | Đầy đủ (`0.55`) | Bật | Bật (Desktop native) | Số lượng đầy đủ |

- Mỗi khu vực trong 5 khu vực có bảng màu bầu trời (`ProceduralSkyMaterial`), màu ánh sáng mặt trời, góc chiếu và mật độ sương mù riêng.
- Các chi tiết trang trí phụ (bụi hoa, hàng rào, cành phụ) tích hợp `visibility_range_end` (LOD theo khoảng cách) để giảm số lượng draw call ở xa.

---

## 4. HỆ THỐNG UI TRÊN NỀN THẾ GIỚI 3D

- Các thành phần UI (`AdventureHUD`, `DialogueBox`, `QuestCard`, `RewardDisplay`, `SettingsModal`, `WorldMap`) giữ phong cách **Modern Fantasy Cartoon**, bo góc, viền sáng, hiệu ứng hover/press từ `UIDesignSystem` và `UIAnimator`.
- Khi khám phá thế giới, thanh trên (`TopBar`) và thanh dưới (`BottomDock`) gọn gàng ở mép màn hình, chừa toàn bộ vùng trung tâm cho nhân vật 3D và Buddy 3D.
- Bong bóng thoại của **Buddy** tự chiếu từ vị trí 3D của Buddy lên màn hình thông qua `Camera3D.unproject_position()`.
