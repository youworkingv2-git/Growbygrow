# SAVE / LOAD & OFFLINE SYNC INTEGRATION (PROMPT 06)

## Dữ liệu lưu trữ (`user://profiles/active_profile.json`, schema v2)
- Nhân vật (`selected_character`, `nickname`), khu vực (`current_area_id`, `area_positions`, `unlocked_areas`, `completed_areas`, `completed_chapters`).
- Chỉ số & phần thưởng (`level`, `exp`, `gold`, `stars`, `claimed_reward_keys`, `reward_history`, `unlocked_achievements`).
- Nhiệm vụ & hội thoại (`active_quests` kèm tiến độ `objectives`, `completed_quests`, `claimed_quests`, `rewarded_quests`, `met_npcs`, `npc_encounters`, `seen_dialogues`).
- Túi đồ, cờ & mini-game (`inventory`, `collected_objects`, `flags`, `minigame_records`).
- Phiên bản & dấu thời gian xung đột (`save_revision`, `last_saved_unix`).

## Cơ chế an toàn & chống xung đột
- **Ghi nguyên tử (Atomic write):** Ghi file `.tmp` rồi đổi tên thành `active_profile.json` (fallback ghi trực tiếp nếu nền tảng không hỗ trợ rename).
- **Bảo vệ xung đột (`SaveLoadManager.resolve_conflict_prefer_newer`):** Không ghi đè dữ liệu mới hơn bằng dữ liệu cũ hơn; luôn hợp nhất tập khóa `claimed_reward_keys` để không bao giờ nhận thưởng trùng sau reload.
- **Hàng đợi đồng bộ offline (`sync_outbox.json`):** Mọi sự kiện `profile_snapshot`, `reward_granted`, `minigame_session_completed`, `learning_attempt` được lưu cục bộ ngay cả khi offline, sẵn sàng đồng bộ lên các bảng `0001`–`0005` trên Supabase khi cấu hình `SUPABASE_URL` và `SUPABASE_ANON_KEY`.
