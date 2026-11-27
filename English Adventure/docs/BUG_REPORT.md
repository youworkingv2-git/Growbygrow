# BUG REPORT – ENGLISH ADVENTURE (PROMPT 08)

Tài liệu ghi nhận toàn bộ lỗi phát hiện trong quá trình kiểm tra mã nguồn, kiểm thử tự động và chạy thử thực tế bản WebGL2 (P8).

---

## Tổng hợp lỗi đã phát hiện & xử lý

| Mã lỗi | Mức độ | Trạng thái | Tóm tắt |
|---|---|---|---|
| **BUG-01** | **P1 – High** | **FIXED** | Thiếu thuộc tính `SaveLoadManager.is_online`, thiếu backup `.bak.json`, kiểm tra schema chưa chặt kiểu collection |
| **BUG-02** | **P1 – High** | **FIXED** | Hiện 2 toast trùng lặp khi mở khóa thành tựu (`RewardManager` + `UIManager`) |
| **BUG-03** | **P1 – High** | **FIXED** | Hiện 2 toast trùng lặp khi bắt đầu / hoàn thành nhiệm vụ (`QuestManager` + `QuestNotificationManager`) |
| **BUG-04** | **P1 – High** | **FIXED** | Mini-games cho phép bấm nhiều đáp án hoặc phím tắt `1–5`/`Enter`/`H` khi panel phản hồi sau đáp án sai đang mở |
| **BUG-05** | **P1 – High** | **FIXED** | Âm thanh TTS / bản ghi âm tiếp tục phát hoặc rò rỉ khi đóng modal Learning Hub / Mini-game / thoát về Main Menu |
| **BUG-06** | **P2 – Medium** | **FIXED** | `GameSpeakingHero` ghi nhầm `target_text_en` thay vì `spoken_text_en` vào `transcript_en` |
| **BUG-07** | **P1 – High** | **FIXED** | Nguy cơ soft-lock Quest 02/03 nếu người chơi nhặt chữ cái hoặc pha lê trước khi nhận quest |
| **BUG-08** | **P2 – Medium** | **FIXED** | `WorldMapUI._process()` cập nhật lại toàn bộ style/kích thước/vị trí nút mỗi frame gây tốn CPU UI |
| **BUG-09** | **P2 – Medium** | **FIXED** | `AreaEnvironment3D` & `PropFactory3D` nhân bản `StandardMaterial3D`/Mesh trùng lặp; particle chưa đổi theo Quality |
| **BUG-10** | **P1 – High** | **FIXED** | `SceneRouter._transition_to()` không dừng speech/recording đang chạy khi chuyển cảnh |
| **BUG-11** | **P2 – Medium** | **FIXED** | Giao diện Mobile Portrait (`390x844`) giữ bố cục ngang nhỏ khó đọc do `vp.x = 1280` dưới `stretch/aspect="expand"` |
| **BUG-12** | **P2 – Medium** | **FIXED** | `AlphabetIsland3DMap` gọi `_camera.look_at()` trước `add_child(_camera)` gây `USER ERROR: Node not inside tree` |

---

## Chi tiết từng lỗi

### BUG-01 (P1 – High) – `SaveLoadManager.is_online` thiếu + Backup & Schema validation
- **Nguyên nhân:** `PronunciationAssessmentManager` và `SpeechRecognitionManager` đọc `SaveLoadManager.is_online`, nhưng `SaveLoadManager` chỉ có biến nội bộ `_is_online_simulated`. Ngoài ra `save_state` không tạo file `.bak.json` dự phòng và `_validate_save_schema` chưa kiểm tra kiểu `Array`/`Dictionary`.
- **Cách sửa (`scripts/services/save_load_manager.gd`):** Thêm `var is_online: bool = false`, `refresh_online_status()`, `set_online_status()`; ghi xoay vòng `active_profile.bak.json` trước khi ghi đè; tự phục hồi từ `.bak.json` khi file chính hỏng; cập nhật `last_saved_unix` mỗi lần lưu và kiểm tra kiểu dữ liệu từng trường schema.

### BUG-02 (P1 – High) – Toast thành tựu bị nhân đôi
- **Nguyên nhân:** `RewardManager.evaluate_achievements()` vừa emit `EventBus.achievement_unlocked` (được `UIManager` hiển thị toast) vừa emit thêm `EventBus.toast_requested`.
- **Cách sửa (`scripts/progression/reward_manager.gd`):** Xóa `toast_requested` trùng lặp, giữ duy nhất `EventBus.achievement_unlocked`.

### BUG-03 (P1 – High) – Toast bắt đầu / hoàn thành nhiệm vụ bị nhân đôi
- **Nguyên nhân:** `QuestManager` emit `quest_started` / `quest_completed`, đồng thời `QuestNotificationManager` lại emit thêm `toast_requested` cho cùng hai sự kiện đó.
- **Cách sửa (`scripts/quest/quest_notification_manager.gd`):** Gỡ bỏ `toast_requested` trùng ở `notify_started()` và `notify_completed()`, giữ lại `notify_objective_updated()`.

### BUG-04 (P1 – High) – Chọn nhiều đáp án / spam phím khi đang mở Feedback Mini-game
- **Nguyên nhân:** Khi trả lời sai ở các mini-game (`Listen & Find`, `Sound Detective`, `Word Builder`, `Sentence Builder`, `Dialogue Adventure`), `MiniGameUI._feedback_panel` hiện nút *Thử lại*, nhưng các nút đáp án và phím `1–5`, `Enter`, `H` vẫn nhận input.
- **Cách sửa (`scripts/minigames/minigame_controller.gd`, `minigame_ui.gd`, 5 file `game_*.gd`):** Thêm `_input_locked` + `set_input_locked()`, khóa ngay khi hiện feedback sai/đúng và chỉ mở khóa khi bấm *Thử lại* hoặc sang câu mới.

### BUG-05 & BUG-10 (P1 – High) – Rò rỉ TTS & ghi âm khi đóng màn hình hoặc chuyển cảnh
- **Nguyên nhân:** Đóng `LearningHubModal`, đổi tab, đóng `MiniGameManager` hoặc chuyển scene qua `SceneRouter` không dừng `playback_manager.stop_all_speech()` và không dọn `speech_recorder`.
- **Cách sửa (`scripts/learning/learning_hub_modal.gd`, `scripts/minigames/minigame_manager.gd`, `scripts/core/scene_router.gd`):** Chủ động dừng toàn bộ speech và gọi `clear_recording(false)` tại mọi điểm đóng/chuyển tab/chuyển cảnh.

### BUG-06 (P2 – Medium) – `GameSpeakingHero` lưu sai chuỗi transcript khi tự luyện
- **Nguyên nhân:** `_complete_self_practice()` truyền `target_text_en` thay vì `spoken_text_en` vào `record_answer(..., transcript_en)`.
- **Cách sửa (`scripts/minigames/games/game_speaking_hero.gd`):** Đổi tham số sang `spoken_text_en` khi có sẵn.

### BUG-07 (P1 – High) – Soft-lock Quest 02/03 nếu thu thập vật phẩm trước khi nhận quest
- **Nguyên nhân:** `InteractableObject` ẩn vĩnh viễn các vật thể `lost_letter` và `crystal` sau khi nhặt. Nếu người chơi nhặt trước khi nhận Quest 02 hoặc trước khi mở bước `q3_step_5`, bước nhiệm vụ mới không tự hoàn thành.
- **Cách sửa (`scripts/quest/quest_manager.gd`):** Thêm `_sync_precompleted_world_objectives(quest_id)` (có cờ chống đệ quy `_syncing_precompleted`) chạy ngay khi nhận quest và khi chuyển bước.

### BUG-08 (P2 – Medium) – `WorldMapUI._process` dựng lại layout mỗi frame
- **Nguyên nhân:** `_layout_map_nodes()` đặt lại `custom_minimum_size`, `font_size` override và `btn.position` trên mọi frame bất kể bản đồ có thay đổi hay không.
- **Cách sửa (`scripts/ui/world_map_ui.gd`):** Cache `_last_canvas_size` và `_last_node_positions`, chỉ cập nhật khi kích thước đổi hoặc tọa độ dịch chuyển `> 0.5px`.

### BUG-09 (P2 – Medium) – Nhân bản Material/Mesh 3D và hạt môi trường không đổi theo Quality
- **Nguyên nhân:** `AreaEnvironment3D` và `PropFactory3D` tạo mới `StandardMaterial3D` và `Mesh` cho từng vật thể lặp; `WorldEnvironment3DController` không điều khiển particle khi đổi chất lượng đồ họa.
- **Cách sửa (`scripts/visual3d/area_environment_3d.gd`, `prop_factory_3d.gd`, `world_environment_3d.gd`):** Thêm static `_mat_cache` (giữ material riêng cho cây/nhà/đèn cần fade khi che camera) và `_mesh_cache`, gắn nhóm `"quality_particles"` để bật/tắt/giảm mật độ hạt theo `low`/`medium`/`high`.

### BUG-11 (P2 – Medium) – Giao diện Mobile Portrait (`390x844`) hiển thị quá nhỏ và không xếp dọc
- **Nguyên nhân:** Dự án dùng `stretch/mode="canvas_items"` + `stretch/aspect="expand"`, khiến viewport logic ở `390x844` có kích thước `(1280, 2770)`. Vì `vp.x == 1280`, các điều kiện `vp.x < 700.0` ở `MainMenuUI` không kích hoạt và font/nút bị co nhỏ ~`0.305x`.
- **Cách sửa (`scripts/core/scene_router.gd`, `scripts/ui/screens/main_menu_ui.gd`, `scripts/ui/adventure_hud.gd`):** Trong `SceneRouter._update_breakpoint()`, đặt `content_scale_factor = 2.0` khi màn hình dọc (`win_size.y > win_size.x`) để kích thước logic trở thành `640 x 1385`; đồng thời cập nhật kiểm tra `is_portrait` trong `MainMenuUI` và rút gọn nhãn dock/top bar ở `AdventureHUD` khi `vp.x < 700.0`.
- **Kết quả kiểm chứng:** Xác nhận trực quan qua ảnh chụp màn hình `01b_mobile_portrait_main_menu.png` và `14_mobile_portrait_village.png` trên Chrome `390x844`: nút bấm, chữ và joystick rõ ràng, không đè chồng.

### BUG-12 (P2 – Medium) – Lỗi `look_at` khi chưa thêm Camera vào SceneTree ở World Map 3D
- **Nguyên nhân:** `AlphabetIsland3DMap._ready()` gọi `_camera.look_at(Vector3.ZERO, Vector3.UP)` ngay trước `add_child(_camera)`, gây lỗi engine `USER ERROR: Node not inside tree. Use look_at_from_position() instead.` khi mở Bản Đồ Đảo.
- **Cách sửa (`scripts/visual3d/alphabet_island_3d_map.gd`):** Đưa `add_child(_camera)` lên trước `_camera.look_at(...)` và kiểm tra `_camera.is_inside_tree()` trong `_process()`.
