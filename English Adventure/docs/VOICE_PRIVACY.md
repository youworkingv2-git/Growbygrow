# VOICE PRIVACY & CHILD SAFETY — ENGLISH ADVENTURE

## 1. Cam kết Bảo vệ Quyền riêng tư Trẻ em

1. **Xin quyền đúng lúc (Just-in-time)**: Chỉ yêu cầu quyền Microphone khi bé nhấn nút `Bật Micro` hoặc `2. Ghi âm`, kèm giải thích tiếng Việt rõ ràng.
2. **Không ghi âm nền / liên tục**: Chỉ thu âm khi `SpeechRecorder` đang ở trạng thái chủ động sau khi bé bấm nút; tự động dừng tối đa ở `15.0` giây.
3. **Không tự động gửi audio lên Cloud**: Bản ghi âm chỉ nằm tạm trên bộ nhớ RAM / Blob URL cục bộ để bé nghe lại. Chỉ gửi lên backend khi bé chủ động bấm `4. Gửi đánh giá phát âm`.
4. **Không lưu trữ bản ghi giọng nói trẻ vô thời hạn**:
   - Client xóa buffer/Blob URL ngay khi nhấn `Hủy bản ghi`, ghi lại, hoặc thoát màn hình luyện nói (`_exit_tree`).
   - Database Supabase (`0006_audio_voice_pronunciation.sql`) chỉ lưu siêu dữ liệu học tập (`expected_text`, điểm số, thời gian) — **không có cột hay bucket lưu file giọng nói trẻ**.
5. **Không lộ API Secret**: Mọi API Key AI nằm hoàn toàn trong biến môi trường của Supabase Edge Function.
6. **Không thu thập dữ liệu để huấn luyện AI**: Khi chọn Azure AI Speech, mặc định dịch vụ xử lý real-time/short-audio trong bộ nhớ với **zero data retention** và **logging tắt mặc định** (xác minh từ tài liệu Microsoft Learn).
7. **Không khóa tiến trình khi từ chối Micro**: Bé từ chối cấp quyền Micro vẫn hoàn thành được bài học và game bằng chế độ nghe mẫu & tự luyện.
