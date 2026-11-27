# UI/UX DESIGN SPECIFICATION
# PROJECT: ENGLISH ADVENTURE

---

## 1. HỆ THỐNG THIẾT KẾ (DESIGN SYSTEM)

### 1.1. Định hướng thẩm mỹ (Visual Direction)
- **Phong cách:** **Colorful 3D Cartoon Adventure** — tươi sáng, giàu chiều sâu, thân thiện nhưng **hiện đại và trưởng thành hơn game mầm non** (phù hợp tâm lý trẻ 10 tuổi thích phiêu lưu, khám phá).
- **Bảng màu chủ đạo:**
  - *Primary Sky Blue:* `#2EA8FF` (nút hành động chính, thanh tiến trình).
  - *Adventure Gold:* `#FFB800` (EXP, Stars, nút Hoàn thành / Bắt đầu).
  - *Magic Emerald:* `#22C55E` (đáp án đúng, trạng thái hoàn thành).
  - *Warm Coral (Soft Error):* `#FB7185` (báo sai dịu mắt — **tránh dùng đỏ gắt gây tâm lý sợ sai**).
  - *Deep Twilight Navy:* `#1E293B` (chữ chính trên nền sáng giúp độ tương phản cao >= 4.5:1).
  - *Cream Card Surface:* `#FFFDF7` (khung thoại Buddy, thẻ từ vựng).
- **Typography:**
  - Font UI & Tiếng Việt: **Nunito / Quicksand Bold & SemiBold** (bo tròn thân thiện, hiển thị đầy đủ dấu tiếng Việt).
  - Font Từ vựng & IPA: **Andika / Noto Sans** (phân biệt cực rõ `I` hoa, `l` thường, `1` số và ký tự IPA `/æ/`, `/θ/`, `/ʃ/`).
- **Kích thước tương tác (Ergonomics cho trẻ 10 tuổi):**
  - Vùng chạm tối thiểu: `56 x 56 dp` cho nút chính; khoảng cách giữa các đáp án tối thiểu `16 dp` để tránh bấm nhầm.

### 1.2. Chiến lược Responsive (4 Form Factors)
> **Nguyên tắc:** Không phóng to/thu nhỏ cứng (blind scaling) giao diện điện thoại lên Desktop/Tablet. Sử dụng **Godot Anchor + Container Adaptive Layout (`ViewportBreakpointManager`)**:

| Breakpoint | Tỷ lệ / Kích thước | Bố cục thích nghi |
|---|---|---|
| **Mobile Portrait** | `< 768px` rộng, dọc | Menu xếp dọc 1 cột; Mini-game chia 2 vùng trên (Đề/Hình) – dưới (Đáp án lưới 2x2); Adventure hiển thị Virtual Joystick trái + nút tương tác phải. |
| **Mobile Landscape** | Cao `< 520px`, ngang | HUD gọn tối đa vào 4 góc; Mini-game chia 2 cột trái (Hình/Audio) – phải (Đáp án); Buddy dock nhỏ gọn góc dưới trái. |
| **Tablet** | `768px – 1199px` | Grid 2–3 cột cho Quest/Inventory/Dashboard; kích thước card tối đa giới hạn (`max_width`), giữ khoảng thở thoáng. |
| **Desktop / Web** | `>= 1200px` | Hiển thị Side-panel thông tin nhiệm vụ/từ vựng ngay bên cạnh thay vì bắt mở popup nhiều lớp; hỗ trợ **Keyboard Shortcuts** (`1-4` chọn đáp án, `Space` nghe lại audio, `WASD`/Mũi tên di chuyển, `E` tương tác) + Hover states cho chuột. |

---

## 2. ĐẶC TẢ CHI TIẾT 18 MÀN HÌNH

### Màn hình 01: Splash Screen
- **Mục đích:** Khởi tạo Core systems, kiểm tra session local, nạp font/audio engine, khơi gợi không khí thế giới phép thuật.
- **Layout:** Logo *ENGLISH ADVENTURE* ở giữa, hình nền đảo bay động nhẹ, thanh tiến trình tải ở dưới.
- **UI Components:** Game Logo, Animated Loading Bar, Version tag, Nút **"Chạm để bắt đầu"** (bắt buộc trên Web để kích hoạt Web AudioContext).
- **Navigation:** Tự động sang `Login Screen` (nếu chưa có profile) hoặc `Home Screen` (nếu đã có profile local).
- **User Interactions:** Chạm/Click để vào game (mở khóa audio trình duyệt).
- **Responsive:** Logo & bar căn giữa theo Safe Area trên mọi tỷ lệ.
- **Loading / Empty / Error States:**
  - *Loading:* Thanh tiến trình mượt kèm mẹo vui của Buddy.
  - *Error (lỗi hỏng file local):* Hiện hộp thoại sửa dữ liệu cache + nút "Thử lại".

### Màn hình 02: Login Screen
- **Mục đích:** Đăng nhập nhanh không rào cản cho trẻ hoặc đăng nhập tài khoản phụ huynh.
- **Layout:** Thẻ trung tâm nổi trên nền phong cảnh Alphabet Island + Buddy vẫy tay bên cạnh.
- **UI Components:** Nút lớn **"Chơi ngay (Khách)"** (nổi bật nhất), nút **"Đăng nhập tài khoản Phụ huynh"**, ô Email/Mật khẩu (khi mở rộng tab phụ huynh), nút chuyển ngôn ngữ UI (`VI`/`EN`).
- **Navigation:** → `Character Selection` (nếu tài khoản mới chưa có profile) hoặc → `Home Screen`.
- **User Interactions:** Bấm Chơi ngay tạo anonymous session offline-ready trong < 2 giây.
- **Responsive:** Thẻ giữa max-width `460px` trên Desktop/Tablet; full-width có padding `24px` trên Mobile Portrait.
- **Loading / Empty / Error States:**
  - *Loading:* Spinner trên nút, vô hiệu hóa double-tap.
  - *Error (sai mật khẩu / mất mạng khi đăng nhập email):* Thông báo tiếng Việt rõ ràng; nếu mất mạng vẫn gợi ý "Chơi chế độ Ngoại tuyến".

### Màn hình 03: Character Selection
- **Mục đích:** Tạo sự gắn bó nhập vai: chọn nhân vật Nam/Nữ và đặt biệt danh.
- **Layout:** Sân khấu 3D/2.5D ở giữa hiển thị 2 nhân vật **Explorer Boy** & **Explorer Girl** đứng cạnh **Buddy**, bên dưới là ô nhập biệt danh và nút xác nhận.
- **UI Components:** Card chọn Nam / Nữ (nhấn vào nhân vật nhảy mừng), ô nhập `Nickname` (có nút **"Gợi ý tên ngầu"**), cảnh báo thân thiện không nhập tên thật/SĐT, nút **"Bắt đầu phiêu lưu!"**.
- **Navigation:** → `Initial Assessment`.
- **User Interactions:** Chạm chọn nhân vật xem animation thử; nhập nickname 2–24 ký tự.
- **Responsive:** 2 nhân vật xếp cạnh nhau trên Landscape/Desktop, xếp thẻ lớn chọn tab trên màn hình dọc rất hẹp.
- **Loading / Empty / Error States:**
  - *Empty:* Nút xác nhận mờ nếu chưa nhập Nickname (kèm gợi ý tên sẵn để trẻ bấm 1 chạm).
  - *Error:* Báo lỗi ngắn nếu nickname chứa ký tự đặc biệt không hợp lệ.

### Màn hình 04: Initial Assessment (Đánh giá đầu vào)
- **Mục đích:** Đo nhanh trình độ thực tế (mất gốc hoàn toàn hay đã biết A–Z) mà không tạo áp lực thi cử.
- **Layout:** Cắt cảnh ngắn của **Professor Owl** & **Buddy**, hiển thị 1 câu hỏi gọn gàng ở giữa, nút loa to và nút **"Bé chưa biết"** ở góc dễ bấm.
- **UI Components:** Thanh tiến độ 1/10 (không đếm ngược thời gian!), nút Loa nghe phát âm, 3–4 thẻ đáp án lớn, nút **"Bé chưa biết câu này"**, hộp thoại động viên của Buddy.
- **Navigation:** Hoàn tất → Màn hình tóm tắt lộ trình gợi ý → `Home Screen` / `World 1`.
- **User Interactions:** Chọn đáp án hoặc chọn "Bé chưa biết" để chuyển nhanh.
- **Responsive:** Portrait xếp 2x2; Landscape/Desktop xếp 1 hàng 3–4 thẻ ngang.
- **Loading / Empty / Error States:**
  - *Loading:* Chuyển câu mượt 200ms.
  - *Error (mất audio):* Tự hiển thị chữ gợi ý phụ để không kẹt bài kiểm tra.

### Màn hình 05: Home Screen (Trại Căn Cứ Phiêu Lưu)
- **Mục đích:** Hub trung tâm dẫn tới phiêu lưu, ôn tập hàng ngày, túi đồ và hồ sơ.
- **Layout:** Cảnh nền 3D/2.5D nhân vật của bé đứng cạnh Buddy bên đống lửa trại/bản đồ. Trên cùng là Status Bar; ở giữa/phải là các nút điều hướng chính.
- **UI Components:**
  - Header: Avatar + Nickname + Level + EXP bar + Gold + Stars + Icon trạng thái Online/Offline.
  - CTA chính cực lớn: **"Tiếp tục Phiêu Lưu"** (vào thẳng Alphabet Island).
  - Nút phụ nổi bật khi có từ đến hạn: **"Ôn tập cùng Buddy (N từ)"**.
  - Thanh menu nhanh: Bản đồ Thế giới, Nhiệm vụ, Túi đồ, Thành tích, Bảng học tập, Cài đặt.
- **Navigation:** Nhánh chính đi tới mọi màn hình (#6, #8, #13, #14, #15, #16, #17) hoặc vào thẳng `Adventure World`.
- **Responsive:** Mobile Portrait dùng Bottom Navigation Bar; Desktop/Landscape dùng Floating Side Dock.
- **Loading / Empty / Error States:**
  - *Empty (chưa có từ cần ôn):* Thẻ Ôn tập đổi thành *"Bé đã ôn hết từ hôm nay! Tuyệt vời!"*.

### Màn hình 06: World Map (Bản đồ 6 Thế Giới)
- **Mục đích:** Cho trẻ thấy bức tranh toàn bộ hành trình 6 Worlds và mục tiêu dài hạn.
- **Layout:** Bản đồ cuộn ngang/dọc minh họa 6 hòn đảo/vương quốc từ *Alphabet Island* đến *Challenge Kingdom*.
- **UI Components:** 6 Node Thế giới (World 1 sáng rực với số Sao/Crystal đạt được; Worlds 2–6 phủ sương *The Silent Shadow* kèm nhãn **"Sắp ra mắt – Post-MVP"**), nút quay lại Home.
- **Navigation:** Chọn World 1 → `World Detail (#7)` hoặc vào thẳng bản đồ phiêu lưu.
- **Responsive:** Cuộn ngang mượt trên Desktop/Landscape; cuộn dọc dạng hành trình leo đảo trên Portrait.
- **Loading / Empty / Error States:** Chạm vào World chưa mở hiện tooltip giải thích cần Crystal của World trước (hoặc thông báo phiên bản tiếp theo).

### Màn hình 07: World Detail (Chi tiết Alphabet Island)
- **Mục đích:** Xem tiến độ 4 Zones trên World 1, số Magic Crystal Shards, danh sách từ vựng thuộc đảo và nút dịch chuyển nhanh tới Zone đã mở.
- **Layout:** Banner đảo + thanh tiến độ Crystal Shards (0/4) + danh sách 4 Zones.
- **UI Components:** Zone Cards (`Echo Beach`, `Letter Woods`, `Whisper Ruins`, `Crystal Lighthouse`), số sao mỗi Zone, nút **"Khám phá ngay"**.
- **Navigation:** → `Adventure Scene` (tại Zone chọn) hoặc → `Quest Selection (#8)`.
- **Responsive:** 2 cột (2x2) trên Tablet/Desktop; danh sách dọc trên Mobile Portrait.
- **Loading / Empty / Error States:** Zone khóa hiển thị điều kiện sao cần đạt rõ ràng.

### Màn hình 08: Quest Selection (Sổ Tay Nhiệm Vụ)
- **Mục đích:** Theo dõi các nhiệm vụ đã xong, đang làm và sắp mở trên đảo.
- **Layout:** Giao diện dạng quyển sổ thám hiểm chia 2 tab: *Nhiệm vụ chính* và *Nhiệm vụ ôn tập*.
- **UI Components:** Danh sách 18 Quests kèm biểu tượng trạng thái (`Locked`, `Available`, `In Progress`, `Completed + 1..3 Stars`), phần thưởng dự kiến (EXP/Gold), nút **"Đi tới NPC / Chơi ngay"**.
- **Navigation:** → `Quest Introduction (#9)` hoặc dịch chuyển tới vị trí NPC.
- **Responsive:** Master-Detail 2 cột (Danh sách trái – Chi tiết phải) trên Desktop/Tablet; danh sách mở rộng accordion/trang chi tiết trên Mobile.
- **Loading / Empty / Error States:** *Empty:* Thông báo khi đã hoàn thành toàn bộ nhiệm vụ hiện có.

### Màn hình 09: Quest Introduction
- **Mục đích:** Dẫn nhập cốt truyện, giới thiệu từ vựng/chữ cái mới cùng Buddy trước khi vào thử thách mini-game.
- **Layout:** Nhân vật NPC + Buddy ở nửa trên; hộp thoại tiếng Việt ngắn gọn + thẻ xem trước từ/âm thanh (Guided Discovery) ở giữa; nút **"Sẵn sàng!"** ở dưới.
- **UI Components:** Khung thoại Buddy (có nút đọc tiếng Việt tùy chọn), thẻ Flash-Discovery có nút Loa đọc chuẩn `en-US` + nút Thu âm thử `Repeat-After-Me`, nút **"Bắt đầu nhiệm vụ"**.
- **Navigation:** → `Gameplay Screen (#10)`.
- **Responsive:** Thẻ từ vựng cuộn ngang trên Mobile; hiển thị hàng ngang đầy đủ trên Tablet/Desktop.
- **Loading / Empty / Error States:** Loading nhẹ khi preload các file audio của nhiệm vụ.

### Màn hình 10: Gameplay Screen (Màn hình Chơi Phiêu Lưu & Mini-game)
- **Mục đích:** Màn hình chơi chính cho cả *Khám phá bản đồ 2.5D/3D* và *5 Mini-games*.
- **Layout:**
  - *Chế độ Adventure:* Khung nhìn 3D/2.5D toàn màn hình; góc trên trái: Mini-profile + Mục tiêu Quest hiện tại; góc dưới trái: Virtual Joystick (chỉ hiện trên cảm ứng); góc dưới phải: Nút Tương tác ngữ cảnh (`Nói chuyện` / `Mở rương`) & Nút gọi `Buddy Gợi ý`.
  - *Chế độ Mini-game:* Thanh tiến độ câu ở trên cùng + Nút Tạm dừng + Nút Gọi Buddy; Vùng tương tác mini-game ở trung tâm (tối thiểu 75% diện tích màn hình).
- **Navigation:** Hoàn thành → `Learning Feedback (#11)` / `Reward Screen (#12)`; Tạm dừng → Popup Resume / Settings / Thoát về World.
- **User Interactions:** Kéo-thả chữ/từ, chạm đáp án, bấm loa nghe lại (1.0x / 0.85x), điều khiển nhân vật.
- **Responsive:** Bố cục Mini-game tự chuyển giữa Stacked (Portrait) và Split 2-cột (Landscape/Desktop); hỗ trợ bàn phím số & Enter trên Desktop.
- **Loading / Empty / Error States:**
  - *Loading:* Overlay chuyển cảnh phép thuật < 1.5s.
  - *Error (lỗi audio/mic):* Hiện phụ đề chữ / fallback tự kiểm tra không chặn tiến trình.

### Màn hình 11: Learning Feedback (Phản hồi học tập tức thì & Tổng kết kiến thức)
- **Mục đích:** Giúp trẻ hiểu ngay tại sao đúng/sai và củng cố ghi nhớ sau mini-game.
- **Layout:** Popup / Overlay mượt ngay trong hoặc cuối ván chơi với biểu cảm của Buddy.
- **UI Components:**
  - *Khi sai:* Giải thích ngắn bằng tiếng Việt, nút nghe so sánh âm đúng vs âm chọn nhầm, nút **"Hiểu rồi, thử tiếp!"**.
  - *Cuối ván:* Danh sách các từ đã học trong phiên (từ nào đúng ngay lần đầu có tick xanh, từ nào cần ôn lại có tag vàng + nút loa nghe lại).
- **Navigation:** → `Reward Screen (#12)` hoặc quay lại câu tiếp theo.
- **Responsive:** Modal tối đa `680px` trên Desktop; bottom-sheet hoặc full card trên Mobile.

### Màn hình 12: Reward Screen (Màn hình Trao Thưởng)
- **Mục đích:** Tạo cảm xúc chiến thắng bùng nổ khi hoàn thành Quest/Mini-game.
- **Layout:** Buddy & nhân vật chính ăn mừng ở giữa; 1–3 Ngôi sao bay vào vị trí; bảng phần thưởng EXP, Gold, Crystal Shard (nếu có).
- **UI Components:** Hiệu ứng đếm số EXP chạy lên thanh Level, nút **"Nhận & Tiếp tục"**, nút **"Chơi lại để đạt 3 sao"** (nếu < 3 sao).
- **Navigation:** → Trở về `Adventure World` hoặc mở chuỗi Quest kế tiếp.
- **Responsive:** Căn giữa cân đối trên cả 4 kích thước màn hình.

### Màn hình 13: Inventory (Túi Đồ & Kho Pha Lê)
- **Mục đích:** Xem vật phẩm thu thập được (Crystal Shards, Magic Crystals, Huy hiệu, Bình gợi ý Buddy, Trang phục).
- **Layout:** Tabs phân loại bên trên/trái + Lưới ô vật phẩm (Inventory Grid) + Panel xem chi tiết vật phẩm.
- **UI Components:** Ô vật phẩm có icon + số lượng, nút **"Trang bị / Sử dụng"** (nếu áp dụng).
- **Navigation:** Mở từ Home hoặc HUD Adventure.
- **Responsive:** Lưới 3 cột (Portrait), 5–6 cột + Panel chi tiết bên phải (Tablet/Desktop).
- **Empty State:** Hiển thị minh họa chiếc túi trống cùng gợi ý *"Hoàn thành nhiệm vụ trên Đảo Chữ Cái để tìm vật phẩm phép thuật nhé!"*.

### Màn hình 14: Achievement (Bảng Thành Tựu)
- **Mục đích:** Khuyến khích thói quen học đúng (không đoán bừa, ôn tập đều, chinh phục kỹ năng).
- **Layout:** Danh sách thẻ thành tựu chia nhóm *Đã đạt* và *Chưa đạt*.
- **UI Components:** Icon huy hiệu, tên thành tựu, thanh tiến độ (VD: `7/10 câu đúng ngay lần đầu`), phần thưởng Gold/EXP.
- **Responsive:** 1 cột trên Mobile Portrait; 2–3 cột trên Tablet/Desktop.
- **Empty State:** Luôn hiển thị danh sách mục tiêu sắp đạt để tạo động lực.

### Màn hình 15: Player Profile (Hồ sơ Nhà Thám Hiểm)
- **Mục đích:** Xem thông tin nhân vật, chỉnh sửa Nickname/Avatar, liên kết tài khoản phụ huynh.
- **Layout:** Khung nhân vật 3D/2D bên trái/trên + thẻ thông số tổng hợp (Level, tổng ngày học streak, tổng sao, số từ đã làm quen).
- **UI Components:** Nút đổi nhân vật Nam/Nữ, nút đổi Nickname, trạng thái tài khoản (`Tài khoản Khách` / `Đã liên kết Email Phụ huynh`), nút **"Sao lưu / Liên kết tài khoản"**.
- **Responsive:** Dọc trên Mobile; 2 cột cân đối trên Tablet/Desktop.

### Màn hình 16: Learning Dashboard (Sổ Tay Tiến Bộ Học Tập)
- **Mục đích:** Giúp trẻ (và phụ huynh xem cùng con) thấy rõ sự tiến bộ của **4 kỹ năng** và kho **Từ vựng đã mở khóa**.
- **Layout:**
  - Phần trên: Biểu đồ 4 kỹ năng (`Listening`, `Speaking`, `Reading`, `Writing`) + Số từ theo bậc Mastery (Mới học / Đang luyện / Thành thạo).
  - Phần dưới: **Từ điển Phiêu lưu (Wordbook)** — tìm kiếm/lọc các từ đã gặp để bấm nghe lại phát âm và xem nghĩa.
- **UI Components:** 4 thanh tiến độ kỹ năng, bộ lọc World/Mastery, thẻ từ vựng có loa phát âm, nút **"Ôn tập các từ yếu ngay"**.
- **Responsive:** Grid 2x2 cho 4 kỹ năng trên mọi thiết bị; Wordbook 2–4 cột tùy chiều rộng.
- **Empty State:** Khi mới vào game chưa học từ nào: hiện *"Hãy hoàn thành Nhiệm vụ 1 để mở khóa trang đầu tiên của Từ điển Phiêu lưu!"*.

### Màn hình 17: Settings (Cài đặt)
- **Mục đích:** Tùy chỉnh âm thanh, giọng đọc, ngôn ngữ giao diện và kiểm tra đồng bộ.
- **Layout:** Danh sách thẻ cài đặt nhóm rõ ràng.
- **UI Components:** Thanh trượt `Nhạc nền (BGM)`, `Hiệu ứng (SFX)`, `Giọng đọc tiếng Anh`, `Giọng Buddy (VI)`; Công tắc `Ngôn ngữ giao diện (Tiếng Việt / English)`; Chọn giọng đọc (`en-US` / `en-GB (tự chuyển US nếu thiếu)`); Nút **"Đồng bộ dữ liệu ngay"** + thời gian đồng bộ cuối; Nút xem Chính sách quyền riêng tư trẻ em.
- **Responsive:** Card căn giữa max-width `640px` trên Desktop; full-width trên Mobile.

### Màn hình 18: Parent Dashboard `[Future Phase – Post-MVP]`
- **Mục đích:** Cổng dành riêng cho phụ huynh (bảo vệ bằng PIN/cổng toán học đơn giản) để xem báo cáo học tập chi tiết, lỗi hay gặp và đặt giới hạn thời gian chơi/ngày (`parental_settings`).
- **Layout (Định hướng thiết kế sẵn):** Bảo vệ bằng lớp xác nhận Phụ huynh → Bảng tổng quan thời lượng học theo tuần, biểu đồ tiến bộ 4 kỹ năng, danh sách top 10 từ con hay nhầm, công tắc bật/tắt micro và giới hạn phút chơi.
- **Trạng thái trong MVP:** Chưa triển khai màn hình đầy đủ ở MVP; bảng `parental_settings` đã có sẵn trong Database Schema để mở rộng mượt ở Post-MVP.

---

## 3. CẬP NHẬT TRIỂN KHAI THỰC TẾ (PROMPT 03 – BUILD 3D UI/UX & GAME EXPERIENCE SYSTEM)

Các hệ thống và màn hình UI/UX 3D đã được triển khai thực tế trong Godot 4.3 (`scripts/ui/`, `scenes/ui/`, `scripts/visual3d/`, `scripts/core/`, `scripts/audio/`):
- **Design System (`UIDesignSystem`) & `UIManager`:** Áp dụng Theme toàn cục (`PRIMARY`, `SECONDARY`, `BACKGROUND`, `SURFACE`, `SUCCESS`, `WARNING`, `ERROR`, `LOCKED`, `REWARD`, `CRYSTAL`, `MAGIC`), hệ thống chữ 8 cấp (`FONT_MAIN_TITLE`..`FONT_CAPTION`), 8 biến thể nút dùng chung 5 trạng thái, Notification Stack không chặn thao tác, `ConfirmationDialog`, `LoadingIndicator`, `Tooltip`, `SettingsModal`.
- **Nền 3D & Camera góc nhìn thứ ba:** `SplashScreen` (`main_entry.tscn`), `MainMenu` (`main_menu.tscn`), `CharacterSelection` (`character_selection.tscn` xoay 360°), `WorldIntroduction` (`world_introduction.tscn`) và `WorldMap` (`world_map.tscn` sa bàn 3D Isometric) đều tích hợp `SubViewport` `own_world_3d = true`. Trong gameplay, `PlayerController` điều khiển nhân vật 3D với `SpringArm3D` tránh xuyên vật thể, hỗ trợ `TouchCameraPad` vuốt xoay camera bên phải trên mobile và chỉnh `camera_sensitivity` / `graphics_quality` (`low`/`medium`/`high`) trong Settings.
- **Các màn hình In-game đã triển khai & kết nối gameplay thực:** `AdventureHUD` (`adventure_hud.tscn`), `DialogueBoxUI` (`dialogue_box_ui.gd`), Quest Log & Quest Intro/Completed (`QuestCardWidget`, `RewardDisplay`), Inventory UI (`BagModal`), Settings UI (`SettingsModalUI`), Pause Menu (`PauseMenuUI`).
- **Phạm vi giữ nguyên chờ Prompt 04+:** `Login Screen` (Account/Supabase Auth), `Initial Assessment`, `Learning Feedback`, `Achievement` đầy đủ, `Learning Dashboard`, và `Parent Dashboard` chưa triển khai ở Prompt 03. Xem chi tiết tại `docs/3D_VISUAL_DIRECTION.md`, `docs/3D_PERFORMANCE.md`, `docs/ASSET_PIPELINE.md`, `docs/UI_DESIGN_SYSTEM.md`, `docs/UI_COMPONENTS.md`, `docs/SCREEN_FLOW.md`, `docs/RESPONSIVE_UI.md`, `docs/ACCESSIBILITY.md`, và `docs/UI_TEST_REPORT.md`.

---

## 4. CẬP NHẬT TRIỂN KHAI THỰC TẾ (PROMPT 05 – MINI-GAME OVERLAY UI)

- **`MiniGameUI` (`scenes/minigames/minigame_host_modal.tscn` + `scripts/minigames/ui/minigame_ui.gd`):** Lớp phủ 2D Fantasy Cartoon (`CanvasLayer` layer 25, `PROCESS_MODE_ALWAYS`) chạy trên nền thế giới 3D đang tạm dừng, bao gồm:
  - **Arcade Launcher:** Mở từ nút **Trò chơi [G]** trên `BottomDock` hoặc từ `LearningHubModal`, hiển thị 8 mini-game khả dụng + 8 template mở rộng.
  - **Quy trình 8 bước thống nhất:** Intro → Learning Objective → Instructions → Gameplay (8 controller riêng biệt) → Immediate Feedback (kèm đáp án, nghĩa tiếng Việt, giải thích, ví dụ, nút Nghe lại & Thử lại) → Result Summary (Sao + Learning Score vs Game Score) → Reward → Return to Adventure (trả lại đúng vị trí 3D trước khi vào mini-game).

---

## 5. CẬP NHẬT TRIỂN KHAI THỰC TẾ (PROMPT 07 – AUDIO SETTINGS & SPEAKING PRACTICE UI)

- **Settings Modal (`SettingsModalUI`):** Bổ sung thanh trượt `Master Volume`, `Giọng nói NPC`, `Âm thanh Học tập` (giữ mức sàn an toàn `15%`), `Tốc độ đọc tiếng Anh` (`0.65x–1.15x`), lựa chọn phương ngữ (`English – US` / `English – UK`), và nút `Mặc định âm thanh`.
- **Speaking Practice UI (`SpeakingPracticePanel`):** Giao diện 3D Fantasy Cartoon dùng chung cho `GameSpeakingHero` và `LearningHubModal`, gồm `Nghe mẫu`, `Nghe chậm`, `Bật Micro`, `Ghi âm / Tạm dừng / Dừng`, thanh thời lượng + mức tín hiệu, `Nghe lại`, `Ghi lại`, `Hủy bản ghi`, `Gửi đánh giá phát âm` (chỉ gửi khi bấm xác nhận) và hoàn thành tự luyện không chặn tiến trình.

