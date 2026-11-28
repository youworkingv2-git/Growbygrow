# HƯỚNG DẪN EXPORT VÀ KIỂM THỬ ANDROID (ANDROID RELEASE GUIDE)
# PROJECT: ENGLISH ADVENTURE

---

## 1. Yêu cầu môi trường & SDK
- **Godot 4.3 Standard** + **Android Export Templates**.
- **Java Development Kit (JDK 17)** (yêu cầu bởi Godot 4.3 Android Gradle build).
- **Android SDK** (`platform-tools`, `build-tools`, Android API Level `35` để đáp ứng yêu cầu `targetSdk=35` hiện hành của Google Play; `minSdk=24` hỗ trợ Android 7.0+).
- **Android Build Template** (`Project -> Install Android Build Template...` trong Godot Editor nếu xuất AAB bằng Gradle).

---

## 2. Cấu hình Ký ứng dụng (Signing) An toàn
- **Tuyệt đối KHÔNG** lưu file `.keystore`/`.jks` hoặc mật khẩu keystore vào Git hay `export_presets.cfg`.
- Tạo Release Keystore riêng trên máy bảo mật:
  ```bash
  keytool -genkey -v -keystore english-adventure-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias english_adventure
  ```
- Sao lưu keystore và mật khẩu ở trình quản lý mật khẩu ngoại tuyến (nếu mất keystore sẽ không thể cập nhật ứng dụng trên Google Play).
- Khi build release trên máy phát triển hoặc CI: truyền thông tin keystore qua biến môi trường (`GODOT_ANDROID_KEYSTORE_RELEASE_PATH`, `GODOT_ANDROID_KEYSTORE_RELEASE_USER`, `GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD`) hoặc nhập trực tiếp trong Export Dialog cục bộ (không commit lại file `export_presets.cfg`).

---

## 3. Xuất APK (Thử nghiệm) & AAB (Google Play)
- **APK cài trực tiếp:** `godot --headless --export-release "Android" builds/android/EnglishAdventure.apk` (hoặc `.\tools\build_release.ps1 -Target android_apk`).
- **AAB cho Google Play:** `godot --headless --export-release "Android AAB" builds/android/EnglishAdventure.aab` (cần Gradle + Android Build Template).

---

## 4. Checklist kiểm thử bắt buộc trên thiết bị Android thật
- Cài `EnglishAdventure.apk` qua `adb install -r` trên tối thiểu 1 máy cấu hình thấp/trung bình và 1 máy màn hình lớn/tablet.
- Kiểm tra Virtual Joystick, Touch Camera Pad, nút Tương tác/Nhảy/Pause không bị che bởi tai thỏ (Safe Area) hoặc mất thao tác khi kéo ngón tay.
- Kiểm tra khi có cuộc gọi đến, chuyển app, khóa màn hình: `AudioManager._on_app_backgrounded()` phải tạm dừng nhạc nền/TTS và hủy ghi âm micro an toàn.
- Đo FPS mục tiêu (`30–60 FPS` ở chất lượng `Low`/`Medium`), RAM và nhiệt độ máy.
