# QUY CHUẨN TÀI NGUYÊN HÌNH ẢNH & ÂM THANH (CONTENT ASSET GUIDELINES)
# PROJECT: ENGLISH ADVENTURE

---

## 1. Tài nguyên Hình ảnh (`assets/learning/images/`)
- **Tổng số hiện có:** **147 file SVG vector sạch** (38 hình nền tảng P4–P8 + 109 hình mới sinh từ `tools/generate_p9_svgs.py`).
- **Tỷ lệ 1:1:** Mỗi từ vựng trong `world_01_vocab.json` (115 từ) và `world_02_a1_vocab.json` (32 từ) đều có **1 hình minh họa riêng biệt**, không dùng chung một hình cho nhiều từ khác nhau gây nhầm lẫn cho trẻ.
- **Phong cách:** Vector cartoon màu sắc tươi sáng, viền rõ, không chứa chữ sai chính tả trong hình, tương thích 100% với Godot 4.3 SVG importer và WebGL2.
- **Bản quyền (`asset_license`):** Tất cả tài nguyên SVG do dự án tự tạo (`CC0-1.0 / Project Original Vector SVG`).

---

## 2. Tài nguyên Âm thanh (`assets/audio/`)
- **Trạng thái hiện tại (Trung thực tuyệt đối):**
  - Nhạc nền & SFX 3D: Có sẵn file `.wav`/procedural audio từ P7 (`assets/audio/sfx/`, `assets/audio/music/`).
  - Giọng đọc từ vựng & câu mẫu (`audio_us_path`): Toàn bộ **147 từ vựng**, **48 cụm từ**, **28 bài nghe**, **16 bài nói** đều khai báo `audio_status: "missing_asset"` vì chưa thu âm/tạo file `.ogg` riêng cho từng mục.
- **Cơ chế phát âm thanh thực tế khi chơi:**
  - `AudioManager.voice_manager` tự động sử dụng **Text-to-Speech thực tế của hệ điều hành / Web Speech API** theo cấu hình giọng `en-US` hoặc `en-GB`, hỗ trợ đọc tốc độ thường (`1.0x`) và đọc chậm (`0.85x`) mà không tạo file âm thanh giả rỗng.
- **Hướng dẫn bổ sung file `.ogg` bản địa sau này:**
  - Đặt file theo đường dẫn chuẩn `res://assets/audio/voice/en_us/<word_id>.ogg`.
  - Chỉ đổi `audio_status` sang `"ready"` sau khi file vật lý tồn tại trên đĩa và vượt qua kiểm tra `check_audio_honesty()` trong `validate_prompt_09.py`.
