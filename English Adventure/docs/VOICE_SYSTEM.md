# VOICE SYSTEM — ENGLISH ADVENTURE

## 1. Kiến trúc Luồng Giọng nói

```
NPC / DialogueBoxUI / LearningHub / MiniGame
  └─> AudioManager.voice_manager (VoiceManager)
        ├─> VoiceProfileManager (cấu hình pitch/rate theo nhân vật & phương ngữ en-US / en-GB)
        └─> AudioPlaybackManager
              ├─> MusicManager.push_duck("speech", 0.30)
              ├─> Bundled / Cached AudioStream (nếu có file thu sẵn)
              ├─> TextToSpeechManager (OS TTS hoặc Web SpeechSynthesis)
              └─> EventBus.voice_playback_started / finished -> Animation miệng NPC
```

## 2. Hỗ trợ Phương ngữ (`en-US` & `en-GB`)

- Cấu hình mặc định cho MVP: **`en-US`**.
- Có thể chuyển sang **`en-GB`** trong Cài đặt (`SettingsModalUI` -> *Phương ngữ chuẩn*), lưu bền vững trong `SettingsManager.preferred_accent`.
- Không trộn lẫn ngẫu nhiên Anh-Mỹ và Anh-Anh trong cùng phiên học: `VoiceProfileManager.get_active_accent()` áp dụng nhất quán cho từ vựng (IPA + audio), phonics (`Z` -> `"Zed"` khi `en-GB`), và lời thoại NPC.

## 3. Tính năng Điều khiển & Ngăn Chồng lấn

- Phát lại (`replay()`), Tạm dừng (`pause()`), Tiếp tục (`resume()`), Dừng (`stop()`).
- Tốc độ đọc điều chỉnh từ `0.65x` đến `1.15x` (mặc định `0.85x` thân thiện trẻ mới học), kèm chế độ **Nghe chậm** (`0.72 * speech_rate`) cho từ vựng và phonics.
- Mọi yêu cầu phát mới đều gọi `stop_all_speech()` trước để đảm bảo hai câu tiếng Anh không bao giờ đọc đè lên nhau.
