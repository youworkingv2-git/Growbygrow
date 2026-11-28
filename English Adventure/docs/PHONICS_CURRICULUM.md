# CHƯƠNG TRÌNH PHONICS & PHÁT ÂM (PHONICS CURRICULUM)
# PROJECT: ENGLISH ADVENTURE

**Tệp dữ liệu:** `data/phonics/phonics_units.json` & `data/alphabet/alphabet_a_z.json`.

---

## 1. Quy tắc sư phạm cốt lõi: Letter Name vs Letter Sound
Trong toàn bộ `alphabet_a_z.json` (26 chữ cái):
- Mỗi chữ cái tách biệt **Tên chữ cái (`letter_name_ipa`)** và **Âm thường gặp (`letter_sound_ipa`)**.
- Ví dụ: Chữ **A/a** có tên chữ `/eɪ/`, nhưng âm ngắn phổ biến trong `apple` là `/æ/`. Hệ thống không bao giờ dùng âm `/eɪ/` để dạy ghép âm `apple`.
- Mỗi chữ cái có `mouth_hint_vi` (hướng dẫn đặt miệng), `exception_note_vi` (lưu ý ngoại lệ nhẹ nhàng), và `anchor_word_ids` trỏ tới từ vựng thật có hình SVG minh họa.

---

## 2. Hệ thống 24 Phonics Units qua 10 nhóm lộ trình

1. `alphabet`, `letter_names`, `letter_sounds`: Nhận diện 26 chữ hoa/thường và phân biệt tên vs âm.
2. `short_vowels` (5 units): `a (/æ/)`, `e (/ɛ/)`, `i (/ɪ/)`, `o (/ɒ/)`, `u (/ʌ/)`.
3. `long_vowels` (3 units): `a_e (/eɪ/)`, `i_e (/aɪ/)`, `o_e (/oʊ/)`.
4. `consonants` (6 units): `b (/b/)`, `c (/k/)`, `d (/d/)`, `m (/m/)`, `s (/s/)`, `t (/t/)`.
5. `consonant_digraphs` (4 units): `sh (/ʃ/)`, `ch (/tʃ/)`, `th (/θ/)`, `wh (/w/)`.
6. `vowel_teams` (3 units): `ee (/iː/)`, `oo (/uː/)`, `ai (/eɪ/)`.
7. `common_sound_patterns` (2 units): `-at (/æt/)`, `-an (/æn/)`.
8. `basic_word_blending` (1 unit): Ghép vần C-V-C (`cat`, `pen`, `dog`, `bag`, `sun`).

---

## 3. Các dạng bài Phonics (`phonics_activities`)
Tích hợp trực tiếp trong Tab *Chữ cái & Âm* (`LearningHubModal` -> nút **Luyện Phonics**) và Mini-game **Sound Detective**:
- Nhận diện âm đầu (`beginning_sound`), âm cuối (`ending_sound`).
- Ghép âm thành từ (`blending`).
- Phân biệt cặp âm gần nhau (`minimal_pair`: `/p/` vs `/b/`).
- Nhận diện tổ hợp chữ (`digraph_match`: `sh`, `ch`, `th`).
Mỗi câu hỏi đảm bảo **duy nhất 1 đáp án đúng**.
