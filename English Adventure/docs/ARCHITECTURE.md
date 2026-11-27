# SOFTWARE ARCHITECTURE DOCUMENT
# PROJECT: ENGLISH ADVENTURE

**Game Engine:** Godot 4.3+ (GDScript, `gl_compatibility` renderer)  
**Backend:** Supabase (PostgreSQL, Supabase Auth, Supabase Storage, PostgREST REST API)  
**Nền tảng mục tiêu:** Android, iOS, Web (WebGL2), Desktop (Windows/macOS)  

---

## 1. NGUYÊN TẮC KIẾN TRÚC CỐT LÕI

1. **Modular Architecture (17 Modules tách biệt):** Mỗi module có trách nhiệm duy nhất (Single Responsibility), giao tiếp qua giao diện rõ ràng và `EventBus`.
2. **Tách rời hoàn toàn Learning Engine và Adventure Engine:**
   - `AdventureEngine` chỉ biết bản đồ, tọa độ, NPC, trạng thái quest và trigger.
   - `LearningEngine` không biết gì về thế giới 3D/2.5D; nó nhận `learning_unit_ids` hoặc `quest_config` và sinh ra câu hỏi/mini-game từ dữ liệu JSON/DB.
3. **Content-Driven & Reusable Vocabulary:** Một bản ghi từ vựng (ví dụ `word_001: "apple"`) nằm duy nhất ở `ContentRepository` và được tái sử dụng tự động cho *Word Hunt, Listening Mission, Word Builder, Sentence Builder, Reading Challenge, Speaking* mà không nhân bản dữ liệu và không viết logic học trùng lặp trong từng mini-game.
4. **Offline-First & Idempotent Sync:** Mọi thao tác chơi và học lưu ngay xuống Local Storage trước, đồng bộ bất đồng bộ lên Supabase khi có kết nối mạng.
5. **Security by Default:** Không lưu `SUPABASE_SERVICE_ROLE_KEY` trong client Godot; toàn bộ truy cập DB đi qua Anon Key + User JWT + PostgreSQL Row Level Security (RLS).

---

## 2. SƠ ĐỒ KIẾN TRÚC TỔNG THỂ (MERMAID)

```mermaid
flowchart TB
    subgraph Presentation["Presentation & Scenes (Godot 4 Control / Node3D)"]
        UI["UI Screens (1..17)<br/>Home, WorldMap, HUD, Dashboard"]
        ADV_SCENE["Adventure World Scene<br/>(2.5D/3D Map, Player, Buddy, NPCs)"]
        MG_SCENES["Mini-game Scenes (5 MVP)<br/>WordHunt, Listening, WordBuilder,<br/>SentenceBuilder, Reading"]
    end

    subgraph CoreLayer["Core Infrastructure & Cross-Cutting"]
        CORE["1. Core Module<br/>(AppRoot, EventBus, SceneRouter, Logger, Config)"]
        LOC["15. Localization Module<br/>(vi / en UI & Bilingual Hints)"]
        AUDIO["9. Audio Module<br/>(Voice EN/VI, SFX, BGM, Mic Adapter)"]
    end

    subgraph AdventureLayer["Adventure & Narrative Domain"]
        ADV["2. Adventure Module<br/>(WorldState, ZoneUnlock, Interactions)"]
        CHAR["3. Character Module<br/>(Player, Buddy AI Presenter, NPC, Dialogue)"]
        QUEST["4. Quest Module<br/>(QuestManager, StepEvaluator)"]
    end

    subgraph LearningLayer["Independent Learning Engine Domain"]
        LEARN["5. Learning Module<br/>(LearningEngine, SessionOrchestrator)"]
        VOCAB["6. Vocabulary Module<br/>(WordRepository, AssetResolver)"]
        GRAM["7. Grammar Module<br/>(Phonics + SentencePatternEngine)"]
        MG_MOD["8. Mini-game Module<br/>(BaseMiniGame, QuestionFactory, Registry)"]
        ASSESS["10. Assessment Module<br/>(PlacementTest, AdaptiveDifficulty)"]
        REVIEW["11. Review Module<br/>(SM-2 Scheduler, MistakeTracker)"]
    end

    subgraph ProgressionLayer["Progression & Economy Domain"]
        PROG["12. Progress Module<br/>(Level, EXP, Stars, WorldProgress)"]
        REWARD["13. Reward Module<br/>(Anti-Guess Mastery, RewardCalculator)"]
        INV["14. Inventory Module<br/>(Items, Crystals, Achievements)"]
    end

    subgraph DataPersistenceLayer["Persistence & Cloud Sync"]
        SAVE["17. Save/Load Module<br/>(Local Cache + Outbox Queue user://)"]
        BACKEND["16. Backend Service Module<br/>(Supabase Auth, REST API, Storage)"]
    end

    UI --> CORE
    ADV_SCENE --> ADV
    ADV_SCENE --> CHAR
    MG_SCENES --> MG_MOD

    ADV --> QUEST
    QUEST -->|EventBus: MiniGameLaunchRequested| LEARN
    LEARN --> VOCAB
    LEARN --> GRAM
    LEARN --> MG_MOD
    LEARN --> ASSESS
    LEARN --> REVIEW
    MG_MOD -->|LearningAttemptRecorded| REWARD
    REWARD --> PROG
    REWARD --> REVIEW
    REWARD --> INV

    PROG --> SAVE
    INV --> SAVE
    REVIEW --> SAVE
    SAVE <--> BACKEND

    CORE -.-> AUDIO
    CORE -.-> LOC
```

---

## 3. CHI TIẾT 17 MODULES BẮT BUỘC

| # | Tên Module | Thư mục dự kiến (`scripts/`) | Trách nhiệm chính | Phụ thuộc cho phép |
|---|---|---|---|---|
| **1** | **Core Module** | `scripts/core/` | Khởi động app, `EventBus` (Signals toàn cục), `SceneRouter`, `AppConfig`, `Logger`, `DataValidator`, `ErrorHandler`. | Không phụ thuộc domain modules. |
| **2** | **Adventure Module** | `scripts/adventure/` | Quản lý trạng thái thế giới, Zone unlocking, tương tác vật thể/cổng, camera follow, vị trí spawn nhân vật. | Core, Quest, Character, Audio. |
| **3** | **Character Module** | `scripts/character/` | Điều khiển Player (Touch Joystick + Keyboard), Buddy companion logic (nhắc việc, giải thích tiếng Việt), NPC trigger, Dialogue Runner, Animation State Machine. | Core, Adventure, Localization, Audio. |
| **4** | **Quest Module** | `scripts/quest/` | Nạp định nghĩa Quest từ `data/quests/`, theo dõi `quest_steps`, phát sự kiện chuyển sang bước học hoặc mini-game, cập nhật trạng thái Quest. | Core, Progress, Learning (chỉ qua DTO/EventBus). |
| **5** | **Learning Module** | `scripts/learning/` | Điều phối phiên học (`LearningSession`), kết hợp Vocabulary + Phonics + Grammar để tạo payload chuẩn cho mini-game và đánh giá kết quả học thuật. | Core, Vocabulary, Grammar, Audio. |
| **6** | **Vocabulary Module** | `scripts/learning/vocabulary/` | Truy vấn và cache dữ liệu từ vựng, ánh xạ `word_id` → hình ảnh/audio/IPA/ví dụ; lọc từ theo skill, difficulty, category. | Core, Backend/Save (content pack). |
| **7** | **Grammar Module** | `scripts/learning/grammar/` | Quản lý Phonics rules (Letter Name vs Letter Sound, Blending) và Grammar Sentence Patterns (tách slot cấu trúc câu để sinh bài tập Sentence Builder & Reading). | Core, Vocabulary. |
| **8** | **Mini-game Module** | `scripts/mini_games/` | Định nghĩa lớp cơ sở `BaseMiniGame`, `MiniGameRegistry`, các Widget dùng chung (LetterTile, WordCard, FeedbackBanner) và 5 mini-games MVP. | Core, Learning (nhận `MiniGameChallengeDTO`), Audio, Localization. |
| **9** | **Audio Module** | `scripts/audio/` | Quản lý Audio Buses (`Master`, `BGM`, `SFX`, `VoiceEN`, `VoiceVI`), preloading clip từ vựng, fallback `en-GB` → `en-US`, và `AudioCaptureAdapter` cho Repeat-After-Me. | Core, Save (settings). |
| **10** | **Assessment Module** | `scripts/assessment/` | Thực hiện Initial Placement Check (kèm tùy chọn "Chưa biết"), tính mức độ ban đầu và `AdaptiveDifficulty` (điều chỉnh số lựa chọn nhiễu/tốc độ theo hiệu suất). | Core, Learning, Progress. |
| **11** | **Review Module** | `scripts/progression/review/` | Tính lịch ôn tập Spaced Repetition (Modified SM-2), ưu tiên từ sai nhiều, tạo `ReviewSession` độc lập khỏi Quest. | Core, Vocabulary, Save. |
| **12** | **Progress Module** | `scripts/progression/` | Lưu & cập nhật `player_level`, `exp`, `stars`, `world_progress`, `lesson_progress`, `quest_progress`. | Core, Save. |
| **13** | **Reward Module** | `scripts/progression/` | Tính toán EXP, Gold, Stars và **Anti-Guess Mastery Algorithm** từ mỗi `learning_attempt`. | Core, Progress, Review, Inventory. |
| **14** | **Inventory Module** | `scripts/progression/` | Quản lý vật phẩm, Crystal Shards, Magic Crystals, Achievements & điều kiện mở khóa huy hiệu. | Core, Progress, Save. |
| **15** | **Localization Module** | `scripts/localization/` | Nạp bảng dịch `vi`/`en` cho UI, định dạng câu song ngữ cho Buddy, quản lý hiển thị font tiếng Việt + IPA. | Core. |
| **16** | **Backend Service Module** | `scripts/services/` | Bọc giao tiếp HTTP REST tới Supabase (Auth, PostgREST, Storage), quản lý refresh JWT token, retry exponential backoff, telemetry lỗi. | Core. |
| **17** | **Save/Load Module** | `scripts/services/persistence/` | Đọc/ghi trạng thái người chơi tại `user://`, quản lý `sync_outbox.json`, hợp nhất dữ liệu local/cloud khi online (Conflict Resolution). | Core, Backend Service. |

---

## 4. CƠ CHẾ TÁI SỬ DỤNG TỪ VỰNG XUYÊN SUỐT (REUSABLE VOCABULARY PIPELINE)

Ví dụ từ `"word_001"` (`apple`) chỉ tồn tại **1 lần** trong `data/vocabulary/world_01_vocab.json` (và bảng `vocabulary`). Khi một Quest yêu cầu kiểm tra `word_001` qua nhiều kỹ năng, `QuestionGeneratorService` trong `Learning Module` tự động chuyển đổi `VocabularyItem` thành các `ChallengeItem` khác nhau:

```mermaid
flowchart LR
    V["VocabularyItem: word_001<br/>word='apple', ipa='/ˈæp.əl/',<br/>img='apple.webp', audio='apple_us.ogg',<br/>example='I eat an apple.'"]

    V -->|"Mode: Word Hunt"| Q1["Mục tiêu: chữ 'A' hoặc từ 'apple'<br/>Distractors: từ cùng category/âm khác"]
    V -->|"Mode: Listening Mission"| Q2["Phát audio 'apple_us.ogg'<br/>Options: 4 ảnh (apple + 3 distractors)"]
    V -->|"Mode: Word Builder"| Q3["Ảnh 'apple.webp' + Audio<br/>Tiles: [a, p, p, l, e] + nhiễu [o, b]"]
    V -->|"Mode: Sentence Builder"| Q4["Mẫu câu 'I eat an ___.'<br/>Blocks: [I] [eat] [an] [apple]"]
    V -->|"Mode: Reading Challenge"| Q5["Câu 'I eat an apple.'<br/>Chọn ảnh đúng hoặc điền khuyết"]
    V -->|"Mode: Repeat-After-Me"| Q6["Nghe 'apple_us.ogg' -> Thu âm thử<br/>-> Tự nghe đối chiếu"]
```

**Kết quả kiến trúc:**
- **Không** có logic học từ vựng riêng bị lặp lại trong từng scene mini-game.
- Mini-game chỉ nhận đầu vào chuẩn `MiniGamePayload` và trả ra đầu ra chuẩn `MiniGameResult` + danh sách `LearningAttemptEvent`.

---

## 5. LUỒNG DỮ LIỆU & GIAO TIẾP SIGNAL / EVENTBUS

### 5.1. Luồng chạy một Quest hoàn chỉnh (Sequence Diagram)

```mermaid
sequenceDiagram
    actor Player
    participant Adv as Adventure + Character
    participant Quest as QuestManager
    participant Bus as EventBus (Autoload)
    participant Learn as LearningModule
    participant MG as MiniGameScene
    participant Reward as Reward + Mastery
    participant Save as SaveLoad + Sync

    Player->>Adv: Tiến tới NPC & bấm Tương tác
    Adv->>Quest: request_start_quest(quest_id)
    Quest->>Adv: show_buddy_intro(dialogue_vi, words)
    Player->>Adv: Bấm "Bắt đầu thử thách!"
    Quest->>Bus: emit("minigame_launch_requested", payload)
    Bus->>Learn: build_challenge(quest_step_spec, player_profile)
    Learn-->>MG: start_minigame(ChallengePayload)
    loop Mỗi câu hỏi trong Mini-game
        Player->>MG: Trả lời (chạm/kéo thả/nghe)
        MG->>Bus: emit("learning_attempt_recorded", attempt_dto)
        Bus->>Reward: evaluate_attempt(attempt_dto)
        Reward->>Save: save_local_attempt_and_queue(attempt_dto)
        MG->>Adv: (nếu sai) Buddy hiện giải thích tiếng Việt
    end
    MG->>Bus: emit("minigame_completed", result_dto)
    Bus->>Reward: calculate_quest_rewards(result_dto)
    Reward->>Save: save_progress_snapshot()
    Save-->>Bus: trigger_background_sync_if_online()
    Bus->>Adv: show_reward_screen_and_unlock_next()
```

### 5.2. Danh sách Signals cốt lõi trên `EventBus`
- `app_state_changed(new_state: StringName)`
- `network_status_changed(is_online: bool)`
- `auth_session_updated(user_id: String, is_anonymous: bool)`
- `quest_started(quest_id: String)` / `quest_step_completed(quest_id: String, step_index: int)` / `quest_completed(quest_id: String, stars: int)`
- `minigame_launch_requested(launch_config: Dictionary)`
- `minigame_completed(result: Dictionary)`
- `learning_attempt_recorded(attempt: Dictionary)`
- `mastery_updated(word_id: String, new_score: float, new_level: int)`
- `reward_granted(reward_bundle: Dictionary)`
- `buddy_prompt_requested(message_key: String, context: Dictionary)`
- `sync_completed(synced_count: int, failed_count: int)`

---

## 6. SERVICE INTERFACES (HỢP ĐỒNG GIAO TIẾP GIỮA CÁC MODULE)

Mặc dù GDScript là ngôn ngữ dynamic/gradual typing, các service cốt lõi tuân theo **hợp đồng hàm rõ ràng (typed GDScript signatures + Resource/DTO classes)**:

1. **`IContentProvider` (`VocabularyModule` / `GrammarModule`):**
   - `get_word(word_id: String) -> VocabularyResource`
   - `query_words(filter: Dictionary) -> Array[VocabularyResource]` (hỗ trợ `world_id`, `category`, `difficulty`, `skill`)
   - `get_distractor_words(target_word_id: String, count: int, strategy: String) -> Array[VocabularyResource]`
   - `get_phonics_unit(phonics_id: String) -> PhonicsResource`
   - `get_sentence_pattern(pattern_id: String) -> GrammarPatternResource`

2. **`IMiniGame` (`BaseMiniGame`):**
   - `setup(challenge_payload: MiniGamePayload) -> void`
   - `start_game() -> void`
   - `pause_game() -> void`
   - `resume_game() -> void`
   - `abort_game() -> void`
   - Signal bắt buộc: `attempt_made(attempt: LearningAttemptDTO)`, `game_finished(result: MiniGameResultDTO)`

3. **`IBackendGateway` (`BackendService`):**
   - `sign_in_anonymous() -> AuthResult`
   - `sign_in_with_email(email: String, password: String) -> AuthResult`
   - `fetch_player_snapshot(profile_id: String) -> SyncResult`
   - `push_sync_batch(events: Array[Dictionary]) -> SyncBatchResult`
   - `download_content_manifest(world_id: String) -> ManifestResult`

4. **`IPersistenceStore` (`SaveLoadModule`):**
   - `save_profile_state(profile_id: String, state: Dictionary) -> Error`
   - `load_profile_state(profile_id: String) -> Dictionary`
   - `enqueue_sync_event(event_type: String, payload: Dictionary) -> void`
   - `get_pending_sync_events(limit: int) -> Array[Dictionary]`
   - `mark_events_synced(client_event_ids: Array[String]) -> void`

---

## 7. ERROR HANDLING, LOGGING, OFFLINE & SYNCHRONIZATION

### 7.1. Error Handling & Logging
- Mọi lỗi được phân loại qua `AppLogger`: `DEBUG`, `INFO`, `WARN`, `ERROR`, `FATAL`.
- Lưu log xoay vòng (rolling log tối đa 2 file x 512 KB) tại `user://logs/app.log`, **tự động loại bỏ (redact)** token JWT hoặc dữ liệu nhạy cảm trước khi ghi.
- **Lỗi mạng / API (4xx/5xx/Timeout):**
  - Không làm treo game hoặc mất màn chơi hiện tại.
  - Tự động chuyển sang chế độ Offline mượt mà với thông báo nhỏ thân thiện (*"Đang chơi ngoại tuyến – Tiến trình vẫn được lưu trên máy!"*).
  - Retry theo chiến lược **Exponential Backoff** (`2s → 4s → 8s → 30s`) cho các yêu cầu nền.
- **Lỗi thiếu tài nguyên học tập (missing audio/image):**
  - `AssetResolver` dùng placeholder an toàn + ghi log cảnh báo + tự bỏ qua từ bị lỗi khi sinh distractor để game không crash.

### 7.2. Chiến lược Offline & Synchronization
1. **Nội dung học tập (Read-only Content):**
   - World 1 (Alphabet Island) được đóng gói sẵn (bundled) trong bản cài MVP để **chơi được 100% offline ngay sau khi cài**.
   - Các gói nội dung mới hoặc bản vá được kiểm tra qua `content_version` trên Supabase khi có mạng.
2. **Dữ liệu người chơi (Read/Write Player Data):**
   - Ghi đồng bộ xuống đĩa (atomic write: ghi file `.tmp` rồi rename) sau mỗi bước hoàn thành.
   - Mỗi hành động học tập (`learning_attempts`) và cập nhật tiến trình được đẩy vào `sync_outbox.json` kèm `client_event_id = UUIDv4` và `occurred_at_utc`.
3. **Giải quyết xung đột (Conflict Resolution) khi đồng bộ đa thiết bị:**
   - `learning_attempts`: **Append-only (Idempotent)** theo `client_event_id` UNIQUE trên PostgreSQL — không bao giờ trùng lặp dù gửi lại nhiều lần.
   - `player_progress` / `player_quest_progress`: **Monotonic High-Water Mark** — `stars`, `best_score`, `exp`, `completed` chỉ tăng hoặc giữ giá trị cao nhất; `vocabulary_mastery` tính lại/hợp nhất theo timestamp mới nhất kèm lịch sử attempt.
   - `gold` / `inventory`: Ghi nhận qua các giao dịch có `client_event_id` để tránh cộng/trừ lặp.

---

## 8. TRẠNG THÁI TRIỂN KHAI THỰC TẾ (CẬP NHẬT PROMPT 02 & PROMPT 03)

Các thành phần đã triển khai thành GDScript & Scene thực thi trong `project.godot`:
- **Autoloads đã đăng ký (`[autoload]`):** `AppLogger`, `EventBus`, `LocalizationManager`, `DataRepository`, `SaveLoadManager`, `GameStateManager`, `QuestManager`, `SettingsManager`, `AudioManager`, `UIManager`, `SceneRouter`.
- **Hệ thống Adventure & Character 3D (Prompt 02 + Addendum 3D):** `AreaExplorationController` (`Node3D`), `Coord3D`, `WorldEnvironment3DController`, `AreaEnvironment3D`, `PropFactory3D`, `CharacterRig3D` (placeholder 3D đa khối có khớp cho 7 nhân vật), `Asset3DSlot` (hệ thống thay thế `.glb`), `UnlockEvaluator`, `InteractionManager`, `InteractableObject`, `PlayerController` (Third-person Camera `SpringArm3D` + TouchCameraPad), `CharacterAnimator`, `BuddyController`, `NpcController`, `DialogueManager`.
- **Hệ thống UI/UX 3D, Audio Bus & Settings (Prompt 03):**
  - `UIDesignSystem`, `UIManager`, `UIAnimator`, `ResponsiveHelper` cùng các component dùng chung (`AdventureConfirmDialog`, `RewardDisplay`, `QuestCardWidget`, `WorldCardWidget`, `AvatarBadge`, `LoadingIndicatorWidget`).
  - Các màn hình thực thi có nền 3D (`Diorama3DStage`, `AlphabetIsland3DMap`): `MainEntry` (Splash 3D), `MainMenuUI`, `CharacterSelectionUI` (xoay 360°), `WorldIntroductionUI`, `WorldMapUI` (Isometric 3D), `AdventureHUD` (Status Bar + Quest Tracker + Bottom Dock + VirtualJoystick + TouchCameraPad + Dialogue Box + Quest Log + Bag Modal + Popups), `PauseMenuUI`, `SettingsModalUI`.
  - `SettingsManager` lưu `user://settings.json` và áp dụng động ngôn ngữ (`vi`/`en`), âm lượng bus `Music`/`SFX`, `graphics_quality` (`low`/`medium`/`high`), `camera_sensitivity`, chế độ điều khiển (`auto`/`keyboard`/`touch`), fullscreen, resolution (Desktop) và `reduced_motion`.
  - `AudioManager` tạo bus `Music` & `SFX`, kết nối sự kiện UI/Gameplay (`button_click`, `popup_open`, `popup_close`, `quest_complete`, `reward_received`, `area_unlocked`) và báo trung thực khi chưa có file audio đính kèm.
- **Điểm nối cho Prompt 04+:** `EventBus.learning_hook_requested` và `quest.learning_hook` sẵn sàng kết nối `LearningEngine` & 5 Mini-games mà không cần sửa kiến trúc thế giới, nhân vật hay UI/UX.

---

## 9. TRẠNG THÁI TRIỂN KHAI PROMPT 04 – ENGLISH LEARNING ENGINE

- **Autoload mới:** `LearningEngine` (`scripts/learning/learning_engine.gd`) đã đăng ký trong `project.godot`.
- **Các module đã triển khai:** `LearningContentRepository`, `LearningPathManager`, `VocabularyManager`, `PhonicsManager`, `GrammarManager`, `ListeningManager`, `SpeakingManager`, `ReadingManager`, `WritingManager`, `QuestionManager`, `AssessmentEngine`, `LearningProgressManager`, `ReviewEngine`, `LearningHubModal`.
- **Dữ liệu độc lập (`data/`):** `learning_curriculum.json`, `spaced_repetition_config.json`, `alphabet_a_z.json` (26 chữ cái), `phonics_units.json` (10 nhóm), `world_01_vocab.json` (32 từ + 32 SVG tại `assets/learning/images/`), `world_01_grammar.json` (15 cấu trúc + 12 câu mẫu), `world_01_listening.json` (12 bài), `world_01_reading.json` (12 bài), `world_01_writing.json` (12 bài), `world_01_speaking.json` (6 bài).
- **Kết nối 3D & Quest:** Mở `LearningHubModal` từ BottomDock / phím `[L]` hoặc từ Quest/Vật thể 3D (`obj_letter_a/b/c`, `obj_shadow_gate_seal`) mà không ảnh hưởng camera hay vị trí nhân vật 3D. Chi tiết xem [`docs/LEARNING_ENGINE.md`](LEARNING_ENGINE.md).

---

## 10. TRẠNG THÁI TRIỂN KHAI PROMPT 05 – MINI-GAME SYSTEM

- **Autoload mới:** `MiniGameManager` (`scripts/minigames/minigame_manager.gd`) đã đăng ký trong `project.godot`, gắn `MiniGameHostModal` (`CanvasLayer` layer 25, `PROCESS_MODE_ALWAYS`).
- **Module lõi (`scripts/minigames/`):** `MiniGameRegistry`, `MiniGameFactory`, `MiniGameSession`, `MiniGameDataProvider`, `MiniGameController`, `MiniGameUI`, `MiniGameAudioManager`, `MiniGameScoring`, `MiniGameDifficulty`, `MiniGameFeedback`, `MiniGameReward`, `MiniGameResult`.
- **8 Mini-game đã triển khai:** `listen_and_find`, `word_builder`, `word_matching`, `sentence_builder`, `sound_detective`, `speaking_hero`, `memory_quest`, `dialogue_adventure` (+ 8 template mở rộng trong `minigame_registry.json`).
- **Kết nối đa chiều:** Mở từ NPC (`professor_owl`, `lily`, `rocky`, `crystal_guardian`), Quest Log (`future_minigame_id`), Vật thể 3D (`obj_village_chest`, `obj_meadow_chest`, `obj_cave_sign`, `obj_lake_chest`, `obj_letter_e`, `obj_shadow_gate_seal`), HUD (`Trò chơi [G]`), và `LearningHubModal`. Chi tiết xem [`docs/MINIGAME_ARCHITECTURE.md`](MINIGAME_ARCHITECTURE.md).

---

## 11. TRẠNG THÁI TRIỂN KHAI PROMPT 06 – QUEST, NPC, REWARD & WORLD PROGRESSION INTEGRATION

- **Autoload mới:** `RewardManager` (`scripts/progression/reward_manager.gd`) kết hợp cùng `InventoryManager` (`inventory_manager.gd`) và `AchievementManager` (`achievement_manager.gd`).
- **Tái cấu trúc `QuestManager` (`scripts/quest/`):** Gồm 10 module (`QuestRepository`, `QuestRegistry`, `QuestInstance`, `QuestStateManager`, `QuestObjectiveManager`, `QuestConditionEvaluator`, `QuestProgressTracker`, `QuestRewardManager`, `QuestNotificationManager`, `QuestEventHandler`) quản lý 6 trạng thái (`locked` -> `available` -> `accepted` -> `in_progress` -> `completed` -> `claimed`) và 12 loại mục tiêu.
- **Nội dung tích hợp:** `chapters.json` (5 Chapters), `world_01_items.json` (15 vật phẩm có `usage_conditions`), `achievements.json` (7 thành tích), 5 Main Quests (`quest_01`..`quest_05`), 3 Side Quests, hội thoại tương tác có lựa chọn và điều kiện sử dụng vật phẩm. Xem [`docs/GAMEPLAY_LOOP.md`](GAMEPLAY_LOOP.md).

---

## 12. TRẠNG THÁI TRIỂN KHAI PROMPT 07 – AUDIO, VOICE & AI PRONUNCIATION SYSTEM

- **Kiến trúc `AudioVoiceSystem` (`scripts/audio/`):** Gồm `AudioManager` (Autoload), `AudioAssetManager`, `AudioSettingsManager`, `MusicManager`, `SoundEffectManager`, `VoiceProfileManager`, `TextToSpeechManager`, `AudioPlaybackManager`, `VoiceManager`, `SpeechRecorder`, `SpeechRecognitionManager`, `PronunciationAssessmentManager`, `PronunciationFeedbackManager`, `AudioEventHandler`.
- **Tài nguyên & TTS:** 11 file `.wav` UI/SFX/BGM gốc sạch bản quyền tại `assets/audio/` (`data/audio/audio_manifest.json`) cùng `DisplayServer.tts_*` + Web SpeechSynthesis fallback hỗ trợ `en-US` & `en-GB`.
- **Ghi âm & AI Adapter:** `SpeechRecorder` đa nền tảng (`AudioEffectRecord` trên Windows/Mobile + `MediaRecorder` có xin quyền trên Web), `SpeakingPracticePanel` dùng chung cho `GameSpeakingHero` & `LearningHubModal`, Supabase Edge Functions (`pronunciation-assess`, `speech-recognize`) và migration `0006_audio_voice_pronunciation.sql`. Chi tiết xem [`docs/AUDIO_SYSTEM.md`](AUDIO_SYSTEM.md) và [`docs/AI_PROVIDER_COMPARISON.md`](AI_PROVIDER_COMPARISON.md).
