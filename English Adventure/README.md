# ENGLISH ADVENTURE – A Fun English Learning Adventure Game

> **Game giáo dục phiêu lưu 3D Fantasy Cartoon dành cho trẻ em 10 tuổi mất gốc tiếng Anh**, xây dựng trên nền tảng **Godot 4.x (GDScript)** và **Supabase (PostgreSQL)**.

---

## 1. Tầm nhìn sản phẩm

**ENGLISH ADVENTURE** giúp trẻ 10 tuổi bắt đầu học tiếng Anh từ con số 0 thông qua một cuộc phiêu lưu kỳ thú chống lại thế lực *The Silent Shadow*. Thay vì làm bài kiểm tra trắc nghiệm khô khan hay lật thẻ từ vựng đơn thuần, người chơi khám phá thế giới, trò chuyện cùng bạn đồng hành rồng nhỏ **Buddy**, hoàn thành nhiệm vụ giải cứu âm thanh – chữ cái – từ vựng, và phát triển cân bằng cả **4 kỹ năng**:

- **Listening** (Nghe)
- **Speaking** (Nói)
- **Reading** (Đọc)
- **Writing** (Viết)

---

## 2. Trạng thái dự án hiện tại (Prompt 01–09)

Dự án đã hoàn thành toàn bộ hệ thống nền tảng **Prompt 01–08** (đã qua kiểm thử WebGL2 E2E) và vừa hoàn tất **Prompt 09 – Content Expansion System**:

- **Stylized 3D World & Characters:** Chuyển đổi toàn bộ gameplay sang **3D thực thụ** (`CharacterBody3D`, camera góc nhìn thứ ba `SpringArm3D` tránh xuyên vật thể, mô hình placeholder 3D có khớp cho cả 7 nhân vật `Boy`, `Girl`, `Buddy`, `Professor Owl`, `Lily`, `Rocky`, `Crystal Guardian`, cùng 5 khu vực 3D với **Welcome Village** làm khu vực 3D trọng điểm, World Map 3D isometric, Diorama 3D trên Main Menu & Character Selection, và thiết lập chất lượng đồ họa `Low` / `Medium` / `High`). Xem [`docs/VISUAL_3D_ARCHITECTURE.md`](docs/VISUAL_3D_ARCHITECTURE.md) và [`docs/ASSET_3D_PIPELINE.md`](docs/ASSET_3D_PIPELINE.md).
- **Core & Persistence:** Đã triển khai 14 Autoloads (`AppLogger`, `EventBus`, `LocalizationManager`, `DataRepository`, `SaveLoadManager`, `GameStateManager`, `QuestManager`, `LearningEngine`, `MiniGameManager`, `RewardManager`, `SettingsManager`, `AudioManager`, `UIManager`, `SceneRouter`).
- **UI/UX Design System & Màn hình:** `UIDesignSystem`, `UIAnimator`, `ResponsiveHelper`, thư viện component dùng chung (`AdventureConfirmDialog`, `RewardDisplay`, `QuestCardWidget`, `WorldCardWidget`, `AvatarBadge`, `LoadingIndicatorWidget`), Splash Screen, Main Menu, Character Selection, World Introduction, World Map, In-game HUD, Dialogue UI, Quest Log, Reward Popup, Inventory UI, Settings Modal, Pause Menu và Notification Stack.
- **World & Exploration:** Xây dựng **Alphabet Island** với **5 khu vực** (`Welcome Village`, `Alphabet Meadow`, `Letter Cave`, `Crystal Lake`, `The Shadow Gate`), bản đồ `World Map` tương tác, cơ chế khóa/mở khóa theo dữ liệu và chuyển cảnh bảo vệ khu vực khóa.
- **Characters & Quests:** Chọn nhân vật `Boy` / `Girl`, điều khiển PC (`WASD`/Arrows + `Space` + `E` + `H` + `L` + `G` + `Esc`) và Mobile (`VirtualJoystick` + nút chạm), đồng hành **Buddy** (7 trạng thái), 4 NPCs (`Professor Owl`, `Lily`, `Rocky`, `Crystal Guardian`), hệ thống hội thoại song ngữ, `InteractionManager` và 8 nhiệm vụ liên kết đầy đủ học liệu.
- **English Learning Engine & Kho nội dung Pre-A1 / A1 (Prompt 04 + 09):** Triển khai bộ máy học tiếng Anh độc lập, hướng dữ liệu kèm `LearningHubModal` (lọc theo Pre-A1 / A1 / Cụm từ, nút luyện Phonics, cổng mở khóa A1 đa điều kiện, bảng 4 trạng thái ghi nhớ và Adaptive Support). Kho nội dung hiện có **26 chữ cái**, **115 từ Pre-A1 + 32 từ mẫu A1** (**147 ảnh SVG độc lập 1:1**), **48 cụm từ**, **24 đơn vị Phonics + 6 bài tập**, **32 mẫu câu + 38 câu ví dụ**, **116 bài thực hành 4 kỹ năng** (28 Nghe, 28 Đọc, 28 Viết, 16 Nói), **14 kịch bản hội thoại** và **20 câu hỏi dùng chung**. Audio `.ogg` giữ trung thực `audio_status: "missing_asset"` (phát thực tế qua `VoiceManager` TTS `en-US`/`en-GB`); AI chấm phát âm giữ `ai_scoring_status: "not_integrated_experimental"`.
- **8 Mini-games & Audio/Voice System (Prompt 05–07):** 8 mini-game kết nối `LearningEngine` (`listen_and_find`, `word_builder`, `word_matching`, `sentence_builder`, `sound_detective`, `speaking_hero`, `memory_quest`, `dialogue_adventure`), 11 file `.wav` UI/SFX/BGM gốc và `SpeakingPracticePanel`.

---

## 3. Danh mục tài liệu

| Tài liệu | Mô tả |
|---|---|
| [`docs/PRD.md`](docs/PRD.md) | Tài liệu Yêu cầu Sản phẩm (Product Requirements Document) & phạm vi MVP |
| [`docs/GDD.md`](docs/GDD.md) | Tài liệu Thiết kế Game (Game Design Document) – Gameplay, Mini-games, Progression, Nhân vật |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Kiến trúc phần mềm 17 modules (Godot 4 + Supabase, Offline-first, Signal/EventBus) |
| [`docs/WORLD_DESIGN.md`](docs/WORLD_DESIGN.md) | Thiết kế Alphabet Island (5 khu vực) & cơ chế mở khóa dữ liệu |
| [`docs/WORLD_MAP.md`](docs/WORLD_MAP.md) | Đặc tả bản đồ thế giới & trạng thái 5 khu vực |
| [`docs/CHARACTER_SYSTEM.md`](docs/CHARACTER_SYSTEM.md) | Nhân vật chính (Boy/Girl), Animation States & Buddy |
| [`docs/NPC_SYSTEM.md`](docs/NPC_SYSTEM.md) | Hệ thống NPC & danh sách NPC Alphabet Island |
| [`docs/DIALOGUE_SYSTEM.md`](docs/DIALOGUE_SYSTEM.md) | Hệ thống hội thoại song ngữ dùng chung |
| [`docs/QUEST_SYSTEM.md`](docs/QUEST_SYSTEM.md) | Hệ thống nhiệm vụ khung & 3 nhiệm vụ mẫu |
| [`docs/ASSET_LIST.md`](docs/ASSET_LIST.md) | Danh sách asset SVG MVP & danh sách asset cần bổ sung |
| [`docs/TEST_REPORT_PROMPT_02.md`](docs/TEST_REPORT_PROMPT_02.md) | Kết quả kiểm thử tự động Prompt 02 |
| [`docs/UI_DESIGN_SYSTEM.md`](docs/UI_DESIGN_SYSTEM.md) | Bảng màu, Typography, Button System & Theme thống nhất (Prompt 03) |
| [`docs/UI_COMPONENTS.md`](docs/UI_COMPONENTS.md) | Danh mục các component UI dùng chung (Prompt 03) |
| [`docs/SCREEN_FLOW.md`](docs/SCREEN_FLOW.md) | Sơ đồ điều hướng & quy tắc bảo vệ luồng màn hình (Prompt 03) |
| [`docs/RESPONSIVE_UI.md`](docs/RESPONSIVE_UI.md) | Kiến trúc Responsive đa thiết bị (Desktop, Tablet, Mobile) (Prompt 03) |
| [`docs/ACCESSIBILITY.md`](docs/ACCESSIBILITY.md) | Nguyên tắc UX thân thiện trẻ 10 tuổi & hỗ trợ tiếp cận (Prompt 03) |
| [`docs/UI_TEST_REPORT.md`](docs/UI_TEST_REPORT.md) | Báo cáo kiểm thử thực tế giao diện 3D & UI/UX (Prompt 03) |
| [`docs/3D_VISUAL_DIRECTION.md`](docs/3D_VISUAL_DIRECTION.md) | Định hướng hình ảnh 3D Fantasy Cartoon & hệ thống Camera góc nhìn thứ ba |
| [`docs/3D_PERFORMANCE.md`](docs/3D_PERFORMANCE.md) | Đánh giá Renderer, tối ưu đa nền tảng & cấu hình Low / Medium / High |
| [`docs/ASSET_PIPELINE.md`](docs/ASSET_PIPELINE.md) | Tổng hợp Asset 3D/UI/Audio, trạng thái Placeholder & quy trình thay thế |
| [`docs/VISUAL_3D_ARCHITECTURE.md`](docs/VISUAL_3D_ARCHITECTURE.md) | Kiến trúc kỹ thuật 3D, `Coord3D` & cây Scene 3D |
| [`docs/ASSET_3D_PIPELINE.md`](docs/ASSET_3D_PIPELINE.md) | Chi tiết Polygon Budget, Texture Spec & slot `Asset3DSlot` |
| [`docs/DATABASE_SCHEMA.md`](docs/DATABASE_SCHEMA.md) | Thiết kế chi tiết 32 bảng PostgreSQL trên Supabase, RLS, bảo mật trẻ em & migration |
| [`docs/ERD.md`](docs/ERD.md) | Sơ đồ thực thể liên kết (ERD) bằng Mermaid & giải thích quan hệ dữ liệu |
| [`docs/LEARNING_CONTENT_SPEC.md`](docs/LEARNING_CONTENT_SPEC.md) | Chuẩn dữ liệu học tập độc lập code (Vocabulary, Phonics, Grammar, 4 Skills, Validation) |
| [`docs/UI_UX_SPEC.md`](docs/UI_UX_SPEC.md) | Đặc tả 18 màn hình, Responsive (Portrait/Landscape/Tablet/Web), States |
| [`docs/MVP_ROADMAP.md`](docs/MVP_ROADMAP.md) | Lộ trình 7 Phase triển khai MVP, phụ thuộc, rủi ro & tiến độ song song |
| [`docs/DECISIONS.md`](docs/DECISIONS.md) | Phân tích & Architecture Decision Records (ADR-001 → ADR-008) |
| [`docs/LEARNING_ENGINE.md`](docs/LEARNING_ENGINE.md) | Kiến trúc bộ máy học tiếng Anh (Prompt 04) |
| [`docs/LEARNING_PATH.md`](docs/LEARNING_PATH.md) | Lộ trình 4 giai đoạn & cây bài học `world_01` |
| [`docs/VOCABULARY_SYSTEM.md`](docs/VOCABULARY_SYSTEM.md) | Kho từ vựng đơn nguồn (32 từ Pre-A1 + 32 SVG) |
| [`docs/PHONICS_SYSTEM.md`](docs/PHONICS_SYSTEM.md) | Bảng chữ cái 26 chữ, Letter Name/Sound & 10 nhóm Phonics |
| [`docs/GRAMMAR_SYSTEM.md`](docs/GRAMMAR_SYSTEM.md) | 15 cấu trúc câu nền tảng & Substitution Builder |
| [`docs/FOUR_SKILLS_SYSTEM.md`](docs/FOUR_SKILLS_SYSTEM.md) | Hệ thống 4 kỹ năng Listening, Speaking, Reading, Writing |
| [`docs/ASSESSMENT_SYSTEM.md`](docs/ASSESSMENT_SYSTEM.md) | Đánh giá học tập, phản hồi sư phạm & phân tách 3 chỉ số |
| [`docs/LEARNING_PROGRESS.md`](docs/LEARNING_PROGRESS.md) | Theo dõi 5 trạng thái kiến thức & lưu trữ Offline-First |
| [`docs/SPACED_REPETITION.md`](docs/SPACED_REPETITION.md) | Cơ chế ôn tập lặp lại có khoảng cách theo cấu hình |
| [`docs/LEARNING_DATABASE.md`](docs/LEARNING_DATABASE.md) | Migration `0003_learning_engine_extensions.sql` & RLS |
| [`docs/LEARNING_TEST_REPORT.md`](docs/LEARNING_TEST_REPORT.md) | Báo cáo kiểm thử tự động & thực tế Prompt 04 |
| [`docs/QA_TEST_PLAN.md`](docs/QA_TEST_PLAN.md) | Kế hoạch kiểm thử tổng thể P8 |
| [`docs/QA_TEST_CASES.md`](docs/QA_TEST_CASES.md) | Danh sách kịch bản kiểm thử đầu cuối `TC01–TC10` & hồi quy |
| [`docs/BUG_REPORT.md`](docs/BUG_REPORT.md) | Danh sách 12 lỗi đã phát hiện và sửa trong P8 |
| [`docs/REGRESSION_TEST_REPORT.md`](docs/REGRESSION_TEST_REPORT.md) | Kết quả kiểm thử hồi quy sau sửa lỗi P8 |
| [`docs/PERFORMANCE_REPORT.md`](docs/PERFORMANCE_REPORT.md) | Số liệu đo hiệu suất WebGL2 thực tế (FPS, Heap, tài nguyên) |
| [`docs/3D_OPTIMIZATION_REPORT.md`](docs/3D_OPTIMIZATION_REPORT.md) | Báo cáo tối ưu hóa Model/Material/Particle 3D & Quality Presets |
| [`docs/CROSS_PLATFORM_TEST_REPORT.md`](docs/CROSS_PLATFORM_TEST_REPORT.md) | Báo cáo kiểm thử đa nền tảng (Web, Windows, Android, iOS) |
| [`docs/SECURITY_REVIEW.md`](docs/SECURITY_REVIEW.md) | Rà soát bảo mật, RLS & an toàn trẻ em |
| [`docs/FINAL_QA_REPORT.md`](docs/FINAL_QA_REPORT.md) | Tổng kết chất lượng dự án tại thời điểm P8 |
| [`docs/KNOWN_ISSUES.md`](docs/KNOWN_ISSUES.md) | Các giới hạn và vấn đề còn tồn tại sau P8 |
| [`docs/CURRICULUM_PRE_A1.md`](docs/CURRICULUM_PRE_A1.md) | Lộ trình học Pre-A1 (20 chủ đề & tích hợp Alphabet Island) |
| [`docs/CURRICULUM_A1.md`](docs/CURRICULUM_A1.md) | Lộ trình học A1 (20 chủ đề, gói mẫu 8 chủ đề & mở khóa đa yếu tố) |
| [`docs/VOCABULARY_CONTENT_SPEC.md`](docs/VOCABULARY_CONTENT_SPEC.md) | Quy chuẩn từ vựng & cụm từ (147 từ, 48 cụm, 147 SVG) |
| [`docs/PHONICS_CURRICULUM.md`](docs/PHONICS_CURRICULUM.md) | Chương trình Phonics (26 chữ cái, 24 nhóm âm, 6 bài tập) |
| [`docs/SENTENCE_PATTERNS.md`](docs/SENTENCE_PATTERNS.md) | Danh mục 32 mẫu câu Pre-A1 & A1 kèm slot thay thế |
| [`docs/GRAMMAR_CURRICULUM.md`](docs/GRAMMAR_CURRICULUM.md) | Ngữ pháp ứng dụng theo tình huống Pre-A1 & A1 |
| [`docs/LISTENING_CONTENT_SPEC.md`](docs/LISTENING_CONTENT_SPEC.md) | Quy chuẩn & 28 bài luyện nghe (Pre-A1 & A1) |
| [`docs/SPEAKING_CONTENT_SPEC.md`](docs/SPEAKING_CONTENT_SPEC.md) | Quy chuẩn & 16 bài luyện nói tích hợp fallback an toàn |
| [`docs/READING_CONTENT_SPEC.md`](docs/READING_CONTENT_SPEC.md) | Quy chuẩn & 28 bài luyện đọc (từ, câu, đoạn 30–50 từ) |
| [`docs/WRITING_CONTENT_SPEC.md`](docs/WRITING_CONTENT_SPEC.md) | Quy chuẩn & 28 bài luyện viết hỗ trợ `acceptable_answers` |
| [`docs/DIALOGUE_CONTENT_SPEC.md`](docs/DIALOGUE_CONTENT_SPEC.md) | Cấu trúc 14 hội thoại tình huống Pre-A1 & A1 |
| [`docs/CONTENT_WORLD_MAPPING.md`](docs/CONTENT_WORLD_MAPPING.md) | Phân bổ nội dung vào 6 thế giới dài hạn & 5 khu Alphabet Island |
| [`docs/CONTENT_QUEST_MAPPING.md`](docs/CONTENT_QUEST_MAPPING.md) | Ánh xạ 8 nhiệm vụ với kho từ vựng, mẫu câu, mini-game & ôn tập |
| [`docs/CONTENT_QUALITY_GUIDELINES.md`](docs/CONTENT_QUALITY_GUIDELINES.md) | Quy chuẩn kiểm duyệt (`review_status`) & tiêu chuẩn ngôn ngữ |
| [`docs/CONTENT_ASSET_GUIDELINES.md`](docs/CONTENT_ASSET_GUIDELINES.md) | Quy chuẩn 147 ảnh SVG 1:1 & khai báo audio trung thực |
| [`docs/CONTENT_VALIDATION_REPORT.md`](docs/CONTENT_VALIDATION_REPORT.md) | Báo cáo kiểm định dữ liệu tự động Prompt 09 |
| [`docs/CONTENT_INTEGRATION_TEST_REPORT.md`](docs/CONTENT_INTEGRATION_TEST_REPORT.md) | Báo cáo kiểm thử tích hợp Test 01–08 (Prompt 09) |
| [`docs/CONTENT_EXPANSION_ROADMAP.md`](docs/CONTENT_EXPANSION_ROADMAP.md) | Kế hoạch mở rộng kho từ vựng & audio giai đoạn tiếp theo |
| [`docs/release/RELEASE_PLAN.md`](docs/release/RELEASE_PLAN.md) | Kế hoạch phát hành đa nền tảng (`v0.9.0-rc.1`) |
| [`docs/release/VERSIONING.md`](docs/release/VERSIONING.md) | Quy tắc quản lý phiên bản thống nhất (`0.9.0` · Build `900`) |
| [`docs/release/BUILD_CONFIGURATION.md`](docs/release/BUILD_CONFIGURATION.md) | Cấu hình Build Development/Release & 5 Export Presets |
| [`docs/release/RELEASE_TEST_REPORT.md`](docs/release/RELEASE_TEST_REPORT.md) | Báo cáo kiểm định phát hành & trạng thái từng nền tảng |
| [`docs/release/RELEASE_CHECKLIST.md`](docs/release/RELEASE_CHECKLIST.md) | Checklist chuẩn bị phát hành Windows, Android, iOS, Web |
| [`docs/release/PRIVACY_POLICY_DRAFT.md`](docs/release/PRIVACY_POLICY_DRAFT.md) | Bản dự thảo Chính sách quyền riêng tư cho trẻ em |
| [`docs/IMPLEMENTATION_CHECKLIST.md`](docs/IMPLEMENTATION_CHECKLIST.md) | Checklist kiểm tra & danh sách công việc cho các Prompt tiếp theo |

---

## 4. Tech Stack

- **Game Engine:** Godot 4.3+ (GDScript, `gl_compatibility` renderer cho Android / iOS / Web / Desktop)
- **Backend & Database:** Supabase (PostgreSQL, Supabase Auth, Supabase Storage, PostgREST / REST API, Row Level Security)
- **Local Storage / Offline:** Local JSON/SQLite cache (`user://`) + Outbox Sync Queue
- **Localization:** Tiếng Việt (`vi` – ngôn ngữ hướng dẫn) & Tiếng Anh (`en` – ngôn ngữ học)

---

## 5. Cấu trúc thư mục dự án

```text
English Adventure/
├── project.godot                # Cấu hình Godot 4.x tối thiểu
├── README.md
├── .env.example                 # Mẫu biến môi trường (không chứa secret thật)
├── .gitignore
├── assets/                      # Tài nguyên đồ họa, 3D/2.5D, âm thanh, font
├── scenes/                      # Godot scenes (.tscn) chia theo domain
├── scripts/                     # GDScript theo kiến trúc 17 modules
├── data/                        # Dữ liệu học tập JSON độc lập logic game
├── localization/                # File dịch giao diện en / vi
├── tests/                       # Unit & Integration tests (GUT / gdUnit4)
├── supabase/
│   └── migrations/              # SQL migrations (schema + RLS)
├── docs/                        # Toàn bộ tài liệu kiến trúc & thiết kế
└── addons/                      # Plugins / test runners (cài ở Prompt 02)
```

---

## 6. Hướng dẫn mở và chạy bộ khung hiện tại

### Yêu cầu môi trường
- **Godot Engine 4.3+** (Standard / GDScript edition, **không** dùng .NET edition để tối ưu Web export).
- **Supabase CLI** hoặc tài khoản Supabase Cloud (cho phần backend/migration).

### Các bước thiết lập ban đầu
1. Sao chép `.env.example` thành `.env` (chỉ dùng cho script tool nội bộ hoặc build config; **tuyệt đối không** đưa `SUPABASE_SERVICE_ROLE_KEY` vào client Godot).
2. Mở **Godot 4.3+ Project Manager** → chọn **Import** → trỏ tới file `project.godot` tại thư mục gốc dự án.
3. Trong Supabase (local hoặc cloud), chạy lần lượt các file migration trong `supabase/migrations/`:
   - `0001_initial_schema.sql`
   - `0002_rls_policies.sql`
   - `0003_learning_engine_extensions.sql`
   - `0004_minigame_system_extensions.sql`
   - `0005_quest_reward_inventory_integration.sql`
   - `0006_audio_voice_pronunciation.sql`
   - `0007_content_expansion_system.sql`
4. Chạy bộ kiểm thử tự động:
   - Python validators (`validate_prompt_02.py`..`validate_prompt_10.py`, `validate_3d_visual_direction.py`).
   - Kiểm tra tài nguyên đóng gói: `python tools/audit_release_assets.py`.
   - Kiểm thử tích hợp nội dung P9: `python tests/integration/run_p9_content_tests.py`.
   - GDScript Unit/Regression Suite trong Godot Editor: `tests/unit/test_p8_regression_suite.gd`, `tests/unit/test_p9_content_integration.gd`, `tests/unit/test_p10_release_readiness.gd`.
   - Đóng gói Release (trên máy đã cài Godot 4.3+): `.\tools\build_release.ps1 -Target windows` hoặc GitHub Actions `.github/workflows/release-multiplatform.yml`.
   - Live WebGL2 E2E QA (Chrome CDP): `python tests/integration/run_webgl2_e2e_qa.py`.
5. Xem `docs/IMPLEMENTATION_CHECKLIST.md`, `docs/FINAL_QA_REPORT.md`, `docs/CONTENT_VALIDATION_REPORT.md`, `docs/release/RELEASE_TEST_REPORT.md`, `docs/release/RELEASE_CHECKLIST.md` để vận hành đầy đủ từ Prompt 01 → Prompt 10.
