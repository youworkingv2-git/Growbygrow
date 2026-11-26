# WORLD MAP SPECIFICATION (PROMPT 02)
# PROJECT: ENGLISH ADVENTURE

---

## 1. BẢN ĐỒ ALPHABET ISLAND (`scenes/world/world_map/world_map.tscn`)

Điều khiển bởi `scripts/ui/world_map_ui.gd`.

### Thành phần hiển thị trên bản đồ
- **5 Điểm Khu vực (Nodes):** `Welcome Village`, `Alphabet Meadow`, `Letter Cave`, `Crystal Lake`, `The Shadow Gate` đặt theo tọa độ chuẩn hóa `map_pos` trong `data/areas/alphabet_island_areas.json`.
- **Đường nối (`ConnectionsLayer`):** Tự động vẽ `Line2D` giữa các cặp khu vực có trong `connected_areas` (màu vàng sáng khi cả hai đầu đã mở, màu xám mờ khi chưa mở).
- **Chỉ báo trực quan:**
  - `[Start]` cho khu vực xuất phát (`Welcome Village`).
  - `[!]` cho khu vực đang có nhiệm vụ `available` hoặc `active`.
  - Màu sắc phân biệt 4 trạng thái:
    - `Locked` (*Chưa mở khóa*): xám mờ, bấm vào hiện lý do & điều kiện mở (`AreaLockedPopup`), **chặn nút Di chuyển**.
    - `Unlocked` (*Đã mở khóa*): xanh dương sáng.
    - `In Progress` (*Đang khám phá*): vàng nổi bật.
    - `Completed` (*Đã hoàn thành*): xanh lá.
- **Thanh Worlds tương lai (`FutureWorldsBar`):** Hiển thị Alphabet Island đang hoạt động và 5 thế giới tiếp theo (*Vocabulary Forest*, *Sentence Kingdom*, *Listening Ocean*, *Speaking City*, *Challenge Kingdom*) ở trạng thái khóa *Sắp ra mắt*.

### Responsive
- Trên màn hình rộng (`>= 860px`): Bản đồ ở bên trái + Bảng chi tiết khu vực ở bên phải.
- Trên màn hình dọc / nhỏ (`< 860px`): Tự động xếp dọc (Bản đồ trên – Chi tiết dưới) và tự tính lại vị trí các đường nối (`_layout_map_nodes`).
