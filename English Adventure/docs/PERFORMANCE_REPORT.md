# PERFORMANCE REPORT – ENGLISH ADVENTURE (PROMPT 08)

**Ghi chú minh bạch về phép đo:** Mọi số liệu dưới đây được đo **thực tế** từ bản WebGL2 build (`fe809d9`) chạy trên Google Chrome (`--headless=new --use-gl=angle --use-angle=swiftshader --enable-webgl`, CPU software rasterizer) thông qua Chrome DevTools Protocol (`Performance.getMetrics`, `performance.getEntriesByType`, và `requestAnimationFrame`). Máy trạm hiện tại chưa cài Godot native binary để đo FPS native DirectX/Vulkan trên GPU phần cứng; các số liệu GPU phần cứng được ghi rõ là **chưa đo được**.

---

## 1. Số liệu tải trang & kích thước Build WebGL2 (Đo thực tế)

| Tài nguyên / Chỉ số | Giá trị đo thực tế | Ghi chú |
|---|---|---|
| `index.wasm` | **8,145,418 bytes** (~7.77 MB), tải `1,441 ms` | Godot 4.3 WebGL2 WASM single-threaded |
| `index.pck` | **1,563,961 bytes** (~1.49 MB), tải `509 ms` | Toàn bộ scenes, scripts, JSON, SVG, 11 WAV |
| `index.js` | **85,558 bytes** (~83.6 KB), tải `439 ms` | Loader JS của Godot |
| `index.png` + `index.icon.png` | **25,076 bytes**, tải `293–374 ms` | Splash & favicon |
| `domInteractiveMs` / `loadEventMs` | **1,052 ms** / **1,053 ms** | HTML + JS khởi chạy |
| Thời gian boot đến Main Menu (`boot_ms`) | **7,452 ms** | Từ khi tải trang tới khi `MiniGameManager` & Autoloads sẵn sàng |

## 2. Bộ nhớ trình duyệt (Chrome `Performance.getMetrics` sau boot)

| Chỉ số | Giá trị đo thực tế |
|---|---|
| `JSHeapUsedSize` | **9,589,024 bytes** (~9.14 MB) |
| `JSHeapTotalSize` | **18,153,472 bytes** (~17.31 MB) |
| `Nodes` / `LayoutObjects` | **48** / **7** |
| `AudioHandlers` / `AudioWorkletProcessors` | **17** / **1** |

## 3. FPS & Frame Time (Chrome Headless + SwiftShader Software GL)

> **Cảnh báo môi trường đo:** SwiftShader dựng 3D hoàn toàn bằng CPU nên FPS thấp hơn rất nhiều so với GPU phần cứng thực tế. Số liệu này dùng để đối chiếu tương đối giữa màn hình tĩnh và cảnh 3D cũng như xác nhận không có hiện tượng treo/đứng hình.

| Kịch bản đo | Frames mẫu | FPS trung bình | Frame time TB | Frame time P95 |
|---|---|---|---|---|
| **Main Menu (có Diorama 3D)** (`5ecdfbc`) | 12 | `7.6 FPS` | `131.94 ms` | `133.5 ms` |
| **Welcome Village 3D Idle** (`5ecdfbc`) | 16 | `7.6 FPS` | `132.30 ms` | `133.4 ms` |
| **Welcome Village 3D Moving** (`5ecdfbc`) | 15 | `7.3 FPS` | `136.67 ms` | `150.1 ms` |
| **Welcome Village 3D Idle** (`fe809d9`, đồng thời tải sau reload) | 4 | `1.7 FPS` | `575.0 ms` | `583.4 ms` |
| **Welcome Village 3D Moving** (`fe809d9`) | 3 | `1.7 FPS` | `605.57 ms` | `616.7 ms` |

## 4. Các chỉ số chưa đo được trong môi trường hiện tại

- **FPS trên GPU phần cứng Windows / Android / iOS:** Chưa đo được do thiếu Godot CLI export Windows/Android/iOS và thiết bị di động vật lý.
- **VRAM & GPU Frame Time chi tiết:** Chưa đo được qua RenderDoc/Godot Profiler vì chạy dưới SwiftShader WebGL2.
- **Thời gian tải giữa các scene trên thiết bị di động tầm trung:** Chưa đo được trên thiết bị thật.
