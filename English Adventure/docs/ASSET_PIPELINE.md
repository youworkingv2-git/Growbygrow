# ASSET & ART PIPELINE
# PROJECT: ENGLISH ADVENTURE (PROMPT 03)

> Tài liệu tổng hợp toàn bộ danh sách asset (3D Characters, 3D Environments, UI, Icons, Materials, Textures, Animations, Audio), ghi nhận trung thực các placeholder hiện có và quy chuẩn thay thế chính thức. (Xem thêm đặc tả kỹ thuật chi tiết slot 3D tại `docs/ASSET_3D_PIPELINE.md`.)

---

## 1. TỔNG QUAN HIỆN TRẠNG ASSET

| Nhóm Asset | Hiện trạng trong repo | Ghi chú minh bạch |
|---|---|---|
| **3D Characters (7 nhân vật)** | **Placeholder 3D đa khối có khớp** (`CharacterRig3D`, `is_placeholder = true`) | Chưa có file `.glb`/Blender từ 3D Artist; sẵn sàng thay qua `Asset3DSlot`. |
| **3D Environments & Props** | **Placeholder 3D khối + Material PBR + Water Shader** (`AreaEnvironment3D`, `PropFactory3D`) | Chưa có `.glb` điêu khắc; hỗ trợ thay từng công trình qua `Asset3DSlot`. |
| **3D Animations** | **Procedural Pivot Animation** (`CharacterAnimator`) | Hoạt ảnh `IDLE`, `WALK`, `RUN`, `JUMP`, `INTERACT`, `CELEBRATE`, `HURT`; chờ clip skeletal trong `.glb`. |
| **UI Assets & Icons** | **Đã có SVG/StyleBox** (`assets/icons/`, `assets/characters/`, `assets/environments/`) | Dùng cho Avatar, HUD chips, Quest Card, World Card; đang chạy thực tế. |
| **Materials & Textures** | **StandardMaterial3D + ShaderMaterial** tạo trong code | Chờ texture atlas/ORM `512x512`–`1024x1024` khi xuất `.glb`. |
| **Fonts** | **Godot System Fallback** (hiển thị đủ tiếng Việt có dấu & tiếng Anh) | Chưa nhúng font `.ttf`/`.otf` tùy chỉnh vào `assets/fonts/`. |
| **Audio (BGM, SFX, Voice EN/VI)** | **Chưa có file `.ogg`/`.wav`** trong `assets/audio/` | `AudioManager` đã cấu hình sẵn buses `Music`/`SFX`; UI Settings hiển thị rõ thông báo chưa có file âm thanh. |

---

## 2. DANH SÁCH ASSET CẦN SẢN XUẤT & THAY THẾ

### 2.1. 3D Characters (`assets/models3d/characters/`)
1. `boy.glb` — Boy Adventurer (Leo) | `4,500–6,500 tris` LOD0 / `2,200 tris` LOD1 | Texture `1024x1024`
2. `girl.glb` — Girl Adventurer (Mia) | `4,500–6,500 tris` LOD0 / `2,200 tris` LOD1 | Texture `1024x1024`
3. `buddy.glb` — Buddy (rồng nhỏ) | `3,500–5,000 tris` LOD0 / `1,800 tris` LOD1 | Texture `1024x1024` + 7 biểu cảm
4. `professor_owl.glb` — Professor Owl | `3,200–4,800 tris` | Texture `1024x1024`
5. `lily.glb` — Lily | `3,500–5,000 tris` | Texture `1024x1024`
6. `rocky.glb` — Rocky | `3,500–5,000 tris` | Texture `1024x1024`
7. `crystal_guardian.glb` — Crystal Guardian | `3,800–5,500 tris` | Texture `1024x1024` + Emissive

### 2.2. 3D Environments & Props (`assets/models3d/props/`)
- `owl_academy_cottage.glb`, `village_cottage.glb`, `village_fountain.glb`, `stylized_tree.glb`, `lamppost_3d.glb`, `signpost_3d.glb`, `treasure_chest_3d.glb` (có `LidPivot`), `lost_letter_3d.glb`, `magic_crystal_3d.glb`, `portal_pad_3d.glb`, `shadow_gate_arch.glb`.

### 2.3. UI, Fonts & Audio (`assets/ui/`, `assets/fonts/`, `assets/audio/`)
- **UI & Icons:** Bộ icon vector/PNG độ phân giải cao cho Inventory items, Achievement badges, World thumbnails.
- **Fonts:** Font rounded thân thiện hỗ trợ đầy đủ tiếng Việt (`Nunito` / `Quicksand` / `Be Vietnam Pro`) cho `assets/fonts/`.
- **Audio:**
  - UI SFX: `button_click.ogg`, `popup_open.ogg`, `popup_close.ogg`, `quest_complete.ogg`, `reward_received.ogg`, `area_unlocked.ogg`.
  - BGM theo khu vực (Welcome Village, Meadow, Cave, Crystal Lake, Shadow Gate).
  - Voice EN (26 chữ cái + từ vựng MVP) & Voice VI hướng dẫn của Buddy.

---

## 3. QUY TRÌNH THAY THẾ AN TOÀN (`Asset3DSlot`)
1. Xuất mô hình từ Blender định dạng **glTF 2.0 (`.glb`)**, `+Y` Up, `+Z` Forward, `1 unit = 1 meter`.
2. Đặt vào `assets/models3d/...` và khai báo trường `"model_3d_path"` trong JSON (`data/characters/` hoặc `data/world/`) hoặc gán `override_model_path` trên node `Asset3DSlot`.
3. `Asset3DSlot.attach_or_placeholder()` tự động nạp `.glb` và đặt `is_placeholder = false` mà không làm gãy animation/camera/collider gameplay.
