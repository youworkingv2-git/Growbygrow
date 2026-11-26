# UI COMPONENTS CATALOG
# PROJECT: ENGLISH ADVENTURE (PROMPT 03)

Tài liệu mô tả các component UI dùng chung trong `scenes/ui/common/` và `scripts/ui/components/` nhằm đảm bảo tái sử dụng thống nhất trên toàn game.

---

## 1. DANH SÁCH COMPONENT DÙNG CHUNG

| Component | Scene / Script | Chức năng & Kết nối dữ liệu |
|---|---|---|
| **Panel & Card** | `UIDesignSystem.make_panel_style()` + `PanelContainer` | Khung nền thống nhất (`opaque` `#14213D` + viền bo tròn `14px` + bóng đổ nhẹ). |
| **Confirmation Dialog** | `scenes/ui/common/confirmation_dialog.tscn` (`AdventureConfirmDialog`) | Hộp thoại xác nhận hành động quan trọng (Ghi đè New Game, Lưu & Thoát về Menu Chính). Hỗ trợ chế độ `danger` và callback `confirmed` / `cancelled`. |
| **Reward Display** | `scenes/ui/common/reward_display.tscn` (`RewardDisplay`) | Hiển thị phần thưởng thực từ dữ liệu Quest: `EXP`, `Gold`, `Magic Crystals`, `Stars`, và `Items`. |
| **Quest Card** | `scenes/ui/common/quest_card.tscn` (`QuestCardWidget`) | Thẻ nhiệm vụ chuẩn hóa cho Sổ tay Nhiệm vụ & World Map: Avatar NPC giao, tên nhiệm vụ, mô tả, tiến độ mục tiêu (`[x]` / `[ ]`), `ProgressBar`, `RewardDisplay`, nhãn trạng thái (`Locked`, `Available`, `Active`, `Completed`). |
| **World Card** | `scripts/ui/components/world_card.gd` (`WorldCardWidget`) | Thẻ khu vực/thế giới với trạng thái khóa/mở khóa/đang làm/hoàn thành và icon trạng thái trực quan (không phụ thuộc chỉ vào màu sắc). |
| **Avatar Badge** | `scripts/ui/components/avatar_badge.gd` (`AvatarBadge`) | Ánh xạ thống nhất texture nhân vật (`boy` / `girl`) và NPC (`buddy`, `professor_owl`, `lily`, `rocky`, `crystal_guardian`). |
| **Loading Indicator** | `scenes/ui/common/loading_indicator.tscn` (`LoadingIndicatorWidget`) | Thanh/vòng báo tải dùng trong Splash Screen và `UIManager.show_loading()`. |
| **Dialogue Box** | `scripts/ui/dialogue_box_ui.gd` (trong `AdventureHUD`) | Khung hội thoại song ngữ EN + VI cuộn an toàn, hiển thị đúng avatar người nói qua `AvatarBadge`, hiệu ứng gõ chữ, nút `Tiếp tục` & `Bỏ qua`, hỗ trợ phím `E` / `Enter` / `Space`. |
| **Notification Stack** | `UIManager.show_notification()` (`scripts/ui/managers/ui_manager.gd`) | Thông báo tự biến mất (3s), không chặn thao tác người chơi, hiển thị trên lớp cao nhất của `_overlay_layer` cho các sự kiện: `Quest Started`, `Quest Completed`, `New Area Unlocked`, `Item Collected`, `Level Up`, `Achievement Unlocked`, `Settings Saved`. |
| **Tooltip** | `UIManager.show_tooltip()` / `hide_tooltip()` | Khung chú thích nổi dùng chung ở lớp phủ trên cùng. |
| **Popup Modals** | `QuestIntroPopup`, `QuestCompletedPopup`, `AreaLockedPopup`, `AreaUnlockedPopup`, `QuestLogModal`, `BagModal`, `SettingsModal`, `PauseMenu` | Dùng chung hiệu ứng `UIAnimator.animate_popup_open()` / `animate_popup_close()` và khóa tương tác nền an toàn. |
