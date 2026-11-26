# MINI-GAME LEARNING FEEDBACK SYSTEM (`MiniGameFeedback`)

## Quy tắc bắt buộc
Mọi câu trả lời trong tất cả 8 mini-game đều trả về phản hồi có cấu trúc qua `MiniGameFeedback.build_item_feedback(...)` kết hợp `AssessmentEngine.build_feedback(...)`:
- **Khi đúng:** Khen ngợi tích cực + hiển thị đáp án đầy đủ + nghĩa tiếng Việt + câu ví dụ (nếu có) + nút nghe lại âm thanh mẫu.
- **Khi sai:** Không bao giờ chỉ hiện dấu X rồi nhảy câu; luôn hiển thị *"Chưa đúng rồi! Đáp án đúng là: ..."*, nghĩa tiếng Việt, giải thích đơn giản, phát lại âm thanh mẫu và cho phép nhấn **"Thử lại"**.
