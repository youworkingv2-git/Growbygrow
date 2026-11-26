# Automated Tests (`tests/`)

Phân nhóm kiểm thử dự kiến (dùng GUT hoặc gdUnit4 ở Prompt 02):
- `unit/`: Kiểm tra Anti-Guess Mastery, Modified SM-2 Review, QuestionFactory, Phonics separation.
- `integration/`: Kiểm tra Offline Save/Load, Sync Outbox idempotency, Quest → LearningEngine → MiniGameResult flow.
- `content_validation/`: Kiểm tra JSON schema, tồn tại asset ảnh/audio, IPA, nghĩa tiếng Việt và tham chiếu chéo `word_id`.
