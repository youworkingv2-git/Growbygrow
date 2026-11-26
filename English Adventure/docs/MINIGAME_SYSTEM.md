# MINI-GAME SYSTEM — HỆ THỐNG TRÒ CHƠI HỌC TIẾNG ANH (PROMPT 05)

## 1. Mục tiêu tổng thể
`MiniGameSystem` là lớp tương tác trò chơi của **English Adventure**, sử dụng trực tiếp nguồn học liệu từ `LearningEngine` (Prompt 04) để giúp trẻ ~10 tuổi mất gốc học từ vựng, phát âm, nghe – nói – đọc – viết thông qua khám phá thế giới 3D, giải đố và giúp đỡ NPC.

## 2. Nguyên tắc cốt lõi
1. **Single Source of Truth:** Không hardcode bản sao từ vựng/câu hỏi riêng trong từng mini-game; toàn bộ nội dung do `MiniGameDataProvider` lấy từ `LearningEngine.content_repo` (`world_01_vocab.json`, `alphabet_a_z.json`, `phonics_units.json`, `world_01_grammar.json`, `world_01_writing.json`, `world_01_speaking.json`) và `data/minigames/dialogue_adventures.json`.
2. **8-Stage Session Flow:** Mọi phiên chơi đều đi qua 8 bước: Introduction → Learning Objective → Instructions → Gameplay → Immediate Feedback → Result Summary → Reward → Return to Adventure.
3. **Zero-Penalty Beginner Design:** Trẻ trả lời sai không bị trừ tiến trình hay phạt thời gian; luôn nhận phản hồi đúng kèm đáp án, nghĩa tiếng Việt, giải thích đơn giản và phát âm mẫu.
4. **3D World Integration:** Mở được từ NPC, Quest, Vật thể 3D, BottomDock (`[G]`), và `LearningHubModal`; tạm dừng thế giới 3D sạch sẽ và trả nhân vật về đúng vị trí `global_position` ban đầu khi kết thúc.
