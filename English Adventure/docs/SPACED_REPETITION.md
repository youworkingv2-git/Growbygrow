# SPACED REPETITION ENGINE
# PROJECT: ENGLISH ADVENTURE (Prompt 04)

## 1. Thiết kế Data-Driven (`spaced_repetition_config.json`)

Toàn bộ khoảng thời gian ôn tập và hệ số điều chỉnh nằm trong `data/curriculum/spaced_repetition_config.json` (không hardcode trong GDScript):

```json
{
  "initial_intervals_days": [0.0, 1.0, 3.0, 7.0, 14.0, 30.0],
  "ease_factor_default": 2.5,
  "ease_factor_min": 1.3,
  "ease_factor_max": 3.0,
  "ease_bonus_on_fast_correct": 0.15,
  "ease_penalty_on_wrong": -0.25,
  "fast_response_threshold_ms": 4500,
  "max_daily_review_batch": 12
}
```

## 2. Cơ chế Điều chỉnh (`ReviewEngine`)

- Khi trẻ trả lời **đúng ở lần thử đầu**: `streak` tăng, khoảng cách ôn tập tăng dần (`1 ngày -> 3 ngày -> 7 ngày -> 14 ngày -> 30 ngày -> interval * ease_factor`). Nếu trả lời nhanh (`<= 4500ms`), `ease_factor` được cộng thưởng.
- Khi trẻ trả lời **sai**: `streak` reset về `0`, `interval_days` về `0` (đưa ngay lại danh sách cần luyện tập), `ease_factor` giảm.
- `ReviewEngine.get_due_review_items(...)` ưu tiên chọn các từ tới hạn hoặc từng sai nhiều để `LearningEngine.get_review_question_batch()` tạo phiên **"Ôn tập thông minh"** đa kỹ năng.
