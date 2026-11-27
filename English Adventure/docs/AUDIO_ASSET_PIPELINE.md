# AUDIO ASSET PIPELINE — ENGLISH ADVENTURE

## 1. Cấu trúc Thư mục & Registry

- Registry trung tâm: `data/audio/audio_manifest.json`
- Quản lý runtime: `AudioAssetManager` (`scripts/audio/audio_asset_manager.gd`)
- Bộ sinh tài nguyên gốc sạch bản quyền: `tools/generate_procedural_audio.py`
- Thư mục cache ngoại tuyến trên thiết bị người chơi: `user://audio_cache/`

## 2. Tài nguyên Đã Đóng Gói Thực tế (Verified Bundled `.wav`)

Tất cả 11 file `.wav` dưới đây được tạo bằng tổng hợp toán học gốc (22050 Hz, 16-bit PCM mono, giấy phép CC0 nội bộ dự án) và đã kiểm chứng tồn tại trên đĩa:

| Audio ID | Nhóm | Đường dẫn | Thời lượng | Trạng thái |
| :--- | :--- | :--- | :---: | :--- |
| `ui_click` | UI | `res://assets/audio/ui/ui_click.wav` | 0.065s | `bundled_verified` |
| `ui_open` | UI | `res://assets/audio/ui/ui_open.wav` | 0.160s | `bundled_verified` |
| `ui_close` | UI | `res://assets/audio/ui/ui_close.wav` | 0.140s | `bundled_verified` |
| `sfx_correct` | SFX | `res://assets/audio/sfx/sfx_correct.wav` | 0.360s | `bundled_verified` |
| `sfx_wrong` | SFX | `res://assets/audio/sfx/sfx_wrong.wav` | 0.270s | `bundled_verified` |
| `sfx_reward_received` | SFX | `res://assets/audio/sfx/sfx_reward_received.wav` | 0.500s | `bundled_verified` |
| `sfx_quest_complete` | SFX | `res://assets/audio/sfx/sfx_quest_complete.wav` | 0.660s | `bundled_verified` |
| `sfx_area_unlocked` | SFX | `res://assets/audio/sfx/sfx_area_unlocked.wav` | 0.600s | `bundled_verified` |
| `sfx_mic_start` | SFX | `res://assets/audio/sfx/sfx_mic_start.wav` | 0.160s | `bundled_verified` |
| `sfx_mic_stop` | SFX | `res://assets/audio/sfx/sfx_mic_stop.wav` | 0.160s | `bundled_verified` |
| `bgm_welcome_village` | Music | `res://assets/audio/music/bgm_welcome_village.wav` | 8.000s (loop) | `bundled_verified` |

## 3. Trạng thái Asset Giọng đọc Từ vựng, Phonics, Câu mẫu & NPC

- Theo nguyên tắc **không tạo đường dẫn giả và không thu âm phát âm sai**, các đường dẫn `.ogg` thu sẵn trong `world_01_vocab.json`, `alphabet_a_z.json`, `phonics_units.json`, `world_01_speaking.json` giữ trạng thái `missing_asset` (`""`).
- Khi phát âm thanh học tập hoặc thoại NPC, `AudioPlaybackManager` theo thứ tự ưu tiên:
  1. File local thu sẵn trong `res://assets/audio/...` (nếu tồn tại).
  2. File đã tải offline trong `user://audio_cache/<audio_id>_<accent>.ogg`.
  3. Giọng đọc hệ thống `TextToSpeechManager` (`DisplayServer.tts_speak` trên Native Windows/Android/iOS hoặc `window.speechSynthesis` trên Web).
  4. Hiển thị văn bản + IPA + mẹo khẩu hình nếu thiết bị không có cả file thu sẵn lẫn TTS.
