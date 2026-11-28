# LỘ TRÌNH HỌC PRE-A1 (BEGINNER FOUNDATION)
# PROJECT: ENGLISH ADVENTURE

**Đối tượng:** Trẻ ~10 tuổi chưa có nền tảng hoặc mất gốc tiếng Anh.  
**Mục tiêu tham chiếu:** Định hướng tham chiếu tương đương cấp độ làm quen trước A1 (Pre-A1). Đây là thước đo thiết kế nội dung trong game, **không phải chứng nhận CEFR chính thức**.  
**Giọng mặc định:** `en-US` (hỗ trợ chuyển `en-GB`). **Ngôn ngữ giải thích:** Tiếng Việt.

---

## 1. Mục tiêu đầu ra Pre-A1
- Nhận diện đủ 26 chữ cái hoa/thường (`A–Z` / `a–z`).
- Phân biệt rõ **Tên chữ cái (Letter Name)** và **Âm chữ cái (Letter Sound)**.
- Nhận diện, nghe hiểu và phát âm các từ đơn gần gũi thông qua hình ảnh trực quan.
- Hiểu và sử dụng cụm từ thông dụng và mẫu câu ngắn 3–6 từ.
- Làm quen hội thoại ngắn trong lớp học, chào hỏi, hỏi tên, hỏi màu sắc, số lượng và sở thích.
- Đọc hiểu đoạn ngắn 1–3 câu và viết từ/câu ngắn có hướng dẫn.

---

## 2. Cấu trúc 20 chủ đề Pre-A1 & Trạng thái triển khai (Gói P9)

| STT | Chủ đề | Trong dữ liệu (`topic`) | Số từ đã triển khai | Số cụm từ | Bài học / Hoạt động |
|---:|---|---|---:|---:|---|
| 1 | Alphabet – Bảng chữ cái | `alphabet_a_z.json` | 26 chữ cái + 26 từ neo | — | `lesson_01_00_intro`, `lesson_01_01_abc`, `lesson_01_02_alphabet_all` |
| 2 | Numbers – Số đếm (1–10) | `numbers` | 10 (`one`..`ten`) | 2 | `lesson_02_02_colors_numbers_family`, `lesson_06_01_shapes_numbers` |
| 3 | Colors – Màu sắc | `colors` | 9 (`red`, `blue`, `green`, `yellow`, `pink`, `black`, `white`, `purple`, `brown` + tag `orange`) | 3 | `lesson_02_02_colors_numbers_family` |
| 4 | Shapes – Hình dạng | `shapes` | 4 (`circle`, `square`, `triangle`, `star`) | — | `lesson_06_01_shapes_numbers` |
| 5 | Family – Gia đình | `family` | 7 (`mom`, `dad`, `sister`, `brother`, `baby`, `grandma`, `grandpa` + `queen`) | 1 | `lesson_02_02_colors_numbers_family` |
| 6 | Body Parts – Bộ phận cơ thể | `body_parts` | 7 (`head`, `eye`, `ear`, `nose`, `mouth`, `hand`, `foot`) | 1 | `lesson_07_01_body_weather` |
| 7 | Animals – Động vật | `animals` | 11 (`cat`, `dog`, `bird`, `fish`, `duck`, `elephant`, `lion`, `rabbit`, `bear`, `frog`, `cow`) | 2 | `lesson_02_01_food_animals` |
| 8 | Fruits – Trái cây | `fruits` (multi-tag `food`) | 7 (`apple`, `banana`, `orange`, `grape`, `mango`, `pear`, `lemon`) | 2 | `lesson_02_01_food_animals` |
| 9 | Food and Drinks – Đồ ăn & Thức uống | `food` / `drinks` | 8 (`milk`, `cake`, `water`, `jam`, `bread`, `egg`, `rice`, `juice`) | 3 | `lesson_02_01_food_animals` |
| 10 | School – Trường học | `school` | 5 (`pencil`, `ruler`, `desk`, `teacher`, `school`) + tags `book/pen/bag` | 5 | `lesson_02_02_colors_numbers_family` |
| 11 | Classroom Objects – Đồ dùng lớp học | `classroom_objects` / `objects` | 7 (`book`, `pen`, `bag`, `pencil`, `ruler`, `desk`, `chair`) | 2 | `lesson_02_02_colors_numbers_family` |
| 12 | Toys – Đồ chơi | `toys` | 5 (`ball`, `doll`, `kite`, `robot`, `bike`) | 4 | `lesson_07_02_toys_places_stories` |
| 13 | Clothes – Quần áo | `clothes` | 5 (`hat`, `shirt`, `shoes`, `coat`, `dress`) | — | `lesson_07_01_body_weather` |
| 14 | House – Ngôi nhà | `house` | 6 (`house`, `door`, `bed`, `table`, `window`, `chair`) | 3 | `lesson_07_01_body_weather` |
| 15 | Rooms & Furniture – Phòng & Nội thất | `rooms_furniture` | 4 tags (`chair`, `door`, `bed`, `table`, `window`) | 2 | `lesson_07_01_body_weather` |
| 16 | Daily Activities – Hoạt động hằng ngày | `daily_activities` | 6 (`eat`, `drink`, `read`, `play`, `sleep`, `run`) | 2 | `lesson_07_02_toys_places_stories` |
| 17 | Greetings – Chào hỏi & Lễ phép | `greetings` | 5 (`hello`, `bye`, `please`, `sorry`, `yes`) | 7 | `lesson_01_00_intro`, `lesson_06_01_shapes_numbers` |
| 18 | Weather – Thời tiết | `weather` | 4 (`sun`, `rain`, `wind`, `cloud`) | 2 | `lesson_07_01_body_weather` |
| 19 | Feelings – Cảm xúc | `feelings` | 4 (`happy`, `sad`, `tired`, `hungry`) | 1 | `lesson_07_01_body_weather` |
| 20 | Places – Địa điểm quen thuộc | `places` | 5 (`zoo`, `park`, `home`, `shop`, `beach`) | 2 | `lesson_07_02_toys_places_stories` |

Tổng gói Pre-A1 hiện tại đang chạy thực tế trong game: **26 chữ cái**, **115 từ vựng cốt lõi**, **36 cụm từ Pre-A1**, **22 mẫu câu/ngữ pháp**, **22 bài nghe**, **22 bài đọc**, **22 bài viết**, **12 bài nói**, **10 hội thoại tình huống**, **10 bài học trên 7 chủ đề**.
