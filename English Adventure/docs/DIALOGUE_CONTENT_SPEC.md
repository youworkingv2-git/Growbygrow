# CẤU TRÚC HỘI THOẠI TÌNH HUỐNG (DIALOGUE CONTENT SPEC)
# PROJECT: ENGLISH ADVENTURE

**Tệp dữ liệu:**
- `data/minigames/dialogue_adventures.json` (**10 kịch bản Pre-A1**)
- `data/minigames/a1_dialogue_adventures.json` (**4 kịch bản mẫu A1**)
- Kèm hội thoại cốt truyện 3D trong `data/dialogue/alphabet_island_dialogues.json` (gắn liền với **Professor Owl**, **Buddy**, **Lily**, **Rocky**, **Crystal Guardian**).

---

## 1. Danh mục 14 kịch bản hội thoại tương tác (`DialogueAdventure`)
### Pre-A1 (10 tình huống):
1. `dlg_adv_01_greeting` — Greeting (`professor_owl`)
2. `dlg_adv_02_introduce` — Introducing Yourself (`lily`)
3. `dlg_adv_03_family` — Family (`lily`)
4. `dlg_adv_04_food` — Food (`professor_owl`)
5. `dlg_adv_05_animals` — Animals (`lily`)
6. `dlg_adv_06_school` — School (`professor_owl`)
7. `dlg_adv_07_help` — Asking for Help (`rocky`)
8. `dlg_adv_08_shopping` — Shopping (`crystal_guardian`)
9. `dlg_adv_09_colors_numbers` — Counting Stars & Colors (`lily`)
10. `dlg_adv_10_can_i_have` — Can I Have Some Water? (`rocky`)

### A1 Sample (4 tình huống):
11. `dlg_adv_11_a1_new_friend` — Meeting a New Friend (`lily`)
12. `dlg_adv_12_a1_hobbies` — Talking About Hobbies (`professor_owl`)
13. `dlg_adv_13_a1_shop` — At the Shop (`crystal_guardian`)
14. `dlg_adv_14_a1_school_day` — At the School & Lunch (`professor_owl`)

---

## 2. Cấu trúc mỗi kịch bản
Mỗi kịch bản có `id`, `topic`, `title_en/vi`, `npc_id`, `npc_name_vi`, `cefr_level`, `linked_grammar_id`, `linked_vocab_ids`, `review_status`, và danh sách `turns`. Mỗi lượt gồm lời NPC song ngữ (`npc_line_en`, `npc_line_vi`), 3 lựa chọn trả lời (chỉ 1 `is_correct: true`), giải thích tiếng Việt (`feedback_vi`), nút nghe giọng NPC và chế độ `"Đọc to câu trả lời"`.
