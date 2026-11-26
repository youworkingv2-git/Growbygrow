# 3D PERFORMANCE & CROSS-PLATFORM OPTIMIZATION
# PROJECT: ENGLISH ADVENTURE (PROMPT 03)

---

## 1. ĐÁNH GIÁ VÀ LỰA CHỌN RENDERER

`project.godot` cấu hình:
- `renderer/rendering_method="gl_compatibility"`
- `renderer/rendering_method.mobile="gl_compatibility"`
- `textures/vram_compression/import_etc2_astc=true`

### Lý do lựa chọn `GL Compatibility (gl_compatibility)`
| Tiêu chí | Forward+ | Mobile | GL Compatibility (Đã chọn) |
|---|---|---|---|
| **Windows / macOS Desktop** | Tốt nhất (Vulkan) | Tốt | Ổn định trên cả máy đồ họa tích hợp / laptop học sinh |
| **Android & iOS** | Không phù hợp máy tầm trung | Tốt (Vulkan/Metal) | Tương thích rộng nhất từ máy cấu hình thấp đến cao |
| **Web (WebGL2)** | Không hỗ trợ | Không hỗ trợ | **Bắt buộc** để export WebGL2 chạy trực tiếp trên trình duyệt |
| **Chi phí chuyển đổi** | Cần shader/light riêng | Cần shader riêng | Một pipeline thống nhất cho cả 4 nền tảng Windows, Android, iOS, Web |

> **Lưu ý:** Nếu trong tương lai tách riêng bản cài cao cấp chỉ dành cho PC/Console, có thể cân nhắc `Mobile` hoặc `Forward+`, nhưng với mục tiêu đa nền tảng đồng thời gồm **WebGL2 + Android + iOS + Windows** hiện tại, `gl_compatibility` là lựa chọn tối ưu và an toàn nhất.

---

## 2. BA MỨC CHẤT LƯỢNG ĐỒ HỌA (`LOW` / `MEDIUM` / `HIGH`)

Cấu hình qua `SettingsManager.graphics_quality` và áp dụng động bởi `WorldEnvironment3DController` (`scripts/visual3d/world_environment_3d.gd`):

| Thông số | `LOW` (Mobile / Tiết kiệm pin) | `MEDIUM` (Web / Cân bằng) | `HIGH` (Windows Desktop) |
|---|---|---|---|
| **Mặc định tự động** | Android, iOS, Mobile Web | WebGL2 Desktop | Windows / Native Desktop |
| **Directional Shadow** | Tắt (`shadow_enabled = false`) | Bật (2 splits, `40 m`) | Bật (4 splits, `55 m`) |
| **3D Resolution Scale** | `0.85` (`scaling_3d_scale`) | `1.0` | `1.0` |
| **MSAA 3D** | Tắt | `2X` (tắt trên WebGL2) | `4X` (tắt trên WebGL2) |
| **Glow / Bloom** | Tắt | Nhẹ (`intensity = 0.24`) | Vừa phải (`intensity = 0.36`, `bloom = 0.06`) |
| **Fog** | Tắt | Bật | Bật |
| **SSAO** | Tắt | Tắt | Bật trên Native Desktop (tắt trên Web & Mobile) |

---

## 3. CÁC KỸ THUẬT TỐI ƯU ĐÃ ÁP DỤNG TRONG CODE

1. **Không lạm dụng Global Illumination (SDFGI/VoxelGI) và hàng loạt đèn Real-time:** Dùng 1 `DirectionalLight3D` duy nhất + `ProceduralSkyMaterial` ambient + vật liệu `emission_enabled` cho đèn lồng và pha lê.
2. **LOD bằng `visibility_range_end` (`scripts/visual3d/prop_factory_3d.gd`):** Các chi tiết nhỏ (hoa, hàng rào, cột đèn, chi tiết phụ) tự động ẩn khi ra xa camera để giảm draw call.
3. **Chia sẻ Material (`StandardMaterial3D` cached):** Giảm số lần đổi trạng thái shader trên GPU.
4. **Giới hạn Particle Effects:** Chỉ dùng `CPUParticles3D` nhẹ (`amount <= 14–18`) tại cổng dịch chuyển và khu vực trung tâm; tránh hiệu ứng GPU compute nặng không tương thích WebGL2/Mobile cũ.
5. **Thích ứng SubViewport:** `MainMenu`, `CharacterSelection`, `WorldIntroduction` và `WorldMap` dùng `SubViewportContainer` (`own_world_3d = true`) gọn nhẹ, ánh sáng đơn giản, tự đồng bộ theo mức chất lượng.

---

## 4. MỤC TIÊU HIỆU NĂNG & HIỆN TRẠNG ĐO KIỂM

- **Mục tiêu thiết kế:** Windows hướng đến `60 FPS`; Android/iOS hướng đến `30–60 FPS` tùy cấu hình.
- **Hiện trạng đo kiểm thực tế:**
  - Đã kiểm thử chạy thực tế trên **WebGL2 (Chromium Desktop & chế độ giả lập Mobile Portrait)** với chuyển động 3D, camera orbit, chuyển cảnh và HUD phản hồi mượt, **0 lỗi console**.
  - **Chưa đo benchmark FPS thực tế trên thiết bị vật lý Windows native, Android, iOS** (chưa có Godot CLI/thiết bị di động vật lý kết nối trong môi trường hiện tại) — không tuyên bố con số FPS đo cứng cho thiết bị chưa chạy thực tế.
