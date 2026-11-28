# GHI CHÚ PHÁT HÀNH (RELEASE NOTES)
# ENGLISH ADVENTURE — `v0.9.0-rc.1` (Build 900)

**Ngày phát hành ứng viên:** 2026-11-27  
**Trạng thái:** Release Candidate 1 (Chuẩn bị kiểm thử cài đặt đa nền tảng)

---

## Điểm mới nổi bật trong `v0.9.0`
1. **Kho nội dung Pre-A1 hoàn chỉnh cho Alphabet Island & Gói mẫu A1:**
   - **26 chữ cái** A–Z tách biệt Tên chữ cái và Âm chữ cái, **24 đơn vị Phonics + 6 bài tập ghép âm**.
   - **115 từ vựng Pre-A1** + **32 từ mẫu A1** kèm **147 ảnh minh họa SVG riêng 1:1**.
   - **48 cụm từ thông dụng**, **32 mẫu câu + 38 câu ví dụ**, **116 bài thực hành 4 kỹ năng** (28 Nghe, 28 Đọc, 28 Viết chấp nhận đa đáp án hợp lệ, 16 Nói), **14 hội thoại tương tác** và **20 câu hỏi dùng chung**.
   - Cơ chế mở khóa A1 đa yếu tố và bảng theo dõi phân tách 4 trạng thái ghi nhớ.
2. **Hoàn thiện Chuẩn bị Phát hành (P10):**
   - Quản lý phiên bản thống nhất (`data/release/version.json`) hiển thị trên Menu Chính và Cài đặt kèm tóm tắt Quyền riêng tư trẻ em.
   - Cơ chế di trú dữ liệu save an toàn (`v1 -> v2`) có sao lưu trước di trú (`.pre_migrate_v1.bak.json`).
   - Tự động tạm dừng nhạc nền/TTS và hủy buffer ghi âm micro khi ứng dụng mất tiêu điểm hoặc thu nhỏ ra nền.
   - Cấu hình export presets cho **Windows Desktop**, **Android APK/AAB**, **iOS** và **Web** cùng bộ script đóng gói & kiểm định tự động.
   - Khắc phục `KI-05` (cập nhật tiền tố `[E]`/`Chạm:` khi thay đổi màn hình) và `KI-06` (đồng bộ tên gợi ý `Leo`/`Mia` khi chưa tự sửa tên).
