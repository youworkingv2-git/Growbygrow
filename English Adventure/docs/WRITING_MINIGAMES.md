# WRITING MINI-GAMES

## 1. Word Builder (`game_word_builder.gd`)
- **Luồng học:** Lấy từ vựng từ `VocabularyManager` theo độ dài phù hợp độ khó (`word_max_length`: 3 ở Easy, 5 ở Medium, 10 ở Hard).
- **Tương tác đa nền tảng:** Hỗ trợ chạm/click thẻ chữ cái trên Mobile & PC, gõ trực tiếp bàn phím A–Z / Backspace / Enter trên PC, nút Xóa chữ cuối / Làm lại, và Gợi ý điền tiếp 1 chữ cái đúng.
- **Hiển thị sau hoàn thành:** Từ đầy đủ, IPA, nghĩa tiếng Việt và phát âm mẫu.

## 2. Sentence Builder (`game_sentence_builder.gd`)
- **Luồng học:** Lấy câu mẫu từ `GrammarManager` (`world_01_grammar.json`) và `arrange_words` (`world_01_writing.json`).
- **Hỗ trợ học tập:** Hiển thị bản dịch tiếng Việt, giải thích ngữ pháp ngắn gọn, phát âm câu hoàn chỉnh, và chấp nhận các biến thể hợp lệ (`accepted_variants`, ví dụ `I am` ↔ `I'm`).
