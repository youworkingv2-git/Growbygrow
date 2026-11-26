# UI/UX TEST REPORT – PROMPT 03
# PROJECT: ENGLISH ADVENTURE

**Ngày kiểm thử:** 2026-11-26  
**Môi trường kiểm thử thực tế:**
- **Static & Structural Validators:** `python tests/content_validation/validate_prompt_02.py` & `python tests/content_validation/validate_prompt_03.py` (máy local Windows 10, chưa cài đặt CLI `godot`).
- **Live Runtime Export & Execution:** GitHub Actions Godot `4.3.0` (Web / WebGL2 `gl_compatibility`, commit `2d9bc2f`, workflow `45768554500`) chạy trực tiếp tại `https://youworkingv2-git.github.io/Growbygrow/` qua trình duyệt Chromium.

---

## 1. KẾT QUẢ KIỂM TRA TỰ ĐỘNG (STATIC VALIDATORS)

| Script | Nội dung kiểm tra | Kết quả |
|---|---|---|
| `validate_prompt_02.py` | 9 file JSON dữ liệu, 210 tham chiếu `res://`, 191 đường dẫn `@onready` trong `.tscn` | **PASS** |
| `validate_prompt_03.py` | 27 file UI/UX mới/cập nhật, 11 autoloads trong `project.godot`, đồng bộ khóa dịch `vi`/`en`, kiểm tra lỗi suy luận kiểu `Variant` | **PASS** |

---

## 2. KẾT QUẢ KIỂM THỬ THỰC TẾ TRÊN WEBGL2 (DESKTOP & MOBILE PORTRAIT)

### 2.1. Luồng Desktop (`1280x720` scaled viewport)
1. **Splash Screen → Main Menu:** Logo, thanh tải và chuyển cảnh tự động sang Main Menu hoạt động mượt; nút `Tiếp tục Phiêu Lưu` chỉ bật khi có dữ liệu lưu hợp lệ; nút `Chơi lại từ đầu` mở `ConfirmationDialog` cảnh báo trước khi ghi đè.
2. **Settings Modal & Notification Stack:** Mở từ Main Menu, World Map và HUD; thẻ modal hiển thị nền đặc (`#14213D`, viền `#476B9E`) không lộ nền sau; các thanh trượt âm lượng, chọn ngôn ngữ (`vi`/`en`), chế độ điều khiển (`auto`/`keyboard`/`touch`), giảm chuyển động (`reduced_motion`) hoạt động; thông báo `"Đã lưu cài đặt!"` nổi ở lớp trên cùng phía trên modal. *(Mục độ phân giải hiển thị ở trạng thái khóa trên Web đúng thực tế nền tảng.)*
3. **Character Selection → World Introduction:** Chọn Boy/Girl đổi viền vàng rõ ràng, kiểm tra độ dài biệt danh, xác nhận an toàn → hiển thị World Introduction 4 đoạn song ngữ EN/VI với thanh tiến độ và nút `Bỏ qua` / `Tiếp tục >`.
4. **In-game Exploration & Sequential Popups (`Welcome Village` → `Alphabet Meadow`):**
   - Di chuyển bằng phím `WASD` và tương tác `E` với `Professor Owl`, `Bé Lily`, và `Biển Chỉ Dẫn Làng Khởi Đầu`.
   - `DialogueBox` hiển thị đúng avatar từng nhân vật (`Professor Owl`, `Lily`, `Buddy`), ẩn sạch `BottomDock`, `InteractBanner`, `QuestTracker` và `MobileControls`.
   - Khi hoàn thành Quest 01 tại Biển Chỉ Dẫn: `DialogueBox` đóng xong mới hiện `QuestCompletedPopup` (`+50 EXP | +25 Gold`), nhấn `Tuyệt vời!` mới hiện `AreaUnlockedPopup` (`Mở khóa: Đồng Cỏ Bảng Chữ Cái!`), nhấn `Đi tới ngay!` chuyển thẳng sang `Alphabet Meadow` và tự nhận đề xuất Quest 02.
5. **World Map:** Hiển thị 5 khu vực và đường nối; khu vực `Welcome Village` hiện `[OK]` & Quest 01 `[OK]`; `Alphabet Meadow` mở khóa `[!]`; `Letter Cave` bị khóa hiển thị rõ lý do mở khóa và vô hiệu hóa nút vào khu vực.
6. **Quest Log, Inventory & Pause Menu:** `QuestLogModal` dùng `QuestCardWidget` đọc trực tiếp từ `QuestManager`; `BagModal` kết nối `GameStateManager.inventory` (hiển thị trạng thái trống trung thực khi chưa có vật phẩm); `PauseMenu` (`Esc`) mở thẻ đặc, nút `Lưu & Về Menu Chính` yêu cầu xác nhận khi đang có Quest dở dang.

### 2.2. Kiểm thử mô phỏng Mobile Portrait (`260x380`, `mobile: true`, `deviceScaleFactor: 2`)
- Breakpoint `mobile_portrait` tự động kích hoạt `VirtualJoystick` (góc dưới trái) và `RightPad` (`Hỏi Buddy`, `Nhảy`, `Tương tác` góc dưới phải).
- `TopBar`, `QuestTracker`, `InteractBanner`, `BottomDock` tự co gọn nằm trọn trong chiều ngang hẹp, không tràn chữ hoặc chồng nút lên nhau.
- **Ghi nhận thực tế:** Khi kéo chiều cao ảo vượt quá `720px` ở tỷ lệ dọc (`expand` aspect), phần nền ngoài vùng `720px` của `Alphabet Meadow` lộ dải nền xám mặc định của Viewport dưới khu vực bản đồ 2D (không ảnh hưởng UI/HUD nhưng cần mở rộng nền cỏ của scene môi trường nếu hỗ trợ chơi dọc toàn màn hình).

---

## 3. CÁC LỖI ĐÃ PHÁT HIỆN VÀ SỬA TRONG QUÁ TRÌNH KIỂM THỬ

1. **Modal & DialogueBox trong suốt trong WebGL2:** Sửa nền `PanelContainer` sang `alpha = 1.0`, truyền `UIManager.shared_theme` xuống các `Control` con của `CanvasLayer`, và áp style tường minh cho `SettingsModal`, `ConfirmationDialog`, `PauseMenu`, `AreaLockedPopup` và `DialogueBox`.
2. **Notification bị che dưới `SettingsModal`:** Đưa `notif_anchor` lên cuối `_overlay_layer` (`offset_top = 14.0`) để hiển thị phía trên mọi modal.
3. **HUD Dock/Joystick không ẩn kịp khi bắt đầu hội thoại:** Đồng bộ `_dialogue_active` + `call_deferred("_sync_overlay_visibility")` khi nhận `EventBus.dialogue_started`.
4. **Chồng 3 popup (`DialogueBox` + `QuestCompletedPopup` + `AreaUnlockedPopup`) khi kiểm tra Biển Chỉ Dẫn:** Đổi thứ tự `InteractionManager` phát thoại trước khi báo tiến độ Quest, sửa `QuestManager._complete_quest()` chỉ chạy `evaluate_all_unlocks(true)` sau khi phát `quest_completed`, và chặn `InteractionManager` khi UI modal đang mở.

---

## 4. PHÂN LOẠI TRẠNG THÁI NGHIỆM THU

- **DONE AND TESTED (WebGL2 Live + Validators):** Design System, Splash, Main Menu, Character Selection, World Introduction, World Map, In-game HUD, Dialogue UI, Quest Intro/Log/Completed Popups, Reward Display, Inventory UI (kết nối dữ liệu thực), Settings Modal (Volume/Language/Control Mode/Reduced Motion/Save), Pause Menu, Notification Stack, Confirmation Dialog, Mobile Portrait Touch Controls layout.
- **IMPLEMENTED BUT NOT TESTED:** Cài đặt `Fullscreen` & đổi `Resolution` trên bản chạy **Windows/macOS Desktop** (không khả dụng trong sandbox WebGL2), kiểm thử cảm ứng thật trên thiết bị **Android / iOS**, và kiểm tra hiệu ứng âm thanh thực tế trên `AudioManager` khi chưa có file âm thanh đi kèm.
- **NOT IMPLEMENTED (ngoài phạm vi Prompt 03 hoặc chờ asset):** Learning Engine & 5 Mini-games hoàn chỉnh, file `.ogg`/`.wav` BGM/SFX, font `.ttf`/`.otf` tùy chỉnh trong `assets/fonts/`.
- **BLOCKED:** Chạy kiểm tra trực tiếp bằng `godot` binary cục bộ trên máy Windows hiện tại (do chưa cài đặt `godot` CLI; đã thay bằng export & chạy thực tế qua GitHub Actions Godot `4.3.0` Web build).
