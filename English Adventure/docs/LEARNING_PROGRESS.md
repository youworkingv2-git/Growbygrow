# LEARNING PROGRESS & PERSISTENCE
# PROJECT: ENGLISH ADVENTURE (Prompt 04)

## 1. 5 Trạng thái Kiến thức (`LearningProgressManager`)

| Trạng thái | Ý nghĩa | Điều kiện chuyển |
|---|---|---|
| `new` | Chưa học | Mặc định khi chưa có lượt thử nào |
| `learning` | Đang học | Mới bắt đầu hoặc Mastery < `practicing_threshold` (45%) |
| `practicing` | Đang luyện tập | Mastery >= 45% và < 70% |
| `reviewing` | Cần ôn tập | Mastery >= 70% hoặc vừa trả lời sai |
| `mastered` | Đã nắm vững | Mastery >= 85% **và** đã kiểm chứng >= 2 kỹ năng khác nhau (`min_distinct_skills_for_mastery`) |

## 2. Theo dõi Toàn diện & Offline-First

- Theo dõi chi tiết từng từ đã học, số lần trả lời sai (`wrong_count`), kỹ năng yếu (`get_weak_skills()`), bài học và chủ đề đã hoàn thành (`completed_lessons`, `completed_topics`).
- **Lưu trữ cục bộ an toàn (Atomic Save):** Ghi ra `user://profiles/learning_progress.json.tmp` rồi đổi tên sang `user://profiles/learning_progress.json`.
- **Hàng đợi đồng bộ (`sync_outbox.json`):** Mọi sự kiện `learning_attempt`, `lesson_completed`, `review_schedule_updated` đều được đẩy vào `SaveLoadManager.enqueue_sync_event(...)` để không mất tiến trình khi offline và đồng bộ được khi kết nối Supabase ở bước tích hợp backend.
