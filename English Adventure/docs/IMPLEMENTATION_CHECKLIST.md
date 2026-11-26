# IMPLEMENTATION CHECKLIST & CONSISTENCY AUDIT
# PROJECT: ENGLISH ADVENTURE

Tài liệu này tổng hợp kết quả kiểm tra tính nhất quán của **Giai đoạn D (Prompt 01)** và lập danh sách công việc cụ thể cần thực hiện trong **Prompt 02**.

---

## PHẦN 1: KẾT QUẢ KIỂM TRA NHẤT QUÁN (STAGE D AUDIT)

| Hạng mục kiểm tra | Trạng thái | Kết quả đối chiếu |
|---|---|---|
| **PRD ↔ GDD ↔ Architecture** | Đạt | Phạm vi MVP thống nhất 100%: **1 World (Alphabet Island)**, **18 Quests**, **26 chữ cái**, **100–150 từ vựng**, **10–15 cấu trúc câu**, **5 mini-games bắt buộc** (`Word Hunt`, `Listening Mission`, `Word Builder`, `Sentence Builder`, `Reading Challenge`) + `Repeat-After-Me` & `Echo Guardian Gate`. Đủ 17 modules trong Architecture. |
| **Database ↔ Learning Content** | Đạt | 32 bảng PostgreSQL trong `docs/DATABASE_SCHEMA.md` và `supabase/migrations/0001_initial_schema.sql` khớp 1:1 với `docs/ERD.md` và mô hình JSON tại `docs/LEARNING_CONTENT_SPEC.md`. Đã tách rõ `letter_name_audio_id` và `letter_sound_audio_id` trong `phonics_content` bằng `CHECK` constraint. |
| **RLS & Bảo mật trẻ em** | Đạt | Đã kiểm tra tự động: **32/32 bảng** có `ENABLE ROW LEVEL SECURITY` trong `0002_rls_policies.sql`. Không có secret key trong `project.godot` hay `.env.example`. Không thu thập PII trẻ em. |
| **Cấu trúc thư mục Godot 4** | Đạt | Toàn bộ cấu trúc `assets/`, `scenes/`, `scripts/`, `data/`, `localization/`, `tests/`, `supabase/`, `docs/`, `addons/` đã khởi tạo hợp lệ với `project.godot` (`4.3`, `GL Compatibility`). Không tạo code giả. |
| **Khả năng mở rộng (Scalability)** | Đạt | `LearningEngine` tách rời hoàn toàn khỏi `AdventureEngine`; `vocabulary` là Single Source of Truth hỗ trợ mở rộng lên 6 Worlds và 600–800+ từ vựng, đa giọng `en-US` / `en-GB`. |
| **Rủi ro đa nền tảng** | Đã kiểm soát | Chọn `gl_compatibility` + Single-threaded WASM + AudioContext unlock trên Web + Fallback mic trên trình duyệt/OS hạn chế quyền. |

---

## PHẦN 2: DANH SÁCH CÔNG VIỆC CHO PROMPT 02 (PHASE 1 & NỀN TẢNG PHASE 2–3)

### 2.1. Hạ tầng Godot 4 & Core Module (`scripts/core/`)
- [ ] Cài đặt framework unit test **GUT** hoặc **gdUnit4** vào `addons/`.
- [x] Triển khai `event_bus.gd` và đăng ký vào `[autoload]` trong `project.godot` *(hoàn thành ở Prompt 02)*.
- [ ] Triển khai `app_config.gd` (đọc cấu hình public Supabase URL & Anon Key từ build config/env không chứa secret).
- [x] Triển khai `app_logger.gd` (ghi log xoay vòng `user://logs/` có redact token) *(hoàn thành ở Prompt 02)*.
- [x] Triển khai `scene_router.gd` & Responsive Breakpoint Manager (4 breakpoints + chặn vào khu vực khóa) *(hoàn thành ở Prompt 02)*.
- [x] Tạo khung dịch giao diện `localization/vi/` và `localization/en/` + `LocalizationManager` *(hoàn thành phần UI Prompt 02; chờ nhúng font tùy chỉnh vào `assets/fonts/`)*.

### 2.2. Backend Service & Offline Save/Load (`scripts/services/`)
- [x] Triển khai `save_load_manager.gd` (atomic write/read profile tại `user://profiles/`, quản lý `sync_outbox.json`, sanitize dữ liệu hỏng) *(hoàn thành ở Prompt 02)*.
- [ ] Triển khai `supabase_auth_service.gd` (Anonymous Sign-In + Parent Email Sign-In + JWT refresh).
- [ ] Triển khai `supabase_sync_service.gd` (Idempotent batch push bằng `client_event_id`, High-Water Mark merge, Exponential Backoff retry).
- [ ] Chạy `0001_initial_schema.sql` và `0002_rls_policies.sql` trên Supabase instance thật và viết integration test xác nhận RLS chặn đọc/ghi chéo user.

### 2.5. Thế giới Alphabet Island, Nhân vật & Nhiệm vụ khung (Prompt 02)
- [x] Màn hình `Character Selection` (Boy / Girl + Nickname + lưu hồ sơ).
- [x] Màn hình `World Introduction` & `World Map` (5 khu vực Alphabet Island + xem trước 5 Worlds tương lai).
- [x] 5 khu vực có thể khám phá (`Welcome Village`, `Alphabet Meadow`, `Letter Cave`, `Crystal Lake`, `The Shadow Gate`) với điều khiển PC + Mobile Touch Joystick.
- [x] Buddy (7 trạng thái), 4 NPCs (`Professor Owl`, `Lily`, `Rocky`, `Crystal Guardian`), `InteractionManager`, `DialogueManager`, `QuestManager` (3 nhiệm vụ mẫu).
- [ ] Mở chạy thử trực quan trong Godot 4.3+ Editor (máy hiện chưa cài `godot`).

### 2.6. Hệ thống UI/UX, Settings & Audio Infrastructure (Prompt 03 – Đã triển khai)
- [x] `UIDesignSystem` (`scripts/ui/managers/ui_design_system.gd`): Bảng màu Fantasy Cartoon Adventure, Typography 7 cấp, 8 Button Variants với 5 trạng thái và Global Theme opaque.
- [x] `UIManager` (`scripts/ui/managers/ui_manager.gd`): Theme toàn cục, Notification Stack không chặn thao tác (nằm trên mọi modal), `ConfirmationDialog`, `SettingsModal`, `LoadingIndicator`, `Tooltip`.
- [x] `UIAnimator` (`scripts/ui/animations/ui_animator.gd`) & `ResponsiveHelper` (`scripts/ui/responsive/responsive_helper.gd`): Tween mượt, hỗ trợ `reduced_motion` và `safe_area`.
- [x] Components dùng chung (`scenes/ui/common/`, `scripts/ui/components/`): `AdventureConfirmDialog`, `RewardDisplay`, `QuestCardWidget`, `WorldCardWidget`, `AvatarBadge`, `LoadingIndicatorWidget`.
- [x] Các màn hình chính & In-game UI: `MainEntry` (Splash), `MainMenuUI`, `CharacterSelectionUI`, `WorldIntroductionUI`, `WorldMapUI`, `AdventureHUD`, `DialogueBoxUI`, `QuestLog`, `QuestCompletedPopup`, `BagModal`, `PauseMenuUI`, `SettingsModalUI`.
- [x] `AdventureHUD` & Third-person Camera 3D: `PlayerController` (`SpringArm3D` collision, `camera_distance`, `camera_height`, `camera_sensitivity`, `camera_smoothing`, `camera_rotation_speed`), `TouchCameraPad` vuốt xoay camera trên Mobile, phím tắt `Tab` (Sổ tay Nhiệm vụ) / `M` (Bản đồ) / `H` (Buddy) / `Esc` (Pause).
- [x] `SettingsManager` (`user://settings.json`) & `AudioManager` (`Music` / `SFX` buses): Đã tích hợp `camera_sensitivity`, `graphics_quality` (`low`/`medium`/`high`), `music_volume`, `sfx_volume`, `language`, `control_mode`, `reduced_motion`, `fullscreen`, `resolution` (Desktop), và ghi nhận rõ khi audio files còn thiếu.

### 2.7. Việc cần làm trong Prompt 04+ (Learning Engine, Mini-games & Audio Assets)
- [ ] Triển khai `LearningEngine`, `VocabularyRepository`, `PhonicsRepository`, `GrammarPatternEngine` và dữ liệu 26 chữ cái + 100–150 từ vựng.
- [ ] Bổ sung file âm thanh thực tế (`assets/audio/sfx/`, `assets/audio/bgm/`, giọng `en-US`, giọng Buddy) và gắn vào `AudioManager`.
- [ ] Kết nối `EventBus.learning_hook_requested` từ các nhiệm vụ sang các mini-game đầu tiên.

### 2.3. Content Schemas & Validator (`data/` & `tests/content_validation/`)
- [ ] Tạo các JSON Schema chuẩn trong `data/schemas/` (`vocabulary.schema.json`, `phonics.schema.json`, `grammar.schema.json`, `quest.schema.json`).
- [ ] Xây dựng script **Content Validator** kiểm tra: cấu trúc trường, định dạng IPA, tồn tại file ảnh/audio, tách biệt `letter_name` vs `letter_sound`, nghĩa tiếng Việt và tham chiếu chéo `word_id`.
- [ ] Soạn tập dữ liệu hạt giống ban đầu cho World 1 (tối thiểu 26 chữ cái `letters_a_z.json` + 30–50 từ neo đầu tiên để test pipeline).

### 2.4. Learning Engine & Audio Core (`scripts/learning/`, `scripts/audio/`, `scripts/assessment/`)
- [ ] Định nghĩa các DTO/Resource (`VocabularyResource`, `PhonicsResource`, `GrammarPatternResource`, `ChallengePayload`, `LearningAttemptDTO`).
- [ ] Triển khai `VocabularyRepository`, `PhonicsRepository`, `GrammarPatternEngine`.
- [ ] Triển khai `QuestionGeneratorService` sinh động câu hỏi cho 5 mini-games từ cùng 1 `word_id` (chứng minh với từ `"apple"`).
- [ ] Triển khai `AudioManager` với các Audio Bus (`Master`, `BGM`, `SFX`, `VoiceEN`, `VoiceVI`), tốc độ nghe chậm `0.85x`, fallback `en-GB` → `en-US`, và `AudioCaptureAdapter`.
- [ ] Triển khai `AntiGuessMasteryCalculator` + `ReviewScheduler` (Modified SM-2) kèm đầy đủ unit test chứng minh chống đoán bừa.

### 2.5. Onboarding Screens (`scenes/boot/`, `scenes/authentication/`, `scenes/home/`)
- [ ] Xây dựng `Splash Screen (#1)` (kích hoạt AudioContext trên Web).
- [ ] Xây dựng `Login Screen (#2)` (Chơi ngay Khách + Đăng nhập Phụ huynh).
- [ ] Xây dựng `Character Selection (#3)` (Chọn Explorer Boy/Girl + Nickname).
- [ ] Xây dựng `Initial Assessment (#4)` (kèm nút "Bé chưa biết").
- [ ] Xây dựng `Home Screen (#5)` & `Settings (#17)`.
