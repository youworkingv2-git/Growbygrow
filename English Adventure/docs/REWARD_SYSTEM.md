# REWARD SYSTEM & ANTI-DUPLICATION (PROMPT 06)

## Kiến trúc `RewardManager` (`scripts/progression/reward_manager.gd`)
Mọi phần thưởng từ **Quest**, **Mini-Game**, **Vật thể 3D (Rương/Pha lê)** và **Thành tựu (`AchievementManager`)** đều đi qua `RewardManager.grant_reward(...)`:
- **Loại phần thưởng:** `EXP` (tăng Level), `Gold`, `Magic Crystal`, `Stars`, `Items`, `Achievements`.
- **Sổ cái chống nhận trùng (`reward_history` & `claimed_reward_keys`):**
  - Mỗi phần thưởng một lần dùng khóa duy nhất (`quest:<id>`, `object:<id>`, `minigame_first:<id>`, `achievement:<id>`).
  - Nếu khóa đã tồn tại trong `claimed_reward_keys`, mọi thao tác gọi lại bị chặn (`duplicate_blocked: true`) và không cộng thêm EXP/Gold/Crystal.
- **Nguyên tắc giáo dục:** Không trừ EXP, không thu hồi kiến thức khi trẻ trả lời sai.
- **Đồng bộ CSDL:** Mỗi lần nhận thưởng sẽ ghi `reward_history`, lưu cục bộ và đẩy sự kiện vào `sync_outbox` (tương thích bảng `public.reward_ledger` trong `0005_quest_reward_inventory_integration.sql`).
