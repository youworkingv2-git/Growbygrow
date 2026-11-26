# Mini-game Module (`scripts/mini_games/`)

Chứa khung dùng chung và cài đặt cho các mini-game (MVP triển khai 5 mini-game):
- `base_mini_game.gd`: Lớp cơ sở `BaseMiniGame` định nghĩa vòng đời `setup()`, `start_game()`, `pause_game()`, `abort_game()` và các signals `attempt_made`, `game_finished`.
- `widgets/`: Các UI component tái sử dụng (`LetterTile`, `WordCard`, `SentenceBlock`, `AudioPlayButton`, `BuddyFeedbackBanner`).
- `word_hunt/`, `listening_mission/`, `word_builder/`, `sentence_builder/`, `reading_challenge/`: Logic điều khiển riêng từng mini-game, **không hardcode từ vựng**.
