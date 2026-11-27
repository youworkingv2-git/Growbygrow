# DIALOGUE SYSTEM SPECIFICATION (PROMPT 02)
# PROJECT: ENGLISH ADVENTURE

---

## 1. THIẾT KẾ HỆ THỐNG HỘI THOẠI DÙNG CHUNG

Hệ thống hội thoại gồm hai thành phần tách biệt giữa dữ liệu và hiển thị:
- **Logic:** `DialogueManager` (`scripts/character/dialogue_manager.gd`)
- **UI:** `DialogueBox` (`scripts/ui/dialogue_box_ui.gd` + `scenes/ui/adventure_hud.tscn`)
- **Dữ liệu:** `data/dialogue/alphabet_island_dialogues.json`

---

## 2. TÍNH NĂNG GIAO DIỆN HỘI THOẠI

- **Chân dung người nói (`Portrait`):** Hiển thị hình đại diện của Professor Owl, Buddy, Lily, Rocky hoặc Crystal Guardian.
- **Tên người nói (`SpeakerName`):** Tự động lấy theo `LocalizationManager.pick_text(...)`.
- **Hiển thị Song ngữ (EN + VI):**
  - Dòng tiếng Anh ngắn gọn phù hợp trẻ mới bắt đầu (`Welcome, young adventurer!`, `Let's explore the island together!`).
  - Dòng tiếng Việt giải thích dễ hiểu bên dưới với hiệu ứng **chữ xuất hiện từng ký tự (Typewriter Reveal)**.
- **Tương tác thân thiện:**
  - Khi chữ đang chạy, bấm `Tiếp tục` sẽ hiện đủ cả câu ngay lập tức; bấm lần nữa sang câu tiếp theo.
  - Có nút `Đóng` cho phép thoát hội thoại khi cần.
  - Tự động khóa di chuyển nhân vật trong lúc hội thoại (`dialogue_started` / `dialogue_ended`) và đồng bộ biểu cảm của Buddy (`buddy_state`).

---

## 3. CẤU TRÚC DỮ LIỆU HỘI THOẠI (`alphabet_island_dialogues.json`)

```json
{
  "speaker_id": "professor_owl",
  "speaker_name_vi": "Giáo sư Cú Mèo",
  "speaker_name_en": "Professor Owl",
  "portrait": "res://assets/characters/npcs/professor_owl.svg",
  "buddy_state": "talking",
  "text_en": "Welcome, young adventurer!",
  "text_vi": "Chào mừng nhà thám hiểm trẻ tuổi!"
}
```
Hỗ trợ bổ sung hội thoại mới hoặc dịch sang nhiều ngôn ngữ mà không cần sửa GDScript.

*(Cập nhật Prompt 06)*: Hỗ trợ thêm `choices` tương tác (`quest_action`: `accept_quest`, `claim_quest`, `start_minigame`, `open_learning_hub`), nút bật/tắt bản dịch tiếng Việt, nút nghe thoại tiếng Anh và lưu `seen_dialogues`. Xem `docs/DIALOGUE_INTEGRATION.md`.

*(Cập nhật Prompt 07)*: `DialogueBoxUI` tự động phát giọng đọc NPC qua `AudioManager.voice_manager.speak_npc_line`, bổ sung nút `Tạm dừng / Tiếp tục nghe`, hỗ trợ đồng bộ phụ đề theo `subtitle_segments` khi có timestamp chuẩn (hiển thị trọn câu khi dùng TTS không có timestamp, không giả lập nhịp). Xem [`docs/NPC_VOICE_DESIGN.md`](NPC_VOICE_DESIGN.md).
