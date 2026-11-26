# ENTITY RELATIONSHIP DIAGRAM (ERD)
# PROJECT: ENGLISH ADVENTURE

Tài liệu này trực quan hóa toàn bộ 32 bảng PostgreSQL trên Supabase (bao gồm đủ 31 bảng yêu cầu trong Task 04 và đầy đủ tách bảng media) cùng giải thích chi tiết các mối quan hệ.

---

## 1. ERD – NHÓM USER MANAGEMENT & PLAYER DATA

```mermaid
erDiagram
    USERS ||--o{ PLAYER_PROFILES : "owns (1:N)"
    USERS ||--o| PARENTAL_SETTINGS : "configures (1:1)"
    PLAYER_PROFILES ||--|| PLAYER_PROGRESS : "has summary (1:1)"
    PLAYER_PROFILES ||--o{ PLAYER_WORLD_PROGRESS : "tracks worlds"
    PLAYER_PROFILES ||--o{ PLAYER_LESSON_PROGRESS : "tracks lessons"
    PLAYER_PROFILES ||--o{ PLAYER_QUEST_PROGRESS : "tracks quests"
    PLAYER_PROFILES ||--o{ LEARNING_ATTEMPTS : "logs attempts"
    PLAYER_PROFILES ||--o{ VOCABULARY_MASTERY : "tracks mastery"
    PLAYER_PROFILES ||--o{ REVIEW_SCHEDULE : "schedules reviews"
    PLAYER_PROFILES ||--o{ PLAYER_INVENTORY : "holds items"
    PLAYER_PROFILES ||--o{ PLAYER_ACHIEVEMENTS : "earns badges"

    USERS {
        uuid id PK
        text account_role
        boolean is_anonymous
        text status
    }
    PLAYER_PROFILES {
        uuid id PK
        uuid user_id FK
        text nickname
        text avatar_gender
        text preferred_accent
    }
    PLAYER_PROGRESS {
        uuid id PK
        uuid profile_id FK
        int player_level
        int total_exp
        int gold
        int total_stars
        int magic_crystals_count
    }
    LEARNING_ATTEMPTS {
        uuid id PK
        uuid client_event_id UK
        uuid profile_id FK
        uuid vocabulary_id FK
        text mini_game_code
        text skill
        boolean is_correct
        numeric quality_score
    }
    VOCABULARY_MASTERY {
        uuid id PK
        uuid profile_id FK
        uuid vocabulary_id FK
        numeric mastery_score
        smallint mastery_level
    }
    REVIEW_SCHEDULE {
        uuid id PK
        uuid profile_id FK
        uuid vocabulary_id FK
        int interval_days
        timestamptz next_review_at
    }
```

---

## 2. ERD – NHÓM GAME WORLD, QUESTS & REWARDS

```mermaid
erDiagram
    WORLDS ||--o{ WORLD_LEVELS : "contains zones"
    WORLDS ||--o{ CHARACTERS : "hosts"
    WORLDS ||--o{ LEARNING_MODULES : "organizes"
    WORLD_LEVELS ||--o{ QUESTS : "contains"
    CHARACTERS ||--o{ CHARACTER_DIALOGUES : "speaks"
    CHARACTERS ||--o{ QUESTS : "gives (NPC)"
    QUESTS ||--o{ QUEST_STEPS : "breaks into"
    QUESTS ||--o| QUESTS : "prerequisite"
    QUEST_STEPS }o--o| LESSONS : "uses content"
    QUEST_STEPS }o--o| MINI_GAMES : "launches"
    ITEMS ||--o{ PLAYER_INVENTORY : "owned in"
    ACHIEVEMENTS ||--o{ PLAYER_ACHIEVEMENTS : "unlocked in"
    REWARDS }o--o| ITEMS : "may grant"

    WORLDS {
        uuid id PK
        text code UK
        smallint order_index
        text name_en
        boolean is_mvp_active
    }
    WORLD_LEVELS {
        uuid id PK
        uuid world_id FK
        text code UK
        smallint order_index
    }
    QUESTS {
        uuid id PK
        uuid world_level_id FK
        uuid npc_character_id FK
        text code UK
        int exp_reward
        int gold_reward
    }
    QUEST_STEPS {
        uuid id PK
        uuid quest_id FK
        smallint step_index
        text step_type
        uuid lesson_id FK
        uuid mini_game_id FK
    }
    MINI_GAMES {
        uuid id PK
        text code UK
        boolean is_mvp_enabled
    }
```

---

## 3. ERD – NHÓM LEARNING CONTENT & MEDIA ASSETS

```mermaid
erDiagram
    LEARNING_MODULES ||--o{ LESSONS : "contains"
    LESSONS ||--o{ QUESTIONS : "has static/template"
    QUESTIONS ||--o{ QUESTION_OPTIONS : "has choices"

    VOCABULARY ||--o{ VOCABULARY_EXAMPLES : "has examples"
    VOCABULARY ||--o{ QUESTIONS : "referenced by"
    VOCABULARY ||--o{ QUESTION_OPTIONS : "reused in"
    VOCABULARY ||--o{ LEARNING_ATTEMPTS : "measured by"
    VOCABULARY ||--o{ VOCABULARY_MASTERY : "mastered in"
    VOCABULARY ||--o{ REVIEW_SCHEDULE : "reviewed in"

    PHONICS_CONTENT ||--o{ QUESTIONS : "tested in"
    GRAMMAR_TOPICS ||--o{ QUESTIONS : "tested in"

    IMAGE_ASSETS ||--o{ VOCABULARY : "illustrates"
    IMAGE_ASSETS ||--o{ QUESTIONS : "illustrates"
    IMAGE_ASSETS ||--o{ ITEMS : "icon"
    IMAGE_ASSETS ||--o{ ACHIEVEMENTS : "badge"

    AUDIO_ASSETS ||--o{ VOCABULARY : "pronounces (US/UK)"
    AUDIO_ASSETS ||--o{ PHONICS_CONTENT : "name_audio & sound_audio"
    AUDIO_ASSETS ||--o{ CHARACTER_DIALOGUES : "voices"
    AUDIO_ASSETS ||--o{ VOCABULARY_EXAMPLES : "reads example"

    VOCABULARY {
        uuid id PK
        text code UK
        uuid world_id FK
        text word
        text ipa_us
        text meaning_vi
        text category
        smallint difficulty
        uuid image_asset_id FK
        uuid audio_us_id FK
        uuid audio_uk_id FK
    }
    PHONICS_CONTENT {
        uuid id PK
        text code UK
        text letter_upper
        text letter_name_ipa
        uuid letter_name_audio_id FK
        text phoneme_symbol
        text letter_sound_ipa
        uuid letter_sound_audio_id FK
    }
```

---

## 4. GIẢI THÍCH QUAN HỆ GIỮA CÁC BẢNG TRỌNG YẾU

1. **Tách `users` và `player_profiles` (`1:N`):**
   - Một tài khoản phụ huynh (`users`) có thể quản lý 1 hoặc nhiều hồ sơ học tập của con (`player_profiles`) trên cùng thiết bị/gia đình mà vẫn giữ nguyên thông tin đăng nhập duy nhất.
2. **Tái sử dụng `vocabulary` qua `quest_steps` → `lessons` → `questions` / Dynamic Generator:**
   - `vocabulary` đóng vai trò **Single Source of Truth**. Mỗi từ chỉ lưu 1 lần với hình ảnh (`image_assets`), âm thanh US/UK (`audio_assets`), IPA và ví dụ (`vocabulary_examples`).
   - Một `quest_step` trỏ tới `lesson_id` + `mini_game_id`. Tùy theo `mini_game_code`, `LearningEngine` có thể lấy câu hỏi dựng sẵn từ `questions` hoặc sinh câu hỏi động trực tiếp từ `vocabulary` & `grammar_topics`.
3. **Tách biệt `letter_name_audio_id` và `letter_sound_audio_id` trong `phonics_content`:**
   - Ràng buộc dữ liệu bắt buộc hai FK trỏ về hai file âm thanh độc lập của `audio_assets`, ngăn lỗi trộn lẫn tên chữ cái và âm chữ cái.
4. **Chuỗi dữ liệu học thuật `learning_attempts` → `vocabulary_mastery` → `review_schedule`:**
   - `learning_attempts` lưu lịch sử từng lần chạm/trả lời (kèm `client_event_id` chống trùng lặp khi đồng bộ offline).
   - Từ `learning_attempts`, hệ thống cập nhật điểm `vocabulary_mastery` (áp dụng logic chống đoán bừa) và tính lại ngày ôn kế tiếp `next_review_at` trong `review_schedule`.
5. **Cách ly hoàn toàn dữ liệu người chơi (`player_*`):**
   - Tất cả 9 bảng tiến trình người chơi đều mang khóa ngoại `profile_id` → `player_profiles(id)` và được kiểm soát chặt qua RLS `is_profile_owner(profile_id)`.
