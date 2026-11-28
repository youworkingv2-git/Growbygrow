# DANH MỤC MẪU CÂU (SENTENCE PATTERNS)
# PROJECT: ENGLISH ADVENTURE

**Tệp dữ liệu:** `data/grammar/world_01_grammar.json` (**22 mẫu câu Pre-A1**, **26 câu mẫu**) & `data/grammar/world_02_a1_grammar.json` (**10 mẫu câu A1**, **12 câu mẫu**).  
Tổng: **32 mẫu câu / điểm ngữ pháp** và **38 `model_sentences`**.

---

## 1. Danh mục 22 mẫu câu Pre-A1 (`world_01_grammar.json`)
| ID | Mẫu câu | Ý nghĩa giao tiếp | Ví dụ mẫu |
|---|---|---|---|
| `gram_01` | `I am ...` | Giới thiệu bản thân, trạng thái | `I am happy.` |
| `gram_02` | `You are ...` | Nói về bạn đối diện | `You are kind.` |
| `gram_03` | `This is ...` | Chỉ vật/người ở gần | `This is an apple.` |
| `gram_04` | `That is ...` | Chỉ vật/người ở xa | `That is a star.` |
| `gram_05` | `It is ...` | Mô tả đồ vật, thời tiết | `It is a red ball.` |
| `gram_06` | `I have ...` | Nói về đồ vật đang có | `I have two books.` |
| `gram_07` | `I like ...` | Nói về sở thích | `I like apples.` |
| `gram_08` | `I can ...` | Nói về khả năng | `I can read English.` |
| `gram_09` | `I want ...` | Nói về mong muốn | `I want some water.` |
| `gram_10` | `What is this?` | Hỏi tên đồ vật | `What is this? It is a pen.` |
| `gram_11` | `What is your name?` | Hỏi tên bạn mới | `What is your name?` |
| `gram_12` | `How are you?` | Hỏi thăm sức khỏe/cảm xúc | `How are you? I am happy!` |
| `gram_13` | `Where is ...?` | Hỏi vị trí đồ vật | `Where is my blue bag?` |
| `gram_14` | `Is this ...?` | Câu hỏi Yes/No đơn giản | `Is this a cat? Yes, it is.` |
| `gram_15` | `Do you like ...?` | Hỏi sở thích bạn bè | `Do you like apples?` |
| `gram_16` | `My name is ...` | Giới thiệu tên riêng | `My name is Leo.` |
| `gram_17` | `I see ...` | Kể vật quan sát được | `I see a white rabbit.` |
| `gram_18` | `What color is it?` | Hỏi màu sắc | `What color is it? It is green.` |
| `gram_19` | `How many ...?` | Hỏi số lượng | `How many apples? Three apples.` |
| `gram_20` | `A / An + noun` | Chọn mạo từ đúng | `an apple, a book` |
| `gram_21` | `Singular & Plural (-s)` | Đếm 1 và nhiều vật | `two cats, six stars` |
| `gram_22` | `in / on / under` | Chỉ vị trí cơ bản | `The apple is on the table.` |

---

## 2. Danh mục 10 mẫu câu A1 (`world_02_a1_grammar.json`)
`I usually ...` (`gram_a1_01`), `I go to ... at ...` (`gram_a1_02`), `I would like ...` (`gram_a1_03`), `Can you ...?` (`gram_a1_04`), `There is ... / There are ...` (`gram_a1_05`), `What are you doing?` (`gram_a1_06`), `Have / Has` (`gram_a1_07`), `my / your / his / her` (`gram_a1_08`), `Where do you live?` (`gram_a1_09`), `Some / Any` (`gram_a1_10`).

Mỗi mẫu câu đều có `substitution_slots` giúp `GrammarManager.generate_substitution_sentences()` tự động sinh câu mới và cung cấp dữ liệu cho mini-game `Sentence Builder`.
