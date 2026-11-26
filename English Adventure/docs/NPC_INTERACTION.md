# NPC INTERACTION & STATE MACHINE (PROMPT 06)

## Danh sách NPC & Vai trò
- **Professor Owl (`professor_owl`):** Người hướng dẫn chính tại `welcome_village`, giao `quest_01_new_adventure` và `quest_05_shadow_gate`, mở `listen_and_find`.
- **Buddy (`buddy_controller.gd`):** Rồng nhỏ đồng hành 3D, phản ứng cảm xúc (`HAPPY`, `THINKING`, `CELEBRATING`...) theo câu trả lời học tập và gợi ý bước nhiệm vụ hiện tại khi nhấn `H` hoặc `Buddy [H]`.
- **Lily (`lily`):** Giao `quest_02_lost_letters` và `side_lily_garden`, hỗ trợ `dialogue_adventure`.
- **Rocky (`rocky`):** Canh giữ manh mối ở `letter_cave`, mở đường tới `crystal_lake`, giao `quest_03_mysterious_gate` và `side_rocky_animals`.
- **Crystal Guardian (`crystal_guardian`):** Giao và nghiệm thu `quest_04_crystal_guardian` tại `crystal_lake` (ôn tập qua Review Engine & Memory Quest để trao `golden_key`).

## Máy trạng thái NPC (`scripts/character/npc_controller.gd`)
- `IDLE`, `NOTICE_PLAYER` (quay mặt và bật vòng sáng khi Player tới gần), `TALKING`, `QUEST_AVAILABLE` (`!` vàng), `QUEST_IN_PROGRESS` (`...` xanh dương), `QUEST_COMPLETED` (`?` xanh lá khi chờ trả nhiệm vụ), `CELEBRATING`.
- Lời thoại và mini-game sau hội thoại được phân giải bằng dữ liệu `dialogue_rules` và `followup_minigame` trong `data/npcs/alphabet_island_npcs.json`.
