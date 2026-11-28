# DANH SÁCH TÀI NGUYÊN CỬA HÀNG (STORE ASSETS CHECKLIST)
# PROJECT: ENGLISH ADVENTURE

> **Lưu ý:** Các mục mang nhãn `REQUIRES_OWNER_INPUT` bắt buộc do chủ dự án cung cấp thông tin thật trước khi nộp lên cửa hàng (không tự tạo URL, email hoặc giấy phép giả).

---

| Tài nguyên / Thông tin | Trạng thái | Ghi chú & Yêu cầu kỹ thuật |
|---|---|---|
| **App Icon (SVG gốc)** | Có sẵn (`res://icon.svg`) | Cần xuất thêm bộ PNG đa kích thước cho Store (`512x512` Google Play, `1024x1024` App Store không trong suốt, `.ico` cho Windows). |
| **Screenshots Desktop / Web** | Có ảnh QA P8 (`builds/qa_screenshots/*.png`) | Cần chụp lại từ bản Release `0.9.0` mới nhất theo đúng tỷ lệ Store (16:9 Desktop, 9:16 & 16:9 Phone, Tablet). |
| **Feature Graphic (Google Play `1024x500`)** | Chưa tạo (`REQUIRES_OWNER_INPUT`) | Banner phong cách 3D Fantasy Cartoon (Explorer + Buddy + Alphabet Island). |
| **Mô tả tiếng Việt (`STORE_DESCRIPTION_VI.md`)** | Đã soạn | Khớp đúng tính năng hiện có (không quảng cáo tính năng chưa bật). |
| **Mô tả tiếng Anh (`STORE_DESCRIPTION_EN.md`)** | Đã soạn | Khớp đúng tính năng hiện có. |
| **Privacy Policy URL** | `REQUIRES_OWNER_INPUT` | Xuất bản `PRIVACY_POLICY_DRAFT.md` lên trang web chính thức sau khi rà soát pháp lý. |
| **Support Contact / Email** | `REQUIRES_OWNER_INPUT` | Cần email hỗ trợ chính thức của chủ dự án. |
| **Age Rating Questionnaire** | Chưa hoàn tất (`REQUIRES_OWNER_INPUT`) | Khai báo trên Google Play Console / App Store Connect (không quảng cáo, không chat, không IAP, học liệu trẻ em). |
| **Signing Keys & Certificates** | `REQUIRES_OWNER_INPUT` | Release Keystore (Android), Apple Distribution Certificate & Provisioning Profile (iOS), Code Signing Cert (Windows nếu cần). |
