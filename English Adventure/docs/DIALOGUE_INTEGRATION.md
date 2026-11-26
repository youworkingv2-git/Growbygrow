# DIALOGUE INTEGRATION (PROMPT 06)

## Tính năng hệ thống hội thoại (`DialogueManager` + `DialogueBoxUI`)
- **Song ngữ Anh – Việt:** Hiển thị đồng thời câu tiếng Anh và bản dịch tiếng Việt; có nút **`Tiếng Việt: BẬT/TẮT`** ngay trên hộp thoại.
- **Nghe thoại tiếng Anh:** Nút **`Nghe thoại`** phát câu tiếng Anh qua `MiniGameAudioManager`.
- **Lựa chọn hội thoại & Quest Actions (`choices`):**
  - Hỗ trợ `quest_action`: `accept_quest`, `claim_quest`, `start_minigame`, `open_learning_hub`.
  - Hỗ trợ chuyển nhánh `next_dialogue_id` (ví dụ: `"Yes, I'm ready!"` -> nhận Quest 01; `"Not yet."` -> `dlg_owl_not_yet`).
- **Lưu trạng thái hội thoại đã xem:** `GameStateManager.seen_dialogues` và `GameStateManager.npc_encounters`.
- **Dữ liệu tập trung:** Quản lý toàn bộ trong `data/dialogue/alphabet_island_dialogues.json`, không hardcode lời thoại vào script NPC.
