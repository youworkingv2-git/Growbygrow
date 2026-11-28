# HƯỚNG DẪN BUILD VÀ PHÂN PHỐI WINDOWS (WINDOWS RELEASE GUIDE)
# PROJECT: ENGLISH ADVENTURE

---

## 1. Điều kiện môi trường build
- **Godot Engine `4.3` Standard** (64-bit, **không** dùng bản .NET).
- **Godot 4.3 Export Templates** đã cài đặt cho Windows Desktop (`windows_release_x86_64.exe`).
- Windows 10 / 11 64-bit (hoặc GitHub Actions `ubuntu-latest` qua `chickensoft-games/setup-godot@v2`).

---

## 2. Các bước tạo bản build Windows Portable
1. Chạy bộ kiểm định trước đóng gói:
   ```powershell
   .\tools\build_release.ps1 -Target windows
   ```
   Script sẽ tự động:
   - Chạy toàn bộ validator `validate_prompt_02.py` .. `validate_prompt_10.py` + `validate_3d_visual_direction.py` + `run_p9_content_tests.py`.
   - Kiểm tra `godot` CLI trong `PATH` (nếu thiếu sẽ dừng và báo lỗi trung thực).
   - Chạy `godot --headless --import` và `godot --headless --verbose --export-release "Windows Desktop" builds/windows/EnglishAdventure.exe`.
   - Xác nhận sự tồn tại của `EnglishAdventure.exe` và `EnglishAdventure.pck` (> 0 byte).
   - Đóng gói thành `builds/EnglishAdventure-v0.9.0-windows-x64.zip` kèm file checksum `.sha256`.

---

## 3. Quy trình kiểm thử & nâng cấp trên máy người dùng sạch
- **Chạy độc lập:** Giải nén ZIP vào thư mục bất kỳ (VD: `C:\Games\EnglishAdventure\`), chạy `EnglishAdventure.exe` mà **không** cần cài Godot Editor hay Python.
- **Lưu dữ liệu người chơi:** Toàn bộ save nằm ở `%APPDATA%\Godot\app_userdata\ENGLISH ADVENTURE\profiles\`.
- **Nâng cấp phiên bản:** Giải nén bản mới đè lên thư mục ứng dụng **không** ảnh hưởng tới thư mục `AppData`, do đó giữ nguyên toàn bộ tiến trình học của trẻ.
- **Môi trường chưa hỗ trợ/chưa kiểm thử:** Máy trạm phát triển hiện tại chưa cài Godot 4.3 CLI nên cần chạy bước export này trên máy cài Godot 4.3 hoặc thông qua workflow `.github/workflows/release-multiplatform.yml`.
