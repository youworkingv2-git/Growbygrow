# WORLD PROGRESSION – ALPHABET ISLAND (PROMPT 06)

## Tiến trình 5 khu vực của Đảo Chữ Cái (`data/areas/alphabet_island_areas.json`)
Mỗi khu vực có 4 trạng thái: `locked` -> `unlocked` -> `in_progress` -> `completed`.

1. **Welcome Village (`welcome_village`):** Mở khóa mặc định; hoàn thành khi xong `quest_01_new_adventure`.
2. **Alphabet Meadow (`alphabet_meadow`):** Mở khóa khi hoàn thành `quest_01_new_adventure`; hoàn thành khi xong `quest_02_lost_letters`.
3. **Letter Cave (`letter_cave`):** Mở khóa khi hoàn thành `quest_02_lost_letters`; hoàn thành khi tìm thấy manh mối `rocky_clue_found`.
4. **Crystal Lake (`crystal_lake`):** Mở khóa khi `flags.rocky_clue_found == true`; hoàn thành khi xong `quest_03_mysterious_gate`.
5. **The Shadow Gate (`shadow_gate`):** Mở khóa khi hoàn thành `quest_03_mysterious_gate` VÀ sở hữu `magic_crystal_shard` trong túi đồ; hoàn thành khi `flags.shadow_gate_inspected == true`.

## Đảm bảo tính toàn vẹn (`GameStateManager` & `UnlockEvaluator`)
- Không mở khóa khu vực chỉ vì đổi scene hoặc tọa độ; `SceneRouter.enter_area` và `AreaExplorationController` luôn kiểm tra `GameStateManager.is_area_unlocked(...)`.
- Khi mở khóa khu vực mới: phát `EventBus.area_unlocked` + `region_unlocked`, hiển thị `AreaUnlockedPopup`, cập nhật `WorldMapUI` và 3D diorama map.
