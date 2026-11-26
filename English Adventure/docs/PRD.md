# PRODUCT REQUIREMENTS DOCUMENT (PRD)
# PROJECT: ENGLISH ADVENTURE

**Phiên bản:** 1.0 (Foundation)  
**Ngày cập nhật:** 2026-11-26  
**Trạng thái:** Approved for Architecture & MVP Planning  

---

## 1. Product Overview

**ENGLISH ADVENTURE** (*A Fun English Learning Adventure Game*) là trò chơi phiêu lưu giáo dục đa nền tảng (Android, iOS, Web/Desktop) được xây dựng bằng **Godot 4.x** và **Supabase**, dành riêng cho **trẻ em Việt Nam 10 tuổi bị mất gốc tiếng Anh** (hoặc chưa từng học bài bản) nhưng yêu thích trò chơi điện tử.

Thay vì thiết kế theo dạng ứng dụng trắc nghiệm hoặc flashcard khô khan, trò chơi đặt người chơi vào vai một nhà thám hiểm trẻ tuổi bước vào thế giới phép thuật đang bị thế lực **The Silent Shadow** đánh cắp âm thanh và ngôn ngữ. Cùng với người bạn đồng hành rồng nhỏ **Buddy** và **Professor Owl**, trẻ khám phá bản đồ, nhận nhiệm vụ, giải mã chữ cái – âm thanh – từ vựng – câu nói qua các mini-game tương tác, từng bước phát triển cân bằng **Listening, Speaking, Reading, Writing** từ con số 0 lên Pre-A1, A1 và hướng tới A2.

---

## 2. Product Vision

> *"Biến việc học lại tiếng Anh từ con số 0 của trẻ 10 tuổi thành một cuộc phiêu lưu kỳ thú mà trẻ tự nguyện mở lên mỗi ngày, ghi nhớ tự nhiên qua hành động và lấy lại sự tự tin giao tiếp."*

**Ba trụ cột chứng minh thành công ở giai đoạn MVP:**
1. **Trẻ muốn chơi tiếp:** Vòng lặp phiêu lưu – nhiệm vụ – phần thưởng – đồng hành cùng Buddy tạo động lực nội tại, không tạo cảm giác "làm bài tập".
2. **Trẻ thực sự ghi nhớ kiến thức:** Hệ thống lặp lại ngắt quãng (Spaced Repetition) kết hợp cơ chế đánh giá Mastery chống đoán bừa đảm bảo trẻ hiểu và nhớ lâu.
3. **Kiến trúc mở rộng không phải viết lại:** Dữ liệu học tập hoàn toàn tách rời khỏi code gameplay, sẵn sàng mở rộng từ World 1 lên 6 Worlds và 600–800+ từ vựng.

---

## 3. Target Audience

### 3.1. Người dùng chính (Primary User – Người chơi)
- **Độ tuổi:** 10 tuổi (dao động thực tế 8–12 tuổi).
- **Trình độ đầu vào:** Mất gốc hoàn toàn (Absolute Beginner / Zero-to-Pre-A1). Không mặc định biết bảng chữ cái tiếng Anh, âm chữ cái hay ngữ pháp cơ bản.
- **Đặc điểm tâm lý:** Thích game phiêu lưu, thích nhân vật dễ thương nhưng **không quá trẻ con** (tránh phong cách mẫu giáo 4–5 tuổi); dễ chán khi bị chấm sai liên tục hoặc đọc toàn chữ tiếng Anh khó hiểu.
- **Ngôn ngữ hướng dẫn:** Tiếng Việt (gần gũi, động viên).
- **Ngôn ngữ mục tiêu:** Tiếng Anh (giọng chuẩn, ưu tiên `en-US`, hỗ trợ cấu trúc `en-GB`).
- **Thiết bị:** Điện thoại Android/iOS, máy tính bảng, trình duyệt Web/Desktop.

### 3.2. Người dùng phụ (Secondary User – Phụ huynh / Người hướng dẫn)
- Hỗ trợ tạo/liên kết tài khoản an toàn, theo dõi tiến độ tổng quan (sâu hơn ở giai đoạn Post-MVP).

---

## 4. Learning Objectives

### 4.1. Mục tiêu dài hạn (Toàn bộ 6 Worlds)
- Đưa trẻ từ **Mất gốc (Zero)** → **Pre-A1** → **CEFR A1** → **tiền đề A2**.
- Thành thạo 600–800 từ vựng cốt lõi theo chủ đề, ngữ âm cơ bản (Phonics & Blending), cấu trúc câu nền tảng và giao tiếp đời sống đơn giản.
- Phát triển cân bằng 4 kỹ năng:
  - **Listening:** Nhận diện âm, từ, cụm từ, câu ngắn và hội thoại đơn giản.
  - **Speaking:** Bắt chước phát âm chính xác, trả lời mẫu câu giao tiếp (chấm phát âm chi tiết ở Post-MVP).
  - **Reading:** Đọc hiểu từ, câu đơn, đoạn ngắn gắn ngữ cảnh hình ảnh.
  - **Writing:** Ghép chữ thành từ đúng chính tả, sắp xếp/hoàn thiện câu chuẩn ngữ pháp.

### 4.2. Mục tiêu học tập trong MVP (World 1 – Alphabet Island)
- Nhận diện và phân biệt **26 chữ cái** (chữ hoa & chữ thường).
- Phân biệt rạch ròi **Letter Name** (tên chữ cái) và **Letter Sound** (âm chữ cái cơ bản), nguyên âm (Vowels) & phụ âm (Consonants), ghép âm đơn giản (Simple Blending – CVC).
- Nắm vững **100–150 từ vựng neo** gắn hình ảnh và âm thanh.
- Sử dụng được **10–15 cấu trúc câu cực cơ bản** (*"I see a..."*, *"It is a..."*, *"This is..."*, *"I have..."*).

---

## 5. Game Objectives

- Xây dựng trải nghiệm **2.5D/3D Cartoon Adventure** có cốt truyện dẫn dắt rõ ràng.
- Cung cấp hệ thống nhân vật có cá tính: Main Character (Nam/Nữ), **Buddy** (rồng nhỏ đồng hành tương tác), **Professor Owl**, NPC giao nhiệm vụ và Boss thử thách.
- Tạo vòng lặp chơi liền mạch: *Khám phá → Nhận nhiệm vụ → Học & Luyện → Thử thách Mini-game → Nhận thưởng → Ôn tập → Mở khóa vùng mới*.
- Chống nhàm chán bằng đa dạng mini-game (5 loại trong MVP) sử dụng chung kho dữ liệu từ vựng.

---

## 6. Core Features

1. **Đánh giá đầu vào không áp lực (Initial Assessment):** Kiểm tra nhanh nhận biết chữ cái/từ cơ bản với lựa chọn "Chưa biết" để xếp điểm xuất phát phù hợp.
2. **Thế giới phiêu lưu tương tác (Adventure World):** Di chuyển nhân vật 3D/2.5D trên bản đồ đảo, tương tác NPC, nhặt vật phẩm/pha lê, mở khóa khu vực.
3. **Hệ thống Buddy đồng hành song ngữ:** Giới thiệu nhiệm vụ, phát âm mẫu, đặt câu hỏi gợi ý, động viên khi sai và giải thích bằng tiếng Việt dễ hiểu.
4. **Hệ thống Nhiệm vụ (Quest System):** 15–20 nhiệm vụ theo mạch truyện tại World 1.
5. **5 Mini-game học tập cốt lõi (MVP):** Word Hunt, Listening Mission, Word Builder, Sentence Builder, Reading Challenge (+ Repeat-After-Me Speaking thử nghiệm).
6. **Hệ thống Tiến trình & Phần thưởng:** Level, EXP, Gold, Stars (1–3 sao), trang bị/vật phẩm cơ bản, mở khóa khu vực.
7. **Hệ thống Ôn tập thông minh (Review System):** Nhắc ôn từ sắp quên dựa trên lịch Spaced Repetition và các lỗi sai trước đó.
8. **Hỗ trợ Offline & Đồng bộ Cloud:** Chơi được các bài đã tải khi mất mạng và tự động đồng bộ lên Supabase khi có kết nối.

---

## 7. Functional Requirements (Yêu cầu chức năng)

### FR-01: Quản lý người dùng & Khởi tạo hồ sơ
- **FR-01.1:** Hỗ trợ đăng nhập nhanh dạng Khách (Anonymous Session) hoặc Tài khoản liên kết (Email/Auth qua Supabase).
- **FR-01.2:** Cho phép chọn nhân vật chính **Nam** hoặc **Nữ** và đặt biệt danh (Nickname, không dùng tên thật bắt buộc).
- **FR-01.3:** Lưu cài đặt giọng nói/âm lượng/ngôn ngữ hướng dẫn.

### FR-02: Đánh giá đầu vào (Initial Assessment)
- **FR-02.1:** Thực hiện bài kiểm tra ngắn (8–12 câu tương tác) kiểm tra nhận diện chữ cái, âm cơ bản và 5–10 từ siêu quen thuộc.
- **FR-02.2:** Luôn có nút "Bé chưa biết" để tránh đoán bừa.
- **FR-02.3:** Gợi ý điểm bắt đầu trên Alphabet Island (ví dụ: bắt đầu từ Zone 1 chữ cái đầu tiên, hoặc mở khóa nhanh Zone 1 để luyện từ Zone 2 nếu đã thuộc bảng chữ cái).

### FR-03: Phiêu lưu & Tương tác Thế giới
- **FR-03.1:** Bản đồ World Map và màn hình phiêu lưu World 1 (Alphabet Island) với 4 phân khu (Zones).
- **FR-03.2:** Điều khiển nhân vật bằng Virtual Joystick (Mobile/Tablet) và Phím mũi tên/WASD + Chuột (Web/Desktop).
- **FR-03.3:** Tương tác NPC, bảng chỉ dẫn, rương/pha lê bằng nút tương tác ngữ cảnh.

### FR-04: Hệ thống Nhiệm vụ & Hội thoại Buddy
- **FR-04.1:** Quản lý trạng thái Quest (`locked`, `available`, `in_progress`, `completed`).
- **FR-04.2:** Buddy hiển thị thoại hướng dẫn tiếng Anh kèm giải thích tiếng Việt, đọc mẫu và phản hồi động viên khi trẻ làm sai.

### FR-05: Learning Engine & Kho dữ liệu độc lập
- **FR-05.1:** Dữ liệu từ vựng, phonics, cấu trúc câu được lưu dưới dạng JSON/DB độc lập với scene mini-game.
- **FR-05.2:** Một `word_id` có thể được truyền vào bất kỳ mini-game nào (Word Hunt, Listening, Word Builder, Sentence Builder, Reading) mà không cần tạo lại bản ghi từ vựng.
- **FR-05.3:** Tách biệt rõ dữ liệu `letter_name` và `letter_sound`.

### FR-06: Mini-games (MVP)
- **FR-06.1:** Triển khai đủ 5 mini-game MVP (`Word Hunt`, `Listening Mission`, `Word Builder`, `Sentence Builder`, `Reading Challenge`) với độ khó điều chỉnh theo năng lực người chơi.
- **FR-06.2:** Hỗ trợ chế độ `Repeat-After-Me` (nghe phát âm, ghi âm thử phát lại tại máy để tự nghe đối chiếu) trong màn học từ/câu.

### FR-07: Đánh giá Mastery & Ôn tập (Review)
- **FR-07.1:** Ghi nhận chi tiết từng `learning_attempt` (đúng/sai, số lần thử, thời gian trả lời, có dùng gợi ý không).
- **FR-07.2:** Tính điểm `vocabulary_mastery` có phạt đoán bừa; không cho tăng lên cấp độ thành thạo cao chỉ bằng chơi lặp lại tức thời.
- **FR-07.3:** Sinh danh sách ôn tập (`review_schedule`) cho những từ đến hạn hoặc hay sai.

### FR-08: Tiến trình, Phần thưởng & Túi đồ
- **FR-08.1:** Cộng EXP, Gold, Stars khi hoàn thành Quest/Mini-game dựa trên kết quả học tập thực tế.
- **FR-08.2:** Mở khóa khu vực mới, vật phẩm trang trí/huy hiệu trong Inventory và Achievements cơ bản.

### FR-09: Đa ngôn ngữ & Âm thanh
- **FR-09.1:** Giao diện chuyển đổi linh hoạt tiếng Việt (mặc định cho giải thích/menu) và tiếng Anh (nội dung học).
- **FR-09.2:** Phát âm thanh từ vựng/câu chuẩn, hiệu ứng âm thanh (SFX) và nhạc nền (BGM) có thanh điều chỉnh riêng.

### FR-10: Offline & Đồng bộ dữ liệu
- **FR-10.1:** Lưu tiến trình vào bộ nhớ cục bộ ngay lập tức sau mỗi bước hoàn thành.
- **FR-10.2:** Hàng đợi đồng bộ (Sync Outbox) gửi dữ liệu an toàn lên Supabase khi có mạng với cơ chế chống trùng lặp (idempotent).

---

## 8. Non-functional Requirements (Yêu cầu phi chức năng)

| Nhóm | Yêu cầu cụ thể |
|---|---|
| **Hiệu năng (Performance)** | Duy trì >= 30–60 FPS trên thiết bị tầm trung (Android RAM 3GB+, WebGL2 browser); thời gian chuyển màn hình < 2 giây; dung lượng tải MVP ban đầu mục tiêu <= 60 MB. |
| **Độ trễ âm thanh** | Độ trễ phát âm thanh từ vựng khi bấm nút < 150 ms (preloaded/cached local). |
| **Khả năng mở rộng** | Thêm 1 từ vựng hoặc 1 Quest mới chỉ cần cập nhật data/content pack, **không** cần sửa GDScript của mini-game. |
| **Bảo mật & Quyền riêng tư trẻ em** | Tuân thủ nguyên tắc tối thiểu hóa dữ liệu trẻ em: không lưu họ tên thật/SĐT/địa chỉ/giọng nói lên cloud ở MVP; không chứa API Secret / Service Role Key trong client; toàn bộ bảng người chơi áp dụng **Supabase Row Level Security (RLS)**. |
| **Độ tin cậy (Reliability)** | Không mất tiến trình khi rớt mạng giữa ván hoặc thoát ứng dụng đột ngột; có error handling & logging chuẩn hóa khi API lỗi. |
| **Khả năng sử dụng (Usability)** | Nút bấm tối thiểu 48x48 dp trở lên trên cảm ứng; font chữ phân biệt rõ `I`, `l`, `1` và chữ thường/hoa; không chữ quá nhỏ trên màn hình dọc điện thoại. |
| **Chất lượng dữ liệu** | Có script/công cụ kiểm tra tính hợp lệ dữ liệu (JSON schema, file audio/image tồn tại, IPA hợp lệ, không thiếu nghĩa tiếng Việt). |

---

## 9. Platform Requirements

| Nền tảng | Yêu cầu kỹ thuật |
|---|---|
| **Android** | Android 8.0 (API 26)+, kiến trúc `arm64-v8a` & `armeabi-v7a`, hỗ trợ Portrait & Landscape (ưu tiên Landscape cho Adventure, tự thích nghi Portrait cho Mini-games/Menu). |
| **iOS** | iOS 14.0+, hỗ trợ iPhone & iPad, xử lý đúng Safe Area (notch/Dynamic Island) và quyền Microphone tùy chọn. |
| **Web / Desktop** | Trình duyệt hỗ trợ WebGL 2 (Chrome, Edge, Safari 15+, Firefox), export Single-threaded WASM để tương thích hosting phổ thông; Desktop (Windows/macOS) hỗ trợ chuột + bàn phím đầy đủ. |

---

## 10. User Stories

- **US-01 (Trẻ mới vào game):** *Là một học sinh 10 tuổi mất gốc*, em muốn vào game nhanh, chọn nhân vật nam/nữ và làm bài kiểm tra đầu vào ngắn có nút "Em chưa biết", để em không thấy sợ khi bắt đầu.
- **US-02 (Khám phá thế giới):** *Là người chơi*, em muốn điều khiển nhân vật đi lại trên Đảo Chữ Cái, nói chuyện với NPC và cùng Buddy mở khóa vùng đất mới, để thấy mình đang chơi game phiêu lưu thật sự.
- **US-03 (Học chữ & âm đúng):** *Là người mới học*, em muốn nghe phân biệt rõ tên chữ cái và âm của chữ cái kèm hình minh họa (ví dụ A – `/æ/` – *apple*), để em đọc ghép vần được từ đơn giản.
- **US-04 (Động viên khi sai):** *Là trẻ hay sợ sai*, khi em chọn nhầm, Buddy giải thích nhẹ nhàng bằng tiếng Việt và gợi ý thay vì phạt nặng hay chê bai, để em dám thử lại.
- **US-05 (Chơi đa dạng mini-game):** *Là người chơi*, em muốn gặp lại từ "apple" khi đi săn chữ, khi nghe nhiệm vụ, khi ghép vần và khi ghép câu ngắn, để em nhớ từ lâu mà không bị chán.
- **US-06 (Chơi không cần mạng):** *Là học sinh dùng tablet ở nhà không có Wi-Fi ổn định*, em vẫn chơi tiếp được các màn đã tải và tiến trình được lưu lại khi có mạng.
- **US-07 (Chống học vẹt/đoán mò):** *Là hệ thống giáo dục*, hệ thống phải nhận biết khi trẻ bấm bừa để chỉ trao sao/mastery xứng đáng và đưa từ đó vào danh sách ôn tập lại.

---

## 11. MVP Scope (Phạm vi Bắt buộc trong MVP)

| Hạng mục | Phạm vi MVP (Chốt cứng – Không tự ý mở rộng) |
|---|---|
| **Thế giới** | **1 World duy nhất:** World 1 – Alphabet Island (chia 4 khu vực nhỏ). |
| **Nhân vật** | 1 Main Character (chọn Nam/Nữ), 1 Buddy (Rồng nhỏ), Professor Owl, 4–6 NPCs trên Alphabet Island, 1 Final Gate Guardian (tổng hợp kiến thức World 1). |
| **Nhiệm vụ** | **15–20 Quests** (mục tiêu chuẩn: 18 Quests theo lộ trình A–Z + phonics + từ & câu cơ bản). |
| **Nội dung học** | **26 chữ cái** (letter name + letter sound + basic phonics/blending), **100–150 từ vựng neo**, **10–15 cấu trúc câu cơ bản**. |
| **Mini-games** | **5 mini-game bắt buộc:** 1. Word Hunt, 2. Listening Mission, 3. Word Builder, 4. Sentence Builder, 5. Reading Challenge (+ Repeat-After-Me & thu âm thử không chấm AI). |
| **Tiến trình & Thưởng** | Player Level, EXP, Gold, Stars, 1 Magic Crystal lớn của World 1 (thu thập các mảnh/tinh thể nhỏ qua các khu vực), Inventory cơ bản, Achievements cơ bản, Review System (Spaced Repetition cơ bản). |
| **Màn hình UI** | Các màn hình từ #1 đến #17 trong `UI_UX_SPEC.md` (trừ Parent Dashboard đầy đủ). |
| **Giọng phát âm** | Đầy đủ **1 giọng chuẩn (`en-US`)**; cấu trúc dữ liệu sẵn sàng cho `en-GB`. |

---

## 12. Future Development Scope & Out-of-Scope

### 12.1. Tính năng phát triển sau MVP (Post-MVP Roadmap)
- **Worlds 2–6:** Vocabulary Forest, Sentence Kingdom, Listening Ocean, Speaking City, Challenge Kingdom.
- **Mở rộng kho nội dung:** Lên 600–800+ từ vựng, đầy đủ 2 bộ audio `en-US` và `en-GB`.
- **Speaking Challenge nâng cao:** Tích hợp nhận diện giọng nói / chấm phát âm từng âm vị (ASR / Pronunciation Scoring) qua backend service/AI an toàn.
- **Boss Battle chuyên biệt:** Mini-game Boss Battle nhiều pha độc lập (ví dụ trận chiến cuối tại Challenge Kingdom chống The Silent Shadow).
- **Parent Dashboard (#18):** Báo cáo chi tiết theo 4 kỹ năng, thời gian học, từ hay sai, thiết lập giới hạn giờ chơi (`parental_settings`).
- **Tùy biến sâu nhân vật & Cửa hàng trang phục:** Dùng Gold mua trang phục/phụ kiện cho Main Character & Buddy.

### 12.2. Tính năng CHƯA NÊN triển khai (Explicitly Excluded)
- Chat tự do giữa người chơi hoặc mạng xã hội / bảng xếp hạng công khai tên thật (rủi ro an toàn trẻ em).
- Chatbot AI hội thoại mở không kiểm soát nội dung cho trẻ 10 tuổi ở giai đoạn đầu.
- PvP trực tiếp thời gian thực (tăng phức tạp server và áp lực cạnh tranh không cần thiết với trẻ mất gốc).
- Giao dịch tiền thật (IAP / Loot box ngẫu nhiên) trong giai đoạn xây dựng giá trị học tập cốt lõi.

---

## 13. Acceptance Criteria (Tiêu chí nghiệm thu MVP)

1. **Khởi động & Onboarding:** Người chơi mới hoàn tất chọn nhân vật và Initial Assessment trong < 5 phút, hiểu rõ cốt truyện và vai trò của Buddy bằng tiếng Việt.
2. **Trải nghiệm phiêu lưu:** Di chuyển mượt trên cả Mobile (touch) và Desktop/Web (keyboard/mouse), nhận và hoàn thành trọn vẹn ít nhất 15 Quests trên Alphabet Island.
3. **Tính độc lập dữ liệu:** Thêm 5 từ vựng mẫu vào JSON + audio/image tương ứng thì cả 5 mini-game đều tự động dùng được các từ đó mà không sửa code mini-game.
4. **Hiệu quả học tập & Anti-Guess:** Trẻ đoán sai liên tục không được cấp Mastery Level cao; từ sai xuất hiện lại trong hàng đợi Review; hoàn thành đủ 4 kỹ năng ở mức Pre-A1 cho 26 chữ cái & 100–150 từ.
5. **Offline & Sync:** Tắt mạng hoàn thành 1 Quest → mở lại app vẫn còn dữ liệu → bật mạng tự đồng bộ lên Supabase không bị trùng lặp bản ghi.
6. **Đa nền tảng & An toàn:** Chạy ổn định trên Android, iOS và WebGL2 browser; kiểm tra bảo mật xác nhận không lộ secret key trong build và RLS chặn đọc/ghi chéo dữ liệu giữa các user.
