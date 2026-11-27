# SPEECH RECOGNITION (STT) — ENGLISH ADVENTURE

## 1. Vai trò & Giới hạn của Speech Recognition (`SpeechRecognitionManager`)

`SpeechRecognitionManager` chuyển bản ghi âm của người chơi thành văn bản (`recognized_text`) để kiểm tra xem người chơi có nói đúng từ/câu mục tiêu hay không.

**Nguyên tắc bắt buộc:**
- Nhận diện đúng văn bản (`"apple" == "apple"`) **KHÔNG đồng nghĩa** với phát âm chuẩn.
- Kết quả STT không bao giờ được dùng để tự sinh điểm phát âm AI giả.

## 2. Các Chế độ Hoạt động

1. `DISABLED` (Mặc định khi chưa cấu hình backend): Trả về `status = "provider_unavailable"` với thông báo trung thực.
2. `SUPABASE_PROXY`: Gửi bản ghi đã được người chơi xác nhận qua HTTPS tới Supabase Edge Function `supabase/functions/speech-recognize/index.ts`, xác thực JWT người chơi và gọi dịch vụ STT trên server (không đặt API Key trong Godot client).
3. `MOCK_DEV_ONLY`: Chỉ khả dụng trong bản build debug/test khi bật tường minh bằng `enable_dev_mock_mode(true)`. Mọi kết quả đều gắn cờ `is_mock = true` và nhãn `[MOCK - Kiểm thử]`.

## 3. Xử lý Lỗi & Môi trường

- **Mất mạng (`offline`)**: Không gửi request, thông báo rõ đang ngoại tuyến và giữ nguyên bản ghi local cho bé nghe lại.
- **Không nghe rõ / tiếng ồn (`no_speech_detected`)**: Đề nghị bé thử nói lại ở nơi yên tĩnh hơn, không phạt điểm.
