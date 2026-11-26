# RESPONSIVE UI ARCHITECTURE
# PROJECT: ENGLISH ADVENTURE (PROMPT 03)

> **Module phụ trách:** `scripts/ui/responsive/responsive_helper.gd` (`ResponsiveHelper`) kết hợp `SceneRouter` (`EventBus.viewport_breakpoint_changed`).

---

## 1. BREAKPOINTS & FORM FACTORS HỖ TRỢ

| Breakpoint | Điều kiện kích thước | Thiết bị mục tiêu | Điều chỉnh bố cục chính |
|---|---|---|---|
| `mobile_portrait` | `width < 768px` & `height > width` | Điện thoại dọc | Card xếp 1 cột dọc, nút đủ lớn (`>= 44–52px` cao), khoảng cách tách biệt, hiện Virtual Joystick & nút chạm phải, áp dụng Safe Area padding. |
| `mobile_landscape` | `height < 520px` & `width >= height` | Điện thoại ngang | TopBar gọn vào cạnh trên, modal tự co chiều cao theo `vp.y - 32px`, hiện Touch Controls khi `control_mode` là `auto` hoặc `touch`. |
| `tablet` | `768px <= width < 1200px` | Máy tính bảng | Panel trung tâm giới hạn `max_width` hợp lý (không kéo giãn toàn màn hình gây méo tỷ lệ đọc), lưới nút/thẻ cân đối. |
| `desktop` | `width >= 1200px` | Windows / Web Desktop | Bố cục ngang rộng thoáng, HUD tối giản 4 góc, hỗ trợ đầy đủ phím tắt (`WASD`/Arrows, `E`, `Space`, `H`, `Esc`) & hover chuột. |

---

## 2. NGUYÊN TẮC KỸ THUẬT TRONG GODOT 4

1. **Stretch Mode trong `project.godot`:** `window/stretch/mode="canvas_items"`, `window/stretch/aspect="expand"` — giúp khung hình tự mở rộng theo tỷ lệ màn hình thực tế của Desktop, Web, Android, iOS mà không cắt xén hay làm nhòe UI.
2. **Container & Anchor Layout:**
   - Sử dụng `CenterContainer`, `MarginContainer`, `VBoxContainer`, `HBoxContainer`, `ScrollContainer`, `anchors_preset` thay vì đặt tọa độ tuyệt đối cố định.
   - Các modal (`SettingsModal`, `ConfirmationDialog`, `PauseMenu`, `QuestLogModal`, `BagModal`, `DialogueBox`, `QuestCompletedPopup`) tự tính kích thước tối đa không vượt quá `viewport.size - margin`, có `ScrollContainer` bảo vệ khi chiều cao màn hình nhỏ (Mobile Landscape).
3. **Safe Area Inset (`ResponsiveHelper.apply_safe_area_margins`):**
   - Đọc `DisplayServer.get_display_safe_area()` và chuyển đổi sang tọa độ giao diện để tránh vùng tai thỏ / camera notch / thanh điều hướng hệ thống trên Android & iOS.
4. **Tùy chọn Chế độ Điều khiển (`SettingsManager.control_mode`):**
   - `auto`: Tự hiện Virtual Joystick & Touch Pad trên thiết bị cảm ứng / màn hình nhỏ hoặc ngay khi phát hiện `InputEventScreenTouch`.
   - `keyboard` / `touch`: Cho phép người chơi chuyển thủ công ngay trong Settings (hữu ích khi test hoặc dùng tablet gắn bàn phím).
