# LỘ TRÌNH HỌC A1 (ELEMENTARY FOUNDATION)
# PROJECT: ENGLISH ADVENTURE

**Mục tiêu tham chiếu:** Giai đoạn tiếp nối sau khi hoàn thành nền tảng Pre-A1, giúp trẻ giao tiếp câu hoàn chỉnh, kể thói quen hằng ngày, nói về bạn bè, sở thích, trường học, mua sắm và hỏi đường cơ bản.  
**Tệp dữ liệu mẫu đã tích hợp:** `data/curriculum/a1_sample_curriculum.json`, `data/vocabulary/world_02_a1_vocab.json`, `data/grammar/world_02_a1_grammar.json`, `data/listening/world_02_a1_listening.json`, `data/reading/world_02_a1_reading.json`, `data/writing/world_02_a1_writing.json`, `data/speaking/world_02_a1_speaking.json`, `data/minigames/a1_dialogue_adventures.json`.

---

## 1. Lộ trình 20 chủ đề A1 & Gói Mẫu Đã Triển Khai

### Nhóm 8 chủ đề ưu tiên đã triển khai nội dung mẫu (Playable trong `world_02`):
1. **My Friends (`friends`):** `friend`, `kind`, `funny`, `share` + Hội thoại `dlg_adv_11_a1_new_friend`.
2. **My School Day (`school`):** `library`, `homework`, `science`, `music` + Bài đọc `read_a1_04` + Hội thoại `dlg_adv_14_a1_school_day`.
3. **My Daily Routine (`daily_activities`):** `breakfast`, `brush`, `study`, `clean` + Bài nghe `list_a1_03` + Bài viết `write_a1_03`, `write_a1_05`.
4. **My Hobbies (`hobbies`):** `draw`, `swim`, `sing`, `dance` + Hội thoại `dlg_adv_12_a1_hobbies` + Bài nói `speak_a1_03`.
5. **Food & Meals (`food`):** `chicken`, `noodles`, `soup`, `salad` + Bài viết `write_a1_04`.
6. **Places in Town (`places`):** `market`, `hospital`, `museum`, `street` + Bài nghe chỉ đường `list_a1_04` + Bài đọc `read_a1_05`.
7. **Shopping (`shopping`):** `price`, `money`, `buy`, `cheap` + Hội thoại `dlg_adv_13_a1_shop` + Bài nói `speak_a1_04`.
8. **Family (`family`):** `cousin`, `uncle`, `aunt`, `parents` + Bài viết giới thiệu `write_a1_06`.

### Nhóm 12 chủ đề mở rộng cho giai đoạn World 2–5 tiếp theo (`planned_extensible`):
9. My Neighborhood, 10. My Home, 11. At the Restaurant, 12. At the Park, 13. Sports and Games, 14. Jobs, 15. Transportation, 16. Seasons, 17. Holidays, 18. Time and Dates, 19. Asking for Directions (mở rộng), 20. Helping Others / Nature / Travel & Adventure.

---

## 2. Cơ chế Mở Khóa Cấp Độ A1 (Multi-Factor Gate)

Hệ thống **không** mở khóa A1 chỉ dựa vào số câu trả lời đúng trong một lượt chơi. Hàm `LearningEngine.evaluate_a1_unlock_status()` kiểm tra đồng thời 4 điều kiện từ `a1_unlock_criteria`:
1. **Hoàn thành tối thiểu 6 bài học nền tảng Pre-A1** trong `world_01` (`Alphabet Island`).
2. **Ghi nhớ hoặc thành thạo ít nhất 15 kiến thức cốt lõi** (`practicing >= 55%`, `reviewing`, hoặc `mastered`).
3. **Độ chính xác tổng hợp tối thiểu 60%** across các lượt trả lời đầu tiên.
4. **Hoàn thành nhiệm vụ cột mốc:** `quest_03_mysterious_gate` (vượt qua Cổng Bí Ẩn ở Letter Cave).

Trong `LearningHubModal`, người chơi luôn nhìn thấy thanh kiểm tra 4 điều kiện này và có thể chọn `"Học thử A1"` để trải nghiệm trước 2 bài mẫu, trong khi tiến độ mở khóa chính thức tách biệt rõ ràng.
