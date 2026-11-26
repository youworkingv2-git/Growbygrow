# END-TO-END TEST REPORT (PROMPT 06)

*Báo cáo này sẽ được cập nhật kết quả chi tiết ngay sau khi chạy `validate_prompt_06.py` và kiểm thử trực tiếp trên bản build WebGL2.*

## 1. Kiểm thử tự động tĩnh (Static & Data Graph Validators)
- `tests/content_validation/validate_prompt_02.py`
- `tests/content_validation/validate_prompt_03.py`
- `tests/content_validation/validate_3d_visual_direction.py`
- `tests/content_validation/validate_prompt_04.py`
- `tests/content_validation/validate_prompt_05.py`
- `tests/content_validation/validate_prompt_06.py`

## 2. Kịch bản End-to-End (WebGL2 / Windows Browser)
- **Scenario 01 – Main Gameplay Loop:** Main Menu -> Character -> Welcome Village -> Move -> Meet Professor Owl -> Accept Quest 01 -> Talk to Buddy -> Play Listen and Find (5 words) -> Return to Professor Owl -> Claim Reward -> Verify EXP/Gold/Crystal/Inventory/Quest Claimed -> Unlock & Travel to Alphabet Meadow -> Save & Reload persistence.
- **Scenario 02 – Wrong Answer:** Chọn đáp án sai trong mini-game, xác nhận phản hồi đúng, không phạt EXP và không hoàn thành mục tiêu khi chưa đủ điều kiện.
- **Scenario 03 – Reward Duplication:** Hoàn thành & nhận thưởng Quest, reload game, kiểm tra `claimed_reward_keys` và xác nhận không thể nhận trùng.
- **Scenario 04 – Offline Queue & Local Persistence:** Lưu tiến trình cục bộ khi offline (`sync_outbox.json`), khôi phục chính xác khi mở lại; ghi nhận trung thực trạng thái chưa gắn Supabase server thật trong môi trường local.
