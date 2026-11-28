# HƯỚNG DẪN EXPORT VÀ XCODE CHO iOS (IOS RELEASE GUIDE)
# PROJECT: ENGLISH ADVENTURE

> **Lưu ý trung thực về môi trường:** Việc biên dịch, ký chứng chỉ và xuất file `.ipa` cho iOS **bắt buộc thực hiện trên máy macOS có cài Xcode**. Môi trường Windows hiện tại chỉ chuẩn bị sẵn cấu hình `preset.4` (`iOS`) trong `export_presets.cfg`, quyền riêng tư Micro và quy trình chuyển giao lên máy Mac. **Chưa** tạo hoặc kiểm thử file `.ipa` thực tế.

---

## 1. Điều kiện tiên quyết trên macOS
- Máy Mac chạy macOS tương thích **Xcode 15/16+** và **iOS SDK** hiện hành của App Store Connect.
- **Godot 4.3 Standard** (macOS) + **iOS Export Templates**.
- Tài khoản **Apple Developer Program** (chính chủ dự án, không dùng tài khoản cá nhân trái phép).
- **Signing Certificate** (`Apple Distribution` / `Apple Development`) và **Provisioning Profile** cho Bundle ID `com.englishadventure.game`.

---

## 2. Quyền riêng tư & Microphone (`Info.plist`)
Preset `"iOS"` trong `export_presets.cfg` đã cấu hình sẵn:
- `privacy/microphone_usage_description`: `"English Adventure chỉ sử dụng micro khi bé bấm nút luyện nói tiếng Anh. Bản ghi không tự động tải lên máy chủ."`
- `user_data/accessible_from_files_app=false` & `accessible_from_itunes_file_sharing=false` để bảo vệ dữ liệu cục bộ của trẻ.
- Nếu người dùng từ chối quyền Micro hoặc thu hồi trong *iOS Settings*, game không crash và cho phép bé tiếp tục học nghe/đọc/viết bình thường (`SpeechRecorder`).

---

## 3. Các bước thực hiện trên máy Mac
1. Sao chép repo `English Adventure` sang máy Mac và mở bằng Godot `4.3`.
2. Vào **Project -> Export -> iOS**: điền `App Store Team ID` và `Provisioning Profile UUID` của chủ dự án (không commit thông tin này lên repo công khai).
3. Xuất ra Xcode project (`.xcodeproj`) hoặc `.ipa`, mở bằng Xcode:
   - Kiểm tra **Signing & Capabilities**, **App Icons (Asset Catalog)** và **Deployment Info** (iPhone & iPad).
   - Chạy thử trên **iPhone & iPad thật** (kiểm tra Safe Area tai thỏ/Dynamic Island, nút gạt im lặng/AudioSession, Virtual Joystick, chuyển ứng dụng ra nền).
4. Archive và tải lên **TestFlight** để kiểm thử nội bộ trước khi xét duyệt App Store Kids Category.
