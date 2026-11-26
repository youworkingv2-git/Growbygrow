## Learning Module

**Purpose:** The heart of the educational system. Routes learning content to the correct mini-game, tracks skill progress, and manages the learning session lifecycle. This module is COMPLETELY INDEPENDENT from the Adventure Module.

**Key Scripts:**
- `learning_engine.gd` – Singleton. Central coordinator for all learning activities. Receives quest content, prepares learning sessions, dispatches to mini-games.
- `content_loader.gd` – Loads vocabulary, phonics, grammar, questions from JSON data files. Caches loaded content.
- `skill_router.gd` – Given a vocabulary item or lesson, determines which mini-games can present it and in what order.
- `learning_session.gd` – Tracks a single learning session: questions presented, answers given, score, time.
- `mastery_checker.gd` – Evaluates whether a player has truly mastered a vocabulary item (not just guessed correctly).

**Dependencies:** 
- Core Module (EventBus)
- Vocabulary Module (word data)
- Grammar Module (grammar data)
- Audio Module (play word audio)
- Assessment Module (track attempts)

**CRITICAL RULE:**
> Vocabulary data is PASSED INTO mini-games as parameters.
> Mini-games NEVER load their own content.
> This enables the same word (e.g., "apple") to be used in Word Hunt, Listening Mission, Word Builder, Sentence Builder, and Reading Challenge without any duplication of data or logic.

**Key Signals:**
```
learning_session_started(session_id, skill, vocab_list)
question_answered(session_id, question_id, is_correct, response_time_ms)
learning_session_completed(session_id, score, skill, vocab_mastered)
mastery_achieved(vocab_id, player_id)
```

**Data Flow:**
```
Quest → LearningEngine.start_session(vocab_ids, skill, mini_game_type)
      → ContentLoader.get_vocab_batch(vocab_ids)
      → SkillRouter.prepare_questions(vocab_list, mini_game_type, difficulty)
      → MiniGameManager.launch(mini_game_type, questions)
      → [Player plays]
      → LearningEngine.record_result(session_id, results)
      → AssessmentModule.update_mastery(player_id, vocab_results)
      → ReviewModule.schedule_reviews(player_id, vocab_results)
```
