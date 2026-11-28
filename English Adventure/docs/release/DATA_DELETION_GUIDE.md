# HƯỚNG DẪN XÓA DỮ LIỆU NGƯỜI CHƠI (DATA DELETION GUIDE)
# PROJECT: ENGLISH ADVENTURE

---

## 1. Xóa dữ liệu ngay trong Game
1. Tại **Menu Chính**, bấm **"Chơi lại từ đầu"** và xác nhận hộp thoại đồng ý (`SaveLoadManager.delete_save()`).
2. Hệ thống sẽ xóa `active_profile.json`, `active_profile.bak.json` và `sync_outbox.json` khỏi thiết bị.

## 2. Xóa thủ công trên từng nền tảng
- **Windows PC:** Xóa thư mục `%APPDATA%\Godot\app_userdata\ENGLISH ADVENTURE\` (lưu ý: gỡ/cài đè bản cập nhật game **không** tự xóa thư mục này để bảo vệ tiến trình của trẻ).
- **Android:** Vào *Cài đặt (Settings) -> Ứng dụng (Apps) -> English Adventure -> Lưu trữ (Storage) -> Xóa dữ liệu (Clear Data)* hoặc gỡ cài đặt ứng dụng.
- **iOS:** Xóa ứng dụng khỏi màn hình chính để xóa toàn bộ dữ liệu sandbox cục bộ.
- **Web (WebGL2):** Xóa dữ liệu trang web (`IndexedDB` / `localStorage`) trong cài đặt trình duyệt.

## 3. Dữ liệu đồng bộ đám mây (nếu bật Supabase)
- Khi triển khai đồng bộ tài khoản Supabase, yêu cầu xóa dữ liệu tài khoản sẽ thực hiện xóa bản ghi theo `user_id` / `profile_id` thông qua quy trình hỗ trợ (`REQUIRES_OWNER_INPUT`).
