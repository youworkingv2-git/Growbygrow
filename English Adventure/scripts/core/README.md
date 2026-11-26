# Core Module (`scripts/core/`)

Đảm nhiệm hạ tầng cốt lõi không phụ thuộc vào bất kỳ domain gameplay hay học tập nào:
- `event_bus.gd` (Autoload trong Prompt 02): Khai báo toàn bộ tín hiệu kết nối lỏng giữa Adventure Engine, Learning Engine, Progression và Services.
- `scene_router.gd`: Quản lý chuyển cảnh, loading overlay, history stack và Responsive viewport breakpoints.
- `app_config.gd`: Đọc cấu hình môi trường an toàn (chỉ `SUPABASE_URL` và `SUPABASE_ANON_KEY`, tuyệt đối không chứa secret).
- `app_logger.gd`: Hệ thống log có phân cấp (`DEBUG`..`FATAL`) và tự động che token nhạy cảm.
- `data_validator.gd`: Kiểm tra tính hợp lệ DTO và content JSON.
