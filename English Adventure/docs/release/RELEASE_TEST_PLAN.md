# KẾ HOẠCH KIỂM THỬ BẢN PHÁT HÀNH (RELEASE TEST PLAN)
# PROJECT: ENGLISH ADVENTURE (`v0.9.0-rc.1`)

---

## 1. Năm kịch bản kiểm thử bắt buộc trên bản Release thực tế

1. **Clean Installation Test:** Cài đặt mới (không có dữ liệu `user://` trước), mở app, chọn nhân vật, hoàn thành nhiệm vụ `quest_01_new_adventure`, thoát và mở lại để xác nhận giữ nguyên tiến độ.
2. **Upgrade & Migration Test:** Đặt file save schema `v1`, mở bản `0.9.0`, kiểm tra `active_profile.pre_migrate_v1.bak.json` được tạo và toàn bộ EXP/Gold/Quests/Unlocked Areas còn nguyên.
3. **Offline Test:** Ngắt Internet hoàn toàn -> mở game -> học Pre-A1/A1, làm bài nghe/đọc/viết/mini-game -> lưu tiến độ -> thoát/mở lại -> bật lại mạng kiểm tra hàng đợi outbox.
4. **Full Gameplay & Audio/Mic Safety Test:** Chơi trọn vòng `Explore -> NPC -> Quest -> Learning Activity -> Mini-game -> Reward -> Area Unlock`; kiểm tra thu nhỏ/chuyển cửa sổ/khóa màn hình (nhạc nền tạm dừng, micro tự hủy buffer an toàn).
5. **Multi-Platform Matrix:** Kiểm thử riêng cho **Windows (.exe)**, **Android (.apk/.aab)**, **iOS (.ipa)** và **Web (WebGL2)**.
