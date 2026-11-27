# KNOWN ISSUES – ENGLISH ADVENTURE (PROMPT 08)

Danh sách các vấn đề còn tồn tại hoặc chưa kiểm chứng đầy đủ tại thời điểm kết thúc P8 và hướng giải quyết đề xuất.

---

## P0 – Critical
- *Không có.*

## P1 – High
- *Không có trong luồng gameplay chính offline/WebGL2.*
- **KI-01 (P1 – Môi trường Cloud chưa cấu hình):** Chức năng chấm phát âm AI (`PronunciationAssessmentManager` + Supabase Edge Function `pronunciation-assess`) và đồng bộ đám mây Supabase (`SaveLoadManager` cloud sync) chưa thể kiểm thử end-to-end vì chưa có project Supabase Cloud + `AZURE_SPEECH_KEY` cấu hình thực tế.
  - **Hướng giải quyết:** Triển khai SQL `0001`–`0006` lên Supabase Cloud, cấu hình `AZURE_SPEECH_KEY` / `AZURE_SPEECH_REGION`, deploy 2 Edge Functions và kiểm thử bằng tài khoản thật.

## P2 – Medium
- **KI-02 (P2 – Thiếu giọng đọc thu âm `.ogg` cho từ vựng & NPC):** Hiện game sử dụng 11 file `.wav` cho UI/SFX/BGM và dùng **Web Speech / OS Text-to-Speech** cho từ vựng/câu/NPC (`AudioAssetManager` có fallback an toàn nếu thiếu `.ogg`). Trên một số trình duyệt/OS không cài gói giọng tiếng Anh hệ thống, TTS có thể không phát tiếng.
  - **Hướng giải quyết:** Thu âm hoặc tạo bộ audio `.ogg` chuẩn `en-US` và `en-GB` cho 38 từ vựng, 26 chữ cái/âm và thoại NPC chính vào `assets/audio/`.
- **KI-03 (P2 – Chưa kiểm thử phần cứng Micro & Native Android/iOS/Windows `.exe`):** Máy trạm QA không có Godot CLI, Android SDK, macOS Xcode hoặc phần cứng micro thực tế trong môi trường headless Chrome.
  - **Hướng giải quyết:** Export và kiểm thử trên Windows native (Godot 4.3), thiết bị Android thật và iOS thật theo hướng dẫn trong `docs/CROSS_PLATFORM_TEST_REPORT.md`.
- **KI-04 (P2 – Một số mini-game registry vẫn là mở rộng tương lai):** `MiniGameManager` đăng ký 16 mini-game trong kiến trúc, trong đó **8 mini-game đã triển khai đầy đủ và có thể chơi**, 8 mini-game còn lại không mở trong MVP (đã đánh dấu rõ, không tạo màn hình giả).

## P3 – Low
- **KI-05 (P3 – Tiền tố nhãn `[E] Tương tác` khi đổi viewport nóng trên Desktop):** Trong thử nghiệm đổi nóng cửa sổ trình duyệt Desktop sang Mobile Portrait (`19_reload_mobile_portrait_hud.png`) khi đang đứng sát NPC, nút `InteractBanner` giữ nguyên chuỗi `"[E] Tương tác: ..."` của lần focus trước cho đến khi bước ra/vào vùng tương tác lại (trên thiết bị mobile thật khi vào màn chơi đã là `"Chạm: ..."`).
  - **Hướng giải quyết:** Cho `AdventureHUD._apply_responsive()` cập nhật lại tiền tố `interact_banner.text` nếu `_has_focused_target` đang bật.
- **KI-06 (P3 – Nickname mặc định khi đổi từ Leo sang Mia):** Khi người chơi mở Character Selection lần đầu (mặc định `"Leo"`), nếu bấm chọn Mia mà chưa tự gõ tên, ô biệt danh vẫn giữ `"Leo"` trừ khi bấm *Gợi ý tên* hoặc tự nhập.
  - **Hướng giải quyết:** Lưu cờ `_nickname_edited_by_user` trong `CharacterSelectionUI` để tự cập nhật `"Leo"` ↔ `"Mia"` khi người chơi chưa sửa tay.
