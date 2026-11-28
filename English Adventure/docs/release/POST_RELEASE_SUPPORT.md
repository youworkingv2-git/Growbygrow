# QUY TRÌNH HỖ TRỢ SAU PHÁT HÀNH (POST-RELEASE SUPPORT)
# PROJECT: ENGLISH ADVENTURE

---

## 1. Tiếp nhận & Chẩn đoán sự cố từ người chơi
- **Log cục bộ an toàn:** `AppLogger` lưu log xoay vòng tối đa 2 file (`app.log` và `app.prev.log`, `512 KB/file`) tại `user://logs/` (đã che toàn bộ `Bearer` token và khóa nhạy cảm). Khi người chơi gặp lỗi, có thể hướng dẫn phụ huynh gửi tệp `app.log` qua kênh hỗ trợ (`REQUIRES_OWNER_INPUT`) — tuyệt đối không tự động gửi dữ liệu nền khi chưa có sự đồng ý.
- **Không thu thập giọng nói vào log:** Không ghi dữ liệu âm thanh micro vào file log hoặc crash report.

## 2. Phân loại SLA xử lý lỗi
| Mức độ | Mô tả | Hành động |
|---|---|---|
| **P0 – Crash / Mất Save** | Đóng ứng dụng đột ngột, không khởi động được, hỏng save | Hotfix `PATCH` (`+0.0.1`) ngay trong chu kỳ khẩn cấp; ưu tiên phục hồi từ `.bak.json`. |
| **P1 – Chặn nhiệm vụ / Sai đáp án** | Không qua được Quest hoặc câu hỏi sai đáp án đúng | Sửa dữ liệu JSON / logic và phát hành bản vá. |
| **P2 – Hiệu suất / Lỗi hiển thị nhỏ** | Rớt FPS trên máy yếu, lệch chữ ở màn hình hiếm | Gộp vào bản cập nhật bảo trì định kỳ. |

## 3. Chiến lược cập nhật không mất dữ liệu
- Mọi bản cập nhật đều giữ nguyên `package/unique_name="com.englishadventure.game"` (Android/iOS) và thư mục lưu `user://`, đồng thời tăng `SAVE_SCHEMA_VERSION` kèm hàm di trú bảo toàn trong `SaveLoadManager` nếu thay đổi cấu trúc save.
