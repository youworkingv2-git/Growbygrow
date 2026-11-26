# GRAMMAR & SENTENCE STRUCTURE SYSTEM
# PROJECT: ENGLISH ADVENTURE (Prompt 04)

## 1. Dữ liệu & Module

- Dữ liệu: `data/grammar/world_01_grammar.json`
- Quản lý: `GrammarManager` (`scripts/learning/grammar_manager.gd`)

## 2. Bộ 15 Cấu trúc Câu Cơ bản (Pre-A1)

1. `I am ...`
2. `You are ...`
3. `This is ...`
4. `That is ...`
5. `It is ...`
6. `I have ...`
7. `I like ...`
8. `I can ...`
9. `I want ...`
10. `What is this?`
11. `What is your name?`
12. `How are you?`
13. `Where is ...?`
14. `Is this ...?`
15. `Do you like ...?`

Kèm **12 câu mẫu đơn giản** (`model_sentences`) dùng trực tiếp trong bài học và hội thoại.

## 3. Trường dữ liệu & Cơ chế Thay thế từ (Substitution Builder)

Mỗi cấu trúc gồm: `id`, `structure`, `explanation_vi`, `example_sentences`, `difficulty`, `common_mistakes_vi`, `substitution_slots`, `practice_activities`.

Hàm `GrammarManager.generate_substitution_sentences(grammar_id)` cho phép trẻ nhìn thấy cách thay thế thành phần trong câu (ví dụ `I like ...` -> `I like apples`, `I like bananas`, `I like milk`, `I like cats`) thay vì học vẹt một câu cố định.
