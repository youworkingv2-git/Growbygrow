# 3D ASSET PIPELINE, PLACEHOLDERS & REPLACEMENT GUIDE
# PROJECT: ENGLISH ADVENTURE

---

## 1. XÁC NHẬN HIỆN TRẠNG ASSET (MINH BẠCH PLACEHOLDER)

**Trạng thái hiện tại:** Dự án **CHƯA** tích hợp các file mô hình `.glb`/`.gltf` điêu khắc thủ công từ Blender.

Thay vì sử dụng ảnh 2D/PNG phẳng để giả lập 3D, toàn bộ nhân vật và công trình trong thế giới 3D hiện đang sử dụng **Mô hình Placeholder 3D Đa bộ phận Có khớp (Articulated Multi-Part 3D Placeholder Models)** được tạo bằng mã (`CharacterRig3D` và `PropFactory3D`):
- Mỗi nhân vật 3D có **hình khối 3D rõ ràng từ mọi góc nhìn**, vật liệu PBR đầy đủ màu sắc, mắt/lông mày/miệng biểu cảm 3D, phụ kiện nhận diện (mũ thám hiểm, kính bảo hộ, mũ cử nhân, mũ rơm, mũ thợ mỏ, vương miện pha lê, cánh rồng), và các khớp chuyển động (`body_pivot`, `head_pivot`, `arm_pivots`, `leg_pivots`, `wing_pivots`, `tail_pivot`).
- Mọi thực thể đều được gắn cờ `is_placeholder = true` trên `CharacterRig3D` và `Asset3DSlot`.

---

## 2. HỆ THỐNG THAY THẾ ASSET CHÍNH THỨC (`Asset3DSlot`)

File: `scripts/visual3d/asset_3d_slot.gd`

Cơ chế hoạt động:
1. Mỗi nhân vật (`Player`, `Buddy`, `NPC`) và vật thể tương tác (`InteractableObject`) đều gắn node `VisualSlot (Asset3DSlot)`.
2. `Asset3DSlot` kiểm tra thuộc tính `override_model_path` (hoặc trường `model_3d_path` trong JSON `playable_characters.json`, `buddy_config.json`, `alphabet_island_npcs.json`, `alphabet_island_objects.json`).
3. Nếu đường dẫn `.glb` / `.gltf` / `.tscn` tồn tại trên đĩa: hệ thống tự động nạp mô hình chính thức (`is_placeholder = false`) thay cho placeholder mà **không cần sửa code gameplay hay scene cây nhân vật**.
4. Nếu chưa có file `.glb`: hệ thống gắn mô hình placeholder 3D tương ứng (`is_placeholder = true`).

### Quy trình thay thế bằng mô hình Blender / GLB
1. Export từ Blender theo chuẩn **glTF 2.0 (`.glb`)**: trục `+Y` hướng lên, hướng mặt nhân vật `+Z`, tỷ lệ `1 Blender unit = 1 meter`, chiều cao chuẩn nhân vật ~`1.45 m`.
2. Đặt file vào thư mục `assets/models3d/characters/<id>.glb` hoặc `assets/models3d/props/<id>.glb`.
3. Khai báo `"model_3d_path": "res://assets/models3d/..."` trong JSON cấu hình tương ứng (hoặc gán vào `override_model_path` trên `Asset3DSlot`).

---

## 3. DANH SÁCH ASSET 3D CẦN SẢN XUẤT, POLYGON BUDGET & TEXTURE SPEC

### A. Nhân vật 3D (7 Nhân vật cốt lõi)

| ID | Tên | Vai trò | Polygon Budget (LOD0 / LOD1) | Texture Resolution | Rig & Biểu cảm yêu cầu |
|---|---|---|---|---|---|
| `boy` | **Boy Adventurer (Leo)** | Nhân vật chính | `4,500–6,500 tris` / `2,200 tris` | `1024x1024` (Albedo + Roughness/ORM) | Humanoid rig (Idle, Walk, Run, Jump, Interact, Celebrate, Hurt) + Blendshapes mặt |
| `girl` | **Girl Adventurer (Mia)** | Nhân vật chính | `4,500–6,500 tris` / `2,200 tris` | `1024x1024` | Humanoid rig đồng bộ xương với Boy + Blendshapes mặt |
| `buddy` | **Buddy** | Rồng nhỏ đồng hành | `3,500–5,000 tris` / `1,800 tris` | `1024x1024` | Cánh + Đuôi + 7 biểu cảm (`idle`, `happy`, `sad`, `surprised`, `thinking`, `talking`, `celebrating`) |
| `professor_owl` | **Professor Owl** | NPC Hướng dẫn | `3,200–4,800 tris` / `1,600 tris` | `1024x1024` | Cánh, đầu xoay, mắt kính vàng, mũ học giả |
| `lily` | **Lily** | NPC Làng Khởi Đầu | `3,500–5,000 tris` / `1,800 tris` | `1024x1024` | Humanoid rig + mũ rơm hoa cúc |
| `rocky` | **Rocky** | NPC Hang Động | `3,500–5,000 tris` / `1,800 tris` | `1024x1024` | Humanoid rig + mũ đèn pha lê |
| `crystal_guardian` | **Crystal Guardian** | NPC Hồ Pha Lê | `3,800–5,500 tris` / `2,000 tris` | `1024x1024` | Vạt áo bay + pha lê xoay + Emissive map |

### B. Công trình & Vật thể môi trường (Welcome Village & Alphabet Island)

| Asset ID | Tên | Polygon Budget (LOD0 / LOD1) | Texture Resolution | Ghi chú |
|---|---|---|---|---|
| `owl_academy_cottage` | Nhà Học Viện Cú Mèo | `2,500–4,000 tris` / `1,000 tris` | `1024x1024` (Trim sheet + Roof) | Dùng chung atlas vật liệu gỗ/đá |
| `village_cottage` | Nhà dân Làng Khởi Đầu | `1,800–3,000 tris` / `800 tris` | `1024x1024` | Có biến thể màu mái |
| `village_fountain` | Đài phun nước quảng trường | `1,500–2,400 tris` / `700 tris` | `512x512` + Water Shader | Tối ưu cho trung tâm Welcome Village |
| `stylized_tree` | Cây xanh Fantasy | `800–1,400 tris` / `350 tris` | `512x512` | Hỗ trợ MultiMesh/Instancing |
| `lamppost_3d` | Đèn đường làng | `450–750 tris` / `200 tris` | `512x512` + Emissive | Đèn ấm không cần Real-time PointLight hàng loạt |
| `signpost_3d` | Biển chỉ dẫn | `350–600 tris` | `512x512` | Vật thể tương tác |
| `treasure_chest_3d` | Rương kho báu (Đóng/Mở) | `700–1,100 tris` | `512x512` | Nắp có khớp `LidPivot` |
| `lost_letter_3d` | Chữ cái phép thuật | `400–800 tris` | `512x512` + Emissive | Biểu tượng chữ A/B/C/E phát sáng |
| `magic_crystal_3d` | Cụm pha lê phép thuật | `350–650 tris` | `512x512` + Emissive | Dùng cho Crystal Lake & Letter Cave |
| `portal_pad_3d` | Cổng dịch chuyển khu vực | `900–1,400 tris` | `512x512` + Emissive | Kết hợp `CPUParticles3D` |
| `shadow_gate_arch` | Cổng Bóng Tối | `1,800–2,800 tris` | `1024x1024` + Emissive | Công trình điểm nhấn Shadow Gate |

---

## 4. NGUYÊN TẮC TỐI ƯU HIỆU NĂNG ASSET 3D

- **Texture Compression:** Sử dụng Basis Universal / VRAM Compressed (`ETC2` trên Android/iOS, `BC7` trên Desktop, `S3TC/ETC2` trên WebGL2), kích thước tối đa `1024x1024` cho nhân vật/công trình lớn và `512x512` cho props nhỏ.
- **Material Sharing & Batching:** Các bộ phận dùng chung `StandardMaterial3D` cached để giảm số lượng shader state switch.
- **LOD & Culling:** Thiết lập `visibility_range_end` cho các chi tiết nhỏ (hoa, hàng rào, cành cây phụ), giới hạn ánh sáng thời gian thực (ưu tiên 1 `DirectionalLight3D` + vật liệu phát sáng emissive cho đèn lồng và pha lê).
