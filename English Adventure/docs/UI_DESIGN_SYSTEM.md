# UI DESIGN SYSTEM
# PROJECT: ENGLISH ADVENTURE (PROMPT 03)

> **File triển khai chuẩn:** `scripts/ui/managers/ui_design_system.gd` (`UIDesignSystem`)  
> **Áp dụng toàn cục:** `UIManager` (`scripts/ui/managers/ui_manager.gd`) gán `UIDesignSystem.build_global_theme()` lên `get_tree().root.theme` ngay khi khởi động.

---

## 1. ĐỊNH HƯỚNG THẨM MỸ (FANTASY CARTOON ADVENTURE)
- Thế giới phép thuật tươi sáng, hài hòa, thân thiện với trẻ ~10 tuổi: **không quá trẻ con** nhưng giàu cảm giác phiêu lưu, dễ nhận biết ngay nút hành động chính, biểu tượng trực quan đi kèm chữ.
- Không lạm dụng quá nhiều màu nổi cùng lúc; chữ trên nền tối luôn giữ tương phản cao (`#F8FAFC` trên nền `#14213D` / `#1B2B48`).

---

## 2. BẢNG MÀU CHÍNH THỨC (`UIDesignSystem`)

| Token | Hex | Mục đích sử dụng |
|---|---|---|
| `PRIMARY` | `#2EA8FF` | Màu chủ đạo (Adventure Sky Blue) — nút chính, thanh chọn, viền focus |
| `PRIMARY_DARK` / `PRIMARY_LIGHT` | `#1677C8` / `#63C0FF` | Viền dưới tạo chiều sâu 3D nhẹ & trạng thái Hover |
| `SECONDARY` | `#FFB800` | Màu phụ (Adventure Gold) — điểm nhấn phiêu lưu, tiêu đề, EXP |
| `BACKGROUND` / `BACKGROUND_MID` | `#0F1D36` / `#172B4D` | Nền Deep Twilight Sky cho các màn hình toàn cảnh |
| `SURFACE` / `SURFACE_ELEVATED` | `#1B2B48` / `#223659` | Nền các bảng, thẻ, modal (render opaque `alpha = 1.0` tránh lộ UI nền) |
| `SURFACE_CREAM` | `#FFFDF7` | Thẻ sáng khi cần độ nổi bật nội dung |
| `SUCCESS` / `SUCCESS_DARK` | `#22C55E` / `#15803D` | Xác nhận, hoàn thành nhiệm vụ, đã lưu |
| `WARNING` | `#F59E0B` | Trạng thái đang thực hiện / lưu ý |
| `ERROR` | `#FB7185` | Cảnh báo lỗi dịu mắt (Warm Coral — không gây tâm lý sợ sai) |
| `LOCKED` / `LOCKED_DARK` | `#64748B` / `#475569` | Khu vực / nhiệm vụ / nút đang bị khóa |
| `REWARD` / `CRYSTAL` | `#FACC15` / `#38BDF8` | Phần thưởng Gold, Stars, Magic Crystals |
| `BORDER_DEFAULT` / `BORDER_FOCUS` | `#476B9E` / `#FDE047` | Viền mặc định & viền Focus cho bàn phím/tay cầm |
| `TEXT_LIGHT` / `TEXT_MUTED` / `TEXT_EN` | `#F8FAFC` / `#CBD5E1` / `#60C5FF` | Chữ chính tiếng Việt, chú thích, nội dung học tiếng Anh |

---

## 3. TYPOGRAPHY HIERARCHY

| Token | Kích thước (`px`) | Vai trò |
|---|---|---|
| `FONT_HEADING` | `26` | Tiêu đề màn hình / Logo / Banner lớn |
| `FONT_SUBHEADING` | `20` | Tiêu đề bảng, popup, khu vực |
| `FONT_LEARNING` | `19` | Nội dung học tiếng Anh (rõ nét, không dùng font trang trí) |
| `FONT_BUTTON` | `17` | Nhãn nút bấm chính & phụ |
| `FONT_DIALOGUE` | `17` | Nội dung hội thoại NPC / Buddy |
| `FONT_BODY` | `16` | Văn bản mô tả, hướng dẫn tiếng Việt |
| `FONT_CAPTION` | `13` | Nhãn phụ, chỉ số EXP, chú thích nhỏ |

- Hỗ trợ đầy đủ dấu tiếng Việt và ký tự tiếng Anh thông qua hệ thống font fallback mặc định của Godot 4.
- *(Ghi chú asset: Chưa nhúng file font tùy chỉnh `.ttf`/`.otf` vào `assets/fonts/` — xem mục Asset còn thiếu.)*

---

## 4. HỆ THỐNG NÚT DÙNG CHUNG (`apply_button_variant`)

| Variant | Ý nghĩa | Màu nền chính |
|---|---|---|
| `primary` | Hành động chính (Play, Map, Enter Area) | `PRIMARY` (`#2EA8FF`) |
| `secondary` | Hành động phụ (Settings, Back, Bag, Quests) | `#2C456E` |
| `confirm` / `success` | Xác nhận, Chấp nhận, Lưu, Đi tới ngay | `SUCCESS` (`#22C55E`) |
| `reward` | Phần thưởng, Tương tác `[E]`, Buddy Help | `SECONDARY` (`#FFB800`) |
| `back` | Quay lại màn hình trước | `#243B61` |
| `close` / `danger` | Đóng bảng, Hành động nguy hiểm | `#B93855` |
| `icon` | Nút công cụ gọn trên HUD / Header | `#233A5E` |
| `disabled` | Trạng thái vô hiệu hóa | `LOCKED` (`#64748B`) |

Mỗi nút tự động có đủ **5 trạng thái**: `normal`, `hover` (sáng +14%), `pressed` (tối -16% + co nhẹ `0.96`), `focus` (viền vàng `BORDER_FOCUS`), và `disabled` (mờ rõ ràng, không nhận hover/click), kết hợp `UIAnimator.attach_button_feedback()` (hover scale `1.03`, click SFX qua `AudioManager`).
