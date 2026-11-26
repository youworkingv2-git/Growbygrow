# EVENT SYSTEM (`EventBus` & `QuestEventHandler`) (PROMPT 06)

## Danh sách sự kiện tích hợp (`scripts/core/event_bus.gd`)
- **Tương tác & Hội thoại:** `player_interacted_with_npc`, `interaction_triggered`, `dialogue_started`, `dialogue_ended`, `dialogue_completed`, `npc_met`.
- **Nhiệm vụ:** `quest_available`, `quest_started`, `quest_accepted`, `quest_step_updated`, `quest_objective_updated`, `quest_completed`, `quest_reward_claimed`.
- **Học tập & Mini-Game:** `learning_hook_requested`, `lesson_started`, `lesson_completed`, `learning_activity_started`, `learning_activity_completed`, `learning_activity_answered`, `learning_knowledge_mastered`, `minigame_started`, `minigame_answered`, `minigame_completed`.
- **Phần thưởng, Túi đồ & Thế giới:** `item_collected`, `inventory_item_used`, `reward_granted`, `achievement_unlocked`, `level_up`, `area_entered`, `area_unlocked`, `region_unlocked`, `region_completed`, `chapter_completed`.
- **Lưu trữ & Đồng bộ:** `save_requested`, `save_completed`, `sync_status_changed`.

## Luồng xử lý chống vòng lặp & khử trùng lặp
- Các module chỉ giao tiếp qua `EventBus` hoặc facade (`QuestManager`, `RewardManager`, `LearningEngine`, `MiniGameManager`) mà không giữ tham chiếu vòng tròn lẫn nhau.
- `QuestEventHandler.is_duplicate_event(dedup_key)` chặn xử lý trùng lặp cùng một câu trả lời mini-game / phiên hoàn thành.
- `QuestManager._on_learning_activity_answered` bỏ qua các bản ghi có `minigame_id` vì đã được xử lý qua `minigame_answered`.
