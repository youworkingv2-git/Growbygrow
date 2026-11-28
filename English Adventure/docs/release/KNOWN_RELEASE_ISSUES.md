# CÁC VẤN ĐỀ CÒN TỒN TẠI TRƯỚC PHÁT HÀNH (KNOWN RELEASE ISSUES)
# PROJECT: ENGLISH ADVENTURE (`v0.9.0-rc.1`)

---

## P0 – Critical (Chặn phát hành công khai)
- **RI-01 (Môi trường Build nhị phân chưa chạy tại máy trạm):** Máy trạm phát triển hiện tại chưa cài đặt Godot `4.3` CLI/Export Templates, Android SDK/JDK và không có macOS/Xcode nên chưa xuất và chạy thử file nhị phân `.exe`, `.apk/.aab`, `.ipa` của phiên bản `0.9.0`.
  - *Cách khắc phục:* Cài Godot `4.3` Standard + Export Templates hoặc chạy GitHub Actions `.github/workflows/release-multiplatform.yml` (Windows/Web) và máy Mac (iOS), sau đó thực hiện kiểm thử `RELEASE_TEST_PLAN.md`.

## P1 – High
- **RI-02 (Dịch vụ Cloud Supabase & Azure AI Speech chưa cấu hình production):** Migration `0001`–`0007` đã sẵn sàng nhưng chưa gắn `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `AZURE_SPEECH_KEY` thực tế. Hiện AI chấm phát âm giữ trung thực `ai_scoring_status: "not_integrated_experimental"`.
  - *Cách khắc phục:* Triển khai Supabase Cloud Staging/Production, chạy SQL migrations và kiểm thử RLS + Edge Functions.
- **RI-03 (Chưa có thông tin pháp lý & Signing chính thức từ chủ dự án):** `PRIVACY_POLICY_DRAFT.md`, `TERMS_OF_USE_DRAFT.md`, `STORE_ASSETS_CHECKLIST.md` còn các trường `REQUIRES_OWNER_INPUT` (URL, Email hỗ trợ, Keystore Android, Apple Team ID, Age Rating).
  - *Cách khắc phục:* Chủ dự án rà soát, điền thông tin thật và thẩm định pháp lý trước khi nộp lên Store.

## P2 – Medium
- **RI-04 (Thiếu giọng đọc `.ogg` thu sẵn):** 147 từ vựng, 48 cụm từ và 116 bài kỹ năng khai báo trung thực `audio_status: "missing_asset"` (đang dùng TTS hệ điều hành/Web `en-US`/`en-GB`).
  - *Cách khắc phục:* Thu âm gói `.ogg` bản địa vào `assets/audio/voices/` theo `docs/CONTENT_ASSET_GUIDELINES.md`.
- **RI-05 (Kho từ vựng mới hoàn thành Gói 1 Pre-A1 & mẫu A1):** Đạt 115/200–250 từ Pre-A1 và 32/300–400 từ A1; phần còn lại triển khai theo `docs/CONTENT_EXPANSION_ROADMAP.md`.

## P3 – Low
- **RI-06 (Một số ảnh SVG 2D P2 legacy chưa tham chiếu trực tiếp trong scene 3D):** 7 file SVG nhỏ (`~14 KB` tổng cộng) giữ lại để tương thích `docs/ASSET_LIST.md`. Không ảnh hưởng hiệu suất hay dung lượng build.
- *(Ghi nhận đã khắc phục trong P10: Lỗi `KI-05` tiền tố `[E] Tương tác` khi đổi viewport nóng và lỗi `KI-06` tự đổi tên gợi ý `Leo` ↔ `Mia` trước khi người dùng sửa tay.)*
