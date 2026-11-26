# Backend Service & Save/Load Modules (`scripts/services/`)

Đảm nhiệm lưu trữ offline và đồng bộ Supabase:
- `save_load_service.gd`: Atomic read/write file tiến trình người chơi tại `user://profiles/<id>/`, quản lý `sync_outbox.json`.
- `supabase_auth_service.gd`: Anonymous sign-in & Parent email login, refresh JWT token.
- `supabase_sync_service.gd`: Đẩy batch `learning_attempts` (idempotent bằng `client_event_id`) và hợp nhất tiến trình theo High-Water Mark khi có mạng.
- `network_monitor.gd`: Theo dõi kết nối và retry theo exponential backoff.
