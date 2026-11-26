# INVENTORY & COLLECTIBLES SYSTEM (PROMPT 06)

## Thành phần (`InventoryManager` + `data/items/world_01_items.json`)
- **Dữ liệu chuẩn hóa cho mỗi vật phẩm:** `id`, `name_vi`, `name_en`, `description_vi`, `item_type` (`magic_crystal`, `golden_key`, `star_fragment`, `quest_item`, `collectible`), `rarity`, `icon_path`, `usable`, `acquisition_source_vi`, `usage_conditions`, `use_effect`.
- **Kiểm tra điều kiện sử dụng (`InventoryManager.can_use_item`):**
  - Vật phẩm đặc biệt như `golden_key` (`Chìa Khóa Vàng`) và `magic_crystal_shard` (`Mảnh Pha Lê Phép Thuật`) chỉ kích hoạt được khi người chơi đang ở đúng khu vực `shadow_gate` (`area_only`).
  - Vật phẩm như `explorer_badge`, `lost_letters_abc`, `star_fragment` có thể kích hoạt hiệu ứng khích lệ của Buddy.
- **Giao diện Túi đồ (`BagModal` trong `AdventureHUD`):**
  - Tab **Vật phẩm**: hiển thị biểu tượng, độ hiếm, mô tả, nguồn gốc, số lượng và nút **Sử dụng**.
  - Tab **Thành tựu**: hiển thị danh sách thành tựu đã mở/chưa mở (`data/rewards/achievements.json`).
  - Tab **Lịch sử thưởng**: hiển thị nhật ký phần thưởng thực tế và trạng thái đồng bộ.
