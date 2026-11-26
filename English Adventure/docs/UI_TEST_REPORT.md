# UI/UX & 3D GAME EXPERIENCE TEST REPORT – PROMPT 03
# PROJECT: ENGLISH ADVENTURE

**Ngày kiểm thử:** 2026-11-26  
**Môi trường kiểm thử thực tế:**
- **Static & Structural Validators:** `validate_prompt_02.py`, `validate_prompt_03.py`, và `validate_3d_visual_direction.py` (máy local Windows 10, chưa cài đặt CLI `godot`).
- **Live Runtime Export & Execution:** GitHub Actions Godot `4.3.0` (Web / WebGL2 `gl_compatibility`, các bản build `3af2375`, `421ab42`, `6d7a5c3`, `ae6e618`, workflow `45775652520`) chạy trực tiếp tại `https://youworkingv2-git.github.io/Growbygrow/` qua trình duyệt Chromium.

---

## 1. KẾT QUẢ KIỂM TRA TỰ ĐỘNG (STATIC VALIDATORS)

| Script | Nội dung kiểm tra | Kết quả |
|---|---|---|
| `validate_prompt_02.py` | 9 file JSON dữ liệu, 177 tham chiếu `res://`, 208 đường dẫn `@onready` trong `.tscn` | **PASS** |
| `validate_prompt_03.py` | 27 file UI/UX, 11 autoloads trong `project.godot`, đồng bộ khóa dịch `vi`/`en`, kiểm tra lỗi suy luận kiểu `Variant` | **PASS** |
| `validate_3d_visual_direction.py` | 10 scene gameplay & khu vực 3D (không dùng `Sprite2D`/`Node2D`), 5 màn hình UI nhúng `SubViewport` `own_world_3d = true`, 7 nhân vật 3D có `is_placeholder`, 3 mức chất lượng đồ họa & `Asset3DSlot` | **PASS** |

---

## 2. KẾT QUẢ KIỂM THỬ THỰC TẾ TRÊN WEBGL2 (DESKTOP & MOBILE)

1. **Splash Screen 3D → Main Menu 3D (`ae6e618`):** Splash Screen hiển thị thế giới 3D `Diorama3DStage` kèm logo và thanh tải; Main Menu hiển thị diorama Welcome Village 3D sống động với Leo 3D và Buddy 3D bay lơ lửng; nút `Tiếp tục Phiêu Lưu` bật vàng khi có Save hợp lệ.
2. **Character Selection 3D (`421ab42` & `6d7a5c3`):** Leo & Mia hiển thị bằng mô hình 3D trên 2 bệ xoay `SubViewportContainer`, không bị giãn dọc ở chế độ **Mobile Portrait (`360×640`)**, hỗ trợ kéo xoay 360°.
3. **World Introduction 3D & World Map 3D Isometric:** Hiển thị sa bàn 3D Đảo Chữ Cái với 5 khu vực, đường nối, vòng xoáy khóa tím và cửa sổ chi tiết từng khu vực.
4. **In-game Exploration 3D (`Welcome Village`) & Third-person Camera (`ae6e618`):**
   - Nhân vật chính Leo 3D, Buddy 3D (bong bóng thoại chiếu theo vị trí 3D), Professor Owl 3D, Bé Lily 3D, Đài phun nước, Biển chỉ dẫn, Rương kho báu, nhà cửa và ánh sáng/bóng đổ hiển thị rõ nét, **0 lỗi console (`window.__gdLogs == []`)**.
   - Trong chế độ Touch/Compact (`MobileControls`), `VirtualJoystick` (góc dưới trái), `RightPad` (`Hỏi Buddy`, `Nhảy`, `Tương tác` góc dưới phải) và `BottomDock` (`Bản đồ`, `Nhiệm vụ`, `Túi đồ`, `Lưu`) tách lớp rõ ràng, không chồng lấp nhau; `Nhiệm vụ` mở `QuestLogModal` (`QuestCardWidget` + `RewardDisplay`) mượt mà và đóng sạch bằng `Esc`.
   - Giao diện `DialogueBox` 2D hiển thị phía dưới trên nền thế giới 3D, cùng chuỗi popup tuần tự `Dialogue` → `QuestCompletedPopup` → `AreaUnlockedPopup`.
5. **Settings Modal & Notification Stack:** Lưu và áp dụng `Music`/`SFX` Volume, Ngôn ngữ (`vi`/`en`), `Control Mode`, `Graphics Quality` (`Low`/`Medium`/`High`), `Camera Sensitivity`, `Reduced Motion`, kèm thông báo không chặn thao tác.

---

## 3. CÁC LỖI ĐÃ PHÁT HIỆN VÀ SỬA TRONG QUÁ TRÌNH KIỂM THỬ

1. **Modal & DialogueBox trong suốt trên WebGL2:** Chuyển nền `PanelContainer` sang opaque (`alpha = 1.0`), truyền `UIManager.shared_theme` và áp style tường minh.
2. **Giãn khung 3D Character Selection trên Mobile Portrait (`421ab42`):** Cập nhật tỷ lệ `SubViewportContainer` theo chế độ portrait.
3. **Lỗi parse GDScript do trùng tên biến `right_pad` trong `AdventureHUD` (`42ed056`):** Đổi tên node `@onready var touch_right_pad: VBoxContainer` để không đè biến cục bộ `right_pad` (safe area margin).
4. **Vùng vuốt `TouchCameraPad` chặn nút `BottomDock` (`ae6e618`):** Đưa `MobileControls` ra phía sau `BottomDock` trong cây scene và giới hạn `TouchCameraPad` (`anchor_bottom = 0.84`).

---

## 4. PHÂN LOẠI TRẠNG THÁI NGHIỆM THU (PROMPT 03 §19)

- **DONE AND TESTED (WebGL2 Live + Static Validators):** Design System (`UIDesignSystem`), Splash 3D, Main Menu 3D, Character Selection 3D, World Introduction 3D, World Map 3D Isometric, Welcome Village 3D, Third-person Camera (`SpringArm3D`, zoom, mouse/key/touch orbit), HUD, Dialogue UI, Quest Intro/Log/Completed Popups, Reward Display, Inventory UI (kết nối dữ liệu thực), Settings Modal (`Graphics Quality`, `Camera Sensitivity`, `Language`, `Control Mode`, `Reduced Motion`, `Music`/`SFX`), Pause Menu, Notification Stack, Confirmation Dialog, và bố cục Touch Controls không chồng lấp.
- **IMPLEMENTED BUT NOT TESTED:**
  - `Fullscreen` & đổi `Resolution` trên bản chạy **Windows Desktop** (bị vô hiệu hóa hợp lý trên WebGL2).
  - Đo **FPS thực tế** trên máy Windows native, thiết bị **Android / iOS** vật lý, và kiểm thử kéo xoay 360° / vuốt `TouchCameraPad` trên màn hình cảm ứng thật.
  - Nghe kiểm tra trực tiếp âm thanh qua `AudioManager` (mã hook `Music`/`SFX` đã kết nối đầy đủ nhưng chưa có file `.ogg`/`.wav` đính kèm).
  - Bốn khu vực 3D còn lại (`Alphabet Meadow`, `Letter Cave`, `Crystal Lake`, `The Shadow Gate`) đã hoàn thiện scene/script và qua validator cấu trúc; trong đợt test trình duyệt này mới ưu tiên kiểm thử trực tiếp **Welcome Village 3D** và **Alphabet Meadow** (chưa đi hết toàn bộ 5 khu vực trên bản 3D mới nhất).
- **NOT IMPLEMENTED:**
  - Bộ mô hình `.glb`/Blender hoàn chỉnh từ 3D Artist (hiện sử dụng placeholder 3D có khớp gắn `is_placeholder = true`, thay thế qua `Asset3DSlot`).
  - File âm thanh `.ogg`/`.wav` trong `assets/audio/` và font tùy chỉnh `.ttf`/`.otf` trong `assets/fonts/`.
  - `LearningEngine`, 5 Mini-games, Supabase Auth/Sync (thuộc phạm vi Prompt 04+).
- **BLOCKED:** Chạy kiểm thử và đo FPS bằng `godot` binary cục bộ trên máy Windows hiện tại (do chưa cài đặt `godot` CLI; đã thay thế bằng build & chạy thực tế qua GitHub Actions Godot `4.3.0` WebGL2).
