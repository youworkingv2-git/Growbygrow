# ASSESSMENT & FEEDBACK SYSTEM
# PROJECT: ENGLISH ADVENTURE (Prompt 04)

## 1. Cấu trúc bản ghi Attempt (`AssessmentEngine`)

Mỗi lần trả lời câu hỏi, `AssessmentEngine.create_attempt_record(...)` lưu đầy đủ 10 trường dữ liệu:

1. `player_id`
2. `activity_id`
3. `question_id`
4. `selected_answer`
5. `correct_answer`
6. `is_correct`
7. `response_time_ms`
8. `number_of_attempts`
9. `hint_used`
10. `completed_at_utc`

## 2. Quy tắc Phản hồi Sư phạm

- **Khi trả lời đúng:** Hiển thị lời khen tích cực, đáp án đầy đủ, giải thích tiếng Việt ngắn gọn, ghi nhận `learning_score` (100 nếu đúng lần đầu không gợi ý, 80 nếu dùng gợi ý, 60 nếu làm lại nhiều lần) và `game_score` tách biệt.
- **Khi trả lời sai:** Không bao giờ chỉ hiện dấu `X`. Hệ thống luôn hiển thị **đáp án đúng**, **giải thích bằng tiếng Việt**, giữ `can_proceed = false` để trẻ xem kiến thức và bấm chọn lại chính xác trước khi qua câu mới (ngăn đoán bừa).

## 3. Phân tách 3 chỉ số

- **Game Score:** Điểm thưởng vui chơi (`total_game_score`, EXP, Gold).
- **Learning Score:** Điểm phản ánh độ chính xác khi học (`total_learning_score`).
- **Mastery:** Mức độ nắm vững kiến thức (`0..100` và trạng thái `new / learning / practicing / reviewing / mastered`).
