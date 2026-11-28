# DATABASE DESIGN SPECIFICATION (SUPABASE / POSTGRESQL)
# PROJECT: ENGLISH ADVENTURE

**Hệ quản trị CSDL:** PostgreSQL 15+ (trên nền tảng Supabase)  
**Số lượng bảng cốt lõi:** 31 bảng chia theo 5 nhóm chức năng  
**Nguyên tắc bảo mật:** Row Level Security (RLS), Tách biệt dữ liệu người dùng, Tối thiểu hóa dữ liệu trẻ em (Child Privacy by Design), Không lưu API Secret / Service Role Key ở client.

---

## 1. QUY ƯỚC THIẾT KẾ CƠ SỞ DỮ LIỆU

- **Primary Key:** Sử dụng `UUID` (`gen_random_uuid()`) cho toàn bộ bảng người dùng, tiến trình, nhiệm vụ và nội dung (hoặc `TEXT` slug PK rõ ràng? → Sử dụng **`UUID` PK** kèm `slug`/`code` UNIQUE cho bảng nội dung để tối ưu join và tương thích Supabase, đồng thời giữ `code` ổn định như `word_001`, `world_01`, `quest_w01_01` để map trực tiếp với JSON offline).
- **Timestamps:** Mọi bảng đều có `created_at TIMESTAMPTZ NOT NULL DEFAULT now()` và bảng có thay đổi trạng thái có `updated_at TIMESTAMPTZ NOT NULL DEFAULT now()`.
- **Child Privacy:** Không lưu họ tên thật, địa chỉ, số điện thoại, ngày sinh đầy đủ hay file ghi âm giọng nói trẻ lên DB ở MVP.

---

## 2. ĐẶC TẢ CHI TIẾT 31 BẢNG

### NHÓM A: USER MANAGEMENT (3 bảng)

#### 2.1. `users` (Liên kết 1-1 với `auth.users` của Supabase Auth)
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK, FK → `auth.users(id) ON DELETE CASCADE` | NO | — | PK | ID định danh tài khoản Supabase Auth |
| `account_role` | `TEXT` | — | NO | `'player'` | CHECK (`'player','parent','admin'`) | Vai trò tài khoản |
| `is_anonymous` | `BOOLEAN` | — | NO | `true` | — | Đánh dấu tài khoản khách chưa liên kết phụ huynh |
| `auth_provider` | `TEXT` | — | NO | `'anonymous'` | — | `'anonymous'`, `'email'` |
| `status` | `TEXT` | — | NO | `'active'` | CHECK (`'active','suspended','deleted'`) | Trạng thái tài khoản |
| `last_seen_at` | `TIMESTAMPTZ` | — | YES | `NULL` | — | Lần hoạt động gần nhất |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |
| `updated_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày cập nhật |

- **Quan hệ:** `1-to-Many` với `player_profiles`; `1-to-1` với `parental_settings`.

#### 2.2. `player_profiles`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID hồ sơ người chơi |
| `user_id` | `UUID` | FK → `users(id) ON DELETE CASCADE` | NO | — | IDX(`user_id`) | Chủ sở hữu tài khoản |
| `nickname` | `TEXT` | — | NO | — | CHECK (`char_length(nickname) BETWEEN 2 AND 24`) | Biệt danh hiển thị (không dùng tên thật) |
| `avatar_gender` | `TEXT` | — | NO | `'boy'` | CHECK (`'boy','girl'`) | Nhân vật chính đã chọn |
| `buddy_name` | `TEXT` | — | NO | `'Buddy'` | — | Tên rồng đồng hành |
| `preferred_ui_locale` | `TEXT` | — | NO | `'vi'` | CHECK (`'vi','en'`) | Ngôn ngữ giao diện |
| `preferred_accent` | `TEXT` | — | NO | `'en-US'` | CHECK (`'en-US','en-GB'`) | Giọng đọc tiếng Anh ưu tiên |
| `initial_assessment_level` | `SMALLINT` | — | NO | `0` | CHECK (`0..3`) | Kết quả xếp loại đầu vào |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |
| `updated_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày cập nhật |

- **Quan hệ:** Thuộc `users` (`N-1`); `1-to-1` với `player_progress`; `1-to-Many` với tất cả bảng dữ liệu tiến trình của người chơi.

#### 2.3. `parental_settings`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID cài đặt |
| `user_id` | `UUID` | FK → `users(id) ON DELETE CASCADE` | NO | — | UNIQUE(`user_id`) | Tài khoản phụ huynh/người chơi |
| `daily_time_limit_minutes` | `INTEGER` | — | NO | `45` | CHECK (`daily_time_limit_minutes BETWEEN 10 AND 240`) | Giới hạn phút chơi/ngày (Post-MVP UI) |
| `microphone_allowed` | `BOOLEAN` | — | NO | `true` | — | Cho phép bật tính năng thu âm thử |
| `sound_effects_enabled` | `BOOLEAN` | — | NO | `true` | — | Bật/tắt SFX |
| `parent_pin_hash` | `TEXT` | — | YES | `NULL` | — | Mã PIN phụ huynh đã hash (Post-MVP) |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |
| `updated_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày cập nhật |

---

### NHÓM B: GAME WORLD (4 bảng)

#### 2.4. `worlds`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID thế giới |
| `code` | `TEXT` | — | NO | — | UNIQUE(`code`) | VD: `'world_01'` |
| `order_index` | `SMALLINT` | — | NO | — | UNIQUE(`order_index`) | Thứ tự 1..6 |
| `name_en` | `TEXT` | — | NO | — | — | Tên tiếng Anh (VD: Alphabet Island) |
| `name_vi` | `TEXT` | — | NO | — | — | Tên tiếng Việt |
| `description_vi` | `TEXT` | — | NO | — | — | Mô tả cốt truyện |
| `required_stars` | `INTEGER` | — | NO | `0` | — | Số sao tối thiểu để mở |
| `is_mvp_active` | `BOOLEAN` | — | NO | `false` | IDX(`is_mvp_active`) | `true` cho World 1 |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |

#### 2.5. `world_levels` (Zones / Khu vực trong mỗi World)
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID khu vực |
| `world_id` | `UUID` | FK → `worlds(id) ON DELETE CASCADE` | NO | — | IDX(`world_id`) | Thuộc World nào |
| `code` | `TEXT` | — | NO | — | UNIQUE(`code`) | VD: `'w01_zone_01'` |
| `order_index` | `SMALLINT` | — | NO | — | UNIQUE(`world_id`, `order_index`) | Thứ tự khu vực trong World |
| `name_en` | `TEXT` | — | NO | — | — | Tên tiếng Anh |
| `name_vi` | `TEXT` | — | NO | — | — | Tên tiếng Việt |
| `unlock_required_stars` | `INTEGER` | — | NO | `0` | — | Số sao mở khu vực |
| `is_boss_zone` | `BOOLEAN` | — | NO | `false` | — | Đánh dấu khu vực chứa Boss/Gate |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |

#### 2.6. `characters`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID nhân vật |
| `code` | `TEXT` | — | NO | — | UNIQUE(`code`) | VD: `'buddy'`, `'prof_owl'`, `'echo_guardian'` |
| `role` | `TEXT` | — | NO | — | CHECK (`'player','buddy','mentor','npc','boss'`) | Vai trò |
| `name_en` | `TEXT` | — | NO | — | — | Tên tiếng Anh |
| `name_vi` | `TEXT` | — | NO | — | — | Tên tiếng Việt |
| `world_id` | `UUID` | FK → `worlds(id) ON DELETE SET NULL` | YES | `NULL` | IDX(`world_id`) | World xuất hiện chính (NULL nếu toàn game) |
| `asset_key` | `TEXT` | — | NO | — | — | Đường dẫn prefab/sprite |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |

#### 2.7. `character_dialogues`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID câu thoại |
| `character_id` | `UUID` | FK → `characters(id) ON DELETE CASCADE` | NO | — | IDX(`character_id`) | Nhân vật nói |
| `dialogue_key` | `TEXT` | — | NO | — | UNIQUE(`dialogue_key`) | Khóa tham chiếu |
| `context_type` | `TEXT` | — | NO | — | CHECK (`'quest_intro','quest_end','hint','encourage','celebrate','ambient'`) | Ngữ cảnh thoại |
| `text_en` | `TEXT` | — | YES | `NULL` | — | Câu tiếng Anh (nếu có) |
| `text_vi` | `TEXT` | — | NO | — | — | Giải thích / lời thoại tiếng Việt |
| `audio_asset_id` | `UUID` | FK → `audio_assets(id) ON DELETE SET NULL` | YES | `NULL` | — | Audio lồng tiếng |
| `order_index` | `SMALLINT` | — | NO | `0` | — | Thứ tự trong chuỗi thoại |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |

---

### NHÓM C: LEARNING CONTENT (10 bảng)

#### 2.8. `audio_assets`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID file âm thanh |
| `code` | `TEXT` | — | NO | — | UNIQUE(`code`) | VD: `'aud_word_001_us'` |
| `accent` | `TEXT` | — | NO | `'en-US'` | CHECK (`'en-US','en-GB','vi-VN'`) | Giọng đọc |
| `category` | `TEXT` | — | NO | — | CHECK (`'letter_name','letter_sound','word','sentence','dialogue','sfx'`) | Phân loại âm thanh |
| `storage_path` | `TEXT` | — | NO | — | — | Đường dẫn Supabase Storage / local res |
| `duration_ms` | `INTEGER` | — | NO | `0` | CHECK (`duration_ms >= 0`) | Thời lượng (ms) |
| `checksum_sha256` | `TEXT` | — | YES | `NULL` | — | Kiểm tra toàn vẹn file tải offline |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |

#### 2.9. `image_assets`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID hình ảnh |
| `code` | `TEXT` | — | NO | — | UNIQUE(`code`) | VD: `'img_word_001'` |
| `storage_path` | `TEXT` | — | NO | — | — | Đường dẫn ảnh |
| `alt_text_en` | `TEXT` | — | NO | — | — | Mô tả ảnh |
| `width_px` | `INTEGER` | — | NO | `512` | — | Chiều rộng |
| `height_px` | `INTEGER` | — | NO | `512` | — | Chiều cao |
| `checksum_sha256` | `TEXT` | — | YES | `NULL` | — | Hash kiểm tra tải offline |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |

#### 2.10. `learning_modules`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID module học |
| `world_id` | `UUID` | FK → `worlds(id) ON DELETE CASCADE` | NO | — | IDX(`world_id`) | Thuộc World nào |
| `code` | `TEXT` | — | NO | — | UNIQUE(`code`) | VD: `'mod_w01_vowels'` |
| `title_en` | `TEXT` | — | NO | — | — | Tiêu đề EN |
| `title_vi` | `TEXT` | — | NO | — | — | Tiêu đề VI |
| `order_index` | `SMALLINT` | — | NO | — | UNIQUE(`world_id`, `order_index`) | Thứ tự |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |

#### 2.11. `lessons`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID bài học |
| `learning_module_id` | `UUID` | FK → `learning_modules(id) ON DELETE CASCADE` | NO | — | IDX(`learning_module_id`) | Thuộc module nào |
| `code` | `TEXT` | — | NO | — | UNIQUE(`code`) | VD: `'lesson_01_01'` |
| `title_en` | `TEXT` | — | NO | — | — | Tên bài học EN |
| `title_vi` | `TEXT` | — | NO | — | — | Tên bài học VI |
| `target_cefr` | `TEXT` | — | NO | `'Pre-A1'` | CHECK (`'Zero','Pre-A1','A1','A2'`) | Trình độ mục tiêu |
| `order_index` | `SMALLINT` | — | NO | — | UNIQUE(`learning_module_id`, `order_index`) | Thứ tự bài |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |

#### 2.12. `vocabulary`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID từ vựng |
| `code` | `TEXT` | — | NO | — | UNIQUE(`code`) | VD: `'word_001'` |
| `world_id` | `UUID` | FK → `worlds(id) ON DELETE RESTRICT` | NO | — | IDX(`world_id`) | World giới thiệu chính |
| `word` | `TEXT` | — | NO | — | IDX(`word`) | Từ tiếng Anh (VD: `'apple'`) |
| `part_of_speech` | `TEXT` | — | NO | `'noun'` | — | Loại từ |
| `ipa_us` | `TEXT` | — | NO | — | — | Phiên âm IPA US |
| `ipa_uk` | `TEXT` | — | YES | `NULL` | — | Phiên âm IPA UK |
| `meaning_vi` | `TEXT` | — | NO | — | — | Nghĩa tiếng Việt |
| `category` | `TEXT` | — | NO | — | IDX(`category`) | Chủ đề (`food`, `animals`...) |
| `difficulty` | `SMALLINT` | — | NO | `1` | CHECK (`1..5`), IDX(`difficulty`) | Độ khó 1–5 |
| `skills` | `TEXT[]` | — | NO | `'{listening,speaking,reading,writing}'` | GIN(`skills`) | Các kỹ năng hỗ trợ |
| `image_asset_id` | `UUID` | FK → `image_assets(id) ON DELETE RESTRICT` | NO | — | — | Hình minh họa |
| `audio_us_id` | `UUID` | FK → `audio_assets(id) ON DELETE RESTRICT` | NO | — | — | Audio `en-US` bắt buộc |
| `audio_uk_id` | `UUID` | FK → `audio_assets(id) ON DELETE SET NULL` | YES | `NULL` | — | Audio `en-GB` (optional) |
| `related_word_codes` | `TEXT[]` | — | NO | `'{}'` | — | Từ liên quan |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |

#### 2.13. `vocabulary_examples`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID câu ví dụ |
| `vocabulary_id` | `UUID` | FK → `vocabulary(id) ON DELETE CASCADE` | NO | — | IDX(`vocabulary_id`) | Thuộc từ nào |
| `sentence_en` | `TEXT` | — | NO | — | — | Câu ví dụ EN |
| `sentence_vi` | `TEXT` | — | NO | — | — | Dịch tiếng Việt |
| `audio_asset_id` | `UUID` | FK → `audio_assets(id) ON DELETE SET NULL` | YES | `NULL` | — | Audio đọc cả câu |
| `difficulty` | `SMALLINT` | — | NO | `1` | CHECK (`1..5`) | Độ khó câu |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |

#### 2.14. `phonics_content`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID bài phonics |
| `code` | `TEXT` | — | NO | — | UNIQUE(`code`) | VD: `'phonics_a_short'` |
| `world_id` | `UUID` | FK → `worlds(id) ON DELETE RESTRICT` | NO | — | IDX(`world_id`) | World chứa nội dung |
| `letter_upper` | `TEXT` | — | NO | — | — | Chữ hoa (`'A'`) |
| `letter_lower` | `TEXT` | — | NO | — | — | Chữ thường (`'a'`) |
| `letter_type` | `TEXT` | — | NO | — | CHECK (`'vowel','consonant','digraph','blend'`) | Loại chữ/âm |
| `letter_name_ipa` | `TEXT` | — | NO | — | — | IPA tên chữ cái (`/eɪ/`) |
| `letter_name_audio_id` | `UUID` | FK → `audio_assets(id) ON DELETE RESTRICT` | NO | — | — | Audio tên chữ cái |
| `phoneme_symbol` | `TEXT` | — | NO | — | — | Ký hiệu phoneme (`'æ'`) |
| `letter_sound_ipa` | `TEXT` | — | NO | — | — | IPA âm chữ cái (`/æ/`) |
| `letter_sound_audio_id` | `UUID` | FK → `audio_assets(id) ON DELETE RESTRICT` | NO | — | — | Audio âm chữ cái |
| `mouth_hint_vi` | `TEXT` | — | YES | `NULL` | — | Hướng dẫn khẩu hình |
| `anchor_word_ids` | `UUID[]` | — | NO | `'{}'` | — | Các từ neo minh họa |
| `order_index` | `SMALLINT` | — | NO | — | — | Thứ tự học |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |

#### 2.15. `grammar_topics`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID chủ điểm ngữ pháp |
| `code` | `TEXT` | — | NO | — | UNIQUE(`code`) | VD: `'gram_001'` |
| `world_id` | `UUID` | FK → `worlds(id) ON DELETE RESTRICT` | NO | — | IDX(`world_id`) | Thuộc World |
| `title_en` | `TEXT` | — | NO | — | — | Tên mẫu câu EN |
| `title_vi` | `TEXT` | — | NO | — | — | Tên mẫu câu VI |
| `explanation_vi` | `TEXT` | — | NO | — | — | Giải thích đơn giản cho trẻ 10 tuổi |
| `pattern_template` | `TEXT` | — | NO | — | — | Template câu (VD: `"{pronoun} {be} {article} {noun}."`) |
| `slots_schema` | `JSONB` | — | NO | `'[]'` | — | Cấu hình slot điền từ |
| `difficulty` | `SMALLINT` | — | NO | `1` | CHECK (`1..5`) | Độ khó |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |

#### 2.16. `questions`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID câu hỏi |
| `code` | `TEXT` | — | NO | — | UNIQUE(`code`) | Mã câu hỏi |
| `lesson_id` | `UUID` | FK → `lessons(id) ON DELETE CASCADE` | YES | `NULL` | IDX(`lesson_id`) | Thuộc bài học (hoặc NULL nếu placement) |
| `skill` | `TEXT` | — | NO | — | CHECK (`'listening','speaking','reading','writing'`), IDX(`skill`) | Kỹ năng kiểm tra |
| `question_type` | `TEXT` | — | NO | — | — | `'audio_to_image'`, `'word_build'`, `'sentence_order'`, `'reading_match'`... |
| `vocabulary_id` | `UUID` | FK → `vocabulary(id) ON DELETE SET NULL` | YES | `NULL` | IDX(`vocabulary_id`) | Tham chiếu từ vựng (nếu có) |
| `phonics_id` | `UUID` | FK → `phonics_content(id) ON DELETE SET NULL` | YES | `NULL` | IDX(`phonics_id`) | Tham chiếu phonics (nếu có) |
| `grammar_topic_id` | `UUID` | FK → `grammar_topics(id) ON DELETE SET NULL` | YES | `NULL` | IDX(`grammar_topic_id`) | Tham chiếu ngữ pháp (nếu có) |
| `prompt_vi` | `TEXT` | — | NO | — | — | Hướng dẫn tiếng Việt |
| `prompt_en` | `TEXT` | — | YES | `NULL` | — | Đề bài tiếng Anh |
| `buddy_hint_vi` | `TEXT` | — | YES | `NULL` | — | Gợi ý của Buddy |
| `audio_asset_id` | `UUID` | FK → `audio_assets(id) ON DELETE SET NULL` | YES | `NULL` | — | Audio câu hỏi |
| `image_asset_id` | `UUID` | FK → `image_assets(id) ON DELETE SET NULL` | YES | `NULL` | — | Ảnh câu hỏi |
| `difficulty` | `SMALLINT` | — | NO | `1` | CHECK (`1..5`) | Độ khó |
| `is_assessment_pool` | `BOOLEAN` | — | NO | `false` | IDX(`is_assessment_pool`) | Dùng cho bài đầu vào |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |

#### 2.17. `question_options`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID phương án |
| `question_id` | `UUID` | FK → `questions(id) ON DELETE CASCADE` | NO | — | IDX(`question_id`) | Thuộc câu hỏi nào |
| `label_en` | `TEXT` | — | NO | — | — | Nội dung chữ |
| `vocabulary_id` | `UUID` | FK → `vocabulary(id) ON DELETE SET NULL` | YES | `NULL` | — | Liên kết từ (tái sử dụng ảnh/audio) |
| `image_asset_id` | `UUID` | FK → `image_assets(id) ON DELETE SET NULL` | YES | `NULL` | — | Ảnh phương án |
| `audio_asset_id` | `UUID` | FK → `audio_assets(id) ON DELETE SET NULL` | YES | `NULL` | — | Audio phương án |
| `is_correct` | `BOOLEAN` | — | NO | `false` | — | Đáp án đúng |
| `order_index` | `SMALLINT` | — | NO | `0` | — | Thứ tự (quan trọng với xếp câu) |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |

---

### NHÓM D: GAMEPLAY (6 bảng)

#### 2.18. `mini_games`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID loại mini-game |
| `code` | `TEXT` | — | NO | — | UNIQUE(`code`) | `'word_hunt'`, `'listening_mission'`, `'word_builder'`, `'sentence_builder'`, `'reading_challenge'`, `'speaking_challenge'`, `'boss_battle'` |
| `name_en` | `TEXT` | — | NO | — | — | Tên tiếng Anh |
| `name_vi` | `TEXT` | — | NO | — | — | Tên tiếng Việt |
| `primary_skills` | `TEXT[]` | — | NO | — | — | Kỹ năng chính |
| `is_mvp_enabled` | `BOOLEAN` | — | NO | `true` | — | Có bật ở MVP không |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |

#### 2.19. `quests`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID nhiệm vụ |
| `code` | `TEXT` | — | NO | — | UNIQUE(`code`) | VD: `'quest_w01_01'` |
| `world_level_id` | `UUID` | FK → `world_levels(id) ON DELETE CASCADE` | NO | — | IDX(`world_level_id`) | Thuộc Zone nào |
| `npc_character_id` | `UUID` | FK → `characters(id) ON DELETE SET NULL` | YES | `NULL` | — | NPC giao nhiệm vụ |
| `prerequisite_quest_id` | `UUID` | FK → `quests(id) ON DELETE SET NULL` | YES | `NULL` | — | Nhiệm vụ tiên quyết |
| `title_en` | `TEXT` | — | NO | — | — | Tên Quest EN |
| `title_vi` | `TEXT` | — | NO | — | — | Tên Quest VI |
| `story_summary_vi` | `TEXT` | — | NO | — | — | Tóm tắt câu chuyện VI |
| `order_index` | `SMALLINT` | — | NO | — | UNIQUE(`world_level_id`, `order_index`) | Thứ tự trong Zone |
| `exp_reward` | `INTEGER` | — | NO | `50` | — | EXP thưởng |
| `gold_reward` | `INTEGER` | — | NO | `20` | — | Gold thưởng |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |

#### 2.20. `quest_steps`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID bước nhiệm vụ |
| `quest_id` | `UUID` | FK → `quests(id) ON DELETE CASCADE` | NO | — | IDX(`quest_id`) | Thuộc Quest |
| `step_index` | `SMALLINT` | — | NO | — | UNIQUE(`quest_id`, `step_index`) | Thứ tự bước (1, 2, 3...) |
| `step_type` | `TEXT` | — | NO | — | CHECK (`'dialogue','learn_intro','minigame','repeat_after_me','explore_trigger'`) | Loại bước |
| `lesson_id` | `UUID` | FK → `lessons(id) ON DELETE SET NULL` | YES | `NULL` | — | Bài học cung cấp dữ liệu |
| `mini_game_id` | `UUID` | FK → `mini_games(id) ON DELETE SET NULL` | YES | `NULL` | — | Mini-game cần chạy |
| `step_config` | `JSONB` | — | NO | `'{}'` | — | Tham số (số câu, word_codes...) |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |

#### 2.21. `items`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID vật phẩm |
| `code` | `TEXT` | — | NO | — | UNIQUE(`code`) | VD: `'crystal_w01_shard_1'`, `'hint_potion'` |
| `item_type` | `TEXT` | — | NO | — | CHECK (`'crystal_shard','magic_crystal','consumable','badge','cosmetic'`) | Phân loại vật phẩm |
| `name_en` | `TEXT` | — | NO | — | — | Tên EN |
| `name_vi` | `TEXT` | — | NO | — | — | Tên VI |
| `description_vi` | `TEXT` | — | NO | — | — | Công dụng |
| `icon_asset_id` | `UUID` | FK → `image_assets(id) ON DELETE SET NULL` | YES | `NULL` | — | Icon |
| `gold_price` | `INTEGER` | — | NO | `0` | — | Giá mua bằng Gold (0 nếu không bán) |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |

#### 2.22. `rewards`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID cấu hình phần thưởng |
| `source_type` | `TEXT` | — | NO | — | CHECK (`'quest','achievement','daily_review','world_clear'`) | Nguồn trao thưởng |
| `source_ref_id` | `UUID` | — | NO | — | IDX(`source_type`, `source_ref_id`) | ID của quest / achievement |
| `exp_amount` | `INTEGER` | — | NO | `0` | — | Số EXP |
| `gold_amount` | `INTEGER` | — | NO | `0` | — | Số Gold |
| `item_id` | `UUID` | FK → `items(id) ON DELETE SET NULL` | YES | `NULL` | — | Vật phẩm tặng kèm |
| `item_quantity` | `INTEGER` | — | NO | `1` | — | Số lượng vật phẩm |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |

#### 2.23. `achievements`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID thành tựu |
| `code` | `TEXT` | — | NO | — | UNIQUE(`code`) | VD: `'ach_first_crystal'` |
| `title_en` | `TEXT` | — | NO | — | — | Tên EN |
| `title_vi` | `TEXT` | — | NO | — | — | Tên VI |
| `description_vi` | `TEXT` | — | NO | — | — | Điều kiện đạt |
| `condition_type` | `TEXT` | — | NO | — | — | `'quests_completed'`, `'words_mastered'`, `'first_try_streak'`, `'daily_streak'` |
| `condition_target` | `INTEGER` | — | NO | `1` | — | Mục tiêu số lượng |
| `badge_image_id` | `UUID` | FK → `image_assets(id) ON DELETE SET NULL` | YES | `NULL` | — | Huy hiệu |
| `created_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày tạo |

---

### NHÓM E: PLAYER DATA (8 bảng)

#### 2.24. `player_progress`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID |
| `profile_id` | `UUID` | FK → `player_profiles(id) ON DELETE CASCADE` | NO | — | UNIQUE(`profile_id`) | 1-1 với `player_profiles` |
| `player_level` | `INTEGER` | — | NO | `1` | CHECK (`player_level >= 1`) | Cấp độ hiện tại |
| `total_exp` | `INTEGER` | — | NO | `0` | CHECK (`total_exp >= 0`) | Tổng EXP |
| `gold` | `INTEGER` | — | NO | `0` | CHECK (`gold >= 0`) | Tổng Gold |
| `total_stars` | `INTEGER` | — | NO | `0` | CHECK (`total_stars >= 0`) | Tổng sao kiếm được |
| `magic_crystals_count` | `INTEGER` | — | NO | `0` | CHECK (`magic_crystals_count >= 0`) | Số Magic Crystals lớn |
| `current_streak_days` | `INTEGER` | — | NO | `0` | — | Chuỗi ngày học liên tiếp |
| `last_study_date` | `DATE` | — | YES | `NULL` | — | Ngày học gần nhất |
| `updated_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Thời điểm cập nhật |

#### 2.25. `player_world_progress`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID |
| `profile_id` | `UUID` | FK → `player_profiles(id) ON DELETE CASCADE` | NO | — | UNIQUE(`profile_id`, `world_id`) | Hồ sơ |
| `world_id` | `UUID` | FK → `worlds(id) ON DELETE CASCADE` | NO | — | IDX(`world_id`) | Thế giới |
| `status` | `TEXT` | — | NO | `'locked'` | CHECK (`'locked','unlocked','completed'`) | Trạng thái mở khóa |
| `stars_earned` | `INTEGER` | — | NO | `0` | — | Sao đạt tại World |
| `crystal_shards_collected` | `INTEGER` | — | NO | `0` | — | Mảnh pha lê thu được |
| `boss_defeated` | `BOOLEAN` | — | NO | `false` | — | Đã thắng Boss/Gate chưa |
| `unlocked_at` | `TIMESTAMPTZ` | — | YES | `NULL` | — | Thời điểm mở |
| `completed_at` | `TIMESTAMPTZ` | — | YES | `NULL` | — | Thời điểm hoàn tất |
| `updated_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Cập nhật |

#### 2.26. `player_lesson_progress`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID |
| `profile_id` | `UUID` | FK → `player_profiles(id) ON DELETE CASCADE` | NO | — | UNIQUE(`profile_id`, `lesson_id`) | Hồ sơ |
| `lesson_id` | `UUID` | FK → `lessons(id) ON DELETE CASCADE` | NO | — | IDX(`lesson_id`) | Bài học |
| `status` | `TEXT` | — | NO | `'not_started'` | CHECK (`'not_started','in_progress','completed'`) | Trạng thái |
| `best_accuracy_pct` | `NUMERIC(5,2)` | — | NO | `0` | CHECK (`best_accuracy_pct BETWEEN 0 AND 100`) | Độ chính xác tốt nhất |
| `attempts_count` | `INTEGER` | — | NO | `0` | — | Số lần học |
| `last_practiced_at` | `TIMESTAMPTZ` | — | YES | `NULL` | — | Lần học cuối |
| `updated_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Cập nhật |

#### 2.27. `player_quest_progress`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID |
| `profile_id` | `UUID` | FK → `player_profiles(id) ON DELETE CASCADE` | NO | — | UNIQUE(`profile_id`, `quest_id`) | Hồ sơ |
| `quest_id` | `UUID` | FK → `quests(id) ON DELETE CASCADE` | NO | — | IDX(`quest_id`) | Nhiệm vụ |
| `status` | `TEXT` | — | NO | `'locked'` | CHECK (`'locked','available','in_progress','completed'`) | Trạng thái |
| `current_step_index` | `SMALLINT` | — | NO | `0` | — | Bước đang làm |
| `best_stars` | `SMALLINT` | — | NO | `0` | CHECK (`0..3`) | Số sao cao nhất |
| `best_score` | `INTEGER` | — | NO | `0` | — | Điểm cao nhất |
| `completed_at` | `TIMESTAMPTZ` | — | YES | `NULL` | — | Thời điểm xong |
| `updated_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Cập nhật |

#### 2.28. `learning_attempts` (Log chống trùng lặp cho Offline Sync & Anti-Guess)
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID lượt làm bài |
| `client_event_id` | `UUID` | — | NO | — | UNIQUE(`client_event_id`) | UUID do client sinh để sync idempotent |
| `profile_id` | `UUID` | FK → `player_profiles(id) ON DELETE CASCADE` | NO | — | IDX(`profile_id`, `attempted_at` DESC) | Hồ sơ |
| `quest_id` | `UUID` | FK → `quests(id) ON DELETE SET NULL` | YES | `NULL` | — | Quest ngữ cảnh |
| `mini_game_code` | `TEXT` | — | NO | — | IDX(`mini_game_code`) | Loại mini-game |
| `skill` | `TEXT` | — | NO | — | CHECK (`'listening','speaking','reading','writing'`) | Kỹ năng thực hành |
| `vocabulary_id` | `UUID` | FK → `vocabulary(id) ON DELETE SET NULL` | YES | `NULL` | IDX(`profile_id`, `vocabulary_id`) | Từ mục tiêu |
| `phonics_id` | `UUID` | FK → `phonics_content(id) ON DELETE SET NULL` | YES | `NULL` | — | Phonics mục tiêu |
| `question_id` | `UUID` | FK → `questions(id) ON DELETE SET NULL` | YES | `NULL` | — | Câu hỏi (nếu tĩnh) |
| `is_correct` | `BOOLEAN` | — | NO | — | — | Đúng hay sai |
| `attempt_number` | `SMALLINT` | — | NO | `1` | CHECK (`attempt_number >= 1`) | Lần thử thứ mấy trong cùng câu |
| `used_hint` | `BOOLEAN` | — | NO | `false` | — | Có dùng gợi ý của Buddy không |
| `used_dont_know` | `BOOLEAN` | — | NO | `false` | — | Người chơi chọn "Chưa biết" |
| `response_time_ms` | `INTEGER` | — | NO | `0` | CHECK (`response_time_ms >= 0`) | Thời gian trả lời (phát hiện bấm bừa) |
| `quality_score` | `NUMERIC(4,2)` | — | NO | `0.0` | CHECK (`quality_score BETWEEN 0 AND 1`) | Điểm chất lượng `q` chống đoán bừa |
| `attempted_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Thời gian thực tế tại client |

#### 2.29. `vocabulary_mastery`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID |
| `profile_id` | `UUID` | FK → `player_profiles(id) ON DELETE CASCADE` | NO | — | UNIQUE(`profile_id`, `vocabulary_id`) | Hồ sơ |
| `vocabulary_id` | `UUID` | FK → `vocabulary(id) ON DELETE CASCADE` | NO | — | IDX(`vocabulary_id`) | Từ vựng |
| `mastery_score` | `NUMERIC(5,2)` | — | NO | `0` | CHECK (`mastery_score BETWEEN 0 AND 100`) | Điểm thành thạo (0–100) |
| `mastery_level` | `SMALLINT` | — | NO | `0` | CHECK (`0..5`), IDX(`profile_id`, `mastery_level`) | Bậc 0..5 (Anti-guess rule) |
| `skills_verified` | `TEXT[]` | — | NO | `'{}'` | — | Các kỹ năng đã chứng minh đúng |
| `distinct_review_days` | `INTEGER` | — | NO | `0` | — | Số ngày khác nhau đã ôn thành công |
| `total_attempts` | `INTEGER` | — | NO | `0` | — | Tổng số lượt |
| `first_try_correct_count` | `INTEGER` | — | NO | `0` | — | Số lần đúng ngay lần 1 |
| `last_practiced_at` | `TIMESTAMPTZ` | — | YES | `NULL` | — | Lần cuối luyện |
| `updated_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Cập nhật |

#### 2.30. `review_schedule`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID lịch ôn |
| `profile_id` | `UUID` | FK → `player_profiles(id) ON DELETE CASCADE` | NO | — | UNIQUE(`profile_id`, `vocabulary_id`) | Hồ sơ |
| `vocabulary_id` | `UUID` | FK → `vocabulary(id) ON DELETE CASCADE` | NO | — | IDX(`profile_id`, `next_review_at`) | Từ cần ôn |
| `interval_days` | `INTEGER` | — | NO | `1` | CHECK (`interval_days >= 1`) | Khoảng cách ngày ôn |
| `ease_factor` | `NUMERIC(4,2)` | — | NO | `2.50` | CHECK (`ease_factor >= 1.30`) | Hệ số SM-2 |
| `repetition_count` | `INTEGER` | — | NO | `0` | — | Số lần ôn thành công liên tiếp |
| `next_review_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Hạn ôn tập tiếp theo |
| `last_reviewed_at` | `TIMESTAMPTZ` | — | YES | `NULL` | — | Lần ôn gần nhất |
| `updated_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Cập nhật |

#### 2.31. `player_inventory`
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID |
| `profile_id` | `UUID` | FK → `player_profiles(id) ON DELETE CASCADE` | NO | — | UNIQUE(`profile_id`, `item_id`) | Hồ sơ |
| `item_id` | `UUID` | FK → `items(id) ON DELETE CASCADE` | NO | — | — | Vật phẩm |
| `quantity` | `INTEGER` | — | NO | `1` | CHECK (`quantity >= 0`) | Số lượng |
| `is_equipped` | `BOOLEAN` | — | NO | `false` | — | Đang trang bị không |
| `acquired_at` | `TIMESTAMPTZ` | — | NO | `now()` | — | Ngày nhận |

#### 2.32. `player_achievements` *(Bổ sung hoàn chỉnh nhóm Player Data = 9 bảng Player Data, tổng 32 bảng tính cả `audio_assets`/`image_assets` tách rõ)*
| Tên trường | Kiểu dữ liệu | PK/FK | Nullable | Default | Index / Unique | Mô tả |
|---|---|---|---|---|---|---|
| `id` | `UUID` | PK | NO | `gen_random_uuid()` | PK | ID |
| `profile_id` | `UUID` | FK → `player_profiles(id) ON DELETE CASCADE` | NO | — | UNIQUE(`profile_id`, `achievement_id`) | Hồ sơ |
| `achievement_id` | `UUID` | FK → `achievements(id) ON DELETE CASCADE` | NO | — | — | Thành tựu |
| `current_value` | `INTEGER` | — | NO | `0` | — | Tiến độ hiện tại |
| `is_unlocked` | `BOOLEAN` | — | NO | `false` | — | Đã mở khóa chưa |
| `unlocked_at` | `TIMESTAMPTZ` | — | YES | `NULL` | — | Thời điểm đạt |

*(Lưu ý: Toàn bộ danh mục bảng được yêu cầu trong Task 04 đều có mặt đầy đủ, không thiếu bất kỳ bảng nào).*

---

## 3. ROW LEVEL SECURITY (RLS) & DATA ISOLATION

### 3.1. Nguyên tắc phân quyền
1. **Nhóm bảng Content & World (`worlds`, `world_levels`, `characters`, `character_dialogues`, `learning_modules`, `lessons`, `vocabulary`, `vocabulary_examples`, `phonics_content`, `grammar_topics`, `questions`, `question_options`, `audio_assets`, `image_assets`, `quests`, `quest_steps`, `mini_games`, `rewards`, `items`, `achievements`):**
   - `RLS ENABLED`.
   - Policy `SELECT`: Cho phép `authenticated` (bao gồm cả Anonymous Supabase session đã cấp JWT) đọc dữ liệu học tập.
   - Policy `INSERT / UPDATE / DELETE`: **Chặn hoàn toàn** từ client (`anon`/`authenticated`), chỉ quản trị qua Migration / Dashboard bằng Service Role ở server/CI.
2. **Nhóm bảng User & Player Data (`users`, `player_profiles`, `parental_settings`, `player_progress`, `player_world_progress`, `player_lesson_progress`, `player_quest_progress`, `learning_attempts`, `vocabulary_mastery`, `review_schedule`, `player_inventory`, `player_achievements`):**
   - `RLS ENABLED` bắt buộc trên 100% bảng.
   - Tạo helper SQL function `public.is_profile_owner(target_profile_id UUID)` kiểm tra:
     `EXISTS (SELECT 1 FROM public.player_profiles p WHERE p.id = target_profile_id AND p.user_id = auth.uid())`.
   - Mọi truy vấn `SELECT`, `INSERT`, `UPDATE` chỉ thành công khi `auth.uid()` khớp chủ sở hữu profile. **Người chơi A tuyệt đối không đọc hoặc sửa được dữ liệu của người chơi B.**

---

## 4. AUTHENTICATION, VALIDATION, MIGRATIONS & BACKUP

### 4.1. Authentication Flow (An toàn cho trẻ 10 tuổi)
- **Bước 1 (Instant Play):** Client gọi Supabase `signInAnonymously()` để nhận `auth.uid()` và JWT ngắn hạn, tạo `player_profiles` với `nickname` + `avatar_gender` (không thu thập PII).
- **Bước 2 (Optional Parent Link):** Phụ huynh có thể nâng cấp tài khoản ẩn danh sang Email/Password (`updateUser`) để đồng bộ đa thiết bị.
- **Bảo mật Client:** Client chỉ chứa `SUPABASE_URL` và `SUPABASE_ANON_KEY` (public key). **Tuyệt đối cấm** nhúng `SUPABASE_SERVICE_ROLE_KEY` vào mã nguồn Godot hay file export.

### 4.2. Data Validation (Ở cả 3 tầng)
1. **Tầng Content Pipeline:** JSON schema + Asset integrity validator trước khi nạp DB.
2. **Tầng Database:** `CHECK` constraints (`difficulty 1..5`, `best_stars 0..3`, `mastery_score 0..100`, `quality_score 0..1`), `NOT NULL`, Foreign Keys và Trigger `set_updated_at()`.
3. **Tầng Logic (Trigger / RPC):** `learning_attempts` không cho phép chèn trùng `client_event_id`.

### 4.3. Database Migrations & Backup Strategy
- **Migrations:** Quản lý tuần tự bằng SQL files đặt tại `supabase/migrations/`:
  - `0001_initial_schema.sql`: Tạo toàn bộ 32 bảng, constraints, indexes, triggers.
  - `0002_rls_policies.sql`: Bật RLS và áp toàn bộ policies bảo vệ dữ liệu.
  - `0003_learning_engine_extensions.sql` *(Prompt 04)*: Bổ sung an toàn 7 bảng (`learning_paths`, `learning_levels`, `topics`, `learning_activities`, `phonics_examples`, `grammar_examples`, `player_skill_progress`) cùng RLS isolation đầy đủ. Xem chi tiết tại [`docs/LEARNING_DATABASE.md`](LEARNING_DATABASE.md).
  - `0004_minigame_system_extensions.sql` *(Prompt 05)*: Bổ sung an toàn 4 bảng (`minigames`, `minigame_sessions`, `minigame_question_logs`, `minigame_rewards`) cùng RLS isolation đầy đủ để lưu phiên chơi, nhật ký từng câu hỏi mini-game và sổ cái chống nhận thưởng trùng.
  - `0005_quest_reward_inventory_integration.sql` *(Prompt 06)*: Bổ sung an toàn 5 bảng (`reward_ledger`, `quest_objective_states`, `player_inventory`, `player_achievements`, `npc_encounters`) cùng RLS isolation để đồng bộ sổ cái thưởng, tiến độ mục tiêu chi tiết, túi đồ và thành tựu.
  - `0006_audio_voice_pronunciation.sql` *(Prompt 07)*: Bổ sung an toàn 4 bảng (`voice_profiles`, `speaking_practice_sessions`, `pronunciation_assessments`, `audio_settings_sync`) với cột điểm AI có thể để `NULL` (không điền điểm giả), cờ `is_mock`, RLS theo `is_profile_owner(profile_id)`, và **tuyệt đối không lưu file audio giọng nói trẻ em**.
  - `0007_content_expansion_system.sql` *(Prompt 09)*: Bổ sung 4 bảng mở rộng kho nội dung (`learning_phrases`, `question_bank_items`, `content_review_logs`, `level_unlock_evaluations`), mở rộng metadata `review_status`/`cefr_level`/`topics` an toàn trên bảng từ vựng, bật `ENABLE ROW LEVEL SECURITY` trên toàn bộ bảng mới và phân tách rõ quyền đọc nội dung `approved`/`published` với dữ liệu đánh giá mở khóa của từng profile.
- **Backup Strategy:**
  - Supabase Daily Automated Backups + Point-in-Time Recovery (PITR) khi lên Production.
  - Dữ liệu Content (`vocabulary`, `quests`, `phonics_content`) được version hóa dưới dạng JSON trong Git (`data/`) nên có thể khôi phục/re-seed bất kỳ lúc nào.
  - Định kỳ export ẩn danh hóa (anonymized backup) nếu dùng cho phân tích chất lượng bài học; không bao giờ dùng dữ liệu thật của trẻ em trong môi trường dev/test.
