# MINI-GAME ADAPTIVE DIFFICULTY (`MiniGameDifficulty`)

## Tiêu chí điều chỉnh
`scripts/minigames/minigame_difficulty.gd` tính độ khó (`easy` / `medium` / `hard`) dựa trên:
- Trình độ hiện tại và tỉ lệ chính xác kỹ năng trong `LearningProgressManager.skill_stats`.
- Số từ đang bị sai gần đây (`get_frequently_missed_items()`).
- Số lần đã chơi và số sao cao nhất của mini-game (`GameStateManager.get_minigame_record()`).
- Chuỗi trả lời đúng ngay lần đầu (`consecutive_first_try`) vs số lần trả lời sai (`wrong_count`) trong phiên.

## Nguyên tắc bảo vệ trẻ mới học
- Không bao giờ tăng độ khó chỉ dựa trên tốc độ bấm nhanh.
- Không trừ điểm hoặc mất tiến trình khi trả lời sai; sai >= 2 lần sẽ tự hạ độ khó về mức dễ hơn và hỗ trợ thêm gợi ý/hình ảnh/âm thanh.
