# GIAI ĐOẠN A – PHÂN TÍCH YÊU CẦU & ARCHITECTURE DECISION RECORDS (DECISIONS.md)

Tài liệu này ghi nhận kết quả **Giai đoạn A (Phân tích yêu cầu, điểm chưa rõ, xung đột, rủi ro kỹ thuật)** và các **Quyết định Kiến trúc (ADRs)** cho dự án **ENGLISH ADVENTURE**.

---

## PHẦN 1: PHÂN TÍCH YÊU CẦU, XUNG ĐỘT & ĐIỂM CẦN LÀM RÕ

### 1.1. Xung đột / Điểm giao thoa giữa phạm vi GDD đầy đủ và phạm vi MVP

| # | Điểm phát hiện | Chi tiết mâu thuẫn tiềm ẩn | Phương án giải quyết |
|---|---|---|---|
| **C-01** | **7 Mini-games (Task 02) vs 5 Mini-games (Mục V - MVP)** | Task 02 yêu cầu thiết kế 7 mini-games (`Word Hunt`, `Listening Mission`, `Word Builder`, `Sentence Builder`, `Reading Challenge`, `Speaking Challenge`, `Boss Battle`), trong khi Mục V chỉ định rõ 5 mini-games bắt buộc cho MVP và ghi Speaking chi tiết là giai đoạn sau. | Thiết kế kiến trúc `BaseMiniGame` chung hỗ trợ đủ 7 loại trong `GDD.md` & `ARCHITECTURE.md`. Trong MVP chỉ triển khai **5 mini-game bắt buộc**, cộng thêm **chế độ Repeat-After-Me & thu âm thử nội bộ** (không chấm điểm AI) và **World 1 Final Gate** tái sử dụng chuỗi thử thách ghép từ 5 mini-game MVP để kết thúc câu chuyện Alphabet Island trọn vẹn. |
| **C-02** | **World 1 (Alphabet Island) vs 100–150 từ vựng & 10–15 cấu trúc câu** | Mục III mô tả World 1 dạy 26 chữ cái & phonics, World 2 dạy từ vựng, World 3 dạy cấu trúc câu. Tuy nhiên Mục V yêu cầu ngay trong MVP (chỉ có World 1) phải có 100–150 từ vựng, 10–15 câu cơ bản, `Sentence Builder` và `Reading Challenge`. | Áp dụng nguyên tắc xuyên suốt *"không giới hạn mỗi thế giới một kỹ năng"*: 26 chữ cái & phonics của World 1 được học qua **100–150 từ neo trực quan** (ví dụ: *A – apple, ant; B – ball, book*) và **10–15 mẫu câu khung tối giản** (*"It is an apple."*, *"I see a cat."*) để mở khóa đủ 4 kỹ năng ngay tại World 1. |
| **C-03** | **Tổ chức thư mục `english-adventure/` (Task 07) vs Root Repo (`docs/`)** | Task 07 minh họa gốc `english-adventure/`, trong khi các task tài liệu yêu cầu path `docs/PRD.md`, `docs/ARCHITECTURE.md` ở thư mục gốc workspace. | Đặt `project.godot`, `docs/`, `scenes/`, `scripts/`, `data/`, `assets/`, `supabase/` trực tiếp tại root workspace `English Adventure/` để cả path tài liệu lẫn Godot project root khớp 100% và không bị lồng thư mục thừa. |
| **C-04** | **Sắp xếp 17 modules (Task 03) vs 8 nhóm thư mục `scripts/` (Task 07)** | Task 03 yêu cầu 17 modules logic rõ ràng, nhưng mẫu thư mục Task 07 chỉ liệt kê 8 thư mục con dưới `scripts/`. | Cho phép mở rộng nhẹ cấu trúc `scripts/` (thêm `scripts/quest/`, `scripts/mini_games/`, `scripts/localization/`) và quy hoạch rõ ràng từng module trong `scripts/README.md` để mỗi module trong 17 modules đều có ranh giới code tách bạch, không dồn cục. |
| **C-05** | **Hai giọng `en-US` và `en-GB` (Task 05) vs Dung lượng MVP** | Task 05 yêu cầu hỗ trợ cả `en-US` và `en-GB` ở tầng dữ liệu, nhưng ghi chú không bắt buộc cung cấp đủ cả hai ở MVP. | Schema dữ liệu (`audio_assets`, JSON vocabulary) thiết kế sẵn map `accents: { "en-US": ..., "en-GB": ... }` với fallback tự động từ giọng người chơi chọn sang giọng mặc định (`en-US`) nếu file `en-GB` chưa có trong MVP. |

### 1.2. Các điểm chưa rõ đã được chuẩn hóa bằng giả định kỹ thuật hợp lý

1. **Cách xử lý khi trẻ 10 tuổi chưa biết gì về tiếng Anh (Mất gốc hoàn toàn) làm Initial Assessment:**
   - *Giải pháp:* Bài đánh giá đầu vào (Placement Check) phải **ngắn (3–5 phút), không gây áp lực thi cử**, toàn bộ hướng dẫn bằng tiếng Việt (có giọng đọc tiếng Việt hoặc minh họa trực quan của Buddy), có nút **"Bé chưa biết chữ/từ này"** để trẻ không phải đoán mò hoặc thấy tự ti.
2. **Định nghĩa 15–20 Quests ở World 1:**
   - *Giải pháp:* Chia Alphabet Island thành **4 khu vực (Zones)** theo cụm chữ cái & phonics (mỗi khu vực 4–5 quests: 26 chữ cái chia thành ~13 cặp/cụm học + nhiệm vụ tổng hợp khu vực + 1 Final Gate Quest = **18 Quests** trong MVP).
3. **Ngôn ngữ hiển thị & Audio tiếng Việt:**
   - *Giải pháp:* Tách rõ `Localization Module` cho text UI song ngữ (`vi`/`en`) và `Audio Module` có kênh riêng cho `voice_en` (người bản ngữ), `voice_vi_buddy` (giọng hướng dẫn Buddy thân thiện, tùy chọn bật/tắt), `sfx`, `bgm`.

### 1.3. Rủi ro kỹ thuật trọng yếu

| ID | Rủi ro | Mức độ | Biện pháp giảm thiểu ngay từ kiến trúc |
|---|---|---|---|
| **R-01** | **Godot 4 Web Export & SharedArrayBuffer / iOS Safari Audio** | Cao | Bắt buộc dùng **GDScript + Compatibility Renderer (`gl_compatibility`)** + Single-threaded Web Export (`threads = false`). Thiết kế `AudioSession` kích hoạt AudioContext ngay sau tương tác chạm đầu tiên của người chơi ở Splash/Login. |
| **R-02** | **Ghi âm Microphone trên Web & Mobile khác nhau** | Trung bình - Cao | Tạo `AudioCaptureService` với fallback an toàn: nếu trình duyệt/OS từ chối quyền mic hoặc không hỗ trợ, màn hình Speaking thử nghiệm chuyển mượt sang chế độ *"Nghe mẫu & Đọc to theo Buddy"* để không làm kẹt nhiệm vụ. |
| **R-03** | **Dung lượng tải ban đầu quá nặng trên Web/Mobile** | Cao | Asset 2.5D/Low-poly 3D tối ưu, nén texture KTX2/WebP, âm thanh OGG/MP3 bitrate chuẩn học tập (64–96 kbps mono cho voice). Thiết kế `ContentPackLoader` để MVP chỉ nạp World 1 (~30–60 MB), các World 2–6 tải theo nhu cầu sau này. |
| **R-04** | **Trẻ đoán bừa hoặc spam click để cày Mastery/EXP** | Cao | Thiết kế **Anti-Guess Mastery Algorithm**: giảm điểm Mastery khi trả lời sai nhiều lần trước khi đúng, không tăng Mastery Tier 4–5 nếu chưa vượt qua các phiên ôn tập cách quãng (Spaced Repetition) ở nhiều ngày khác nhau và tối thiểu 2 kỹ năng khác nhau. |
| **R-05** | **Mất kết nối mạng hoặc đồng bộ xung đột giữa nhiều thiết bị** | Trung bình | Offline-first với Local Cache + **Idempotent Event Outbox** (`client_event_id` UUID). Dữ liệu tiến trình đồng bộ theo quy tắc merge an toàn (không ghi đè giảm sao/level cao hơn, cộng dồn attempt theo UUID). |
| **R-06** | **Tuân thủ quyền riêng tư dữ liệu trẻ em (10 tuổi)** | Cao | Không thu thập họ tên thật, SĐT, địa chỉ, ảnh thật, giọng nói thô lên server ở MVP. Hỗ trợ chế độ chơi khách (Guest/Device profile) hoặc tài khoản do phụ huynh liên kết. |

---

## PHẦN 2: ARCHITECTURE DECISION RECORDS (ADRs)

### ADR-001: Godot 4.3+ GDScript & `gl_compatibility` Renderer thay vì Godot .NET (C#) hay Forward+
- **Ngữ cảnh:** Dự án chạy đồng thời Android, iOS và Web/Desktop.
- **Quyết định:** Sử dụng **Godot 4.3+ (hoặc 4.x bản ổn định mới nhất)** với **GDScript thuần** và renderer **`gl_compatibility`** (OpenGL ES 3 / WebGL 2).
- **Lý do:**
  1. Godot 4 C#/.NET có hạn chế nghiêm trọng với Web export (WASM) và kích thước build lớn trên mobile.
  2. `Forward+` không hỗ trợ WebGL2 và nặng pin trên điện thoại phổ thông của học sinh Việt Nam.
  3. GDScript tích hợp tự nhiên với Scene/Signal architecture và đội ngũ phát triển nhanh.
- **Phương án thay thế đã loại:** Unity (nặng bản WebGL, vấn đề licensing), Godot .NET (không tối ưu Web), HTML5 Canvas/Phaser (yếu ở 2.5D/3D Cartoon Adventure).

### ADR-002: Phong cách đồ họa 2.5D / Stylized Low-Poly 3D kết hợp UI Vector Sạch
- **Ngữ cảnh:** Game cần cảm giác phiêu lưu 3D/2.5D Cartoon sinh động nhưng vẫn mượt 60 FPS trên Web và máy tầm trung.
- **Quyết định:** Dùng **3D Low-Poly Stylized với Camera cố định góc nghiêng (3/4 Adventure Camera / 2.5D follow)** cho thế giới phiêu lưu, kết hợp **Control UI 2D sắc nét** cho HUD và các mini-game đòi hỏi thao tác kéo-thả/ghép chữ chính xác.
- **Lý do:** Kết hợp được chiều sâu khám phá thế giới với độ rõ chữ cái/từ vựng cực cao cho trẻ mới học đọc-viết.
- **Phương án thay thế:** Full Free-Camera 3D (khó điều khiển cho trẻ 10 tuổi trên màn hình cảm ứng dọc, dễ chóng mặt, nặng FPS).

### ADR-003: Tách biệt hoàn toàn Learning Engine và Adventure Engine qua EventBus & Content Repository
- **Ngữ cảnh:** Yêu cầu bắt buộc *"Learning Engine phải độc lập với Adventure Engine"* và *"Một từ vựng dùng lại trong nhiều mini-game"*.
- **Quyết định:**
  - `AdventureEngine` chỉ quản lý di chuyển, bản đồ, NPC, trigger và gửi `QuestRequested` / `MiniGameLaunchRequested(quest_id, learning_unit_ids)`.
  - `LearningEngine` nhận danh sách `word_id` / `phonics_id` / `grammar_id` từ `ContentRepository` (đọc JSON chuẩn hóa) và sinh động câu hỏi/mini-game payload (`QuestionSpec`).
  - Hai tầng giao tiếp qua **EventBus (Signals)** và **Data DTOs**, không tham chiếu node trực tiếp của nhau.
- **Lý do:** Đảm bảo thêm World 2–6 hoặc thêm 700 từ mới không cần sửa code mini-game hay bản đồ; dễ unit test `LearningEngine` độc lập không cần load 3D scene.

### ADR-004: Offline-First Local Storage + Idempotent Sync Queue lên Supabase
- **Ngữ cảnh:** Học sinh chơi trên máy tính bảng/điện thoại có thể mất Wi-Fi; cần đồng bộ lên Supabase PostgreSQL khi có mạng.
- **Quyết định:**
  - Lưu trữ nội bộ tại `user://profiles/<profile_id>/` (snapshot tiến trình + `sync_outbox.json` chứa các sự kiện có `client_event_id` UUIDv4).
  - Giao tiếp Supabase qua REST/PostgREST (`HTTPRequest` trong Godot) thông qua `BackendService` dùng **Supabase Anon Key + JWT user token (RLS bảo vệ)**; **tuyệt đối không** lưu Service Role Key ở client.
- **Lý do:** Không cần custom backend server trung gian tốn chi phí vận hành trong MVP; RLS của PostgreSQL bảo vệ dữ liệu từng người chơi ở mức dòng.
- **Phương án thay thế:** Custom Node/Go API Server (tăng chi phí & thời gian MVP, có thể bổ sung Supabase Edge Functions ở giai đoạn sau khi tích hợp AI Speaking).

### ADR-005: Tách biệt Letter Name, Letter Sound, Phoneme và Word Pronunciation trong Data Model
- **Ngữ cảnh:** Trẻ Việt Nam mất gốc thường nhầm tên chữ cái `/eɪ/` (*ay*) với âm chữ cái `/æ/` (*a* trong *apple*).
- **Quyết định:** Trong JSON và bảng `phonics_content`, tách thành 4 trường tường minh: `letter_name_ipa` + `letter_name_audio`, `letter_sound_ipa` + `letter_sound_audio`, `phoneme_symbol`, và `vocabulary.ipa` + `audio_assets`.
- **Lý do:** Ngăn lỗi sư phạm nghiêm trọng ngay từ cấu trúc dữ liệu, bắt buộc mọi bài học Phonics World 1 phải phân biệt rõ 2 khái niệm này.

### ADR-006: Thuật toán Mastery chống đoán bừa (Anti-Guessing Mastery + Modified SM-2)
- **Ngữ cảnh:** Không cho phép trẻ đạt Mastery chỉ bằng cách chơi nhiều lần hoặc bấm đại cho đến khi trúng.
- **Quyết định:**
  - Mastery của mỗi từ/kiến thức gồm `mastery_score` (0–100) và `mastery_level` (0–5).
  - Điểm cộng chỉ tính trọn vẹn khi đúng ở **lần thử đầu tiên (first-try)**, không dùng quá nhiều gợi ý, và **thời gian phản hồi hợp lý** (tránh auto-tap < 400ms ở câu phức tạp).
  - Để lên **Level 4–5 (Mastered)** bắt buộc có **ít nhất 2 kỹ năng khác nhau** (ví dụ: Listening + Word/Sentence Builder) và **ít nhất 2 phiên ôn tập cách ngày** qua `review_schedule`.
- **Lý do:** Chứng minh được tiêu chí cốt lõi của MVP: *"Trẻ thực sự ghi nhớ kiến thức"*.

### ADR-007: Bảo vệ dữ liệu trẻ em & Guest-to-Parent Auth Flow
- **Ngữ cảnh:** Đối tượng là trẻ 10 tuổi; quy định cấm lưu dữ liệu nhạy cảm không cần thiết.
- **Quyết định:** Cho phép vào chơi ngay bằng **Supabase Anonymous Sign-In** (tạo `user_id` ẩn danh gắn với thiết bị, lưu tiến trình cloud an toàn dưới RLS) hoặc **Tài khoản Phụ huynh tạo sẵn** (Email + Mật khẩu / OTP phụ huynh, con chọn profile bằng Nickname + Avatar). Không lưu tên thật, email của trẻ, ngày sinh chi tiết hay file ghi âm lên cloud ở MVP.
- **Lý do:** Giảm ma sát trải nghiệm lần đầu (trẻ chơi ngay trong 30 giây) mà vẫn đồng bộ được cloud và an toàn dữ liệu trẻ em.

### ADR-008: Chuẩn hóa 2.5D Top-Down Node2D + 5 Khu Vực Alphabet Island (Cập nhật Prompt 02)
- **Ngữ cảnh:** Prompt 02 quy định cụ thể 5 khu vực cho Alphabet Island (`Welcome Village`, `Alphabet Meadow`, `Letter Cave`, `Crystal Lake`, `The Shadow Gate`) và nhấn mạnh di chuyển 2D nhất quán nếu bản đồ dùng 2D thay vì dựng hệ thống 3D phức tạp khi chưa có model 3D.
- **Quyết định:**
  1. Cập nhật World 1 từ 4 zone sang **5 khu vực chuẩn Prompt 02** trong `data/areas/alphabet_island_areas.json` và `docs/GDD.md`.
  2. Triển khai thế giới phiêu lưu bằng **`Node2D` Y-Sorted 2.5D (`CharacterBody2D` + `y_sort_enabled = true`)** kết hợp tài nguyên SVG Cartoon tự tạo và `CharacterAnimator` (7 states), giữ nguyên renderer `gl_compatibility` cho Web/Android/iOS.
- **Lý do:** Đảm bảo đồ họa cartoon sắc nét đa nền tảng, dễ mở rộng sprite sheet sau này và bám sát phạm vi Prompt 02.
