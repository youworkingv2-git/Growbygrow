# PHONICS & PRONUNCIATION SYSTEM
# PROJECT: ENGLISH ADVENTURE (Prompt 04)

## 1. Mục tiêu sư phạm

Hỗ trợ trẻ 10 tuổi bắt đầu từ con số 0 làm quen bảng chữ cái và ngữ âm tiếng Anh một cách khoa học:
- **Tách biệt tuyệt đối Tên chữ cái (Letter Name) và Âm cơ bản (Letter Sound)** (ví dụ `A` tên `/eɪ/`, âm ngắn `/æ/` trong `apple`; `C` tên `/siː/`, âm `/k/` trong `cat`).
- Không dạy máy móc rằng một chữ chỉ có một cách phát âm; các âm phụ/ngoại lệ được lưu trong `additional_sounds` và `exception_note_vi` để giới thiệu dần ở A1+.
- Hỗ trợ cấu hình giọng **Anh-Mỹ (`en-US`)** hoặc **Anh-Anh (`en-GB`)** thông qua `SettingsManager.preferred_accent` (ví dụ chữ `Z`: `/ziː/` US vs `/zɛd/` UK).

## 2. Dữ liệu & Module

- `data/alphabet/alphabet_a_z.json`: Đủ **26 chữ cái A–Z** với `letter_name_ipa`, `letter_sound_ipa`, `additional_sounds`, `exception_note_vi`, `mouth_hint_vi`, `anchor_word_ids`, `audio_status: "missing_asset"`.
- `data/phonics/phonics_units.json`: Bao phủ **10 nhóm Phonics bắt buộc**:
  1. `alphabet`
  2. `letter_names`
  3. `letter_sounds`
  4. `short_vowels` (`/æ/, /ɛ/, /ɪ/, /ɒ/, /ʌ/`)
  5. `long_vowels` (`/eɪ/, /aɪ/`)
  6. `consonants` (`/b/`, ...)
  7. `consonant_digraphs` (`sh /ʃ/`, `ch /tʃ/`, `th /θ/`)
  8. `vowel_teams` (`ee /iː/`, `oo /ʊ/`)
  9. `common_sound_patterns` (`-at`)
  10. `basic_word_blending` (`c-a-t -> cat`, `s-h-i-p -> ship`, `b-a-g -> bag`, ...)
- `PhonicsManager` (`scripts/learning/phonics_manager.gd`): API truy vấn bảng chữ cái, IPA theo giọng cấu hình và đơn vị Phonics.
