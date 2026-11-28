# LIÊN KẾT NỘI DUNG VỚI NHIỆM VỤ VÀ MINI-GAME (CONTENT QUEST MAPPING)
# PROJECT: ENGLISH ADVENTURE

**Tệp dữ liệu:** `data/quests/world_01_quests.json`, `data/questions/question_bank.json`.

---

## 1. Bảng ánh xạ 8 Nhiệm vụ Alphabet Island với Kho nội dung P9

| Quest ID | Khu vực | Mini-game yêu cầu | Chủ đề & Từ/Cụm từ liên kết (`learning_hook`) | Mẫu câu & Ôn tập |
|---|---|---|---|---|
| `quest_01_new_adventure` (Chính) | Welcome Village | `listen_and_find` | `greetings`, `numbers` (`word_hello`, `word_yes`, `word_one`, `word_two`; `phr_01`, `phr_06`) | `gram_01`, `gram_16`; Ôn: `word_hello` |
| `quest_02_lost_letters` (Chính) | Alphabet Meadow | `word_builder` | `alphabet`, `fruits`, `toys`, `animals` (`word_apple`, `word_ball`, `word_cat`; `phr_08`, `phr_10`) | `gram_03`, `gram_20`; Ôn: `word_apple`, `word_cat` |
| `quest_03_mysterious_gate` (Chính) | Letter Cave | `word_matching`, `sentence_builder` | `phonics`, `school`, `food` (`word_ship`, `word_book`, `word_milk`; `phr_16`, `phr_14`) | `gram_06`, `gram_07`; Ôn: `word_apple`, `word_ball`, `word_ship` |
| `quest_04_crystal_guardian` (Chính) | Crystal Lake | `memory_quest` | `colors`, `shapes`, `animals`, `weather` (`word_red`, `word_blue`, `word_star`, `word_frog`, `word_sun`; `phr_11`, `phr_33`) | `gram_18`, `gram_19`; Ôn: `word_red`, `word_frog` |
| `quest_05_shadow_gate` (Chính) | The Shadow Gate | `word_builder`, `sentence_builder`, `listen_and_find`, `dialogue_adventure` | `simple_sentences`, `feelings`, `places` (`word_happy`, `word_park`, `word_home`; `phr_04`, `phr_36`) | `gram_07`, `gram_15`, `gram_22`; Ôn: `word_apple`, `word_cat`, `word_happy`, `word_star` |
| `side_buddy_treasure` (Phụ) | Welcome Village | `word_matching` | `food`, `fruits` (`word_banana`, `word_cake`, `word_grape`; `phr_09`, `phr_15`) | `gram_07`; Ôn: `word_banana` |
| `side_lily_garden` (Phụ) | Alphabet Meadow | `sound_detective` | `colors`, `alphabet` (`word_green`, `word_yellow`, `word_pink`, `word_purple`; `phr_08`) | `gram_18`; Ôn: `word_green`, `word_yellow` |
| `side_rocky_animals` (Phụ) | Letter Cave | `speaking_hero` | `animals` (`word_dog`, `word_bird`, `word_lion`, `word_rabbit`, `word_bear`; `phr_12`, `phr_32`) | `gram_17`; Ôn: `word_dog`, `word_lion` |

---

## 2. Tái sử dụng qua Ngân hàng câu hỏi (`question_bank.json`) & Difficulty Scaling 5 cấp
Một đơn vị kiến thức (VD: `word_apple`) xuất hiện xuyên suốt ở:
1. **Level 1 – Nhận diện:** Listen and Choose / Sound Detective.
2. **Level 2 – Ghi nhớ:** Image & Word Matching / Memory Quest.
3. **Level 3 – Hiểu nghĩa:** Multiple Choice chọn nghĩa tiếng Việt.
4. **Level 4 – Sử dụng:** Word Builder (đánh vần) / Fill in the Blank.
5. **Level 5 – Vận dụng tình huống mới:** Sentence Builder / Dialogue Adventure / Speaking Hero.
