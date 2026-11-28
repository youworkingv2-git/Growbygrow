# HƯỚNG DẪN PHÁT HÀNH WEBGL2 (WEB RELEASE GUIDE)
# PROJECT: ENGLISH ADVENTURE

---

## 1. Đánh giá khả năng hỗ trợ Web
- **Ưu tiên:** Web là nền tảng thứ 4 (sau Windows, Android, iOS), phục vụ trải nghiệm nhanh và kiểm thử tự động trên trình duyệt máy tính.
- **Ưu điểm đã kiểm chứng (P8):**
  - Chạy tốt trên Chrome/Edge hỗ trợ WebGL2 với `Single-threaded WASM` (không đòi hỏi SharedArrayBuffer/COOP-COEP header phức tạp trên GitHub Pages).
  - Đã có pipeline tự động `.github/workflows/deploy-web.yml` xuất ra GitHub Pages.
  - Web Speech API TTS (`en-US` / `en-GB`) và `localStorage` (`user://`) hoạt động ổn định.
- **Hạn chế cần lưu ý:**
  - Trình duyệt di động cấu hình yếu có thể tải chậm WASM/PCK lần đầu hoặc hạn chế `MediaRecorder` / TTS tùy trình duyệt (đặc biệt iOS Safari).
  - Ghi âm Micro trên Web bắt buộc chạy qua **HTTPS** (`https://`) hoặc `localhost` và phụ thuộc sự cho phép của trình duyệt.

---

## 2. Lệnh xuất bản Web
```powershell
.\tools\build_release.ps1 -Target web
```
Hoặc chạy GitHub Actions `.github/workflows/deploy-web.yml` khi push lên nhánh `main` (với file thay đổi trong `English Adventure/`).
