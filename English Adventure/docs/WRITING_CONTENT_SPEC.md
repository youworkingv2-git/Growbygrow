# QUY CHUẨN NỘI DUNG LUYỆN VIẾT (WRITING CONTENT SPEC)
# PROJECT: ENGLISH ADVENTURE

**Tệp dữ liệu:** `data/writing/world_01_writing.json` (**22 bài viết Pre-A1**) & `data/writing/world_02_a1_writing.json` (**6 bài viết A1**). Tổng: **28 bài viết**.

---

## 1. Các dạng bài luyện viết
1. `fill_missing_letter`: Chọn chữ cái còn thiếu (`A P P _ E`, `S _ N`, `L I B _ A R Y`).
2. `assemble_letters_word`: Ghép các chữ cái rời thành từ (`DOG`, `FROG`, `BREAD`, `MUSIC`).
3. `fill_word_in_sentence`: Điền từ phù hợp vào chỗ trống trong câu (`The ball is ___.`, `I ___ my teeth every morning.`).
4. `arrange_words_sentence`: Sắp xếp từ lộn xộn thành câu chuẩn trật tự.
5. `type_simple_sentence`: Viết câu hoàn chỉnh có gợi ý `starter_chips`.

---

## 2. Hỗ trợ nhiều cách diễn đạt đúng (`acceptable_answers`)
Trong Prompt 09, `WritingManager.evaluate_answer()` (`scripts/learning/writing_manager.gd`) được nâng cấp:
- Chuẩn hóa chữ hoa/thường, khoảng trắng thừa và dấu câu cuối câu (`.`, `!`, `?`).
- Kiểm tra mảng `acceptable_answers` bên cạnh `target_text`, giúp những bài viết mở như `write_21`, `write_22`, `write_a1_05`, `write_a1_06` chấp nhận cả các biến thể hợp lệ (VD: `"Hello! I am happy."` và `"I'm happy."` hay `"I usually do my homework."` và `"I usually study English."`).
- Phản hồi ngay lập tức kèm giải thích tiếng Việt khi sai hoặc đúng.
