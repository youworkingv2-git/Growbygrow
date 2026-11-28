# QUY TẮC QUẢN LÝ PHIÊN BẢN (VERSIONING)
# PROJECT: ENGLISH ADVENTURE

---

## 1. Semantic Versioning (`MAJOR.MINOR.PATCH`)
- **`MAJOR`**: Thay đổi kiến trúc lớn hoặc thay đổi tương thích dữ liệu (VD: `1.0.0` phát hành công khai đầu tiên).
- **`MINOR`**: Bổ sung tính năng hoặc mở rộng gói học liệu lớn (VD: `0.9.0` Release Candidate sau khi hoàn thành P9 Content Expansion).
- **`PATCH`**: Sửa lỗi, tối ưu hiệu suất và tinh chỉnh UX không phá vỡ dữ liệu save (VD: `0.9.1`).

| Mốc | Phiên bản | Ý nghĩa |
|---|---|---|
| Prototype / P1–P7 | `0.1.0` – `0.4.0` | Xây dựng khung 3D, Learning Engine, Mini-games, Quest, Audio |
| QA & Content P8–P9 | `0.8.0` – `0.9.0` | Kiểm thử tổng thể + Kho nội dung Pre-A1 & mẫu A1 |
| **Release Candidate hiện tại** | **`0.9.0` (Build `900`)** | Chuẩn bị đóng gói phát hành đa nền tảng (P10) |
| First Public Release | `1.0.0` | Phát hành chính thức sau kiểm thử nhị phân & phê duyệt của chủ dự án |

---

## 2. Nguồn sự thật duy nhất (Single Source of Truth)
Số phiên bản được lưu thống nhất tại **`data/release/version.json`** và đồng bộ chặt với:
1. `project.godot` → `application/config/version="0.9.0"`
2. `export_presets.cfg` → Windows `0.9.0.0`, Android `version/name="0.9.0"` & `version/code=900`, iOS `0.9.0` (`900`)
3. `scripts/core/release_info.gd` → hiển thị trong `MainMenuUI`, `SettingsModalUI`, `AppLogger`, và lưu kèm trong `SaveLoadManager` (`app_version`, `build_number`, `schema_version`).

Bộ kiểm định `tests/content_validation/validate_prompt_10.py` tự động báo lỗi nếu bất kỳ tệp nào bị lệch phiên bản.
