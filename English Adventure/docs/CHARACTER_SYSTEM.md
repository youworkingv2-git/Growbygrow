# CHARACTER SYSTEM SPECIFICATION (PROMPT 02)
# PROJECT: ENGLISH ADVENTURE

---

## 1. NHÂN VẬT CHÍNH (PLAYER CHARACTERS)

Dữ liệu cấu hình tại `data/characters/playable_characters.json`, điều khiển bởi `PlayerController` (`scripts/character/player_controller.gd`) và `scenes/characters/player/player.tscn`:

| ID | Tên | Asset Vector | Đặc điểm |
|---|---|---|---|
| `boy` | **Leo (Boy Adventurer)** | `assets/characters/player/boy/boy_adventurer.svg` | Trang phục thám hiểm xanh dương, kính bảo hộ, ba lô nâu. |
| `girl` | **Mia (Girl Adventurer)** | `assets/characters/player/girl/girl_adventurer.svg` | Trang phục thám hiểm hồng-ngọc, băng đô xanh, ba lô vàng. |

**Nguyên tắc cân bằng:** Hai nhân vật hoàn toàn bình đẳng về tốc độ di chuyển (`walk_speed = 235`, `run_speed = 340`), khả năng học tập và phần thưởng; hỗ trợ lưu lựa chọn vào hồ sơ và mở rộng trang phục sau này.

### Hệ thống Hoạt ảnh (`CharacterAnimator` – `scripts/character/character_animator.gd`)
Hỗ trợ đầy đủ 7 trạng thái theo cấu trúc chuẩn:
- `IDLE` (thở nhẹ)
- `WALK` (nhún bước đi + nghiêng nhẹ)
- `RUN` (nhún nhanh hơn khi giữ `Shift` hoặc đẩy joystick hết biên)
- `JUMP` (nhảy vòng cung `Space` / nút Nhảy)
- `INTERACT` (nhịp tương tác khi mở rương / nói chuyện)
- `CELEBRATE` (nhảy mừng)
- `HURT` (rung nhẹ báo va chạm/sai cho gameplay sau này)

### Điều khiển Đa nền tảng
- **Desktop/Web:** `WASD` hoặc Phím mũi tên để di chuyển, `Shift` để chạy, `Space` để nhảy, `E` để tương tác, `H` để hỏi Buddy.
- **Mobile/Tablet:** Tự động hiển thị `VirtualJoystick` (góc dưới trái) + các nút chạm lớn `Tương tác`, `Nhảy`, `Hỏi Buddy` (góc dưới phải).

---

## 2. NHÂN VẬT ĐỒNG HÀNH BUDDY (`BuddyController`)

- **Script / Scene:** `scripts/character/buddy_controller.gd` / `scenes/characters/buddy/buddy.tscn`
- **Asset:** `assets/characters/buddy/buddy_dragon.svg`
- **Hành vi:** Bay lơ lửng theo sau nhân vật chính mượt mà (`lerp`), tự quay hướng nhìn về phía người chơi, hiển thị bong bóng thoại gợi ý (`SpeechBubble`) và phản ứng theo sự kiện `quest_completed`, `area_unlocked`, `dialogue_started`.
- **7 trạng thái biểu cảm hỗ trợ:** `idle`, `happy`, `sad`, `surprised`, `thinking`, `talking`, `celebrating`.
- **Điểm mở rộng giọng nói:** Đã tách trường `voice_hook_enabled` và chú thích hook trong `speak_tip()` để gắn `AudioModule` ở Prompt 03+ (chưa có file lồng tiếng thật trong Prompt 02).
