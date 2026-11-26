# SPEAKING MINI-GAMES

## 1. Speaking Hero (`game_speaking_hero.gd`)
- **Kiến trúc tách 3 lớp độc lập:**
  1. **Model Audio Playback:** Nghe phát âm mẫu + xem IPA + mẹo khẩu hình (`mouth_hint_vi`).
  2. **Local Microphone Recording & Playback:** Dùng `AudioEffectRecord` trên bus `"Record"` khi chạy trên thiết bị native (Windows/Android/iOS) có microphone; hỗ trợ nút ghi âm, nghe lại bản ghi, và ghi âm lại. Trên WebGL2/máy không có mic, thông báo trung thực trạng thái thiết bị.
  3. **Speech Recognition & AI Pronunciation Assessment (Pending):** Lấy báo cáo năng lực từ `SpeakingManager.get_capability_report()` (`ai_pronunciation_scoring_available = false`, `"not_integrated_experimental"`). **Tuyệt đối không tự tạo điểm phát âm giả.**

## 2. Chế độ luyện nói trong Dialogue Adventure (`game_dialogue_adventure.gd`)
- Có công tắc `"Đọc to câu trả lời"` cho phép người chơi nghe mẫu và luyện đọc theo từng lượt hội thoại của 8 tình huống giao tiếp.
