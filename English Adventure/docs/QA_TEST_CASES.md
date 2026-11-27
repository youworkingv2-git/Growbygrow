# QA TEST CASES – ENGLISH ADVENTURE (PROMPT 08)

Tài liệu liệt kê các kịch bản kiểm thử đầu cuối bắt buộc (`TC01–TC10`) cùng các ca kiểm thử biên cho Quest, Learning Engine, Mini-Game, Audio/Mic, Save/Load, Offline và Đa nền tảng.

---

## 1. Kịch bản kiểm thử đầu cuối bắt buộc (TC01 – TC10)

| Mã | Tên kịch bản | Các bước kiểm thử | Kết quả mong đợi |
|---|---|---|---|
| **TC01** | **New Game** | Khởi động game → vào Main Menu → bấm *Bắt đầu Phiêu lưu mới* → chọn Girl (Mia) rồi Boy (Leo) → nhập biệt danh → xác nhận → qua *World Introduction* → vào *Welcome Village*. | Game không treo màn hình đen; Boy và Girl hiển thị đúng, có khả năng tương đương; nhân vật xuất hiện tại `Welcome Village` cùng Buddy. |
| **TC02** | **Character Movement & Camera** | Giữ `W`/`A`/`S`/`D`, bấm `Space` nhảy, kéo chuột xoay camera, kiểm tra va chạm biên & địa hình. | Nhân vật di chuyển/nhảy mượt, không rơi khỏi bản đồ, không kẹt địa hình; `SpringArm3D` không xuyên mặt đất và làm mờ vật cản hợp lý. |
| **TC03** | **NPC Dialogue** | Tiến lại gần `Professor Owl` (`<= 2.6m`) → bấm `[E]` → đọc hội thoại song ngữ EN/VI → chuyển tiếp các câu → mở `QuestIntroPopup` → bấm nhận *Quest 01*. | Không tương tác được từ khoảng cách quá xa; hội thoại hiển thị tên, nội dung EN/VI; nhận nhiệm vụ cập nhật Quest Tracker & phát duy nhất 1 toast. |
| **TC04** | **Learning Activity** | Mở `LearningHubModal` (`[L]`) → duyệt tab *Bài học*, *Chữ cái & Âm*, *Từ vựng*, *Mẫu câu* → bấm nút nghe tên chữ `A` và âm `'apple'` → trả lời câu hỏi. | Bài học tải đúng từ `LearningEngine`; tách biệt Letter Name `/eɪ/` và Letter Sound `/æ/`; phát âm thanh chuẩn và phản hồi đúng/sai rõ ràng. |
| **TC05** | **Mini-game Integration** | Mở Arcade (`[G]`) hoặc từ Quest → chọn `Listen and Find` → bấm *Bắt đầu* → thử chọn sai (kiểm tra khóa nút khi feedback mở) → hoàn thành → kiểm tra tiến độ Quest. | Không cho bấm đúp/chọn nhiều đáp án khi feedback đang mở; điểm & sao tính đúng; kết quả đồng bộ về `QuestManager` và `LearningProgressManager`. |
| **TC06** | **Quest Completion & Reward** | Hoàn thành đủ mục tiêu của `Quest 01` → quay lại `Professor Owl` hoặc Claim từ Quest Log → nhận thưởng EXP/Gold/Item. | Chuyển trạng thái `Completed` → `Claimed`; thưởng cộng vào hồ sơ, vật phẩm vào túi đồ; bấm nhận lại không bị nhân đôi phần thưởng. |
| **TC07** | **World Progression** | Mở *Bản Đồ Đảo* (`[M]`) → thử bấm vào khu vực đang khóa (`Alphabet Meadow` / `Letter Cave`) → sau khi mở khóa `Alphabet Meadow`, di chuyển sang khu vực mới. | Khu vực khóa hiện popup thông báo lý do và bị chặn bởi `SceneRouter.enter_area()`; khu vực đã mở vào được bình thường và cập nhật bản đồ 3D. |
| **TC08** | **Save and Load** | Thoát/đóng trình duyệt hoàn toàn → mở lại game với cùng profile → kiểm tra nút *Tiếp tục Phiêu Lưu*, tên nhân vật, cấp độ, khu vực, nhiệm vụ và vật phẩm. | Hiển thị đúng `Leo (Lv.1) — Làng Khởi Đầu`; bấm *Tiếp tục* vào đúng khu vực và giữ nguyên tiến độ. |
| **TC09** | **Offline Mode** | Ngắt kết nối mạng (CDP `offline=true`) → di chuyển, mở bài học đã tải, bấm nút *Lưu* → khôi phục mạng. | Không khóa game khi mất mạng; dữ liệu học tập cục bộ hoạt động bình thường; thao tác lưu vẫn ghi local an toàn và xếp hàng outbox. |
| **TC10** | **Audio, Speaking & Mic Permission** | Mở hoạt động Speaking / `Speaking Hero` → bấm *Nghe mẫu* → thử bấm *Ghi âm* khi chưa cấp quyền/không có mic → kiểm tra phản hồi & điểm AI. | Nghe mẫu TTS/WAV hoạt động; không tự gửi audio khi chưa xác nhận; khi từ chối/thiếu mic báo thông báo thân thiện; không tạo điểm AI giả. |

## 2. Ca kiểm thử biên & Hồi quy (Regression Cases)

| Mã | Mục tiêu | Kết quả mong đợi |
|---|---|---|
| **REG-01** | Đọc `SaveLoadManager.is_online` và đổi trạng thái mạng qua `set_online_status()` | Thuộc tính tồn tại, mặc định an toàn, không gây lỗi runtime khi gọi AI Pronunciation/STT. |
| **REG-02** | Hỏng file `active_profile.json` khi có `active_profile.bak.json` | `SaveLoadManager.load_state()` tự phục hồi từ file backup `.bak.json` mà không mất tiến độ người chơi. |
| **REG-03** | Thu thập chữ cái A/B/C hoặc `obj_lake_crystal` **trước** khi nhận Quest 02/03 | `_sync_precompleted_world_objectives()` tự đồng bộ tiến độ, không bị soft-lock nhiệm vụ. |
| **REG-04** | Thoát Learning Hub / chuyển tab / thoát Mini-game / thoát về Main Menu khi TTS hoặc ghi âm đang chạy | Âm thanh thoại dừng ngay (`stop_all_speech()`) và buffer ghi âm được dọn sạch (`clear_recording(false)`). |
| **REG-05** | Mở game trên màn hình điện thoại dọc `390x844` (Mobile Portrait) | `SceneRouter` áp dụng `content_scale_factor = 2.0`, `MainMenuUI` xếp dọc, `AdventureHUD` hiện Virtual Joystick không che Bottom Dock. |
