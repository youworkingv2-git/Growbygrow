# GAMEPLAY LOOP – ENGLISH ADVENTURE (PROMPT 06)

## Vòng lặp Gameplay Chính (Core Loop)

```
EXPLORE (Khám phá thế giới 3D)
   ↓
DISCOVER (Phát hiện NPC, Rương, Biển chỉ dẫn, Chữ cái, Cổng)
   ↓
NPC INTERACTION (Nhấn E / Chạm tương tác với NPC)
   ↓
QUEST ACCEPTED (Chấp nhận nhiệm vụ qua Hội thoại / Popup / Quest Log)
   ↓
LEARNING OBJECTIVE (Xác định từ vựng/kỹ năng cần học)
   ↓
MINI-GAME (Khởi chạy mini-game Prompt 05 phù hợp)
   ↓
ASSESSMENT (AssessmentEngine + LearningProgressManager + ReviewEngine ghi nhận)
   ↓
QUEST COMPLETION (QuestObjectiveManager kiểm tra đủ điều kiện -> Completed)
   ↓
REWARD (QuestRewardManager -> RewardManager trao thưởng không trùng -> Claimed)
   ↓
WORLD PROGRESSION (GameStateManager.evaluate_all_unlocks mở khóa khu vực/chương mới)
   ↓
EXPLORE NEW AREA (Di chuyển qua Portal / World Map sang khu vực mới)
```

## Liên kết mã nguồn thực tế
- **Explore & Discover:** `scripts/character/player_controller.gd`, `scripts/adventure/interaction_manager.gd`, `scripts/adventure/interactable_object.gd`
- **NPC & Dialogue:** `scripts/character/npc_controller.gd`, `scripts/character/dialogue_manager.gd`, `scripts/ui/dialogue_box_ui.gd`
- **Quest & Objectives:** `scripts/quest/quest_manager.gd` và 10 module con (`QuestRepository`, `QuestRegistry`, `QuestStateManager`, `QuestObjectiveManager`, `QuestConditionEvaluator`, `QuestProgressTracker`, `QuestRewardManager`, `QuestNotificationManager`, `QuestEventHandler`)
- **Learning & Mini-Game:** `scripts/learning/learning_engine.gd`, `scripts/minigames/minigame_manager.gd`
- **Reward & Inventory:** `scripts/progression/reward_manager.gd`, `scripts/progression/inventory_manager.gd`, `scripts/progression/achievement_manager.gd`
- **World Progression:** `scripts/core/game_state_manager.gd`, `scripts/adventure/unlock_evaluator.gd`, `scripts/ui/world_map_ui.gd`
