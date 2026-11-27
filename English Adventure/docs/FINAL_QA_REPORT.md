# FINAL QA REPORT – ENGLISH ADVENTURE (PROMPT 08)

**Dự án:** English Adventure (Alphabet Island MVP)  
**Thời điểm tổng kết:** 27/11/2026 (Commit `fe809d9`)  
**Phạm vi:** Giai đoạn P8 sau khi hoàn thiện P1–P7  

---

## 1. Tóm tắt điều hành

- **Trạng thái tổng thể:** Phạm vi MVP hiện tại trên **WebGL2 (Desktop & Responsive Mobile Viewport)** đã hoạt động ổn định, vượt qua toàn bộ 10 kịch bản đầu cuối (`TC01–TC10` trong giới hạn môi trường trình duyệt), **không còn lỗi P0** và **không còn lỗi P1** trong luồng gameplay chính.
- **Đã sửa 12 lỗi thực tế** (`7` lỗi P1, `5` lỗi P2) gồm lỗi runtime `SaveLoadManager.is_online`, double-toast thành tựu/nhiệm vụ, spam đáp án/phím tắt mini-game khi panel feedback mở, rò rỉ TTS/recorder khi thoát modal hoặc đổi cảnh, soft-lock Quest 02/03 nếu nhặt vật phẩm sớm, nhân bản material/mesh 3D, bố cục Mobile Portrait bị co nhỏ, và lỗi `look_at()` trước `add_child()` ở World Map 3D.
- **Tính trung thực về các tính năng chưa hoàn thiện / chưa test được:**
  - **AI Pronunciation Assessment (Azure AI Speech) & STT:** Kiến trúc và Edge Functions đã có (`pronunciation-assess`, `speech-recognize`), nhưng chưa gắn `AZURE_SPEECH_KEY` / Supabase Cloud live nên **chưa test API thật** và giữ nguyên trạng thái `Not Configured` (tuyệt đối không chấm điểm ngẫu nhiên giả).
  - **Microphone Recording thật:** Code xin quyền/ghi âm đã hoàn thiện (`SpeechRecorder`, `SpeakingPracticePanel`), nhưng môi trường Chrome headless không có phần cứng micro thật và chưa test cấp quyền/thu âm trên thiết bị Android/iOS vật lý.
  - **Native Windows / Android / iOS builds:** Chưa export và chạy trên máy thật do thiếu Godot CLI/Android SDK/macOS Xcode tại máy kiểm thử.

## 2. Đánh giá tiêu chí hoàn thành P8 (20/20 hạng mục)

1. Game khởi động được: **Đạt** (`7.45s` tới sẵn sàng trên WebGL2, `0` lỗi).
2. Chọn Boy / Girl & lưu nhân vật: **Đạt** (`02_char_select.png`, `03_char_girl_selected.png`, reload giữ nguyên `Leo`).
3. Di chuyển 3D trong Alphabet Island: **Đạt** (`WASD`, `Space`, va chạm biên).
4. Camera 3D ổn định (`SpringArm3D` + xoay chuột/chạm): **Đạt**.
5. Tương tác NPC đúng khoảng cách (`<= 2.6m`): **Đạt** (`06_village_near_owl.png`).
6. Hội thoại song ngữ EN/VI & lựa chọn: **Đạt** (`07_owl_dialogue.png`).
7. Nhận và theo dõi nhiệm vụ: **Đạt** (`QuestTracker`, `QuestManager`, `test_p8_regression_suite.gd`).
8. Mini-game kết nối Learning Engine & Quest System: **Đạt** (`11b`/`11c`, `validate_prompt_05.py`).
9. Kết quả học tập cập nhật (`LearningProgressManager`, SM-2): **Đạt** (đã xác minh code + validator).
10. Phần thưởng EXP/Gold/Crystal/Item lưu & chống nhận trùng: **Đạt** (`test_p8_regression_suite.gd`).
11. Mở khóa khu vực đúng điều kiện & chặn khu vực khóa: **Đạt** (`12b_world_map_locked_popup.png`).
12. Save/Load hoạt động qua lần mở lại trình duyệt & có backup `.bak.json`: **Đạt** (`18_reload_continued_village.png`).
13. Audio & Web Speech TTS (`en-US`/`en-GB`) hoạt động: **Đạt** (`4` câu TTS ghi nhận live, `11` file `.wav`).
14. Ghi âm & tự nghe lại: **Hoạt động ở mức mã nguồn & UI**, chưa thu âm phần cứng thật trong headless.
15. AI chấm phát âm: **Chưa tích hợp key/server thật** (`BLOCKED` — không tạo điểm giả).
16. Không còn lỗi P0: **Đạt** (`0` P0).
17. Không còn lỗi P1 trong luồng gameplay chính: **Đạt** (`0` P1 mở).
18. Lỗi tồn tại được ghi rõ: **Đạt** (`docs/KNOWN_ISSUES.md`).
19. Báo cáo hiệu suất dựa trên số liệu đo thực tế: **Đạt** (`docs/PERFORMANCE_REPORT.md`).
20. Báo cáo kiểm thử nền tảng ghi rõ thiết bị/môi trường: **Đạt** (`docs/CROSS_PLATFORM_TEST_REPORT.md`).
