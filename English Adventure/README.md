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

## 2. Trạng thái dự án hiện tại (Prompt 01–03 + Addendum 3D Visual Direction)

Dự án đã hoàn thành **Prompt 01 (Kiến trúc & Database)**, **Prompt 02 (Thế giới Game & Hệ thống Nhân vật)**, **Prompt 03 (Hệ thống UI/UX thống nhất)** và **Addendum – 3D Visual Direction**:

- **Stylized 3D World & Characters:** Chuyển đổi toàn bộ gameplay sang **3D thực thụ** (`CharacterBody3D`, camera góc nhìn thứ ba `SpringArm3D` tránh xuyên vật thể, mô hình placeholder 3D có khớp cho cả 7 nhân vật `Boy`, `Girl`, `Buddy`, `Professor Owl`, `Lily`, `Rocky`, `Crystal Guardian`, cùng 5 khu vực 3D với **Welcome Village** làm khu vực 3D trọng điểm, World Map 3D isometric, Diorama 3D trên Main Menu & Character Selection, và thiết lập chất lượng đồ họa `Low` / `Medium` / `High`). Xem [`docs/VISUAL_3D_ARCHITECTURE.md`](docs/VISUAL_3D_ARCHITECTURE.md) và [`docs/ASSET_3D_PIPELINE.md`](docs/ASSET_3D_PIPELINE.md).
- **Core & Persistence:** Đã triển khai 11 Autoloads (`AppLogger`, `EventBus`, `LocalizationManager`, `DataRepository`, `SaveLoadManager`, `GameStateManager`, `QuestManager`, `SettingsManager`, `AudioManager`, `UIManager`, `SceneRouter`).
- **UI/UX Design System & Màn hình:** `UIDesignSystem`, `UIAnimator`, `ResponsiveHelper`, thư viện component dùng chung (`AdventureConfirmDialog`, `RewardDisplay`, `QuestCardWidget`, `WorldCardWidget`, `AvatarBadge`, `LoadingIndicatorWidget`), Splash Screen, Main Menu, Character Selection, World Introduction, World Map, In-game HUD, Dialogue UI, Quest Log, Reward Popup, Inventory UI, Settings Modal, Pause Menu và Notification Stack.
- **World & Exploration:** Xây dựng **Alphabet Island** với **5 khu vực** (`Welcome Village`, `Alphabet Meadow`, `Letter Cave`, `Crystal Lake`, `The Shadow Gate`), bản đồ `World Map` tương tác, cơ chế khóa/mở khóa theo dữ liệu và chuyển cảnh bảo vệ khu vực khóa.
- **Characters & Quests:** Chọn nhân vật `Boy` / `Girl`, điều khiển PC (`WASD`/Arrows + `Space` + `E` + `H` + `Esc`) và Mobile (`VirtualJoystick` + nút chạm), đồng hành **Buddy** (7 trạng thái), 4 NPCs (`Professor Owl`, `Lily`, `Rocky`, `Crystal Guardian`), hệ thống hội thoại song ngữ, `InteractionManager` và 3 nhiệm vụ mẫu.
- **Learning Engine & Mini-games:** Chưa triển khai nội dung học hoàn chỉnh và file âm thanh (dành cho **Prompt 04+**).

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
4. Xem `docs/IMPLEMENTATION_CHECKLIST.md` để bắt đầu triển khai Phase 1 ở **Prompt 02**.
