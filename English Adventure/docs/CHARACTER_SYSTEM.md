# CHARACTER SYSTEM SPECIFICATION (PROMPT 02)
# PROJECT: ENGLISH ADVENTURE

---

## 1. NHÂN VẬT CHÍNH (PLAYER CHARACTERS – 3D STYLIZED RIG)

Dữ liệu cấu hình tại `data/characters/playable_characters.json`, điều khiển bởi `PlayerController` (`CharacterBody3D` – `scripts/character/player_controller.gd`) và `scenes/characters/player/player.tscn`:

| ID | Tên | Mô hình 3D (Hiện tại) | Đặc điểm |
|---|---|---|---|
| `boy` | **Leo (Boy Adventurer)** | `CharacterRig3D("boy")` via `Asset3DSlot` *(3D Placeholder có khớp)* | Trang phục thám hiểm xanh dương, mũ thám hiểm có lông vũ, ba lô nâu, giày bốt. |
| `girl` | **Mia (Girl Adventurer)** | `CharacterRig3D("girl")` via `Asset3DSlot` *(3D Placeholder có khớp)* | Trang phục thám hiểm hồng-ngọc, tóc tết 2 bên + kẹp ngôi sao, ba lô & váy thám hiểm. |

**Lưu ý Asset:** Nhân vật 3D hiện tại là **mô hình placeholder 3D có hình dáng rõ ràng và đầy đủ khớp chuyển động** (không dùng ảnh PNG phẳng trong thế giới 3D), sẵn sàng thay thế bằng file `.glb` qua `Asset3DSlot`. Xem chi tiết tại [`docs/ASSET_3D_PIPELINE.md`](ASSET_3D_PIPELINE.md).

**Nguyên tắc cân bằng:** Hai nhân vật hoàn toàn bình đẳng về tốc độ di chuyển (`walk_speed = 6.2 m/s`, `run_speed = 9.2 m/s`, `jump_velocity = 7.4 m/s`), khả năng học tập và phần thưởng; hỗ trợ lưu lựa chọn vào hồ sơ và mở rộng trang phục sau này.

### Hệ thống Hoạt ảnh 3D (`CharacterAnimator` – `scripts/character/character_animator.gd`)
Hỗ trợ đầy đủ 7 trạng thái trên khớp 3D (`body_pivot`, `head_pivot`, `arm_pivots`, `leg_pivots`, tự xoay hướng theo vector di chuyển):
- `IDLE` (thở nhẹ)
- `WALK` (nhún bước đi + nghiêng nhẹ)
- `RUN` (nhún nhanh hơn khi giữ `Shift` hoặc đẩy joystick hết biên)
- `JUMP` (nhảy vòng cung `Space` / nút Nhảy)
- `INTERACT` (nhịp tương tác khi mở rương / nói chuyện)
- `CELEBRATE` (nhảy mừng)
- `HURT` (rung nhẹ báo va chạm/sai cho gameplay sau này)

### Điều khiển Đa nền tảng
- **Desktop/Web:** `WASD` hoặc Phím mũi tên để di chuyển theo góc camera, chuột phải/giữa kéo hoặc `Q` / `C` để xoay camera, cuộn chuột để zoom, `Shift` để chạy, `Space` để nhảy 3D, `E` để tương tác, `H` để hỏi Buddy.
- **Mobile/Tablet:** Tự động hiển thị `VirtualJoystick` (góc dưới trái) + các nút chạm lớn `Tương tác`, `Nhảy`, `Hỏi Buddy` (góc dưới phải).

---

## 2. NHÂN VẬT ĐỒNG HÀNH BUDDY 3D (`BuddyController`)

- **Script / Scene:** `scripts/character/buddy_controller.gd` / `scenes/characters/buddy/buddy.tscn` (`Node3D`)
- **Mô hình 3D:** `CharacterRig3D("buddy")` via `Asset3DSlot` *(Rồng nhỏ 3D có cánh vỗ, đuôi phát sáng, sừng vàng và biểu cảm khuôn mặt 3D)*
- **Hành vi:** Bay lơ lửng theo sau nhân vật chính mượt mà trong không gian 3D (`lerp`), vỗ cánh & vẫy đuôi liên tục, tự quay hướng nhìn về phía người chơi, chiếu bong bóng thoại gợi ý (`SpeechBubble`) lên màn hình bằng `Camera3D.unproject_position()` và phản ứng theo sự kiện `quest_completed`, `area_unlocked`, `dialogue_started`.
- **7 trạng thái biểu cảm hỗ trợ:** `idle`, `happy`, `sad`, `surprised`, `thinking`, `talking`, `celebrating`.
- **Điểm mở rộng giọng nói:** Đã tách trường `voice_hook_enabled` và chú thích hook trong `speak_tip()` để gắn `AudioModule` ở Prompt 03+ (chưa có file lồng tiếng thật trong Prompt 02).
