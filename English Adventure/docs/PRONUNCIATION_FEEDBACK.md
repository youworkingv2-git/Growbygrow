# PRONUNCIATION FEEDBACK ENGINE — ENGLISH ADVENTURE

## 1. Triết lý Phản hồi cho Trẻ ~10 Tuổi (`PronunciationFeedbackManager`)

- **Luôn tích cực, không gây xấu hổ**: Tuyệt đối không dùng từ ngữ chê bai hoặc chấm điểm `0` khi dịch vụ AI chưa phản hồi.
- **Chỉ hiển thị chỉ số thật**: Chỉ in `Overall`, `Accuracy`, `Fluency`, `Completeness`, `Prosody` nếu giá trị khác `null` từ dịch vụ AI.
- **Chỉ gợi ý lỗi âm vị khi có dữ liệu**: Chỉ nhắc chú ý âm `/æ/` hoặc `/ʃ/` khi `phoneme_feedback` trả về từ AI thực sự có `accuracy_score < 65`.

## 2. Các Mức Phản hồi Thân thiện

| Tình huống | Thông điệp tiếng Anh | Thông điệp tiếng Việt |
| :--- | :--- | :--- |
| Điểm tổng >= 80 | `"Great job! Your pronunciation sounds good!"` | `"Con làm tốt lắm! Phát âm rất rõ ràng!"` |
| Điểm tổng 60–79 | `"Nice try! Let's listen and polish it together."` | `"Khá lắm rồi! Hãy nghe lại mẫu và thử thêm một lần nữa nhé."` |
| Điểm tổng < 60 | `"Good try! Let's listen and practice again."` | `"Cố gắng tốt lắm! Mình cùng nghe chậm lại và nói lại nhé."` |
| Offline / Chưa nối AI | `"Self-Practice Recorded"` | `"AI đánh giá phát âm chưa kích hoạt trên máy chủ. Bé hãy nghe lại bản ghi của mình và so sánh với giọng mẫu nhé!"` |

Mọi trạng thái đều cho phép bé **Nghe mẫu**, **Nghe chậm**, **Nghe lại bản ghi của mình**, **Thử lại** hoặc **Tiếp tục bài học**.
