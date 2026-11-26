# LEARNING ENGINE ARCHITECTURE
# PROJECT: ENGLISH ADVENTURE (Prompt 04)

**Learning Engine** là bộ máy quản lý, vận hành và đánh giá toàn bộ hoạt động học tiếng Anh trong game 3D **English Adventure**, được thiết kế theo hướng **độc lập, hướng dữ liệu (Data-Driven), hỗ trợ Offline-First**, để có thể tái sử dụng cho nhiều thế giới và toàn bộ mini-game ở Prompt 05.

---

## 1. Kiến trúc Module (`LearningEngine` Autoload)

`LearningEngine` (`scripts/learning/learning_engine.gd`) là facade toàn cục điều phối các module chuyên trách:

| Module | File | Trách nhiệm chính |
|---|---|---|
| `LearningContentRepository` | `scripts/learning/learning_content_repository.gd` | Tải & lập chỉ mục toàn bộ JSON học liệu (`curriculum`, `alphabet`, `phonics`, `vocabulary`, `grammar`, `listening`, `reading`, `writing`, `speaking`, `spaced_repetition_config`). |
| `LearningPathManager` | `scripts/learning/learning_path_manager.gd` | Quản lý cây `LearningPath -> Level -> World -> Topic -> Lesson -> LearningActivity`. |
| `VocabularyManager` | `scripts/learning/vocabulary_manager.gd` | Quản lý 32+ từ vựng đơn nguồn (Single Source of Truth), IPA `en-US`/`en-GB`, distractor và trạng thái học. |
| `PhonicsManager` | `scripts/learning/phonics_manager.gd` | Quản lý 26 chữ cái A–Z, tách biệt Letter Name vs Letter Sound, ngoại lệ phát âm và 10 nhóm Phonics. |
| `GrammarManager` | `scripts/learning/grammar_manager.gd` | Quản lý 15 cấu trúc câu nền tảng và bộ sinh câu thay thế (Substitution Builder). |
| `ListeningManager` | `scripts/learning/listening_manager.gd` | Phát âm thanh (khi có asset) & chấm câu hỏi nghe 6 dạng. |
| `SpeakingManager` | `scripts/learning/speaking_manager.gd` | Hiển thị mẫu câu/IPA/khẩu hình, kiểm tra mic, ghi nhận tự luyện (tách bạch rõ AI chấm điểm chưa tích hợp). |
| `ReadingManager` | `scripts/learning/reading_manager.gd` | Chấm đọc từ, ghép hình, điền khuyết, sắp xếp từ và đoạn văn ngắn. |
| `WritingManager` | `scripts/learning/writing_manager.gd` | Chấm điền chữ cái, ghép chữ, ghép câu và viết câu đơn giản. |
| `QuestionManager` | `scripts/learning/question_manager.gd` | Chuẩn hóa câu hỏi từ dữ liệu bài học hoặc sinh câu hỏi tái sử dụng từ Vocabulary cho mini-game. |
| `AssessmentEngine` | `scripts/assessment/assessment_engine.gd` | Ghi log 10 trường dữ liệu attempt, phân tách `Game Score` / `Learning Score` / `Mastery`, phản hồi sư phạm khi đúng/sai. |
| `LearningProgressManager` | `scripts/progression/learning_progress_manager.gd` | Lưu trạng thái `new/learning/practicing/reviewing/mastered`, thống kê 4 kỹ năng, lưu cục bộ và đẩy `sync_outbox`. |
| `ReviewEngine` | `scripts/progression/review_engine.gd` | Spaced Repetition dựa hoàn toàn trên cấu hình `spaced_repetition_config.json`. |
| `LearningHubModal` | `scenes/learning/learning_hub_modal.tscn` | Giao diện 2D học tập phủ trên thế giới 3D mà không làm xê dịch vị trí nhân vật hay camera. |

---

## 2. Kết nối với Thế giới 3D & Quest System

1. **Qua BottomDock / Phím `[L]`:** Người chơi mở `LearningHubModal` bất cứ lúc nào từ `AdventureHUD`.
2. **Qua Quest & Vật thể 3D:**
   - `QuestManager._complete_quest()` gọi `trigger_learning_hook_for_quest(quest_id)` phát `EventBus.learning_hook_requested`.
   - Khi tương tác với các chữ cái thất lạc (`obj_letter_a/b/c`) hoặc Cổng Bóng Tối (`obj_shadow_gate_seal`) trong `AreaExplorationController`, sau hội thoại sẽ mở thẳng bài học tương ứng (`lesson_01_01_abc` hoặc `lesson_01_18_gate`).
   - Hoàn thành bài học lần đầu cộng EXP/Gold vào `GameStateManager` và lưu cờ `lesson_done_<id>`.
3. **API cho Mini-Game (Prompt 05):**
   - `LearningEngine.get_mini_game_vocabulary_pack(topic, max_difficulty, count)`
   - `LearningEngine.get_review_question_batch(limit)`
   - `LearningEngine.question_manager.build_reusable_vocab_question(word_id, skill)`

---

## 3. TÍCH HỢP VỚI MINI-GAME SYSTEM (PROMPT 05)

- `MiniGameDataProvider` truy xuất trực tiếp `content_repo`, `vocabulary_manager`, `phonics_manager`, `grammar_manager`, `speaking_manager` mà không sao chép dữ liệu từ vựng riêng.
- Mỗi lượt trả lời trong mini-game gọi `MiniGameSession.record_answer(...)` → gửi về `AssessmentEngine`, `LearningProgressManager`, `ReviewEngine` và `EventBus.minigame_answered`. Chi tiết xem [`docs/MINIGAME_ARCHITECTURE.md`](MINIGAME_ARCHITECTURE.md).
