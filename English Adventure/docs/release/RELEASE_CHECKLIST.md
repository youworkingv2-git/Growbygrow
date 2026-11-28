# CHECKLIST TRƯỚC KHI PHÁT HÀNH (RELEASE CHECKLIST)
# PROJECT: ENGLISH ADVENTURE (`v0.9.0`)

---

## A. Kỹ thuật, Cấu hình & Kiểm định Tự động
- [x] Thống nhất phiên bản `0.9.0` (Build `900`) giữa `version.json`, `project.godot`, `export_presets.cfg` và UI Settings/Main Menu.
- [x] Tách cấu hình Development (`DEBUG`) và Release (`INFO`, chỉ nạp nội dung `approved`/`published`, loại bỏ `tests/`, `tools/`, `docs/`, `supabase/` khỏi `.pck`).
- [x] Quét bảo mật: `0` secret/key/mật khẩu trong code, config và `export_presets.cfg`.
- [x] Save/Load có `schema_version=2`, sao lưu `.bak.json`, sao lưu tiền di trú `v1 -> v2` và không xóa dữ liệu khi nâng cấp.
- [x] Tạm dừng âm thanh & hủy buffer ghi âm micro ngay khi ứng dụng ra nền / mất focus.
- [x] Vượt qua toàn bộ kiểm định tự động `validate_prompt_02.py` .. `validate_prompt_10.py`, `validate_3d_visual_direction.py` và `run_p9_content_tests.py`.

## B. Đóng gói & Kiểm thử Nhị phân Thực tế (Cần hoàn tất trên máy có SDK/Thiết bị)
- [ ] Export và kiểm thử cài đặt sạch `EnglishAdventure.exe` trên Windows 10/11 64-bit.
- [ ] Chạy `tests/unit/test_p8_regression_suite.gd`, `test_p9_content_integration.gd`, `test_p10_release_readiness.gd` bằng Godot `4.3` CLI.
- [ ] Export `EnglishAdventure.apk` / `.aab` ký bằng Release Keystore thật và test trên >= 2 máy Android (thấp/trung bình & tablet).
- [ ] Export `.ipa` trên macOS + Xcode và test trên iPhone/iPad thật (Safe Area, Micro permission, AudioSession).
- [ ] Chụp bộ Screenshots chính thức từ bản Release `0.9.0` & tạo icon PNG đa kích thước.

## C. Pháp lý, Store & Phê duyệt Chủ dự án
- [ ] Chủ dự án điền các trường `REQUIRES_OWNER_INPUT` (Privacy Policy URL, Support Email, Đơn vị phát hành).
- [ ] Hoàn thành Age Rating Questionnaire trên Google Play Console / App Store Connect.
- [ ] Phê duyệt nội dung sư phạm Pre-A1/A1 và quyết định thời điểm chuyển từ `0.9.0-rc.1` sang `1.0.0`.
