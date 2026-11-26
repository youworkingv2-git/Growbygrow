# LISTENING MINI-GAMES

## 1. Listen and Find (`game_listen_and_find.gd`)
- **Luồng học:** Professor Owl phát âm từ vựng từ `VocabularyManager`; người chơi chọn hình minh họa tương ứng.
- **Độ khó:** Easy = 2 hình (ưu tiên khác chủ đề để tránh gây nhiễu sớm), Medium = 3 hình, Hard = 4–5 hình.
- **Phản hồi:** Nút Nghe lại (`Space`), Gợi ý chữ cái đầu + IPA (`H`), phát lại từ ngay khi chọn sai kèm nghĩa tiếng Việt.

## 2. Sound Detective (`game_sound_detective.gd`)
- **Luồng học:** Phân biệt rõ **Tên chữ cái** (Letter Name: `/eɪ/`, `/biː/`) và **Âm chữ cái** (Letter Sound: `/æ/`, `/b/`) ở Pre-A1 dựa trên `alphabet_a_z.json`, đồng thời mở rộng phân biệt từ ở Medium/Hard.
- **Âm thanh:** Sử dụng `MiniGameAudioManager.play_word_or_sentence()`; ưu tiên file `.ogg` nếu có, fallback giọng đọc trình duyệt trên Web, và báo rõ trạng thái `missing_asset` nếu chưa có file thu âm.
