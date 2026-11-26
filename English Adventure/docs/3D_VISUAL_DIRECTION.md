# 3D VISUAL DIRECTION SPECIFICATION
# PROJECT: ENGLISH ADVENTURE (PROMPT 03)

**Định hướng chính thức:** High-quality Stylized 3D Fantasy Cartoon Adventure  
**Góc nhìn gameplay:** Third-person Camera (`SpringArm3D` + `Camera3D`)  
**Đối tượng người chơi:** Trẻ em ~10 tuổi (tươi sáng, giàu chiều sâu, hiện đại, không quá đơn giản hay quá trẻ con)

---

## 1. NGUYÊN TẮC THỊ GIÁC CỐT LÕI

1. **Thế giới 3D thực thụ:** Không sử dụng 2D hoặc 2.5D giả lập; không dùng ảnh PNG phẳng làm nhân vật chính, NPC hay công trình trong không gian gameplay.
2. **Chất lượng Stylized Fantasy Cartoon:**
   - Hình khối rõ ràng, mềm mại, màu sắc tươi sáng có độ tương phản dịu mắt (Filmic Tonemapper `exposure = 0.86`).
   - Ánh sáng tự nhiên theo từng khu vực (ban ngày ấm áp tại *Welcome Village* & *Alphabet Meadow*, ánh lam huyền ảo tại *Crystal Lake* & *Letter Cave*, sắc tím phép thuật tại *The Shadow Gate*).
3. **Đồng bộ giữa Thế giới 3D và UI 2D Overlay:**
   - Các màn hình ngoài gameplay (`SplashScreen`, `MainMenu`, `CharacterSelection`, `WorldIntroduction`, `WorldMap`) đều đặt **cảnh 3D sống động (`SubViewport` `own_world_3d = true`)** làm trung tâm hoặc nền, kết hợp UI Fantasy hiện đại có chiều sâu, bóng đổ và bo tròn.
   - Trong lúc chơi, HUD tối giản 4 góc, không che khuất nhân vật chính; khi đối thoại với NPC, camera tự căn khung hình (`set_dialogue_focus`) để nhìn rõ cả nhân vật và NPC 3D phía trên hộp thoại 2D.

---

## 2. THIRD-PERSON CAMERA SYSTEM

Triển khai tại `scripts/character/player_controller.gd` (`CameraPivot` → `SpringArm3D` → `Camera3D`):

| Thông số | Mặc định | Giới hạn / Ý nghĩa |
|---|---|---|
| `camera_distance` | `6.8 m` | Thu phóng bằng cuộn chuột trong khoảng `4.0 m – 10.5 m` |
| `camera_height` | `1.35 m` | Độ cao tâm quan sát ngang vai nhân vật |
| `camera_sensitivity` | `1.0` (`0.4 – 2.0`) | Điều chỉnh trực tiếp trong `SettingsModal` và lưu vào `user://settings.json` |
| `camera_smoothing` | `8.5` | Độ mượt nội suy vị trí & góc xoay, tránh rung lắc cho trẻ em |
| `camera_rotation_speed` | `1.9 rad/s` | Tốc độ xoay bằng phím `Q`/`C` (hỗ trợ trackpad laptop) |
| `camera_collision` | `true` | `SpringArm3D` (`collision_mask = 2`, `margin = 0.35`) ngăn xuyên địa hình/nhà cửa |

- **Điều khiển PC:** `WASD` / Phím mũi tên di chuyển tương đối theo hướng camera; giữ chuột phải/giữa kéo để xoay góc nhìn; cuộn chuột để zoom; `Space` nhảy; `E` tương tác; `H` hỏi Buddy; `Tab` mở Sổ tay Nhiệm vụ; `M` mở Bản đồ Đảo; `Esc` mở Pause Menu.
- **Điều khiển Mobile:** `VirtualJoystick` bên trái di chuyển; `TouchCameraPad` vùng vuốt bên phải xoay camera 3D mượt (có giới hạn bước góc an toàn cho trẻ); các nút `Hỏi Buddy`, `Nhảy`, `Tương tác` đặt bên phải không chồng lấp `BottomDock`.

---

## 3. HỆ THỐNG 7 NHÂN VẬT 3D & 5 KHU VỰC

- **7 Nhân vật 3D (`scripts/visual3d/character_rig_3d.gd`):** `boy` (Leo), `girl` (Mia), `buddy` (rồng nhỏ bay), `professor_owl`, `lily`, `rocky`, `crystal_guardian` — có khớp xoay đa phần, biểu cảm khuôn mặt (`set_expression`), hoạt ảnh `IDLE / WALK / RUN / JUMP / INTERACT / CELEBRATE / HURT` và tương thích thay thế `.glb` qua `Asset3DSlot`.
- **5 Khu vực 3D (`scripts/visual3d/area_environment_3d.gd`):** Trọng tâm hoàn chỉnh chi tiết tại **Welcome Village** (đồi cỏ, quảng trường đá cuội, đài phun nước chuyển động, Học viện Cú Mèo, nhà Lily, cây xanh, đèn lồng, hàng rào, hoa và hạt đom đóm), cùng 4 khu vực chơi được **Alphabet Meadow**, **Letter Cave**, **Crystal Lake** (mặt nước shader phản chiếu), và **The Shadow Gate**.

*(Tài liệu kỹ thuật chi tiết cây scene & chuyển đổi tọa độ xem thêm tại `docs/VISUAL_3D_ARCHITECTURE.md`.)*
