# Learning, Vocabulary & Grammar Modules (`scripts/learning/`)

Tầng **Learning Engine độc lập hoàn toàn với Adventure Engine**:
- `learning_engine.gd`: Nhận yêu cầu từ `QuestModule` hoặc `ReviewModule`, gọi `QuestionFactory` sinh `ChallengePayload`.
- `vocabulary/`: `VocabularyRepository` đọc JSON từ `data/vocabulary/`, index theo `word_id`, `category`, `difficulty`, `skills`.
- `grammar/`: `PhonicsRepository` (tách biệt `letter_name` và `letter_sound`) và `GrammarPatternEngine` (sinh bài tập từ mẫu câu & slots).
- `dto/`: Định nghĩa các lớp dữ liệu chuẩn (`VocabularyResource`, `ChallengePayload`, `LearningAttemptDTO`).
