# ACCESSIBILITY & CHILD-FRIENDLY UX (10 YEARS OLD)
# PROJECT: ENGLISH ADVENTURE (PROMPT 03)

---

## 1. NGUYÊN TẮC THIẾT KẾ CHO TRẺ ~10 TUỔI

1. **Dễ đọc & Phân biệt rõ ràng:**
   - Nội dung hướng dẫn mặc định bằng **Tiếng Việt** rõ nghĩa, câu ngắn gọn; nội dung học **Tiếng Anh** tách dòng riêng màu xanh sáng (`TEXT_EN = #60C5FF`) với cỡ chữ `19px` (`FONT_LEARNING`), không dùng font trang trí rườm rà.
   - Độ tương phản cao giữa chữ (`#F8FAFC`) và nền (`#14213D`).
2. **Nút bấm lớn, có biểu tượng đi kèm chữ:**
   - Các nút điều hướng chính có chiều cao `42–56px`, icon minh họa trực quan (Bản đồ, Nhiệm vụ, Túi đồ, Gold, Magic Crystals, Cài đặt).
   - Khoảng cách giữa các nút tối thiểu `8–14px` để tránh chạm nhầm trên điện thoại/máy tính bảng.
3. **Không phụ thuộc hoàn toàn vào màu sắc:**
   - Trạng thái khu vực và nhiệm vụ luôn đi kèm **ký hiệu chữ/biểu tượng + nhãn văn bản** (`[LOCKED]`, `[AVAILABLE]`, `[ACTIVE]`, `[OK]`, icon ổ khóa, dấu check) bên cạnh màu sắc phân biệt.
4. **Phản hồi nhẹ nhàng, không trách móc khi mắc lỗi:**
   - Màu cảnh báo dùng Warm Coral (`#FB7185`) dịu mắt.
   - Khi nhấn vào khu vực bị khóa hoặc gõ tên quá ngắn, hệ thống giải thích nhẹ nhàng cách mở/sửa thay vì báo lỗi gắt.
5. **Chống thao tác nhầm & Bảo vệ dữ liệu:**
   - `New Game` khi đã có tiến trình lưu **bắt buộc qua `ConfirmationDialog` xác nhận**.
   - `Save & Exit` khi đang có nhiệm vụ dở dang **lưu an toàn + xác nhận** trước khi rời màn chơi.
   - `Character Selection` tách riêng bước chọn nhân vật + đặt tên + bấm `Confirm` thay vì bấm 1 chạm là vào thẳng.
   - Nút nhận thưởng (`Tuyệt vời!`) khóa sau lần nhấn đầu (`_reward_claim_locked`) để không cộng thưởng lặp.
6. **Hỗ trợ đa phương thức nhập & Giảm chuyển động:**
   - Hỗ trợ đầy đủ **Chuột**, **Bàn phím** (`Tab`/Focus border vàng `BORDER_FOCUS`, `WASD`/Arrows, `E`, `Space`, `Enter`, `Esc`, `H`) và **Cảm ứng** (`VirtualJoystick` + nút chạm lớn).
   - Cung cấp tùy chọn **"Giảm hiệu ứng chuyển động" (`reduced_motion`)** trong `SettingsModal`, tắt toàn bộ tween co giãn/nhấp nháy trong `UIAnimator` để tránh gây xao nhãng hoặc mỏi mắt cho trẻ nhạy cảm với chuyển động.
