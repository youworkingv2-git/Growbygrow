# QUEST INTEGRATION (PROMPT 06)

## Kiến trúc 10 module trong `scripts/quest/`
1. `QuestRepository` (`quest_repository.gd`): Truy xuất dữ liệu từ `data/quests/world_01_quests.json` và `data/quests/chapters.json`.
2. `QuestRegistry` (`quest_registry.gd`): Phân loại Main Quests, Side Quests, theo Area và NPC.
3. `QuestInstance` (`quest_instance.gd`): Biểu diễn trạng thái runtime của từng nhiệm vụ.
4. `QuestStateManager` (`quest_state_manager.gd`): Quản lý 6 trạng thái `locked`, `available`, `accepted`, `in_progress`, `completed`, `claimed`. Không dùng trạng thái `failed` để phạt trẻ học sai.
5. `QuestObjectiveManager` (`quest_objective_manager.gd`): Hỗ trợ 12 loại mục tiêu (`talk_to_npc`, `visit_area`/`discover_location`, `collect_item`/`collect_tag`, `interact_object`, `learn_vocabulary`, `complete_learning_activity`, `complete_minigame`, `answer_questions_correctly`, `reach_learning_mastery`, `open_new_area`, `defeat_boss`, `return_to_npc`) và 5 chế độ (`sequential`, `parallel`, `optional`, `repeatable`, `hidden`).
6. `QuestConditionEvaluator` (`quest_condition_evaluator.gd`): Đánh giá điều kiện level, khu vực, vật phẩm, cờ và nhiệm vụ tiên quyết.
7. `QuestProgressTracker` (`quest_progress_tracker.gd`): Lưu và truy vấn tiến độ số (`current/target`, ví dụ `3/5` từ).
8. `QuestRewardManager` (`quest_reward_manager.gd`): Chuyển trạng thái `completed -> claimed` qua `RewardManager` với khóa chống nhận trùng `quest:<id>`.
9. `QuestNotificationManager` (`quest_notification_manager.gd`): Thông báo toast không che khuất màn hình.
10. `QuestEventHandler` (`quest_event_handler.gd`): Khử trùng lặp sự kiện từ `EventBus`.

## Nhiệm vụ mẫu đã cấu hình (`data/quests/world_01_quests.json`)
- **Main Quests:** `quest_01_new_adventure`, `quest_02_lost_letters`, `quest_03_mysterious_gate`, `quest_04_crystal_guardian`, `quest_05_shadow_gate`.
- **Side Quests:** `side_buddy_treasure`, `side_lily_garden`, `side_rocky_animals`.
