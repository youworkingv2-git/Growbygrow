# MINI-GAME SCORING & REWARD SYSTEM

## 1. Tách biệt chỉ số (`MiniGameScoring`)
- `correct_answers`, `incorrect_answers`, `first_try_correct`, `attempts`, `hints_used`, `completion_time_ms`.
- **Learning Score:** Điểm phản ánh mức độ tiếp thu kiến thức (`100` đúng lần đầu không gợi ý, `65` đúng sau khi thử lại, giảm nhẹ khi dùng gợi ý).
- **Game Score:** Điểm thưởng trò chơi (`20`/`10` + thưởng độ khó).
- **Stars (1–3):** Dựa trên độ chính xác và trả lời đúng ngay lần đầu, không dùng tốc độ làm điều kiện duy nhất để đánh rớt trẻ.

## 2. Phần thưởng & Chống nhận trùng (`MiniGameReward`)
- Cấu hình EXP, Gold, `crystal_item`, `one_time_crystal`, `replay_exp`, `replay_gold` nằm trong `data/minigames/minigame_registry.json`.
- Sử dụng cờ `mg_first_reward_<id>` và `mg_quest_reward_<quest_id>_<id>` để đảm bảo hoàn thành lại cùng Quest/Mini-Game không bị farm trùng thưởng lần đầu hoặc Crystal một lần.
