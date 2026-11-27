# MVP DEVELOPMENT ROADMAP (PHASES 1–7)
# PROJECT: ENGLISH ADVENTURE

**Mục tiêu MVP:** Triển khai hoàn chỉnh **World 1 – Alphabet Island** (18 Quests, 26 chữ cái, 100–150 từ vựng, 10–15 cấu trúc câu, 5 mini-games bắt buộc + Repeat-After-Me, Offline + Supabase Sync) chứng minh 3 tiêu chí: *Trẻ muốn chơi tiếp – Trẻ thực sự ghi nhớ – Kiến trúc mở rộng không phải viết lại.*

**Ước tính tổng thời gian MVP:** **12 – 14 tuần** (với đội ngũ gọn 3–4 thành viên chuyên môn hoặc phân bổ theo luồng song song).

---

## TỔNG QUAN TIẾN ĐỘ & LUỒNG SONG SONG

```mermaid
gantt
    title ENGLISH ADVENTURE - MVP ROADMAP (14 Weeks)
    dateFormat  YYYY-MM-DD
    section Core & Backend
    Phase 1: Setup & Core Systems         :p1, 2026-12-01, 14d
    section World & Narrative
    Phase 2: World Map, Characters, Quest :p2, after p1, 14d
    section Learning & Content
    Phase 3: Learning Engine, Vocab, Audio:p3, after p1, 21d
    section Mini-games
    Phase 4: 5 MVP Mini-games             :p4, after p3, 21d
    section Progression & Review
    Phase 5: Mastery, Rewards, Review     :p5, after p3, 14d
    section Responsive & Platforms
    Phase 6: Responsive UI & Multi-OS     :p6, after p4, 14d
    section QA & Release
    Phase 7: Testing, Opt & MVP Release   :p7, after p6, 14d
```

> **Tối ưu hóa song song:**
> - Sau khi xong **Phase 1**, **Phase 2 (Adventure/Character/Quest)** và **Phase 3 (Learning Engine/Content/Audio)** chạy **song song hoàn toàn** (nhờ kiến trúc tách biệt Adventure và Learning).
> - Trong **Phase 4**, 5 mini-games có thể phân công làm song song sau khi hoàn thành `BaseMiniGame` và `QuestionFactory`.
> - **Phase 5 (Progression/Review)** chạy gối đầu song song với nửa sau Phase 4.

---

## PHASE 1: Architecture, Project Setup, Core Systems (Tuần 1–2)
- **Mục tiêu:** Thiết lập nền móng kỹ thuật Godot 4, Supabase database, Core autoloads, Auth & Save/Load cục bộ.
- **Công việc:**
  - Hoàn thiện cấu trúc repo Godot 4 (`gl_compatibility`), CI kiểm tra lint/test cơ bản.
  - Chạy SQL Migrations (`0001_initial_schema.sql`, `0002_rls_policies.sql`) trên Supabase dev project.
  - Code `Core Module` (`EventBus`, `SceneRouter`, `AppConfig`, `AppLogger`, `DataValidator`).
  - Code `Localization Module` (khung dịch `vi`/`en` + font chữ hỗ trợ tiếng Việt & IPA).
  - Code `BackendService` (Supabase Anonymous Auth + Email Auth + HTTP client) & `SaveLoadModule` (`user://` + `sync_outbox.json`).
  - Cài đặt test framework (GUT hoặc gdUnit4).
- **Deliverables:** App chạy Splash → Login → tạo/lưu profile offline & đồng bộ được lên Supabase.
- **Dependencies:** Hoàn thành tài liệu Prompt 01.
- **Acceptance Criteria:**
  - Anonymous login thành công, RLS chặn đọc/ghi profile khác.
  - Unit tests `SaveLoad` & `EventBus` pass 100%.
  - Không chứa Service Role Key trong client.
- **Potential Risks:** Cấu hình HTTPS/CORS khi test Supabase từ Godot Web build. (*Giảm thiểu:* Test Web export sớm ngay cuối Phase 1).

---

## PHASE 2: World Map, Characters, Quest System (Tuần 3–4 | Song song Phase 3)
- **Mục tiêu:** Xây dựng trải nghiệm phiêu lưu trên Alphabet Island (4 Zones), nhân vật điều khiển, Buddy và hệ thống Quest.
- **Công việc:**
  - Tạo Scene `World Map (#6)` và `World Detail (#7)`.
  - Dựng bản đồ 2.5D/3D nhẹ cho **World 1 – Alphabet Island** (4 Zones, cổng mở khóa, điểm tương tác NPC/Rương).
  - Xây dựng `Character Module`: Explorer Boy/Girl (di chuyển Joystick + Keyboard), Buddy bay theo sau, Professor Owl & NPCs, Animation State Machine (`idle`, `walk`, `interact`, `happy`, `encourage`, `talk`).
  - Xây dựng `Quest Module`: Nạp `world_01_quests.json` (18 Quests), quản lý trạng thái, màn hình `Quest Selection (#8)` và `Quest Introduction (#9)`.
- **Deliverables:** Người chơi chọn Nam/Nữ, đi lại trên Alphabet Island, nói chuyện NPC & Buddy, nhận Quest và gọi được tín hiệu mở mini-game giả lập.
- **Dependencies:** Phase 1 (`EventBus`, `SceneRouter`, `Localization`).
- **Acceptance Criteria:**
  - Chạy >= 45 FPS trên thiết bị test chuẩn.
  - Chuyển đổi mượt điều khiển Touch Joystick và Keyboard/Mouse.
- **Potential Risks:** Tài nguyên 3D/2.5D nặng làm tăng thời gian tải Web. (*Giảm thiểu:* Dùng low-poly tối ưu, giới hạn kích thước texture <= 1024px, dùng chung material atlas).

---

## PHASE 3: Learning Engine, Vocabulary, Audio & Initial Assessment (Tuần 3–5 | Song song Phase 2)
- **Mục tiêu:** Xây dựng toàn bộ tầng dữ liệu học tập độc lập, hệ thống âm thanh và bài đánh giá đầu vào.
- **Công việc:**
  - Biên soạn & chuẩn hóa dữ liệu World 1 (`data/`): **26 chữ cái** (tách Letter Name & Letter Sound), **100–150 từ vựng neo**, **10–15 cấu trúc câu**, hình ảnh `.webp`, audio `en-US` (và audio hướng dẫn Buddy VI).
  - Xây dựng công cụ/script **Content Validator** kiểm tra JSON, IPA, ảnh, audio, referential integrity.
  - Code `Vocabulary Module`, `Grammar Module` (Phonics + Sentence Slots), `Learning Module` (`QuestionGeneratorService` sinh payload chuẩn từ `word_id`).
  - Code `Audio Module` (preloading, audio buses, điều chỉnh tốc độ chậm 0.85x, `AudioCaptureAdapter` cho thu âm thử cục bộ).
  - Xây dựng `Assessment Module` & màn hình `Initial Assessment (#4)` (có nút "Bé chưa biết").
- **Deliverables:** Bộ dữ liệu World 1 vượt qua 100% kiểm tra Validator; API nội bộ sinh câu hỏi cho mọi loại mini-game từ cùng 1 `word_id`.
- **Dependencies:** Phase 1 (`Core`, `SaveLoad`, `Audio` bus cơ bản).
- **Acceptance Criteria:**
  - Đổi/thêm 1 từ vựng mới vào JSON, `QuestionGeneratorService` tự sinh đúng dữ liệu cho cả 5 mini-game.
  - Phát âm thanh không trễ (< 150ms); phân biệt đúng audio `letter_name` và `letter_sound`.
- **Potential Risks:** Chậm tiến độ sản xuất audio/hình ảnh cho 150 từ. (*Giảm thiểu:* Chuẩn hóa quy trình thu/tạo asset hợp pháp sớm từ tuần 2, khóa danh sách 150 từ ngay tuần 3).

---

## PHASE 4: Mini-games Implementation (Tuần 6–8)
- **Mục tiêu:** Triển khai hoàn chỉnh 5 mini-game MVP + chế độ Repeat-After-Me + World 1 Final Gate.
- **Công việc:**
  - Xây dựng `BaseMiniGame`, các UI Widgets dùng chung (`LetterTile`, `WordCard`, `SentenceBridgeBlock`, `AudioPlayButton`, `BuddyFeedbackOverlay`).
  - Triển khai 5 mini-games bắt buộc (có thể chia 2 dev làm song song):
    1. `Word Hunt` (Săn chữ & từ tương tác).
    2. `Listening Mission` (Nghe 1.0x / 0.85x chọn hình/từ).
    3. `Word Builder` (Ghép chữ theo Phonics/CVC, có chữ nhiễu).
    4. `Sentence Builder` (Sắp xếp thẻ từ nối cầu ánh sáng).
    5. `Reading Challenge` (Đọc câu ngắn bấm nghe hỗ trợ + chọn tranh/điền từ).
  - Tích hợp `Repeat-After-Me` (ghi âm thử cục bộ + nghe lại) vào bước học từ & chuỗi `Echo Guardian` (World 1 Gate) ghép 3 hiệp từ 5 mini-game.
  - Nối hoàn chỉnh luồng Quest → LearningEngine → MiniGame → LearningFeedback (#11).
- **Deliverables:** Chơi trọn vẹn cả 18 Quests của World 1 từ đầu đến cuối với 5 mini-games thật.
- **Dependencies:** Phase 2 (Quest triggers) + Phase 3 (LearningEngine & Data).
- **Acceptance Criteria:**
  - Không hardcode bất kỳ từ vựng nào trong scene/script của 5 mini-game.
  - Mỗi mini-game phát ra `LearningAttemptDTO` chuẩn xác (kèm `attempt_number`, `used_hint`, `response_time_ms`).
- **Potential Risks:** UX kéo-thả trên màn hình nhỏ bị che ngón tay. (*Giảm thiểu:* Hỗ trợ song song cả **kéo-thả** và **chạm 1 lần để đặt chữ**).

---

## PHASE 5: Progression, Rewards, Review System & Dashboards (Tuần 8–9 | Gối đầu Phase 4)
- **Mục tiêu:** Hoàn thiện động lực chơi lâu dài, chống đoán bừa và cơ chế ôn tập ghi nhớ thật.
- **Công việc:**
  - Code `Reward Module` (EXP, Gold, Stars, Diminishing Returns khi cày lại) & **Anti-Guess Mastery Engine**.
  - Code `Review Module` (Modified SM-2 Scheduler, ưu tiên từ yếu/đa kỹ năng).
  - Code `Progress Module` & `Inventory Module` (Magic Crystal Shards, Achievements, Wordbook).
  - Xây dựng các màn hình: `Home Screen (#5)`, `Reward Screen (#12)`, `Inventory (#13)`, `Achievement (#14)`, `Player Profile (#15)`, `Learning Dashboard (#16)`, `Settings (#17)`.
  - Hoàn thiện Background Sync Queue đẩy `learning_attempts`, `vocabulary_mastery`, `review_schedule`, `player_progress` lên Supabase.
- **Deliverables:** Vòng lặp học – thưởng – ôn tập – đồng bộ cloud hoàn chỉnh.
- **Dependencies:** Phase 3 (`Vocabulary`), Phase 4 (`LearningAttemptDTO`).
- **Acceptance Criteria:**
  - Thử nghiệm spam bấm sai/bấm nhanh < 400ms không thể đẩy từ lên Mastery Level 3–5.
  - Từ sai xuất hiện trong hàng đợi `Ôn tập cùng Buddy` với hạn đúng quy tắc SM-2.
  - Offline sync không tạo bản ghi trùng lặp khi bật lại mạng.
- **Potential Risks:** Cân bằng EXP/Stars quá dễ hoặc quá khó gây nản. (*Giảm thiểu:* Tham số cân bằng đặt trong file config để tinh chỉnh nhanh qua playtest).

---

## PHASE 6: Responsive UI & Multi-Platform Porting (Tuần 10–11)
- **Mục tiêu:** Đảm bảo trải nghiệm chuẩn chỉnh trên cả Mobile Portrait, Mobile Landscape, Tablet và Desktop/Web.
- **Công việc:**
  - Triển khai `ViewportBreakpointManager` và kiểm tra toàn bộ 17 màn hình MVP trên 4 tỷ lệ màn hình + Safe Area (tai thỏ iOS/Android).
  - Tối ưu điều khiển bàn phím/chuột riêng cho Web & Desktop (không mang cảm giác phóng to app điện thoại).
  - Build thử nghiệm và xử lý vấn đề đặc thù từng nền tảng:
    - **Android:** APK/AAB, quyền Audio/Mic, Back button handling.
    - **iOS:** Xcode export, Audio session khi gạt nút im lặng, Safe Area.
    - **Web:** Single-threaded WASM, kích hoạt audio sau click đầu tiên, fallback mic trên Safari/Firefox, tối ưu kích thước nén gzip/brotli.
- **Deliverables:** Bản build chạy ổn định trên Android, iOS TestFlight/Simulator và Web browser.
- **Dependencies:** Phase 4 & Phase 5.
- **Acceptance Criteria:**
  - Không bị cắt chữ, đè nút hoặc tràn màn hình ở cả 4 form factors.
  - Bản Web tải và khởi động xong < 8 giây trên mạng băng thông phổ thông.
- **Potential Risks:** Khác biệt hiệu năng Shader/WebGL trên Safari iOS hoặc Android giá rẻ. (*Giảm thiểu:* Tránh shader hậu kỳ phức tạp, tắt MSAA nặng trên Web/Mobile thấp).

---

## PHASE 7: Testing, Optimization, Playtest & MVP Release (Tuần 12–14)
- **Mục tiêu:** Kiểm thử chất lượng kỹ thuật, bảo mật và **playtest thực tế với trẻ ~10 tuổi** trước khi phát hành MVP.
- **Công việc:**
  - Chạy bộ Automated Tests: Unit tests (Mastery, SM-2, QuestionGenerator, SyncQueue), Content Validator, Integration tests (Offline → Online sync, RLS security check).
  - Profiling hiệu năng (FPS, Memory, Draw calls, Audio latency) và tối ưu dung lượng gói cài <= 60 MB.
  - **Playtest giáo dục (5–10 trẻ ~10 tuổi mất gốc):** Quan sát trẻ tự chơi để đo lường:
    - Trẻ có hiểu nhiệm vụ mà không cần người lớn dịch hộ không?
    - Trẻ có muốn chơi tiếp sang Quest 3–5 không?
    - Kiểm tra khả năng nhớ 10 từ đã học sau 48 giờ.
  - Sửa lỗi ưu tiên cao (P0/P1) từ playtest, chốt bản phát hành MVP.
- **Deliverables:** Báo cáo QA, Báo cáo Playtest 3 tiêu chí MVP, Bản phát hành MVP (Web + Android + iOS).
- **Dependencies:** Phase 6.
- **Acceptance Criteria:**
  - 0 lỗi Crash/Blocker (P0), 0 lỗi mất tiến trình.
  - Đạt đủ 6 tiêu chí nghiệm thu tại mục 13 của `docs/PRD.md`.
- **Potential Risks:** Phát hiện nội dung quá khó với trẻ mất gốc hoàn toàn trong buổi playtest. (*Giảm thiểu:* Dành trọn tuần 13 để tinh chỉnh tốc độ hướng dẫn của Buddy và độ khó 5 Quest đầu ngay từ dữ liệu JSON).

---

## CẬP NHẬT TRẠNG THÁI THỰC TẾ TẠI PROMPT 08 (27/11/2026)

- **Đã hoàn thành kiểm thử kỹ thuật P8 trên WebGL2 & bộ kiểm thử tự động:** `0` lỗi P0, `0` lỗi P1 trong luồng gameplay chính; đã sửa 12 lỗi (`BUG-01`..`BUG-12`), tối ưu cache Material/Mesh 3D, Responsive Mobile Portrait (`390x844`) và backup save `.bak.json`.
- **Cần hoàn thành trước khi phát hành chính thức:**
  1. Cài đặt Godot 4.3+ Editor/Export Templates để export & kiểm thử trên **Windows `.exe`**, **Android APK** và **iOS IPA** thật.
  2. Cấu hình Supabase Cloud + `AZURE_SPEECH_KEY` để kiểm thử đồng bộ đám mây RLS và AI chấm phát âm thật.
  3. Tổ chức Playtest giáo dục với 5–10 trẻ ~10 tuổi và bổ sung giọng thu âm `.ogg` cho toàn bộ từ vựng/NPC nếu có ngân sách sản xuất.
