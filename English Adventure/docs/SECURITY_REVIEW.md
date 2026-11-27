# SECURITY & CHILD SAFETY REVIEW – ENGLISH ADVENTURE (PROMPT 08)

**Phạm vi kiểm tra:** Mã nguồn Godot client (`scripts/`, `project.godot`, `.env.example`, `data/`), cấu trúc lưu cục bộ (`user://`), Supabase SQL Migrations (`0001`–`0006`) và Supabase Edge Functions (`pronunciation-assess`, `speech-recognize`).

---

## 1. Kết quả kiểm tra bảo mật kỹ thuật

| Hạng mục | Trạng thái | Chi tiết kiểm chứng |
|---|---|---|
| **Không lộ API Key / Secret trong Client** | **PASS** | Đã quét toàn bộ mã nguồn qua `validate_prompt_08.py`: không tìm thấy `SUPABASE_SERVICE_ROLE_KEY`, `AZURE_SPEECH_KEY`, token JWT cứng hay mật khẩu trong `scripts/`, `scenes/`, `data/`, `project.godot`. |
| **Supabase RLS (Row Level Security)** | **PASS (Static SQL)** | Kiểm tra `0002_rls_policies.sql` và các migration `0003`–`0006`: toàn bộ **32+ bảng** đều bật `ENABLE ROW LEVEL SECURITY` và giới hạn quyền truy cập theo `auth.uid()` / `player_profiles`. |
| **Edge Functions Guard cho AI/STT** | **PASS (Code Audit)** | `supabase/functions/pronunciation-assess/index.ts` và `speech-recognize/index.ts` đều xác thực Bearer JWT với Supabase Auth (`supabase.auth.getUser()`), kiểm tra kích thước payload tối đa (8 MB), và lưu `AZURE_SPEECH_KEY` hoàn toàn phía server (`Deno.env.get`). |
| **Logging an toàn** | **PASS** | `AppLogger` viết log cục bộ tại `user://logs/` và không in thông tin nhạy cảm hay API secret ra console. |
| **Lưu cục bộ & Phục hồi hỏng file** | **PASS** | `SaveLoadManager` lưu tại `user://profiles/active_profile.json` kèm bản sao lưu `active_profile.bak.json`, có xác thực kiểu schema trước khi nạp để tránh crash từ file bị chỉnh sửa/hỏng. |

## 2. An toàn & Quyền riêng tư cho trẻ em (~10 tuổi)

- **Quyền Microphone & Ghi âm:**
  - `SpeechRecorder` chỉ thu âm khi người chơi bấm nút ghi âm trong `SpeakingPracticePanel` hoặc `GameSpeakingHero`; không tự động ghi âm nền.
  - Khi người chơi rời màn hình học tập, chuyển tab hoặc chuyển cảnh, `clear_recording(false)` hủy buffer ghi âm tạm.
  - **Không tự động gửi dữ liệu giọng nói lên máy chủ:** Người chơi phải bấm nút gửi đánh giá mới truyền audio (và hiện tại nếu chưa cấu hình Supabase Proxy/API, tính năng đánh giá AI từ chối gửi thay vì giả lập).
- **Không quảng cáo, không liên kết ngoài, không chat công khai:** Không có module quảng cáo, không có chat giữa người chơi, không có đường dẫn ra mạng xã hội trong UI game.
- **Thu thập dữ liệu tối thiểu:** Chỉ lưu biệt danh (nickname tự chọn/gợi ý), giới tính nhân vật (`boy`/`girl`), và tiến độ học tập.

## 3. Khuyến cáo & Giới hạn tuyên bố

> **Lưu ý quan trọng:** Báo cáo này dựa trên kiểm tra mã nguồn, SQL migration và cấu hình Edge Functions tại thời điểm P8. Dự án **chưa** kiểm thử thâm nhập (penetration test) trên instance Supabase Cloud thật có dữ liệu sản xuất và **chưa** được đánh giá pháp lý chính thức (COPPA / GDPR-K / Nghị định bảo vệ dữ liệu cá nhân Việt Nam). Cần hoàn thành rà soát pháp lý và kiểm thử RLS trực tiếp trên môi trường staging trước khi phát hành thương mại cho trẻ em.
