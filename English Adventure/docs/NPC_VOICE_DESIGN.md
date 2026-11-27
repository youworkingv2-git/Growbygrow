# NPC VOICE DESIGN & LIP SYNC — ENGLISH ADVENTURE

## 1. Cấu hình Giọng đọc Từng Nhân vật (`data/audio/voice_profiles.json`)

| NPC ID | Tên hiển thị | Ưu tiên MVP | Pitch | Rate | Phong cách |
| :--- | :--- | :--- | :---: | :---: | :--- |
| `professor_owl` | Giáo sư Cú Mèo | **Primary** | `0.90` | `0.84` | Ấm áp, rõ ràng, kiên nhẫn khi giảng bài & giao nhiệm vụ |
| `buddy` | Buddy (Rồng Nhỏ) | **Primary** | `1.18` | `0.95` | Vui vẻ, sinh động, câu ngắn động viên trẻ |
| `lily` | Lily | Secondary | `1.12` | `0.88` | Thân thiện, nhẹ nhàng trong hội thoại |
| `rocky` | Rocky | Secondary | `0.84` | `0.90` | Khỏe khoắn, năng động |
| `crystal_guardian` | Người Gác Pha Lê | Secondary | `0.94` | `0.78` | Điềm tĩnh, huyền bí cho thử thách đặc biệt |

## 2. Đồng bộ Phụ đề (`DialogueBoxUI`)

- Hỗ trợ hiển thị song ngữ EN + VI (bật/tắt tiếng Việt), nút **Nghe thoại** (phát lại) và **Tạm dừng / Tiếp tục nghe**.
- Kiến trúc hỗ trợ trường `subtitle_segments` (`[{ text, start_sec, end_sec }]`) khi có file audio thu sẵn kèm timestamp chính xác.
- **Nguyên tắc trung thực**: Khi phát bằng TTS (không có timestamp chuẩn theo từng từ), hiển thị trọn câu tiếng Anh thay vì giả lập hiệu ứng tô sáng lệch nhịp.

## 3. Animation Miệng Nhân vật 3D (`CharacterRig3D`)

- Vì model 3D hiện tại là Procedural Placeholder Rig (`CharacterRig3D`) chưa có Blend Shape hoặc Viseme chuẩn:
  - Hệ thống sử dụng `CharacterRig3D.set_speaking(active, delta)` để mở/đóng `mouth_mesh` và gật nhẹ `head_pivot` trong khi `EventBus.voice_playback_started` đang hoạt động.
  - Tự động dừng ngay khi `EventBus.voice_playback_finished` hoặc `dialogue_ended` phát ra.
  - **Giới hạn đã ghi nhận**: Đây là animation nói cơ bản (basic mouth open/close), không phải lip-sync theo âm vị (viseme).
