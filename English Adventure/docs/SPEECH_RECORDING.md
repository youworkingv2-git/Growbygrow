# SPEECH RECORDING — ENGLISH ADVENTURE

## 1. Tổng quan `SpeechRecorder` (`scripts/audio/speech_recorder.gd`)

`SpeechRecorder` cung cấp khả năng thu âm giọng nói người chơi theo cơ chế chủ động và bảo vệ quyền riêng tư trẻ em:

- **Windows / Android / iOS (Native)**: Sử dụng `AudioStreamMicrophone` kết hợp `AudioEffectRecord` trên bus `"Record"` (được mute đầu ra).
  - Kiểm tra danh sách thiết bị đầu vào (`AudioServer.get_input_device_list()`).
  - Xin quyền hệ điều hành (`OS.request_permissions()`) trên Android/iOS khi người chơi bấm nút ghi âm hoặc `Bật Micro`.
  - Phân tích tín hiệu WAV cơ bản sau ghi âm (`_analyze_wav_quality`): đo `rms_db`, `peak_db`, phát hiện nói quá nhỏ (`too_quiet`) hoặc bị rè/quá sát (`clipped`).
- **WebGL2 (Browser)**: Tích hợp `navigator.mediaDevices.getUserMedia` + `MediaRecorder` thông qua bridge `window.__eaRecorder` chỉ kích hoạt khi người chơi nhấn nút; phát lại qua Blob URL cục bộ và thu hồi bộ nhớ (`URL.revokeObjectURL`) ngay khi hủy hoặc ghi lại.

## 2. Quy trình Giao diện (`SpeakingPracticePanel`)

1. `1. Nghe mẫu` / `Nghe chậm`
2. `Bật Micro` (nếu chưa cấp quyền)
3. `2. Ghi âm` -> Thanh thời lượng (`0.0s / 15.0s`) + Thanh mức tín hiệu Micro -> `Tạm dừng` / `Dừng`
4. `3. Nghe lại` / `Ghi lại` / `Hủy bản ghi`
5. `4. Gửi đánh giá phát âm` (chỉ thực hiện khi bé bấm nút xác nhận) hoặc tự xác nhận hoàn thành (`Mình đã nói to, rõ rồi!` / `Cần luyện thêm câu này`).

## 3. Xử lý Khi Từ chối Quyền Micro / Không có Thiết bị

- Hiển thị thông báo tiếng Việt nhẹ nhàng.
- Không khóa tiến trình học hay nhiệm vụ: bé vẫn nghe được âm thanh mẫu, xem khẩu hình/IPA và hoàn thành các bài học/mini-game khác bình thường.
