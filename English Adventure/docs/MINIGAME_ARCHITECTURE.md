# MINI-GAME ARCHITECTURE (PROMPT 05)

## Sơ đồ thành phần
```text
MiniGameSystem
├── MiniGameManager          (Autoload: scripts/minigames/minigame_manager.gd)
├── MiniGameRegistry         (scripts/minigames/minigame_registry.gd <- data/minigames/minigame_registry.json)
├── MiniGameFactory          (scripts/minigames/minigame_factory.gd)
├── MiniGameSession          (scripts/minigames/minigame_session.gd)
├── MiniGameDataProvider     (scripts/minigames/minigame_data_provider.gd)
├── MiniGameController       (scripts/minigames/minigame_controller.gd -> 8 games/*.gd)
├── MiniGameUI               (scripts/minigames/ui/minigame_ui.gd + scenes/minigames/minigame_host_modal.tscn)
├── MiniGameAudioManager     (scripts/minigames/minigame_audio_manager.gd)
├── MiniGameScoring          (scripts/minigames/minigame_scoring.gd)
├── MiniGameDifficulty       (scripts/minigames/minigame_difficulty.gd)
├── MiniGameFeedback         (scripts/minigames/minigame_feedback.gd)
├── MiniGameReward           (scripts/minigames/minigame_reward.gd)
└── MiniGameResult           (scripts/minigames/minigame_result.gd)
```

## Luồng dữ liệu giữa MiniGameSystem và LearningEngine
1. `MiniGameManager.start_minigame(id, context, tier)` kiểm tra trạng thái mở khóa qua `MiniGameRegistry`, xác định độ khó qua `MiniGameDifficulty`, và tạo danh sách câu hỏi qua `MiniGameDataProvider`.
2. Người chơi trả lời trong `MiniGameController` → gọi `MiniGameSession.record_answer(...)`.
3. `MiniGameSession` cập nhật đồng thời:
   - `LearningEngine.assessment_engine.create_attempt_record(...)`
   - `LearningEngine.progress_manager.record_attempt(...)` (cập nhật mastery & skill accuracy)
   - `LearningEngine.review_engine.record_review_outcome(...)` (lịch ôn tập Spaced Repetition)
   - `SaveLoadManager.enqueue_sync_event(...)` (outbox Supabase)
   - `EventBus.minigame_answered`
4. Khi hoàn tất, `MiniGameSession.finalize_session()` tính điểm tách biệt (`MiniGameScoring`), phát thưởng chống trùng (`MiniGameReward`), lưu `GameStateManager.minigame_records`, và phát `EventBus.minigame_completed` cho `QuestManager`.
