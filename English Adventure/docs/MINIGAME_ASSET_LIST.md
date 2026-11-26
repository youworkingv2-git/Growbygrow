# MINI-GAME ASSET LIST & HONEST STATUS REPORT

## 1. Đã có và đang sử dụng trực tiếp
- Hình minh họa SVG từ vựng dùng chung của Prompt 04 (`res://assets/learning/images/*.svg`: `apple`, `banana`, `orange`, `cat`, `dog`, `bird`, `book`, `ball`, `bag`, `sun`, `tree`, `flower`, `water`, `milk`, `bread`, `fish`, `red`, `blue`, `green`, `yellow`, `one`, `two`, `three`, `mother`, `father`, `happy`, `ship`).
- Toàn bộ JSON dữ liệu học tập dùng chung (`alphabet_a_z.json`, `phonics_units.json`, `world_01_vocab.json`, `world_01_grammar.json`, `world_01_writing.json`, `world_01_speaking.json`) + 2 JSON mới (`minigame_registry.json`, `dialogue_adventures.json`).
- Giao diện 2D Stylized Fantasy Cartoon Overlay (`MiniGameUI`) dựng bằng `StyleBoxFlat` & theme thống nhất.

## 2. Asset còn thiếu / đang chờ bổ sung
- **File thu âm giọng đọc chuẩn (`.ogg`)** cho từ vựng (`audio_us_path` / `audio_uk_path`), âm chữ cái (`audio_name` / `audio_sound`), câu mẫu ngữ pháp và hội thoại NPC (`audio_status: "missing_asset"`). Hiện tại trên WebGL2 có hỗ trợ đọc fallback qua Web Speech API (`AudioManager.speak_browser_tts_fallback`), trên desktop/mobile chưa có file `.ogg` sẽ hiển thị trung thực văn bản + IPA.
- **SFX chuyên biệt cho mini-game** (`minigame_correct.ogg`, `minigame_wrong.ogg`, `minigame_click.ogg`, `minigame_reward.ogg`).
- **Dịch vụ ngoài chưa tích hợp:** Cloud ASR (Speech-to-Text) & AI Pronunciation Scoring cho **Speaking Hero**.
