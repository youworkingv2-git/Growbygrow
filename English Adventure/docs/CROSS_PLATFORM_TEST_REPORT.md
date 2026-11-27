# CROSS-PLATFORM TEST REPORT – ENGLISH ADVENTURE (PROMPT 08)

Tài liệu phân tách rõ ràng giữa nền tảng **đã chạy kiểm thử thực tế** và các nền tảng **chưa thể kiểm thử / bị chặn** do giới hạn công cụ và thiết bị trong môi trường hiện tại.

---

## 1. Bảng tổng hợp kiểm thử đa nền tảng

| Nền tảng | Môi trường / Thiết bị sử dụng | Trạng thái | Kết quả & Chi tiết |
|---|---|---|---|
| **Web (WebGL2)** | Windows 11 + Google Chrome Headless (`1280x720`) + SwiftShader WebGL2, URL `https://youworkingv2-git.github.io/Growbygrow/?p8qa=fe809d9` | **PASS** | Khởi động ổn định; render 3D + UI; di chuyển WASD/Space + drag camera; hội thoại Professor Owl; TTS `en-US`; Learning Hub; Listen & Find mini-game; World Map + khóa khu vực; Offline mode; Save/Load sau khi tắt mở lại trình duyệt. `0` console error. |
| **Mobile Viewport (Responsive Portrait `390x844` & Landscape `844x390`)** | Chrome CDP `Emulation.setDeviceMetricsOverride` (`deviceScaleFactor=2, mobile=true`) trên bản WebGL2 | **PASS (Layout & Touch UI)** | Sau khi sửa BUG-11: Main Menu xếp dọc cân đối, `AdventureHUD` hiển thị Virtual Joystick + các nút `Hỏi Buddy`/`Nhảy`/`Tương tác` + Bottom Dock không che nhau, chữ dễ đọc. **Chưa test cảm ứng đa điểm thật trên màn hình điện thoại.** |
| **Windows PC (Native `.exe` / Godot Editor)** | Không có Godot 4.3+ CLI hoặc bản `.exe` đã export trên máy trạm | **NOT TESTED (WebGL2 trên Windows Chrome đã chạy)** | Mã nguồn GDScript & `SettingsManager` hỗ trợ `resolution_index`, `fullscreen`, bàn phím/chuột và lưu `user://`; chưa chạy thử native binary `.exe` hay trong Godot Editor. |
| **Android** | Không có Android SDK / Android export template / thiết bị Android vật lý | **NOT TESTED / BLOCKED** | Đã cấu hình `gl_compatibility`, `import_etc2_astc=true`, `SafeArea`, `VirtualJoystick`, `TouchCameraPad` và xin quyền mic trong `SpeechRecorder`. Cần export APK & test thực tế trên máy Android. |
| **iOS** | Không có macOS / Xcode / thiết bị iPhone/iPad | **NOT TESTED / BLOCKED** | Đã thiết kế Safe Area và cơ chế phát âm/ghi âm dự phòng cho WebKit/iOS. Cần macOS + Xcode để export IPA và kiểm thử microphone/privacy permission trên iOS thật. |

## 2. Điều kiện cần để hoàn tất kiểm thử các nền tảng còn lại

1. **Windows Native / Godot Editor:** Cài đặt **Godot 4.3+ Standard**, mở `project.godot`, chạy scene `scenes/boot/main_entry.tscn`, và chạy `tests/unit/test_p8_regression_suite.gd` để đo FPS phần cứng & kiểm tra export `.exe`.
2. **Android:** Cài Godot 4.3 Export Templates + Android SDK/JDK, cấu hình preset Android trong `export_presets.cfg`, cài APK lên thiết bị thật để kiểm tra Virtual Joystick đa chạm, microphone `RECORD_AUDIO` permission, Safe Area và nhiệt độ/FPS.
3. **iOS:** Dùng máy macOS có Xcode + tài khoản Apple Developer để export & kiểm tra `NSMicrophoneUsageDescription`, âm thanh Safari/AVAudioSession và Safe Area tai thỏ/Dynamic Island.
