# BƯỚC 2 – CURRICULUM DESIGN

**English Adventure**  
**Phiên bản:** 1.0  
**Đối tượng dùng tài liệu:** người viết nội dung, giáo viên tiếng Anh, lập trình viên, producer  
**Nguồn tham chiếu (không sao chép):** Hang Out 1 (Compass) · Cambridge Pre A1 Starters / A1 Movers / A2 Flyers (chủ đề + kỹ năng công bố)

Tài liệu này biến GDD thành **chương trình học sản xuất được**. Mỗi dòng bài học đủ để:

- giáo viên biết trẻ học gì và dùng câu nào
- content writer viết story, câu hỏi, audio script
- lập trình viên gắn `lesson_id`, từ, mini-game, reward

---

## 0. Cách dùng tài liệu này

| Người | Đọc gì trước | Làm gì tiếp |
| --- | --- | --- |
| Producer | Mục 1–4, 12 | Chốt phạm vi MVP, không phình feature |
| Giáo viên | Mục 2–8 | Duyệt vocab + mẫu câu, ghi chú từ khó với trẻ Việt |
| Content writer | Mục 7–9 + JSON MVP | Viết script 6 bước / bài, không copy sách |
| Lập trình viên | Mục 10–11 + JSON/CSV | Import lesson data, không hard-code nội dung |

File kèm:

- `lesson-matrix-full.csv` — toàn bộ hành trình World 0–10
- `mvp-lessons.json` — tutorial + 10 bài World 1, sẵn schema game
- `vocabulary-bank-mvp.json` — 69 từ MVP (kể cả in/on/under ở boss)

---

## 1. Nguyên tắc curriculum

### 1.1. Game trước, ngôn ngữ sau

Mỗi bài bắt đầu bằng **nhiệm vụ trong nhà / bản đồ**, không bằng danh sách từ.

Sai: *Hôm nay học 8 từ về gia đình.*  
Đúng: *Ai đang ở nhà? Tìm bố, mẹ và em bé.*

### 1.2. Tham chiếu, không sao chép

Hang Out 1 dùng để **canh mục tiêu**: chủ đề unit, mẫu câu trẻ cần làm được, độ khó beginner.

Cambridge YLE dùng để **canh đầu ra**: chủ đề (nhà, trường, đồ ăn, động vật…), kỹ năng nghe/đọc/nói/viết, grammar theo band Starters → Movers → Flyers.

**Cấm đưa vào game:** hội thoại sách, audio sách, hình sách, đề thi, wordlist nguyên văn, tên nhân vật sách nếu gây nhầm lẫn thương hiệu.

### 1.3. Xoắn ốc (spiral)

Một mục không dạy một lần rồi bỏ.

Ví dụ `blue`:

1. L01 thấy áo xanh (hình, chưa bắt buộc đọc)
2. L05 *I have a blue ball*
3. L07 *I'm wearing a blue hat*
4. L08 củng cố *What color is it?*
5. Review / Boss nghe *Find the blue chair*

### 1.4. Số từ mỗi bài

- Bài thường: **5–8 từ mới** (cụm 2 từ như `years old` tính 1 mục)
- Số 1–10 nhập một cụm ở L02, ôn lại khi đếm đồ
- Review / Boss: **0 từ mới**, chỉ tái sử dụng từ yếu

### 1.5. Thời lượng

| Loại | Thời gian |
| --- | --- |
| Tutorial beat | 1–2 phút |
| Lesson thường | 6–9 phút |
| Review | 8–10 phút |
| Boss | 8–12 phút |

---

## 2. Bản đồ năng lực: Hang Out 1 → World → Flyers

Cột Hang Out 1 là **kỹ năng/chủ đề tương đương**, không phải “làm lại unit sách”.

| Hang Out 1 | Chủ đề / kỹ năng hướng tới | World trong game | Band YLE |
| --- | --- | --- | --- |
| Welcome | greeting, tên, số 1–10, màu | W0, W1-L01, L02, L08 | Starters |
| Unit 1 School things | I have / Do you have | W2 | Starters |
| Unit 2 My toys | this / these, What's this? | W1-L05 | Starters |
| Unit 3 Classroom | Where's…? in / on / under | W2 | Starters |
| Unit 4 Family & friends | This is my…, he / she | W1-L03 | Starters |
| Unit 5 Actions & animals | can / can't, động từ hành động | W4 (+ eat/drink sang W3) | Starters |
| Unit 6 Feelings | How are you? I'm… | W2-L09, W6 | Starters |
| Unit 7 Daily activities + rooms | Present simple, rooms | W1-L04, W7 | Starters |
| Unit 8 Face & body | has, bộ phận cơ thể | W1-L06 | Starters |
| Unit 9 Jobs | What does he/she do? places | W5 | Starters → Movers |
| *(không có trong HO1)* | clothes, food, weather, travel, past, going to | W1-L07, W3, W6, W8, W9 | Starters → Flyers |
| *(kỹ năng đề)* | nghe ghép người-tranh, đọc chuyện, viết đoạn, kể tranh | W9, W10 | Flyers |

Thứ tự **world của game** (nhà trước, trường sau) khác sách (đồ dùng học trước). Cố ý: trẻ 10 tuổi vào phiêu lưu từ ngôi nhà của mình, rồi mới tới trường.

---

## 3. Mở khóa grammar (toàn hành trình)

| Band | World | Mẫu được mở |
| --- | --- | --- |
| Beginner | W0–W1 | Hello chunks · I am / I'm · This is · I have · It's a… · There is · What color… · I'm wearing… |
| A1 | W2–W4 | Do you have? Yes/No · Where is? in/on/under/next to · I like / don't like · can/can't · a/an · plurals |
| A1+ | W5–W7 | Present simple routines · What does he do? · Present continuous · frequency · adjectives · How's the weather? |
| A2 | W8–W9 | going to · Past simple (was/were + regular + irregular thường gặp) · comparatives · mô tả tranh · kể ngắn |
| A2 Flyers prep | W10 | Cùng grammar A2, dùng trong nhiệm vụ dài hơn: nghe lấy thông tin, đọc tìm chi tiết, viết 20–30 từ, nói theo tranh |

Câu hỏi luôn có **dạng khẳng định + nghi vấn + trả lời ngắn** khi trẻ đã sẵn sàng (từ W2).

---

## 4. Phạm vi số liệu

| World | ID | Số lesson | Từ mới (ước tính) | Level |
| --- | --- | --- | ---: | --- |
| Tutorial Village | W0 | 4 beat (1 scene chain) | 8 chunks | Pre-A1 |
| My Home | W1 | 10 | 69 | Pre-A1 / A1 |
| My School | W2 | 12 | ~70 | A1 |
| Food City | W3 | 12 | ~70 | A1 |
| Animal World | W4 | 12 | ~70 | A1 |
| City | W5 | 12 | ~70 | A1 / A1+ |
| Weather & Seasons | W6 | 10 | ~50 | A1+ |
| Hobbies | W7 | 12 | ~60 | A1+ |
| Travel | W8 | 12 | ~60 | A2 |
| Adventure World | W9 | 14 | ~40 (chủ yếu tái sử dụng) | A2 |
| Flyer Island | W10 | 16 | ~40 + ôn toàn bộ | A2 |
| **Tổng full** | | **~126** | **~600** | Beginner → A2 |

MVP chỉ sản xuất **W0 + W1** (69 từ/cụm, gồm greeting + số 1–10 + in/on/under).

---

## 5. 15 mẫu câu MVP (World 1)

Trẻ phải **nghe hiểu + nói được** (không cần giải thích grammar):

1. Hello! / Hi! / Goodbye!
2. What's your name?
3. My name is …
4. I am ten. / I'm ten years old.
5. This is my mum.
6. He is my brother. / She is my sister.
7. I have a ball.
8. What's this? It's a bed.
9. There is a lamp.
10. Where is the cat? It's under the bed.
11. What color is it? It's blue.
12. I'm wearing a hat.
13. Touch your nose.
14. Thank you. / Please.
15. Yes. / No. *(W2 mới dạy Yes, I do.)*

---

## 6. Mini-game theo bài (MVP)

Chỉ 5 loại trong MVP. Cột trong CSV dùng đúng tên này.

| Code | Tên | Input | Win condition |
| --- | --- | --- | --- |
| `find_it` | Find It | audio từ/câu | chạm đúng object trong scene |
| `match` | Match | 4–6 cặp | word ↔ picture |
| `listen_choose` | Listen & Choose | audio câu | chọn đúng 1/3 hình |
| `word_puzzle` | Word Puzzle | chữ xáo | xếp thành từ |
| `sentence_builder` | Sentence Builder | mảnh câu | đúng thứ tự |

Speaking dùng `speaking_challenge` (thu âm + keyword), không tính là mini-game thứ 6 của MVP feature list — nó là **bước Use**, có thể tắt nếu máy không mic.

---

## 7. WORLD 0 – Tutorial Village (4 beat)

Không phải 4 lesson đầy đủ. Một scene ~5 phút, có thể skip phần đã biết nếu phụ huynh bật “con đã chơi rồi”.

| Beat | Nhiệm vụ game | Ngôn ngữ | Kỹ năng |
| --- | --- | --- | --- |
| T01 First steps | Chạm cổng làng, nhận bản đồ | Hello! Hi! | Nghe + chạm |
| T02 Your name | Gặp NPC Mira, nói/gõ tên | What's your name? My name is … | Nói hoặc gõ |
| T03 How to play | Nghe “Find the star”, chọn Có/Không | Yes. No. Listen. | Nghe + chọn |
| T04 Enter home | Giúp Mira, nhận 5 coins | Thank you. Bye. | Nói/chọn |

**Star rating tutorial:** không bắt buộc 3 sao. Chỉ cần hoàn thành.

---

## 8. WORLD 1 – MY HOME (MVP — spec sản xuất)

Badge thế giới: **Home Explorer**  
Boss: **The Missing Teddy**  
Story khung: Nhân vật về nhà mới. Teddy (gấu bông) chạy mất. Mỗi lesson tìm một manh mối trong nhà.

Màu sắc và số **xoắn ốc**: L01–L07 dùng 3–4 màu và số 1–5 trong hình; L02 dạy số 1–10; L08 mới khóa kỹ năng *What color is it?*

### 8.1. Bảng bài World 1

| ID | Bài | Chủ đề | Từ mới | Mẫu câu | Grammar | L | S | R | W | Mini-game | Level |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| W1-L01 | Hello! | Chào hỏi | 5 | Hello! Thank you. | chunks | ✓ | ✓ | | | listen_choose | Beginner |
| W1-L02 | My Name | Tên, tuổi, số | 8 + số 1–10 | My name is… I'm ten. | be (I am) | ✓ | ✓ | ✓ | | word_puzzle | Beginner |
| W1-L03 | My Family | Gia đình | 7 | This is my… He/She is… | this is, my, he/she | ✓ | ✓ | ✓ | | match | Beginner |
| W1-L04 | My Room | Phòng, nội thất | 7 | This is my room. There is a… | there is, this is | ✓ | ✓ | ✓ | ✓ | find_it | Beginner |
| W1-L05 | My Toys | Đồ chơi | 7 | I have a… What's this? | have, a/an | ✓ | ✓ | ✓ | ✓ | find_it | Beginner |
| W1-L06 | My Body | Cơ thể | 8 | Touch your… I have two… | plural, số | ✓ | ✓ | | | listen_choose | Beginner |
| W1-L07 | My Clothes | Quần áo | 7 | I'm wearing… | wearing + noun | ✓ | ✓ | ✓ | | match | Beginner |
| W1-L08 | My Colors | Màu | 8 | What color is it? It's… | adj + n | ✓ | ✓ | ✓ | ✓ | sentence_builder | Beginner |
| W1-L09 | Home Review | Ôn nhà | 0 | mix 1–8 | mix | ✓ | ✓ | ✓ | ✓ | memory mix* | Beginner |
| W1-L10 | Boss | Teddy mất tích | 0 | Where is…? It's under… | in/on/under | ✓ | ✓ | ✓ | | listening_detective** | Beginner |

\*Review dùng Match + Sentence Builder + Listen & Choose luân phiên.  
\*\*Boss dùng Find It + Listen & Choose + Speaking; `in/on/under` **dạy nhẹ trong boss** bằng hình (gấu *in* hộp, *on* giường, *under* giường) — 3 giới từ, không thêm từ vựng nội thất mới.

### 8.2. Spec từng bài (đủ để viết script)

Mỗi bài giữ đúng 6 bước GDD. Dưới đây là **nhiệm vụ + ngôn ngữ + asset**.

---

#### W1-L01 Hello!

**Hook:** Cửa nhà khóa. NPC Mira: *Hello! Can you help?*  
**Từ mới:** hello, hi, goodbye, please, thank you  
**Tái sử dụng:** yes, no  
**Discover:** 5 bong bóng lời chào trên sân. Chạm → audio chậm + thường.  
**Practice:** `listen_choose` — nghe *Thank you* / *Hello* / *Goodbye*, chọn đúng mặt NPC.  
**Use (speaking):** Nhắc *Hello!* hoặc *Hi!* (keyword hello/hi).  
**Challenge:** Mở cửa: nói hoặc chọn *Please* rồi *Thank you*.  
**Reading/Writing:** không.  
**Reward:** 20 XP, 5 coins.  
**Audio script (gốc):**  
- Mira: Hello!  
- Mira: Hi! What's this? It's a door.  
- Mira: Please help. Thank you! Goodbye!

---

#### W1-L02 My Name

**Hook:** Hòm thư có bản đồ. Cần ghi danh nhà thám hiểm.  
**Từ mới:** name, friend, boy, girl, years old *(cụm)*, plus numbers **one–ten**  
**Mẫu:** What's your name? My name is … I am ten. / I'm ten years old.  
**Discover:** Bảng tên + nến sinh nhật số 1–10.  
**Practice:** `word_puzzle` — NAME, TEN, FRIEND.  
**Use:** Nói *My name is [tên đã tạo]*.  
**Challenge:** Chọn đúng tuổi (mặc định 10, phụ huynh sửa được 8–12).  
**Reading:** 1 dòng `My name is Linh.` (tên NPC).  
**Reward:** 20 XP, 5 coins, item *Name Badge*.

---

#### W1-L03 My Family

**Hook:** Ai đang ở nhà? Tìm người thân để hỏi chuyện Teddy.  
**Từ mới:** mum, dad, sister, brother, grandma, grandpa, family  
**Mẫu:** This is my mum. He is my brother. She is my sister. Who is this?  
**Discover:** Khung ảnh gia đình trên tường — chạm từng người.  
**Practice:** `match` — word ↔ portrait.  
**Use:** Nói *This is my mum.* khi chạm ảnh mẹ.  
**Challenge:** Mira hỏi *Who is this?* — chọn + nói.  
**Reading:** `This is my family.`  
**Reward:** 20 XP, 5 coins.

Ghi chú: dùng *mum/dad* (Starters) kèm tooltip phụ huynh “mother/father”. Không nhồi *uncle/aunt/cousin* vào MVP.

---

#### W1-L04 My Room

**Hook:** Phòng ngủ tối. Bật đèn, tìm manh mối Teddy.  
**Từ mới:** room, bed, desk, chair, lamp, door, window  
**Mẫu:** This is my room. This is my bed. There is a lamp.  
**Discover:** Scene phòng 2D, chạm đồ thì học từ.  
**Practice:** `find_it` — *Find the chair.* / *Find the window.*  
**Use:** Sentence builder *This is my bed.*  
**Challenge:** Nghe *There is a lamp.* → chạm đèn.  
**Writing L1:** điền `This is my ____.` (bed/desk).  
**Reward:** 20 XP, 5 coins, house item *Lamp*.

---

#### W1-L05 My Toys

**Hook:** Rương đồ chơi. Teddy từng ở đây.  
**Từ mới:** toy, doll, ball, car, robot, puzzle, kite  
**Tái sử dụng:** have, a, colors đã thấy  
**Mẫu:** I have a ball. What's this? It's a robot.  
**Discover:** 7 đồ chơi phát sáng lần lượt.  
**Practice:** `find_it` + `listen_choose` (2 round).  
**Use:** *I have a car.*  
**Writing L2:** xếp `I / have / a / doll`  
**Reward:** 20 XP, 5 coins.

---

#### W1-L06 My Body

**Hook:** Gương ma thuật. Làm đúng động tác để gương mở ngăn kéo.  
**Từ mới:** head, eyes, nose, mouth, hands, feet, arms, legs  
**Mẫu:** This is my nose. Touch your head. I have two hands.  
**Discover:** silhouette nhân vật, chạm bộ phận.  
**Practice:** `listen_choose` — *Touch your feet* (3 hình).  
**Use:** Nói *Touch your nose* theo Simon-says với Mira.  
**Reading:** không đoạn; chỉ nhãn.  
**Reward:** 20 XP, 5 coins.

---

#### W1-L07 My Clothes

**Hook:** Mưa nhỏ ngoài sân. Cần mặc đồ trước khi ra tìm Teddy.  
**Từ mới:** T-shirt, pants, dress, hat, shoes, socks, jacket  
**Mẫu:** I'm wearing a hat. It's a blue jacket. Put on your shoes.  
**Discover:** tủ quần áo kéo-thả lên avatar.  
**Practice:** `match` word ↔ clothes.  
**Use:** *I'm wearing a T-shirt.*  
**Reading:** `I am wearing a jacket.`  
**Reward:** 20 XP, 5 coins, avatar item *Blue Hat*.

*pants* kèm nhãn phụ *trousers* (US/UK) trong data, UI hiện 1 từ theo locale.

---

#### W1-L08 My Colors

**Hook:** Mảnh bản đồ bị lem màu. Phải sơn đúng màu theo lời Mira.  
**Từ mới:** red, blue, yellow, green, orange, pink, black, white  
**Tái sử dụng:** ball, hat, bed, car…  
**Mẫu:** What color is it? It's red. I have a green kite.  
**Discover:** palette 8 màu.  
**Practice:** `sentence_builder` — *It / is / blue.*  
**Use:** Nói màu của đồ Mira giơ.  
**Writing L1:** `It is ____.`  
**Reward:** 20 XP, 5 coins.

Không nhồi brown/purple vào bài mới; để review nếu adaptive cần thêm (optional extra, không bắt buộc MVP).

---

#### W1-L09 Home Review

**Hook:** Album gia đình. Ôn để nhớ đường đi trong nhà.  
**Từ mới:** không.  
**Pool:** toàn bộ từ L01–L08, ưu tiên từ accuracy < 70%.  
**Vòng:** Match 6 cặp → Listen & Choose 4 câu → Sentence Builder 3 câu → Speaking 2 câu.  
**Reading:** 3 câu: `This is my room. I have a red ball. I'm wearing a hat.`  
**Writing:** 1 câu xếp + 1 chỗ trống.  
**Reward:** 25 XP, 8 coins, ôn xong mở cửa tầng trên.

---

#### W1-L10 Boss – The Missing Teddy

**Hook:** Nghe tiếng gấu. Manh mối: *It's under the bed.*  
**Từ mới:** không. **Grammar mới nhẹ:** in, on, under (minh họa).  
**Luồng 6 beat (không game over):**

1. **Listen** — Mira: *Teddy is in the house. Find Teddy.*
2. **Find It** — tìm hat / ball / jacket theo audio (nhiễu 2 đồ sai).
3. **Read** — mảnh giấy: `Teddy is under the bed.`
4. **Choose** — Where is Teddy? in the box / on the desk / under the bed
5. **Speak** — *It's under the bed.*
6. **Reward** — ôm Teddy, Badge **Home Explorer**, +30 XP boss +20 lesson, 15 coins, unlock World 2 map icon (khóa nội dung, chỉ hiện “Coming soon” nếu chưa làm W2)

Hearts = 3. Sai → Try again, không trừ hết mạng trừ khi bỏ cuộc. Phụ huynh có thể bật “practice mode” không hearts.

---

## 9. WORLD 2–10 (outline sản xuất sau MVP)

Chi tiết từng dòng nằm trong `lesson-matrix-full.csv`. Dưới đây là **ý đồ từng world** đủ để giáo viên duyệt phạm vi.

### World 2 – My School (HO1 U1, U3, U6)

I have a pencil. Do you have a ruler? Where is the book? It's on the desk. This is my teacher. How are you? I'm happy.

Boss GDD: **The Lost Backpack**.

### World 3 – Food City

Fruit, veg, drinks, meals, I like / I don't like, Can I have some milk?  
Hang Out 1 không có unit đồ ăn — đây là bước **mở rộng có chủ đích** về Starters food.

Boss: **Food Festival** (phục vụ đúng món theo lời khách).

### World 4 – Animal World (HO1 U5)

Pets, farm, wild, body parts, habitats, A bird can fly. The elephant is big.

Boss: **Find the Lost Puppy**.

### World 5 – City (HO1 U9)

Places, shops, hospital, jobs, bus/bike/car, next to / opposite.  
What does she do? She's a doctor. She works in a hospital.

Boss: **Find the Library**.

### World 6 – Weather & Seasons

It's sunny/rainy/cloudy/windy. I'm wearing a jacket. I feel hot/cold. Seasons.  
Ôn feelings + clothes.

Boss: **Storm Island Rescue**.

### World 7 – Hobbies (HO1 U7 mở rộng)

I like swimming. She plays football. What do you do at the weekend?  
Present continuous: What are you doing? I'm reading.  
Frequency: always / sometimes / never (A1+).

Boss: **Talent Show**.

### World 8 – Travel

Holiday, airport, hotel, train, bus, beach. Where are you going? I'm going to the beach.  
**going to** tương lai gần.

Boss: **Catch the Plane**.

### World 9 – Adventure World

Nghe 2–4 câu, đọc 40–70 từ, sắp tranh, Past simple, so sánh hơn, mô tả tranh, hỏi NPC.

Boss: **Temple of Stories**.

### World 10 – Flyer Island

Nhiệm vụ **tinh thần** A2 Flyers, nội dung gốc:

| Lesson | Kỹ năng mô phỏng (không copy đề) |
| --- | --- |
| FL01–03 | Nghe: ghép người–hành động–quần áo; điền 1 từ; chọn tranh |
| FL04–06 | Đọc: định nghĩa–từ; chuyện có chỗ trống; câu hỏi chi tiết |
| FL07–08 | Viết: từ theo tranh; 3–5 câu / đoạn ngắn |
| FL09–12 | Nói: khác biệt 2 tranh; hỏi theo thẻ; kể 4 tranh; câu hỏi cá nhân |
| FL13–15 | Grammar + vocab island + ôn hỗn hợp |
| FL16 | Boss **Flyer Castle** → Badge Flyer Champion |

Không gọi là “đề thi”. UI: *Island Trial*, *Story Gate*, *Talk with the Captain*.

---

## 10. Schema dữ liệu (lập trình viên)

Bám GDD §25, §39, §40. File JSON MVP đã theo schema này.

### 10.1. Vocabulary

```json
{
  "id": "HOME_001",
  "word": "bed",
  "meaning_vi": "giường",
  "image": "images/home/bed.png",
  "audio_normal": "audio/en/bed.mp3",
  "audio_slow": "audio/en/bed_slow.mp3",
  "example": "This is my bed.",
  "topic": "home",
  "world_id": "W1",
  "lesson_id": "W1-L04",
  "level": "Beginner",
  "cefr": "Pre-A1",
  "difficulty": 1,
  "review_interval_days": [1, 3, 7, 14, 30]
}
```

### 10.2. Lesson

```json
{
  "lesson_id": "W1-L04",
  "world_id": "W1",
  "title": "My Room",
  "title_vi": "Phòng của mình",
  "level": "Beginner",
  "topic": "rooms",
  "duration_min": 8,
  "vocabulary": ["HOME_020", "HOME_021"],
  "grammar": ["this_is", "there_is"],
  "sentence_patterns": ["This is my room.", "There is a lamp."],
  "story": { "npc": "mira", "lines": ["This is my room.", "Find the lamp."] },
  "steps": ["story", "discover", "practice", "use", "challenge", "reward"],
  "mini_games": ["find_it"],
  "listening": [{ "level": 1, "audio": "find_the_lamp", "answer": "lamp" }],
  "speaking": [{ "prompt": "What's this?", "expect": ["It's a bed.", "A bed."] }],
  "reading": ["This is my room."],
  "writing": [{ "level": 1, "template": "This is my ____.", "answer": "bed" }],
  "rewards": { "xp": 20, "coins": 5, "stars_max": 3 },
  "hangout1_ref": "U7-rooms",
  "yle_ref": "Starters-home"
}
```

### 10.3. Question

`type`: LISTENING | VOCABULARY | GRAMMAR | READING | SPEAKING | WRITING  
Sai không hiện explanation dài. Một câu: *Listen again!* hoặc *Try again!*

### 10.4. Quy tắc import

- Thêm bài mới = thêm JSON, không sửa `LessonManager` besides registry
- `hangout1_ref` và `yle_ref` chỉ metadata nội bộ, **không hiện cho trẻ**
- Locale UI: vi cho phụ huynh; in-game child-facing text **English first**, gợi ý VI chỉ khi bật “Hint” (tối đa 1 lần / câu)

---

## 11. Adaptive + SRS (gắn curriculum)

Mỗi cặp `user_id + word_id` lưu: accuracy, attempts, last_result, next_review_at, skill_flags.

Review chen vào:

- đầu bài tiếp theo: 2–3 thẻ từ bài trước (30–45 giây)
- W1-L09 và mọi bài Review
- Daily Quest “Review 5 words”

Nếu `orange` (khi có) < 50% accuracy: bắt buộc xuất hiện trong Find It hoặc Match của bài kế, tối đa 2 từ yếu / bài để không thành kiểm tra.

---

## 12. Tiêu chí “xong curriculum một bài”

Content writer tick trước khi gửi:

- [ ] Hook là nhiệm vụ game, không phải “học 8 từ”
- [ ] 5–8 từ mới, mỗi từ có ảnh + audio thường/chậm + 1 câu ví dụ gốc
- [ ] Câu ví dụ dùng lại trong Practice hoặc Challenge
- [ ] Có Listen, có ít nhất 1 lần Speak (hoặc chọn miệng nếu tắt mic)
- [ ] Sai → Try again, không đoạn text dài
- [ ] Không copy Hang Out / Cambridge
- [ ] Tên file asset = `word_id`
- [ ] Phụ huynh xem được: topic, số từ, kỹ năng của bài

---

## 13. Việc **không** làm ở Bước 2

- Không viết 100 audio script full game
- Không vẽ 600 asset
- Không soạn đề thi Flyers
- Không dịch wordlist Cambridge vào JSON

---

## 14. Bước 3 (sau khi duyệt curriculum)

1. **Lesson scripts W0–W1** — thoại NPC từng màn, file audio list  
2. **Wireframe Unity** — Home, Lesson, Find It, Parent  
3. **Pipeline asset** — 66 từ: art + 2 audio  
4. **Prototype 1 lesson** — W1-L04 My Room (đủ 6 bước + save)

Khi 10 bài World 1 khiến trẻ bấm *Continue*, mới mở World 2 trên cùng pipeline.
