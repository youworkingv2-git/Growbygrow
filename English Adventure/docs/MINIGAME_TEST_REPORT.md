# MINI-GAME TEST REPORT (PROMPT 05)

## 1. Kiểm thử tự động (Static & Integrity Validators)
Đã chạy và **PASS (exit code 0)** toàn bộ 5 script kiểm tra sau commit `9092177`:
- `tests/content_validation/validate_prompt_02.py` — Checked JSON files: 21, `res://` references: 237, `@onready` node paths: 222.
- `tests/content_validation/validate_prompt_03.py` — Checked required UI/UX files: 27.
- `tests/content_validation/validate_3d_visual_direction.py` — Checked 3D gameplay & area scenes: 10, UI dioramas: 5, character rigs: 7.
- `tests/content_validation/validate_prompt_04.py` — Passed: 26 letters, 32 vocab + SVGs, 15 grammar, 12 listening, 12 reading, 12 writing, 6 speaking, 8 lessons.
- `tests/content_validation/validate_prompt_05.py` — Checked Prompt 05 files: 37 (Registry 8 core + 8 template, `dialogue_adventures.json`, kiến trúc `MiniGameSystem`, migration `0004`, không trùng lặp từ vựng cứng).

## 2. Kiểm thử thực tế trên bản WebGL2 (GitHub Pages CI Build)
### 2.1. Kết quả đã kiểm chứng trực tiếp trên bản build `e6e11c7` (`cursor-ide-browser`, 0 lỗi GDScript/Runtime trong `window.__godotLogs`)
- **Khởi động & Thế giới 3D:** Vào từ Main Menu -> Welcome Village mượt mà, HUD hiển thị đầy đủ, nút `Trò chơi [G]` và `Học tập [L]` hoạt động.
- **Mở từ Arcade, LearningHubModal & Quest Log:**
  - Mở Arcade từ HUD (`Trò chơi [G]`) và từ `LearningHubModal` (`Mở Trò Chơi`).
  - Mở `listen_and_find` trực tiếp từ `Sổ Tay Nhiệm Vụ` (`quest_01_new_adventure`).
- **4 Mini-game ưu tiên:**
  1. `listen_and_find`: Hoàn thành đủ 4/4 câu; kiểm thử nút `Gợi ý (H)`, chọn đáp án sai hiển thị phản hồi tiếng Việt + giải thích + `Nghe lại` + `Thử lại`, phím tắt `1`/`2`, màn hình tổng kết (`4/4`, `Learning Score: 240`, `Game Score: 35`, `+30 EXP | +15 Gold + 1 Pha Lê Âm Thanh`), quay lại đúng vị trí 3D và HUD cập nhật (`30/115 EXP`, `15 Gold`, `1 Crystal`).
  2. `word_builder`: Khởi chạy từ `LearningHubModal`, nhấn `Enter` bắt đầu, gõ phím `D-A-D` + `Enter`, nhận phản hồi đúng (`"Đáp án: Dad — Bố..."`, `Điểm học: 100`), thoát `Esc` về thế giới 3D.
  3. `word_matching`: Ghép đủ 3 cặp (`Ball`, `Sister`, `Brother`), hoàn thành nhận `+30 EXP | +15 Gold + 1 Pha Lê Tri Thức`; HUD cập nhật `60/115 EXP`, `30 Gold`, `2 Crystals`, Arcade cập nhật `Lượt chơi: 1 | Sao cao nhất: 3/3`.
  4. `sentence_builder`: Kiểm thử `Gợi ý từ kế` (đặt `"I"`), ghép `"I can say hello."`, nhấn `Kiểm tra câu`, nhận phản hồi đúng (`Điểm học: 80`), thoát về thế giới 3D.
- **4 Mini-game mở rộng:**
  5. `sound_detective`: Xác nhận chế độ Letter Sound + IPA + chọn đáp án bằng phím `1`.
  6. `speaking_hero`: Xác nhận hiển thị banner trung thực về khả năng hỗ trợ (nghe mẫu + tự luyện hoạt động; mic chưa khả dụng trên Web/không mic; chấm điểm phát âm AI ghi rõ đang chờ tích hợp dịch vụ ngoài, không chấm giả).
  7. `memory_quest`: Cuộn Arcade bằng chuột, mở trò chơi và lật thẻ (`Sister`).
  8. `dialogue_adventure`: Chọn tình huống (`Greeting – Chào hỏi`), hiển thị câu thoại song ngữ Anh–Việt, chọn câu trả lời và nhận phản hồi.
- **Đồng bộ Learning Engine (`LearningHubModal`):**
  - Tab `Bài học`: `Ôn Tập Thông Minh` cập nhật lên `5 câu hỏi` từ lịch sử làm sai/luyện tập ở mini-game.
  - Tab `Tiến độ`: Ghi nhận `Learning Score: 850 điểm`, `Game Score: 150 điểm`, thống kê 4 kỹ năng (`Listening: 9 lượt`, `Reading: 4 lượt`, `Writing: 2 lượt`) và danh sách `Từ vựng cần luyện tập thêm` (`word_chair`, `word_bag`, `word_pen`, `word_book`).
- **Tự động lưu cục bộ:** `[SaveLoadManager] Saved profile state locally` chạy định kỳ không lỗi.

### 2.2. Các lỗi UI/Logic nhỏ phát hiện khi chơi thử và đã sửa ở commit `9092177` (build WebGL2 deploy thành công)
- Thay ký tự `★`/`☆` (bị lỗi font ô vuông trên WebGL2) thành `[*]`/`[ ]` và `↔` thành `<->`.
- Sửa tổng số mục ở bảng nhiều cặp (`word_matching`, `memory_quest`) trong `MiniGameSession` để hiển thị đúng `3/3` thay vì `3/1`, đồng thời reset đếm lượt thử theo từng cặp đúng.
- Tăng độ tương phản chữ tối cho nút thẻ đã ghép/đang chọn (`word_matching`, `memory_quest`) và nút lựa chọn / `CheckButton` (`dialogue_adventure`).
- Bổ sung kiểm tra `anchor_word` khớp chữ cái trong `_build_sound_detective` để tránh ghép chữ `Z` với ví dụ `'one'` hay `X` với `'five'`.

### 2.3. Các hạng mục chưa kiểm thử xong trên bản chạy thực tế (Cần xác nhận thêm)
- Kiểm thử sau reload trình duyệt trên bản `9092177` (xác nhận đọc lại `60/115 EXP`, `30 Gold`, `2 Crystals` từ save cục bộ và xác nhận chống nhận trùng Magic Crystal khi chơi lại cùng mini-game) bị tạm dừng do cửa sổ Cursor đang thu nhỏ (`visibilityState: hidden`) khiến WebGL2 không render khung hình mới.
- Mở trực tiếp từ tương tác 3D bằng phím `E` trước NPC (`professor_owl`, `lily`, `rocky`) và rương/vật thể (`obj_village_chest`) chưa bấm hoàn tất trực tiếp trên phiên WebGL2 (đã xác nhận kết nối trong code và static validator).
- Chưa chạy file thực thi Windows native (`Godot.exe` không có sẵn trong môi trường CLI hiện tại; build được kiểm chứng qua CI GitHub Actions export WebGL2).

## 3. Đánh giá Android / iOS
- **Thiết kế tương thích cảm ứng:** Nút bấm kích thước tối thiểu `48–68px`, chọn chạm trực tiếp (không đòi hỏi kéo thả pixel chính xác), hỗ trợ gõ phím/nút ảo, bố cục `CanvasLayer` responsive co giãn theo viewport.
- **Lưu ý trung thực:** Chưa chạy build APK/IPA trực tiếp trên thiết bị Android/iOS vật lý; mới kiểm thử thực tế trên trình duyệt Chromium (Windows) chạy bản WebGL2.

