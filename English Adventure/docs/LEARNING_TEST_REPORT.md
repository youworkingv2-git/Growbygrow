# LEARNING ENGINE TEST REPORT
# PROJECT: ENGLISH ADVENTURE (Prompt 04)

**Ngày kiểm thử:** 2026-11-26  
**Phiên bản:** Prompt 04 (`0.4.0-learning-engine`, commit `4c32a09`)

---

## 1. Kiểm thử Tự động (Automated Content, Scene & GDScript Validators)

| Bộ kiểm thử | Kết quả | Chi tiết |
|---|---|---|
| `python tests/content_validation/validate_prompt_02.py` | **PASS** | 19 JSON files, 224 `res://` refs, 221 `@onready` paths |
| `python tests/content_validation/validate_prompt_03.py` | **PASS** | 27 UI/UX files, localization parity (`vi` / `en`), zero GDScript 4.3 `Variant` traps |
| `python tests/content_validation/validate_3d_visual_direction.py` | **PASS** | 10 3D gameplay & area scenes, 5 dioramas, 7 3D character rigs |
| `python tests/content_validation/validate_prompt_04.py` | **PASS** | 26 chữ cái A–Z, 32 từ vựng + 32 file SVG tồn tại thực tế, 10 nhóm Phonics, 15 cấu trúc câu + 12 câu mẫu, 12 bài Listening, 12 bài Reading, 12 bài Writing, 6 bài Speaking (`not_integrated_experimental`), 8 bài học, toàn vẹn tham chiếu Quest `learning_hook` |

## 2. Kiểm thử Build & Import Tài nguyên Godot 4.3 (CI GitHub Actions)

- **Workflow `Deploy Godot WebGL2 to GitHub Pages`** trên commit `4c32a09`: **SUCCESS**.
  - `Import Godot Resources (Headless)`: **SUCCESS** (Godot 4.3.0 import thành công 32 ảnh SVG tại `assets/learning/images/`, `scenes/learning/learning_hub_modal.tscn`, `scenes/ui/adventure_hud.tscn` và toàn bộ GDScript mới).
  - `Export Godot Web Build`: **SUCCESS**.
  - `Deploy to GitHub Pages`: **SUCCESS** tại `https://youworkingv2-git.github.io/Growbygrow/`.

## 3. Kiểm thử Thực tế & Những phần chưa thể chạy tương tác tự động

- **Đã kiểm tra thực tế qua CDP trên bản deploy:** Trang WebGL2 tải xong (`readyState: "complete"`, `#status` ẩn sau khi nạp WASM/PCK, `<canvas>` kích thước `823x425`, `0` lỗi console khi tải).
- **Chưa kiểm tra tương tác trực quan trên Windows/Browser trong phiên này:**
  - Máy Windows cục bộ chưa cài binary `godot` CLI để chạy scene headless/editor trực tiếp.
  - Khi gọi `browser_take_screenshot` trên Cursor IDE Browser, cửa sổ Cursor đang ở trạng thái ẩn/thu nhỏ nên Chromium không vẽ frame để chụp ảnh và thao tác click từng nút bài học trong `LearningHubModal`.
  - **Khuyến nghị kiểm tra thủ công bởi người dùng (theo Mục G trong báo cáo):** Mở game trên Windows (Godot 4.3+) hoặc mở trình duyệt tới `https://youworkingv2-git.github.io/Growbygrow/`, vào game và nhấn `[L]` hoặc nút **Học tập** để đi hết 1 bài học mẫu (kiểm tra trả lời sai -> xem đáp án/giải thích -> thử lại -> trả lời đúng -> thoát/tải lại trang kiểm tra lưu tiến trình).
