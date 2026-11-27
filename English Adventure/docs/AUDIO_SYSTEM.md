# AUDIO SYSTEM — ENGLISH ADVENTURE (Prompt 07)

## 1. Tổng quan Kiến trúc `AudioVoiceSystem`

Hệ thống âm thanh và giọng nói của **English Adventure** được tổ chức theo mô hình module độc lập dưới `scripts/audio/`, giao tiếp thông qua `AudioManager` (Autoload) và `EventBus`, không để NPC hay Mini-game gọi trực tiếp API nhà cung cấp AI bên ngoài.

```
scripts/audio/
├── audio_manager.gd                  # Autoload Facade điều phối toàn bộ hệ thống
├── audio_asset_manager.gd            # Quản lý manifest, metadata, cache offline, audit asset
├── audio_settings_manager.gd         # Quản lý AudioServer Buses (Master, Music, SFX, Voice, Learning)
├── music_manager.gd                  # Nhạc nền lặp & ducking tự động khi có thoại
├── sound_effect_manager.gd           # Pool SFX đa âm + chống spam click
├── voice_profile_manager.gd          # Hồ sơ giọng đọc NPC & Learning Narrator (en-US / en-GB)
├── text_to_speech_manager.gd         # Adapter TTS đa nền tảng (DisplayServer.tts_* + Web SpeechSynthesis)
├── audio_playback_manager.gd         # Hàng đợi phát thoại/sample thống nhất, chống chồng chéo
├── voice_manager.gd                  # API giọng nói cho NPC, Từ vựng, Phonics, Câu mẫu
├── speech_recorder.gd                # Ghi âm đa nền tảng + kiểm tra quyền Micro + tín hiệu
├── speech_recognition_manager.gd     # Adapter Speech-to-Text (STT) tách biệt khỏi chấm phát âm
├── pronunciation_assessment_manager.gd # Adapter AI Pronunciation Assessment + Proxy Backend + MOCK Dev
├── pronunciation_feedback_manager.gd # Sinh phản hồi tích cực EN/VI thân thiện với trẻ 10 tuổi
└── audio_event_handler.gd            # Gắn EventBus gameplay/quest/dialogue vào Music/SFX/Playback
```

## 2. Phân tách Audio Buses (`AudioServer`)

- `Master`: Âm lượng tổng.
- `Music`: Nhạc nền phiêu lưu (`bgm_welcome_village.wav`), tự động giảm xuống `0.30x` (ducking) khi có giọng đọc tiếng Anh.
- `SFX`: Hiệu ứng UI (`ui_click`, `ui_open`, `ui_close`) và Gameplay (`sfx_correct`, `sfx_wrong`, `sfx_reward_received`, `sfx_quest_complete`, `sfx_area_unlocked`, `sfx_mic_start`, `sfx_mic_stop`).
- `Voice`: Lời thoại NPC (Professor Owl, Buddy, Lily, Rocky, Crystal Guardian).
- `Learning`: Âm thanh từ vựng, phonics, câu mẫu, bản ghi âm của trẻ — giữ mức sàn an toàn tối thiểu `15%` để trẻ không tắt nhầm âm thanh bài học.
- `Record`: Bus thu âm riêng cho `AudioEffectRecord`, luôn được mute đầu ra để tránh vọng mic (feedback loop).

## 3. Nguyên tắc Phân tách Ba Chức năng

1. **Text-to-Speech (TTS)**: Chuyển văn bản thành giọng nói (`TextToSpeechManager`).
2. **Speech-to-Text (STT)**: Chuyển giọng nói thành văn bản (`SpeechRecognitionManager`).
3. **Pronunciation Assessment**: Đánh giá chất lượng phát âm (`PronunciationAssessmentManager`).

Không đồng nhất STT với đánh giá phát âm và không tự chấm điểm giả từ độ khớp chuỗi.
