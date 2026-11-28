# BÁO CÁO KIỂM THỬ BẢN PHÁT HÀNH (RELEASE TEST REPORT)
# PROJECT: ENGLISH ADVENTURE (`v0.9.0-rc.1`)

**Ngày lập báo cáo:** 2026-11-27  
**Phạm vi:** Kiểm định tự động P2–P10, rà soát tài nguyên/bảo mật và trạng thái kiểm thử từng nền tảng.

---

## 1. Kết quả Kiểm định Tự động & Công cụ (Đã chạy thực tế)

| Bộ kiểm định | Kết quả | Chi tiết đo được |
|---|---|---|
| `validate_prompt_02.py` .. `validate_prompt_09.py` | **PASS (0 errors)** | Toàn bộ cấu trúc scene/script 3D, UI/UX, Learning Engine, 8 Mini-games, Quest/Reward, Audio/Voice và 147 từ + 48 cụm + 32 mẫu câu + 116 bài kỹ năng hợp lệ 100%. |
| `validate_prompt_10.py` | **PASS (0 errors)** | Khớp phiên bản `0.9.0` (Build `900`), đủ 5 export presets, `0` secret rò rỉ, có save migration `v1->v2`, background audio/mic safety, đủ 20 tài liệu release. |
| `validate_3d_visual_direction.py` | **PASS (0 errors)** | 10 scene 3D, 5 UI Diorama 3D, 7 Character Rig 3D hợp lệ. |
| `run_p9_content_tests.py` | **PASS (0 failures)** | Toàn bộ kịch bản Test 01–08 về dữ liệu & luật mở khóa A1 đều đạt. |
| `tools/audit_release_assets.py` | **PASS** | `184` asset (`1.079 MB`); `0` file trùng lặp; tổng dung lượng nguồn đóng gói trước nén ~`2.46 MB`. |

---

## 2. Trạng thái Kiểm thử theo Nền tảng (Trung thực theo môi trường)

| Nền tảng | Trạng thái Cấu hình | Trạng thái Build | Trạng thái Cài đặt & Chạy thử Release | Ghi chú môi trường |
|---|---|---|---|---|
| **Windows PC (`.exe`)** | **Đã cấu hình** | **Chưa build cục bộ** | **Chưa test file `.exe`** | Máy hiện tại thiếu Godot `4.3` CLI & Export Templates; cần chạy `.\tools\build_release.ps1 -Target windows` trên máy có Godot 4.3 hoặc qua GitHub Actions `release-multiplatform.yml`. |
| **Android (`.apk`/`.aab`)** | **Đã cấu hình** | **Chưa build cục bộ** | **Chưa test thiết bị thật** | Thiếu Android SDK (`API 35`), JDK 17, Release Keystore và điện thoại Android kết nối `adb`. |
| **iOS (`.ipa`)** | **Đã cấu hình** | **Chưa build** | **Chưa test iPhone/iPad** | Thiếu máy **macOS + Xcode + Apple Developer Account**. |
| **Web (WebGL2)** | **Đã cấu hình** | **CI `.github/workflows/deploy-web.yml` sẵn sàng** | **Đã test P8 (WebGL2 Chrome E2E)** | Đã kiểm thử `TC01–TC10` ở P8; cần kích hoạt CI để xuất lại gói WebGL2 mới nhất có nội dung P9 & bản vá P10. |
