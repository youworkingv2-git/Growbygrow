# READING MINI-GAMES

## 1. Word Matching (`game_word_matching.gd`)
- Hỗ trợ chuyển đổi 2 chế độ:
  - **Chế độ 1 (`word_image`):** Ghép từ tiếng Anh (kèm IPA & phát âm khi chạm) với hình minh họa.
  - **Chế độ 2 (`word_vi`):** Ghép từ tiếng Anh với nghĩa tiếng Việt.
- Không ép đồng hồ đếm ngược ở Easy/Medium; chỉ hiển thị gợi ý thời gian nhẹ ở Hard.

## 2. Memory Quest (`game_memory_quest.gd`)
- Hỗ trợ 3/4/6 cặp thẻ (`pair_count`) và 3 chế độ (`word_image`, `word_vi`, `audio_image` — nghe âm thanh rồi tìm hình).
- Kết hợp trí nhớ không gian với ghi nhớ từ vựng và phát âm chuẩn khi lật đúng cặp.

## 3. Dialogue Adventure (`game_dialogue_adventure.gd`)
- 8 tình huống giao tiếp song ngữ Anh–Việt từ `data/minigames/dialogue_adventures.json`: Greeting, Introducing Yourself, Family, Food, Animals, School, Asking for Help, Shopping.
