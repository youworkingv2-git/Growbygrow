# LEARNING DATABASE EXTENSIONS (SUPABASE POSTGRESQL)
# PROJECT: ENGLISH ADVENTURE (Prompt 04)

## 1. Chiến lược Migration An toàn

Prompt 04 giữ nguyên toàn bộ 32 bảng và chính sách RLS đã triển khai ở `0001_initial_schema.sql` và `0002_rls_policies.sql`, đồng thời bổ sung migration cộng thêm **`supabase/migrations/0003_learning_engine_extensions.sql`**.

## 2. Các bảng bổ sung trong `0003_learning_engine_extensions.sql`

| Bảng mới | Mục đích | Bảo mật RLS |
|---|---|---|
| `learning_paths` | Quản lý lộ trình học tổng | `SELECT` cho `authenticated` |
| `learning_levels` | Giai đoạn CEFR (`Pre-A1`, `A1`, `A1+`, `A2`) | `SELECT` cho `authenticated` |
| `topics` | Chủ đề trong từng World (`Topic 01–05`) | `SELECT` cho `authenticated` |
| `learning_activities` | Hoạt động học gắn trong từng `lesson` | `SELECT` cho `authenticated` |
| `phonics_examples` | Các từ ghép vần minh họa cho `phonics_content` | `SELECT` cho `authenticated` |
| `grammar_examples` | Câu ví dụ mở rộng cho `grammar_topics` | `SELECT` cho `authenticated` |
| `player_skill_progress` | Thống kê độ chính xác 4 kỹ năng của từng trẻ | `is_profile_owner(profile_id)` |

## 3. An toàn dữ liệu trẻ em

- Client **chỉ** sử dụng Anonymous/Authenticated user JWT + `anon_key` khi kết nối Supabase; **không** nhúng `service_role` key trong Godot client.
- Mọi bảng tiến trình cá nhân đều ràng buộc `is_profile_owner(profile_id)`.
