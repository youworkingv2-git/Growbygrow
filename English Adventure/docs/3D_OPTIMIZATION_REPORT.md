# 3D OPTIMIZATION REPORT – ENGLISH ADVENTURE (PROMPT 08)

**Renderer:** Godot 4.3 `gl_compatibility` (GLES3 / WebGL2)  
**Đối tượng tối ưu:** 5 khu vực 3D Alphabet Island, Diorama 3D, World Map 3D, hệ thống ánh sáng, camera và thiết lập chất lượng `Low` / `Medium` / `High`.

---

## 1. Phân tích nguyên nhân & Điểm nghẽn ban đầu

Trước khi chỉnh sửa, kiểm tra mã nguồn dựng 3D (`AreaEnvironment3D`, `PropFactory3D`, `WorldEnvironment3DController`, `WorldMapUI`) phát hiện 3 nguyên nhân gây dư thừa tài nguyên CPU/GPU:
1. **Nhân bản Material & Mesh mỗi vật thể:** Mỗi hàng rào, đá, bụi hoa, cột đèn, ngôi nhà hoặc khối nước đều cấp phát mới `StandardMaterial3D` và `BoxMesh` / `CylinderMesh` / `SphereMesh`, làm tăng số shader/uniform binding và bộ nhớ hình học.
2. **Chất lượng Particle không phản hồi Settings:** `AmbientParticles` và `PortalParticles` giữ nguyên mật độ phát hạt ngay cả khi người chơi chọn mức đồ họa `Low` trên máy yếu hoặc trình duyệt/điện thoại.
3. **Cập nhật UI chiếu từ 3D mỗi frame:** `WorldMapUI._process()` gán lại kích thước, font override và vị trí cho cả 5 nút khu vực mỗi frame dù camera/canvas đứng yên.

## 2. Các tối ưu hóa đã triển khai

| Hạng mục | Kỹ thuật áp dụng | File sửa đổi | Bảo toàn chất lượng hình ảnh |
|---|---|---|---|
| **Material Caching** | Static `_mat_cache` dùng chung material theo `(color, roughness, metallic, emission)` cho vật thể tĩnh (đất, đá, hàng rào, đài phun nước, bia chỉ dẫn, cổng vòm). | `scripts/visual3d/area_environment_3d.gd`, `scripts/visual3d/prop_factory_3d.gd` | Không thay đổi màu sắc hay độ nhám bề mặt. **Giữ material riêng** cho cây, nhà và đèn đường có thể bị làm mờ khi che camera (`PlayerController` camera fade) để tránh mờ nhầm hàng loạt vật thể khác. |
| **Mesh Geometry Reuse** | Static `_mesh_cache` tái sử dụng `BoxMesh`, `CylinderMesh`, `SphereMesh` có cùng thông số kích thước. | `scripts/visual3d/area_environment_3d.gd`, `scripts/visual3d/prop_factory_3d.gd` | Giữ nguyên toàn bộ hình dáng low-poly hoạt hình của nhân vật và công trình. |
| **Dynamic Particle Quality** | Gắn các `CPUParticles3D` vào group `"quality_particles"` và cập nhật động khi `WorldEnvironment3DController._apply_quality()` chạy (`low`: tắt hạt ambient để nhẹ GPU; `medium`: giảm `amount_ratio = 0.65`; `high`: `1.0`). | `scripts/visual3d/area_environment_3d.gd`, `scripts/visual3d/world_environment_3d.gd` | Giữ nguyên hiệu ứng phát sáng pha lê và không khí ở mức Medium/High. |
| **UI Projection Throttling** | Cache `_last_canvas_size` và `_last_node_positions`, bỏ qua cập nhật layout khi dịch chuyển `<= 0.5px`. | `scripts/ui/world_map_ui.gd` | Vị trí nút trên bản đồ 3D vẫn bám chính xác theo góc camera xoay nhẹ. |

## 3. Hệ thống Graphics Quality Settings (`Low` / `Medium` / `High`)

Đã kiểm tra khả năng chuyển đổi 3 mức trong `SettingsModalUI` → `SettingsManager.graphics_quality` → `WorldEnvironment3DController`:
- **Low:** Tắt shadow trên `DirectionalLight3D`, tắt Glow & Fog nhẹ hơn, đặt `scaling_3d_scale = 0.75`, tắt ambient particles phụ (`quality_particles`).
- **Medium:** Bật shadow mềm vừa, `scaling_3d_scale = 0.90`, giữ `amount_ratio = 0.65` cho hạt môi trường.
- **High:** Đầy đủ shadow, Glow bật, Fog khí quyển đầy đủ, `scaling_3d_scale = 1.0`, `amount_ratio = 1.0`.

## 4. Camera & Animation 3D

- **Camera Follow & Collision:** `PlayerController` sử dụng `SpringArm3D` với `collision_mask = 2` (chỉ va chạm địa hình/tường, không giật vào tán cây/nhà) kết hợp cơ chế làm mờ vật cản nằm giữa camera và nhân vật (`_faded_occluders`), giúp góc nhìn thứ 3 mượt mà khi di chuyển và xoay camera.
- **Character & NPC Animation:** `CharacterAnimator` đồng bộ trạng thái `IDLE`, `WALK`, `RUN`, `JUMP`, `INTERACT`, `CELEBRATE` với mô hình nhân vật 3D có khớp của Leo, Mia, Buddy và 4 NPCs; không ghi nhận lỗi giật hoặc kẹt chuyển trạng thái khi test di chuyển liên tục trên WebGL2.
