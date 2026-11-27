# AI SPEECH & PRONUNCIATION PROVIDER COMPARISON (Verified Nov 2026)

Tài liệu này tổng hợp kết quả nghiên cứu từ tài liệu chính thức của các nhà cung cấp dịch vụ Speech / Pronunciation Assessment nhằm lựa chọn giải pháp tối ưu cho **English Adventure**.

## 1. Bảng So sánh Theo 10 Tiêu chí

| Tiêu chí | Microsoft Azure AI Speech (Pronunciation Assessment) | Google Cloud Speech-to-Text (v1 / v2) | Speechace API (`v9`) |
| :--- | :--- | :--- | :--- |
| **1. Hỗ trợ tiếng Anh** | Có (`en-US`, `en-GB`, và nhiều biến thể khác). | Có (`en-US`, `en-GB`, ...). | Có (`en-us`, `en-gb`, ...). |
| **2. Đánh giá phát âm chuyên sâu** | **Có** (Model chuyên dụng riêng cho Pronunciation Assessment). | **Không** — Chỉ là dịch vụ Speech-to-Text (trả về transcript & word confidence, không chấm chất lượng phát âm). | **Có** (Chuyên dụng cho đánh giá phát âm: `Score Text`, `Score Word`, `Score Speech`). |
| **3. Điểm ở cấp từ** | **Có** (`Words[].PronunciationAssessment.AccuracyScore` + `ErrorType`: None/Omission/Insertion/Mispronunciation). | Chỉ có `confidence` nhận diện STT, không phải độ chuẩn phát âm. | **Có** (`quality_score` & `stress_score` từng từ). |
| **4. Phản hồi ở cấp âm vị (Phoneme)** | **Có** (`Granularity: Phoneme`, `PhonemeAlphabet: IPA` hoặc `SAPI`). | **Không**. | **Có** (`quality_score` từng âm tiết & âm vị). |
| **5. Hỗ trợ Anh-Mỹ (`en-US`) & Anh-Anh (`en-GB`)** | Có cả `en-US` và `en-GB`. *Lưu ý đã xác minh*: `ProsodyScore` và syllable-level hiện chỉ hỗ trợ `en-US`. | Có cả `en-US` và `en-GB` (chỉ STT). | Có cả `en-us` và `en-gb` (kể cả intonation cho English). |
| **6. Lưu ý trẻ em / Độ tuổi** | Cần backend kiểm soát độ tuổi/tuân thủ pháp luật (COPPA/GDPR-K); không thu thập thông tin cá nhân trẻ khi chỉ gửi audio ẩn danh. | Cần tuân thủ chính sách dữ liệu trẻ em từ phía ứng dụng gọi API. | Dùng `user_id` ẩn danh do app sinh ra, ứng dụng chịu trách nhiệm tuân thủ COPPA. |
| **7. SDK / REST API** | REST API short-audio (`POST https://<resource>.cognitiveservices.azure.com/stt/speech/recognition/conversation/cognitiveservices/v1?language=...&format=detailed` + header `Pronunciation-Assessment` Base64 JSON) & Speech SDK. | REST / gRPC (`speech.recognize`). | REST API (`POST https://api.speechace.co/api/scoring/text/v9/json`, multipart form-data). |
| **8. Chi phí & Mô hình tính phí** | Tính phí theo thời lượng audio ngang mức Standard Speech-to-Text (có gói Free/Pay-as-you-go & Commitment tier theo tài liệu Azure). | Tính phí theo thời lượng 15 giây / phút STT. | Gói đăng ký thương mại / theo lượt hoặc phút API riêng của Speechace. |
| **9. Giới hạn dung lượng & thời lượng** | Short-audio REST API giới hạn **<= 30 giây** cho Pronunciation Assessment (60s cho STT thường); streaming qua Speech SDK không giới hạn thời gian. | Synchronous REST <= 1 phút audio. | `Score Text` hỗ trợ tối đa **45 giây** mỗi yêu cầu. |
| **10. Bảo mật & Lưu trữ dữ liệu** | **Zero retention mặc định** cho real-time/short-audio REST (xử lý trong RAM, audio logging tắt mặc định; nếu bật mới lưu tối đa 30 ngày và xóa được). | Cần cấu hình Data Logging opt-out; mặc định xử lý theo điều khoản Google Cloud. | Theo điều khoản tài khoản Speechace (gửi qua API key ở backend). |

## 2. Quyết định Lựa chọn cho MVP & Lý do

- **Lựa chọn MVP**: **Microsoft Azure AI Speech Pronunciation Assessment** kết nối qua **Supabase Edge Function** (`supabase/functions/pronunciation-assess/index.ts`).
- **Lý do**:
  1. Đáp ứng thật cả **PronScore (Overall)**, **Accuracy**, **Fluency**, **Completeness**, **Prosody (`en-US`)**, **Word ErrorType**, và **Phoneme-level IPA feedback** qua một REST API gọn nhẹ (`<= 30s` — hoàn toàn phù hợp từ đơn và câu ngắn của trẻ 10 tuổi).
  2. Hỗ trợ đồng thời `en-US` và `en-GB`.
  3. Chính sách **zero retention mặc định** (xử lý trên RAM, tắt logging mặc định) phù hợp nghiêm ngặt cho ứng dụng giáo dục trẻ em.
  4. Google Cloud Speech-to-Text **bị loại khỏi vai trò Pronunciation Assessment** vì chỉ cung cấp STT transcript, chỉ phù hợp làm STT adapter nếu cần nhận diện văn bản thuần túy.

## 3. Tài liệu Chính thức Đã Kiểm chứng

- Microsoft Learn — *Speech to text REST API for short audio*: `https://learn.microsoft.com/en-us/azure/ai-services/speech-service/rest-speech-to-text-short`
- Microsoft Learn — *Use pronunciation assessment*: `https://learn.microsoft.com/en-us/azure/ai-services/speech-service/how-to-pronunciation-assessment`
- Microsoft Learn — *Data, privacy, and security for Speech to text*: `https://learn.microsoft.com/en-us/azure/foundry/responsible-ai/speech-service/speech-to-text/data-privacy-security`
- Google Cloud Docs — *Cloud Speech-to-Text Overview*: `https://docs.cloud.google.com/speech-to-text/docs/overview`
- Speechace API Docs — *Score Text*: `https://api-docs.speechace.com/api-reference/score-text`
