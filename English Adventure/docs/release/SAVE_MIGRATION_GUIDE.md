# HƯỚNG DẪN TƯƠNG THÍCH VÀ DI TRÚ DỮ LIỆU SAVE (SAVE MIGRATION GUIDE)
# PROJECT: ENGLISH ADVENTURE

**Tệp quản lý:** `scripts/services/save_load_manager.gd` (`SAVE_SCHEMA_VERSION = 2`).

---

## 1. Cấu trúc Versioning trong Save Data
Mỗi file `user://profiles/active_profile.json` lưu kèm:
- `schema_version`: Phiên bản cấu trúc dữ liệu save (hiện tại `2`).
- `app_version`: Phiên bản ứng dụng tại thời điểm lưu (`"0.9.0"`).
- `build_number`: Số build (`900`).
- `save_revision` & `last_saved_unix`: Chống ghi đè tiến trình mới bằng dữ liệu cũ.

---

## 2. Quy trình nâng cấp an toàn (`v1 -> v2`)
Khi `SaveLoadManager._try_read_valid_save()` đọc file có `schema_version < SAVE_SCHEMA_VERSION`:
1. **Sao lưu trước di trú (`_backup_pre_migration`):** Ghi nguyên trạng file cũ vào `user://profiles/active_profile.pre_migrate_v<N>.bak.json`.
2. **Chuyển đổi không phá hủy (`migrate_save_data`):**
   - Ánh xạ `rewarded_quests` -> `claimed_quests` nếu thiếu.
   - Bổ sung an toàn các trường mới (`npc_encounters`, `minigame_records`, `claimed_reward_keys`, `reward_history`, `unlocked_achievements`) với giá trị mặc định rỗng mà **không** xóa `exp`, `gold`, `stars`, `unlocked_areas`, `inventory`, `completed_quests`.
3. **Phục hồi khi hỏng file chính:** Nếu `active_profile.json` bị lỗi JSON, tự động sao lưu sang `corrupted_<timestamp>.json` và phục hồi từ bản sao lưu xoay vòng `active_profile.bak.json`.
4. **Hồ sơ học tập P4–P9 (`user://learning_progress.json`):** Lưu tách biệt độc lập để nâng cấp game không làm mất trạng thái ghi nhớ từ vựng và lịch ôn tập SM-2.
