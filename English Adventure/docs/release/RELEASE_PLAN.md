# KẾ HOẠCH PHÁT HÀNH (RELEASE PLAN)
# PROJECT: ENGLISH ADVENTURE (`v0.9.0-rc.1`)

**Phiên bản mục tiêu hiện tại:** `0.9.0` (Build `900` · Release Candidate 1)  
**Đối tượng người dùng:** Trẻ em ~10 tuổi mới bắt đầu học tiếng Anh (Pre-A1 & nền tảng A1).

---

## 1. Mục tiêu từng nền tảng

| Thứ tự ưu tiên | Nền tảng | Định dạng phân phối | Trạng thái kỹ thuật hiện tại |
|---|---|---|---|
| **1. Windows PC** | Windows 10/11 64-bit | Portable ZIP (`EnglishAdventure.exe` + `.pck`) | Đã cấu hình preset `"Windows Desktop"` & script đóng gói `tools/build_release.ps1` + CI `.github/workflows/release-multiplatform.yml`. Cần Godot 4.3+ CLI & Export Templates để xuất file thực tế. |
| **2. Android** | Android 7.0+ (`minSdk=24`, `targetSdk=35`, `arm64-v8a`) | `.apk` (cài thử nghiệm) & `.aab` (Google Play) | Đã cấu hình preset `"Android"` & `"Android AAB"` + quyền `INTERNET`, `RECORD_AUDIO`, Safe Area, `VirtualJoystick`. Cần Android SDK/JDK + Release Keystore của chủ dự án. |
| **3. iOS** | iPhone / iPad | `.ipa` qua Xcode | Đã cấu hình preset `"iOS"` + mô tả quyền Micro tiếng Việt. Cần **macOS + Xcode + Apple Developer Account** để build & ký. |
| **4. Web (WebGL2)** | Trình duyệt hỗ trợ WebGL2 | Static Web (`index.html`, `.wasm`, `.pck`) | Đã cấu hình preset `"Web"` + GitHub Actions `.github/workflows/deploy-web.yml` & đã kiểm thử WebGL2 E2E P8. |

---

## 2. Lộ trình chốt phát hành (Release Candidate -> Public Release)
1. **RC1 (`0.9.0`, hiện tại):** Đóng băng tính năng lớn, hoàn tất kiểm định dữ liệu P1–P10, chuẩn bị cấu hình & tài liệu phát hành.
2. **Export & Kiểm thử nhị phân thực tế:** Chạy build Windows `.exe`, Android `.apk/.aab` và iOS `.ipa` trên môi trường có đủ Godot 4.3 + SDK + thiết bị thật.
3. **Thẩm định pháp lý & nội dung:** Chủ dự án rà soát/duyệt `PRIVACY_POLICY_DRAFT.md`, `TERMS_OF_USE_DRAFT.md`, điền thông tin liên hệ/URL thật (`REQUIRES_OWNER_INPUT`) và thẩm định sư phạm.
4. **Public Release (`1.0.0`):** Chỉ gắn nhãn `1.0.0` và phát hành công khai sau khi tất cả nền tảng mục tiêu vượt qua `RELEASE_TEST_PLAN.md`.
