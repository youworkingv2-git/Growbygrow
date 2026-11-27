extends CanvasLayer
## Adventure HUD integrating Minimal Status Bar, EXP Bar, Gold & Magic Crystals,
## Quest Tracker, Compact Bottom Dock, Touch Controls, Dialogue UI, Quest Cards,
## Reward Display Popup, Inventory UI, and Pause Menu.

signal interact_pressed()
signal jump_pressed()
signal buddy_help_pressed()
signal joystick_changed(vec: Vector2)
signal camera_look_delta(delta_px: Vector2)
signal quest_accepted(quest_id: String)
signal overlay_blocking_changed(blocked: bool)

const QUEST_CARD_SCENE := preload("res://scenes/ui/common/quest_card.tscn")

var _pending_intro_quest_id: String = ""
var _queued_intro_quest_id: String = ""
var _pending_unlocked_area_id: String = ""
var _pending_completed_quest: Dictionary = {}
var _suppress_immediate_unlock_popup: bool = false
var _active_popup_quest_id: String = ""
var _quest_log_filter: String = "main"
var _bag_tab: String = "items"
var _has_focused_target: bool = false
var _touch_input_seen: bool = false
var _reward_claim_locked: bool = false
var _dialogue_active: bool = false
var _cam_touch_idx: int = -1
var _cam_mouse_drag: bool = false

@onready var top_bar: PanelContainer = $TopBar
@onready var avatar_icon: TextureRect = $TopBar/Margin/Row/ProfileBox/Avatar
@onready var player_info_label: Label = $TopBar/Margin/Row/ProfileBox/StatsCol/PlayerInfo
@onready var exp_bar: ProgressBar = $TopBar/Margin/Row/ProfileBox/StatsCol/ExpRow/ExpBar
@onready var exp_label: Label = $TopBar/Margin/Row/ProfileBox/StatsCol/ExpRow/ExpLabel
@onready var area_title_label: Label = $TopBar/Margin/Row/AreaTitle
@onready var gold_label: Label = $TopBar/Margin/Row/RightStats/GoldChip/GoldLabel
@onready var crystal_label: Label = $TopBar/Margin/Row/RightStats/CrystalChip/CrystalLabel
@onready var settings_btn: Button = $TopBar/Margin/Row/RightStats/SettingsBtn
@onready var pause_btn: Button = $TopBar/Margin/Row/RightStats/PauseBtn

@onready var quest_tracker_panel: PanelContainer = $QuestTracker
@onready var tracker_title: Label = $QuestTracker/Margin/VBox/Title
@onready var tracker_step: Label = $QuestTracker/Margin/VBox/StepLabel

@onready var bottom_dock: PanelContainer = $BottomDock
@onready var map_btn: Button = $BottomDock/Margin/Row/MapBtn
@onready var quests_btn: Button = $BottomDock/Margin/Row/QuestsBtn
@onready var bag_btn: Button = $BottomDock/Margin/Row/BagBtn
@onready var desktop_buddy_btn: Button = $BottomDock/Margin/Row/DesktopBuddyBtn
@onready var learn_btn: Button = $BottomDock/Margin/Row/LearnBtn
@onready var minigames_btn: Button = $BottomDock/Margin/Row/MiniGamesBtn
@onready var save_btn: Button = $BottomDock/Margin/Row/SaveBtn

@onready var interact_banner: Button = $InteractBanner
@onready var toast_panel: PanelContainer = $ToastPanel
@onready var toast_label: Label = $ToastPanel/Margin/Label
@onready var toast_timer: Timer = $ToastTimer

@onready var mobile_controls: Control = $MobileControls
@onready var touch_camera_pad: Control = $MobileControls/TouchCameraPad
@onready var joystick: Control = $MobileControls/VirtualJoystick
@onready var touch_right_pad: VBoxContainer = $MobileControls/RightPad
@onready var touch_interact_btn: Button = $MobileControls/RightPad/TouchInteractBtn
@onready var touch_jump_btn: Button = $MobileControls/RightPad/TouchJumpBtn
@onready var buddy_btn: Button = $MobileControls/RightPad/BuddyBtn

@onready var dialogue_box: PanelContainer = $DialogueBox

@onready var quest_intro_popup: PanelContainer = $QuestIntroPopup
@onready var qi_title: Label = $QuestIntroPopup/Margin/VBox/Title
@onready var qi_desc: Label = $QuestIntroPopup/Margin/VBox/Desc
@onready var qi_reward: Label = $QuestIntroPopup/Margin/VBox/Reward
@onready var qi_accept_btn: Button = $QuestIntroPopup/Margin/VBox/Buttons/AcceptBtn
@onready var qi_later_btn: Button = $QuestIntroPopup/Margin/VBox/Buttons/LaterBtn

@onready var quest_done_popup: PanelContainer = $QuestCompletedPopup
@onready var qd_title: Label = $QuestCompletedPopup/Margin/VBox/Title
@onready var qd_reward_display: RewardDisplay = $QuestCompletedPopup/Margin/VBox/RewardDisplay
@onready var qd_continue_btn: Button = $QuestCompletedPopup/Margin/VBox/ContinueBtn

@onready var area_locked_popup: PanelContainer = $AreaLockedPopup
@onready var al_reason: Label = $AreaLockedPopup/Margin/VBox/Reason
@onready var al_close_btn: Button = $AreaLockedPopup/Margin/VBox/CloseBtn

@onready var area_unlocked_popup: PanelContainer = $AreaUnlockedPopup
@onready var au_title: Label = $AreaUnlockedPopup/Margin/VBox/Title
@onready var au_desc: Label = $AreaUnlockedPopup/Margin/VBox/Desc
@onready var au_travel_btn: Button = $AreaUnlockedPopup/Margin/VBox/Buttons/TravelNowBtn
@onready var au_stay_btn: Button = $AreaUnlockedPopup/Margin/VBox/Buttons/StayBtn

@onready var quest_log_modal: PanelContainer = $QuestLogModal
@onready var quest_log_list: VBoxContainer = $QuestLogModal/Margin/VBox/Scroll/List
@onready var quest_log_close_btn: Button = $QuestLogModal/Margin/VBox/Header/CloseBtn

@onready var bag_modal: PanelContainer = $BagModal
@onready var bag_list: VBoxContainer = $BagModal/Margin/VBox/Scroll/List
@onready var bag_close_btn: Button = $BagModal/Margin/VBox/Header/CloseBtn

@onready var pause_menu: PauseMenuUI = $PauseMenu
@onready var learning_hub_modal: LearningHubModal = $LearningHubModal


func _ready() -> void:
	_apply_design_system()
	_hide_all_modals()
	interact_banner.visible = false
	toast_panel.visible = false

	for btn: Button in [
		map_btn, quests_btn, bag_btn, learn_btn, minigames_btn, save_btn, settings_btn, pause_btn,
		interact_banner, touch_interact_btn, touch_jump_btn, buddy_btn, desktop_buddy_btn
	]:
		btn.focus_mode = Control.FOCUS_NONE
		UIAnimator.attach_button_feedback(btn)

	for modal_btn: Button in [
		qi_accept_btn, qi_later_btn, qd_continue_btn, al_close_btn,
		au_travel_btn, au_stay_btn, quest_log_close_btn, bag_close_btn
	]:
		UIAnimator.attach_button_feedback(modal_btn)

	map_btn.pressed.connect(func() -> void: SceneRouter.go_to_world_map())
	quests_btn.pressed.connect(_open_quest_log)
	bag_btn.pressed.connect(_open_bag)
	learn_btn.pressed.connect(func() -> void: open_learning_hub())
	minigames_btn.pressed.connect(func() -> void: MiniGameManager.open_arcade_launcher())
	settings_btn.pressed.connect(func() -> void:
		UIManager.open_settings(true)
	)
	pause_btn.pressed.connect(_toggle_pause_menu)
	save_btn.pressed.connect(func() -> void:
		if GameStateManager.save_now("manual_hud"):
			show_toast(LocalizationManager.tr_key("saved_toast", "Đã lưu tiến trình!"))
	)
	interact_banner.pressed.connect(func() -> void: interact_pressed.emit())
	touch_interact_btn.pressed.connect(func() -> void: interact_pressed.emit())
	touch_jump_btn.pressed.connect(func() -> void: jump_pressed.emit())
	buddy_btn.pressed.connect(func() -> void: buddy_help_pressed.emit())
	desktop_buddy_btn.pressed.connect(func() -> void: buddy_help_pressed.emit())
	joystick.vector_changed.connect(func(v: Vector2) -> void: joystick_changed.emit(v))
	touch_camera_pad.gui_input.connect(_on_touch_camera_pad_input)

	qi_accept_btn.pressed.connect(_on_accept_quest_pressed)
	qi_later_btn.pressed.connect(func() -> void:
		UIAnimator.animate_popup_close(quest_intro_popup, func() -> void: _sync_overlay_visibility())
	)
	qd_continue_btn.pressed.connect(_on_quest_done_continue)
	al_close_btn.pressed.connect(func() -> void:
		UIAnimator.animate_popup_close(area_locked_popup, func() -> void: _sync_overlay_visibility())
	)
	au_stay_btn.pressed.connect(func() -> void:
		UIAnimator.animate_popup_close(area_unlocked_popup, func() -> void:
			_sync_overlay_visibility()
			_flush_queued_quest_intro()
		)
	)
	au_travel_btn.pressed.connect(func() -> void:
		area_unlocked_popup.visible = false
		_queued_intro_quest_id = ""
		_sync_overlay_visibility()
		if not _pending_unlocked_area_id.is_empty():
			SceneRouter.enter_area(_pending_unlocked_area_id)
	)
	quest_log_close_btn.pressed.connect(func() -> void:
		UIAnimator.animate_popup_close(quest_log_modal, func() -> void: _sync_overlay_visibility())
	)
	bag_close_btn.pressed.connect(func() -> void:
		UIAnimator.animate_popup_close(bag_modal, func() -> void: _sync_overlay_visibility())
	)
	toast_timer.timeout.connect(func() -> void: toast_panel.visible = false)

	pause_menu.resumed.connect(func() -> void: _sync_overlay_visibility())
	learning_hub_modal.closed.connect(func() -> void: _sync_overlay_visibility())
	pause_menu.world_map_requested.connect(func() -> void: SceneRouter.go_to_world_map())
	pause_menu.quests_requested.connect(func() -> void: _open_quest_log())
	pause_menu.settings_requested.connect(func() -> void: UIManager.open_settings(true))
	pause_menu.save_and_exit_requested.connect(func() -> void:
		pause_menu.close_pause()
		UIManager.request_exit_to_main_menu()
	)

	EventBus.progress_updated.connect(_refresh_header)
	EventBus.quest_started.connect(func(_id: String) -> void: _refresh_quest_tracker())
	EventBus.quest_step_updated.connect(func(_id: String, _idx: int) -> void: _refresh_quest_tracker())
	EventBus.quest_objective_updated.connect(func(_id: String, _oid: String, _c: int, _t: int) -> void: _refresh_quest_tracker())
	EventBus.quest_completed.connect(_on_quest_completed)
	EventBus.quest_reward_claimed.connect(func(_id: String, _r: Dictionary) -> void:
		_refresh_quest_tracker()
		_refresh_header()
	)
	EventBus.toast_requested.connect(func(msg: String, _kind: String) -> void: show_toast(msg))
	EventBus.area_locked_attempted.connect(_on_area_locked_attempted)
	EventBus.area_unlocked.connect(_on_area_unlocked)
	EventBus.dialogue_started.connect(func(_id: String) -> void:
		_dialogue_active = true
		_sync_overlay_visibility()
		call_deferred("_sync_overlay_visibility")
	)
	EventBus.dialogue_ended.connect(_on_dialogue_ended)
	EventBus.pause_toggled.connect(func(_p: bool) -> void: call_deferred("_sync_overlay_visibility"))
	EventBus.viewport_breakpoint_changed.connect(func(_b: String, _s: Vector2) -> void: _apply_responsive())
	EventBus.settings_changed.connect(_apply_responsive)
	EventBus.ui_locale_changed.connect(func(_l: String) -> void: _refresh_localized_labels())

	_refresh_header()
	_refresh_quest_tracker()
	_refresh_localized_labels()
	_apply_responsive()


func _apply_design_system() -> void:
	if UIManager.shared_theme != null:
		for child in get_children():
			if child is Control:
				(child as Control).theme = UIManager.shared_theme

	var solid_modal := UIDesignSystem.make_panel_style(Color(0.08, 0.13, 0.24, 1.0), UIDesignSystem.BORDER_DEFAULT, 14, 2, 0, 0)
	var hud_panel := UIDesignSystem.make_panel_style(Color(0.07, 0.12, 0.22, 0.96), UIDesignSystem.BORDER_DEFAULT, 12, 2, 0, 0)
	for p: PanelContainer in [top_bar, quest_tracker_panel, bottom_dock]:
		p.add_theme_stylebox_override("panel", hud_panel)
	for m: PanelContainer in [dialogue_box, quest_intro_popup, quest_done_popup, area_locked_popup, area_unlocked_popup, quest_log_modal, bag_modal]:
		m.add_theme_stylebox_override("panel", solid_modal)
	dialogue_box.add_theme_stylebox_override("panel", UIDesignSystem.make_panel_style(Color(0.07, 0.12, 0.23, 1.0), UIDesignSystem.PRIMARY, 16, 2, 0, 0))

	UIDesignSystem.apply_button_variant(map_btn, "primary")
	UIDesignSystem.apply_button_variant(quests_btn, "secondary")
	UIDesignSystem.apply_button_variant(bag_btn, "secondary")
	UIDesignSystem.apply_button_variant(desktop_buddy_btn, "reward")
	UIDesignSystem.apply_button_variant(learn_btn, "confirm")
	UIDesignSystem.apply_button_variant(minigames_btn, "reward")
	UIDesignSystem.apply_button_variant(save_btn, "primary")
	UIDesignSystem.apply_button_variant(settings_btn, "icon")
	UIDesignSystem.apply_button_variant(pause_btn, "secondary")
	UIDesignSystem.apply_button_variant(interact_banner, "reward")
	UIDesignSystem.apply_button_variant(qi_accept_btn, "confirm")
	UIDesignSystem.apply_button_variant(qi_later_btn, "secondary")
	UIDesignSystem.apply_button_variant(qd_continue_btn, "reward")
	UIDesignSystem.apply_button_variant(al_close_btn, "primary")
	UIDesignSystem.apply_button_variant(au_travel_btn, "confirm")
	UIDesignSystem.apply_button_variant(au_stay_btn, "secondary")
	UIDesignSystem.apply_button_variant(quest_log_close_btn, "close")
	UIDesignSystem.apply_button_variant(bag_close_btn, "close")


func is_blocking_overlay_above_dialogue() -> bool:
	return (
		quest_intro_popup.visible
		or quest_done_popup.visible
		or area_locked_popup.visible
		or area_unlocked_popup.visible
		or quest_log_modal.visible
		or bag_modal.visible
		or learning_hub_modal.visible
		or pause_menu.visible
		or MiniGameManager.is_overlay_open()
		or UIManager.is_modal_open()
	)


func _is_any_modal_or_dialogue_open() -> bool:
	return (
		_dialogue_active
		or dialogue_box.visible
		or quest_intro_popup.visible
		or quest_done_popup.visible
		or area_locked_popup.visible
		or area_unlocked_popup.visible
		or quest_log_modal.visible
		or bag_modal.visible
		or learning_hub_modal.visible
		or pause_menu.visible
		or MiniGameManager.is_overlay_open()
		or UIManager.is_modal_open()
	)


func _sync_overlay_visibility() -> void:
	var blocked := _is_any_modal_or_dialogue_open()
	var dlg_open := _dialogue_active or dialogue_box.visible
	interact_banner.visible = (not blocked) and _has_focused_target
	bottom_dock.visible = not blocked
	quest_tracker_panel.visible = not dlg_open
	top_bar.modulate.a = 0.55 if dlg_open else 1.0
	var use_touch := SceneRouter.is_mobile_or_compact() or _touch_input_seen
	mobile_controls.visible = use_touch and (not blocked)
	desktop_buddy_btn.visible = (not blocked) and (not use_touch)
	overlay_blocking_changed.emit(blocked)


func _on_touch_camera_pad_input(event: InputEvent) -> void:
	if _is_any_modal_or_dialogue_open():
		_cam_touch_idx = -1
		_cam_mouse_drag = false
		return
	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed and _cam_touch_idx == -1:
			_cam_touch_idx = st.index
		elif not st.pressed and st.index == _cam_touch_idx:
			_cam_touch_idx = -1
	elif event is InputEventScreenDrag:
		var sd := event as InputEventScreenDrag
		if sd.index == _cam_touch_idx:
			camera_look_delta.emit(sd.relative)
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			_cam_mouse_drag = mb.pressed
	elif event is InputEventMouseMotion and _cam_mouse_drag:
		var mm := event as InputEventMouseMotion
		camera_look_delta.emit(mm.relative)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and not _touch_input_seen:
		_touch_input_seen = true
		_apply_responsive()
	elif event is InputEventKey and event.pressed and not event.echo:
		if MiniGameManager.is_overlay_open():
			return
		var kc: Key = (event as InputEventKey).keycode
		if kc == KEY_ESCAPE:
			if UIManager.is_modal_open():
				return
			if learning_hub_modal.visible:
				learning_hub_modal.close_modal()
			elif quest_log_modal.visible:
				UIAnimator.animate_popup_close(quest_log_modal, func() -> void: _sync_overlay_visibility())
			elif bag_modal.visible:
				UIAnimator.animate_popup_close(bag_modal, func() -> void: _sync_overlay_visibility())
			elif not dialogue_box.visible:
				_toggle_pause_menu()
		elif kc == KEY_G and not _is_any_modal_or_dialogue_open():
			MiniGameManager.open_arcade_launcher()
			get_viewport().set_input_as_handled()
		elif kc == KEY_L and not _dialogue_active and not dialogue_box.visible and not pause_menu.visible and not UIManager.is_modal_open():
			if learning_hub_modal.visible:
				learning_hub_modal.close_modal()
			else:
				open_learning_hub()
			get_viewport().set_input_as_handled()
		elif kc == KEY_TAB and not _dialogue_active and not dialogue_box.visible and not pause_menu.visible and not UIManager.is_modal_open():
			if quest_log_modal.visible:
				UIAnimator.animate_popup_close(quest_log_modal, func() -> void: _sync_overlay_visibility())
			else:
				_open_quest_log()
			get_viewport().set_input_as_handled()
		elif kc == KEY_M and not _is_any_modal_or_dialogue_open():
			SceneRouter.go_to_world_map()
			get_viewport().set_input_as_handled()


func _toggle_pause_menu() -> void:
	if pause_menu.visible:
		pause_menu.close_pause()
	else:
		pause_menu.open_pause()
	_sync_overlay_visibility()


func _on_dialogue_ended(_dialogue_id: String) -> void:
	_dialogue_active = false
	dialogue_box.visible = false
	if not _pending_completed_quest.is_empty():
		var qid: String = str(_pending_completed_quest.get("quest_id", ""))
		var rw: Dictionary = _pending_completed_quest.get("rewards", {})
		_pending_completed_quest.clear()
		_show_quest_completed_modal(qid, rw)
	elif not quest_done_popup.visible and not GameStateManager.pending_area_unlocked_popup.is_empty():
		_show_next_pending_unlock()
	else:
		_flush_queued_quest_intro()
	_sync_overlay_visibility()


func _hide_all_modals() -> void:
	quest_intro_popup.visible = false
	quest_done_popup.visible = false
	area_locked_popup.visible = false
	area_unlocked_popup.visible = false
	quest_log_modal.visible = false
	bag_modal.visible = false
	learning_hub_modal.visible = false
	pause_menu.visible = false


func open_learning_hub(initial_lesson_id: String = "") -> void:
	var req := initial_lesson_id
	if req.is_empty():
		req = LearningEngine.consume_requested_lesson()
	learning_hub_modal.open_hub(req)
	_sync_overlay_visibility()


func set_area_header(area_data: Dictionary) -> void:
	area_title_label.text = "%s (%s)" % [
		str(area_data.get("name_vi", "")),
		str(area_data.get("name_en", ""))
	]


func set_focused_target(meta: Dictionary) -> void:
	if meta.is_empty():
		_has_focused_target = false
		interact_banner.visible = false
		touch_interact_btn.disabled = true
		return
	_has_focused_target = true
	var prefix := "Chạm: " if SceneRouter.is_mobile_or_compact() else "[E] Tương tác: "
	interact_banner.text = prefix + str(meta.get("title", ""))
	interact_banner.visible = not _is_any_modal_or_dialogue_open()
	touch_interact_btn.disabled = false


func show_quest_intro(quest_id: String) -> void:
	if quest_done_popup.visible or area_unlocked_popup.visible or _dialogue_active or dialogue_box.visible or not _pending_completed_quest.is_empty():
		_queued_intro_quest_id = quest_id
		return
	var q: Dictionary = DataRepository.quests_by_id.get(quest_id, {})
	if q.is_empty():
		return
	_pending_intro_quest_id = quest_id
	qi_title.text = "Nhiệm vụ mới: %s (%s)" % [str(q.get("title_vi", "")), str(q.get("title_en", ""))]
	qi_desc.text = str(q.get("description_vi", ""))
	var rw: Dictionary = q.get("rewards", {})
	qi_reward.text = "Phần thưởng: +%d EXP | +%d Gold" % [int(rw.get("exp", 0)), int(rw.get("gold", 0))]
	UIAnimator.animate_popup_open(quest_intro_popup)
	_sync_overlay_visibility()


func _flush_queued_quest_intro() -> void:
	if _queued_intro_quest_id.is_empty():
		return
	if quest_done_popup.visible or area_unlocked_popup.visible or _dialogue_active or dialogue_box.visible or not _pending_completed_quest.is_empty():
		return
	var qid := _queued_intro_quest_id
	_queued_intro_quest_id = ""
	show_quest_intro(qid)


func show_toast(msg: String) -> void:
	toast_label.text = msg
	toast_panel.visible = true
	toast_timer.start(3.0)


func _on_accept_quest_pressed() -> void:
	UIAnimator.animate_popup_close(quest_intro_popup, func() -> void: _sync_overlay_visibility())
	if not _pending_intro_quest_id.is_empty():
		quest_accepted.emit(_pending_intro_quest_id)
		_pending_intro_quest_id = ""


func set_dialogue_pending(active: bool) -> void:
	_dialogue_active = active


func clear_pending_completed_quest(quest_id: String = "") -> void:
	if quest_id.is_empty() or str(_pending_completed_quest.get("quest_id", "")) == quest_id:
		_pending_completed_quest.clear()


func set_suppress_immediate_unlock_popup(suppress: bool) -> void:
	_suppress_immediate_unlock_popup = suppress


func _on_quest_completed(quest_id: String, rewards: Dictionary) -> void:
	_refresh_quest_tracker()
	_refresh_header()
	if _dialogue_active or dialogue_box.visible:
		_pending_completed_quest = { "quest_id": quest_id, "rewards": rewards }
		return
	_show_quest_completed_modal(quest_id, rewards)


func show_claimed_reward_popup(quest_id: String, rewards: Dictionary) -> void:
	_show_quest_completed_modal(quest_id, rewards)


func _show_quest_completed_modal(quest_id: String, rewards: Dictionary) -> void:
	_reward_claim_locked = false
	_active_popup_quest_id = quest_id
	qd_continue_btn.disabled = false
	var q: Dictionary = DataRepository.quests_by_id.get(quest_id, {})
	var already_claimed := GameStateManager.claimed_quests.has(quest_id)
	qd_title.text = "Hoàn thành: %s!" % str(q.get("title_vi", quest_id))
	qd_continue_btn.text = "Tuyệt vời!" if already_claimed else LocalizationManager.tr_key("btn_claim_reward", "Nhận thưởng!")
	qd_reward_display.set_rewards(rewards)
	UIAnimator.animate_popup_open(quest_done_popup)
	UIAnimator.animate_reward_pop(qd_reward_display)
	_sync_overlay_visibility()


func _on_quest_done_continue() -> void:
	if _reward_claim_locked:
		return
	_reward_claim_locked = true
	qd_continue_btn.disabled = true
	if not _active_popup_quest_id.is_empty() and not GameStateManager.claimed_quests.has(_active_popup_quest_id):
		QuestManager.claim_quest_reward(_active_popup_quest_id)
	_active_popup_quest_id = ""
	UIAnimator.animate_popup_close(quest_done_popup, func() -> void:
		_sync_overlay_visibility()
		if not _show_next_pending_unlock():
			_flush_queued_quest_intro()
	)


func _on_area_locked_attempted(_area_id: String, reason_vi: String) -> void:
	al_reason.text = reason_vi
	UIAnimator.animate_popup_open(area_locked_popup)
	_sync_overlay_visibility()


func _on_area_unlocked(area_id: String) -> void:
	if _suppress_immediate_unlock_popup:
		return
	if not quest_done_popup.visible and not dialogue_box.visible and not _dialogue_active and _pending_completed_quest.is_empty():
		_show_area_unlocked_modal(area_id)


func _show_next_pending_unlock() -> bool:
	if GameStateManager.pending_area_unlocked_popup.is_empty():
		return false
	var aid: String = GameStateManager.pending_area_unlocked_popup.pop_front()
	_show_area_unlocked_modal(aid)
	return true


func _show_area_unlocked_modal(area_id: String) -> void:
	GameStateManager.pending_area_unlocked_popup.erase(area_id)
	var area := DataRepository.get_area(area_id)
	if area.is_empty():
		return
	_pending_unlocked_area_id = area_id
	au_title.text = "Mở khóa: %s!" % str(area.get("name_vi", area_id))
	au_desc.text = str(area.get("description_vi", ""))
	UIAnimator.animate_popup_open(area_unlocked_popup)
	_sync_overlay_visibility()


func _refresh_header() -> void:
	avatar_icon.texture = AvatarBadge.get_character_texture(GameStateManager.selected_character)
	player_info_label.text = "%s | Lv.%d" % [GameStateManager.nickname, GameStateManager.level]
	var next_exp := GameStateManager.get_exp_for_next_level()
	exp_bar.max_value = float(maxi(1, next_exp))
	exp_bar.value = float(GameStateManager.exp)
	exp_label.text = "%d/%d" % [GameStateManager.exp, next_exp]
	gold_label.text = str(GameStateManager.gold)
	crystal_label.text = str(GameStateManager.get_magic_crystal_count())


func _refresh_quest_tracker() -> void:
	for q_done in DataRepository.quests_ordered:
		var qid_done := str(q_done.get("id", ""))
		if QuestManager.get_detailed_quest_status(qid_done) == "completed":
			tracker_title.text = "Hoàn thành! Chờ nhận thưởng:"
			tracker_step.text = "• %s (Nhấn [Tab] hoặc gặp NPC để nhận thưởng)" % str(q_done.get("title_vi", qid_done))
			return

	var active_id := QuestManager.get_active_quest_id()
	if not active_id.is_empty():
		var q: Dictionary = DataRepository.quests_by_id.get(active_id, {})
		var step := QuestManager.get_current_step(active_id)
		var q_state: Dictionary = GameStateManager.active_quests.get(active_id, {})
		var steps: Array = q.get("steps", [])
		var step_num := mini(int(q_state.get("step_index", 0)) + 1, maxi(1, steps.size()))
		var prog := QuestManager.get_objective_progress(active_id, str(step.get("id", "")))
		var tgt := int(prog.get("target", 1))
		var prog_str := " (%d/%d)" % [int(prog.get("current", 0)), tgt] if tgt > 1 else ""
		tracker_title.text = "Nhiệm vụ (%d/%d): %s" % [step_num, maxi(1, steps.size()), str(q.get("title_vi", ""))]
		tracker_step.text = "• " + LocalizationManager.pick_text(step, "title") + prog_str
		return

	var next_q := QuestManager.get_next_suggested_quest()
	if not next_q.is_empty():
		var npc_id := str(next_q.get("giver_npc_id", ""))
		var npc: Dictionary = DataRepository.npcs_by_id.get(npc_id, {})
		tracker_title.text = "Nhiệm vụ sẵn sàng: " + str(next_q.get("title_vi", ""))
		tracker_step.text = "• Gặp %s để nhận nhiệm vụ" % str(npc.get("name_vi", npc_id))
	else:
		tracker_title.text = "Tiến trình Đảo Chữ Cái"
		tracker_step.text = "• Chúc mừng! Bạn đã hoàn thành toàn bộ nhiệm vụ trên Đảo Chữ Cái!"


func _refresh_localized_labels() -> void:
	var vp := get_viewport().get_visible_rect().size
	var short_dock := vp.x < 700.0
	map_btn.text = LocalizationManager.tr_key("btn_map", "Bản đồ")
	quests_btn.text = LocalizationManager.tr_key("btn_quests", "Nhiệm vụ")
	bag_btn.text = LocalizationManager.tr_key("btn_bag", "Túi đồ")
	learn_btn.text = LocalizationManager.tr_key("btn_learn", "Học tập") if short_dock else ("%s [L]" % LocalizationManager.tr_key("btn_learn", "Học tập"))
	minigames_btn.text = LocalizationManager.tr_key("btn_minigames", "Trò chơi") if short_dock else ("%s [G]" % LocalizationManager.tr_key("btn_minigames", "Trò chơi"))
	save_btn.text = LocalizationManager.tr_key("btn_save", "Lưu")
	settings_btn.text = LocalizationManager.tr_key("btn_settings", "Cài đặt")
	pause_btn.text = LocalizationManager.tr_key("btn_pause", "Menu")
	buddy_btn.text = LocalizationManager.tr_key("btn_buddy", "Hỏi Buddy")
	desktop_buddy_btn.text = "%s [H]" % LocalizationManager.tr_key("btn_buddy", "Hỏi Buddy")
	touch_jump_btn.text = LocalizationManager.tr_key("btn_jump", "Nhảy")
	touch_interact_btn.text = LocalizationManager.tr_key("btn_interact_mobile", "Tương tác")
	_refresh_quest_tracker()


func _open_quest_log() -> void:
	_populate_quest_log()
	UIAnimator.animate_popup_open(quest_log_modal)
	_sync_overlay_visibility()


func _populate_quest_log() -> void:
	for c in quest_log_list.get_children():
		c.queue_free()

	var tabs_row := HBoxContainer.new()
	tabs_row.add_theme_constant_override("separation", 6)
	var filters := [
		{ "id": "main", "label": "Chính tuyến" },
		{ "id": "side", "label": "Nhiệm vụ phụ" },
		{ "id": "completed", "label": "Hoàn thành" },
		{ "id": "locked", "label": "Chưa mở" }
	]
	for f_dict in filters:
		var fid := str(f_dict["id"])
		var tb := Button.new()
		tb.text = str(f_dict["label"])
		tb.custom_minimum_size = Vector2(0, 34)
		tb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tb.focus_mode = Control.FOCUS_NONE
		UIDesignSystem.apply_button_variant(tb, "primary" if _quest_log_filter == fid else "secondary")
		tb.pressed.connect(func() -> void:
			_quest_log_filter = fid
			_populate_quest_log()
		)
		tabs_row.add_child(tb)
	quest_log_list.add_child(tabs_row)

	var filtered := QuestManager.get_quests_by_filter(_quest_log_filter)
	if filtered.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "Chưa có nhiệm vụ nào trong mục này."
		empty_lbl.add_theme_color_override("font_color", UIDesignSystem.TEXT_MUTED)
		quest_log_list.add_child(empty_lbl)
		return

	for q in filtered:
		var card := QUEST_CARD_SCENE.instantiate() as QuestCardWidget
		quest_log_list.add_child(card)
		card.setup_quest(q)
		var qid := str(q.get("id", ""))
		var detailed := QuestManager.get_detailed_quest_status(qid)

		var action_row := HBoxContainer.new()
		action_row.add_theme_constant_override("separation", 8)
		var has_actions := false

		if detailed == "available":
			has_actions = true
			var acc_btn := Button.new()
			acc_btn.text = "Nhận nhiệm vụ này"
			acc_btn.custom_minimum_size = Vector2(0, 36)
			acc_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			UIDesignSystem.apply_button_variant(acc_btn, "confirm")
			acc_btn.pressed.connect(func() -> void:
				QuestManager.start_quest(qid)
				_populate_quest_log()
			)
			action_row.add_child(acc_btn)
		elif detailed == "completed":
			has_actions = true
			var claim_btn := Button.new()
			claim_btn.text = LocalizationManager.tr_key("btn_claim_reward", "Nhận thưởng!")
			claim_btn.custom_minimum_size = Vector2(0, 38)
			claim_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			UIDesignSystem.apply_button_variant(claim_btn, "reward")
			claim_btn.pressed.connect(func() -> void:
				var res := QuestManager.claim_quest_reward(qid)
				if bool(res.get("granted", false)):
					_populate_quest_log()
					show_claimed_reward_popup(qid, q.get("rewards", {}))
			)
			action_row.add_child(claim_btn)

		var mg_id := QuestManager.get_quest_minigame_id(qid)
		if not mg_id.is_empty() and detailed != "locked":
			has_actions = true
			var mg_btn := Button.new()
			mg_btn.text = "Chơi Mini-Game (%s)" % mg_id.replace("_", " ").capitalize()
			mg_btn.custom_minimum_size = Vector2(0, 36)
			mg_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			UIDesignSystem.apply_button_variant(mg_btn, "primary")
			mg_btn.pressed.connect(func() -> void:
				quest_log_modal.visible = false
				_sync_overlay_visibility()
				MiniGameManager.start_minigame(mg_id, {
					"source_type": "quest",
					"source_id": qid,
					"quest_id": qid,
					"bypass_unlock": true
				})
			)
			action_row.add_child(mg_btn)

		if has_actions:
			quest_log_list.add_child(action_row)


func _open_bag() -> void:
	_populate_bag()
	UIAnimator.animate_popup_open(bag_modal)
	_sync_overlay_visibility()


func _populate_bag() -> void:
	for c in bag_list.get_children():
		c.queue_free()

	var tabs_row := HBoxContainer.new()
	tabs_row.add_theme_constant_override("separation", 8)
	for t_dict in [
		{ "id": "items", "label": "Vật phẩm (%d)" % InventoryManager.get_enriched_items().size() },
		{ "id": "achievements", "label": "Thành tựu (%d/%d)" % [GameStateManager.unlocked_achievements.size(), DataRepository.achievements_ordered.size()] },
		{ "id": "history", "label": "Lịch sử thưởng (%d)" % GameStateManager.reward_history.size() }
	]:
		var tid := str(t_dict["id"])
		var tb := Button.new()
		tb.text = str(t_dict["label"])
		tb.custom_minimum_size = Vector2(0, 34)
		tb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tb.focus_mode = Control.FOCUS_NONE
		UIDesignSystem.apply_button_variant(tb, "primary" if _bag_tab == tid else "secondary")
		tb.pressed.connect(func() -> void:
			_bag_tab = tid
			_populate_bag()
		)
		tabs_row.add_child(tb)
	bag_list.add_child(tabs_row)

	var sync_lbl := Label.new()
	sync_lbl.text = SaveLoadManager.get_sync_status_summary()
	sync_lbl.add_theme_font_size_override("font_size", 12)
	sync_lbl.add_theme_color_override("font_color", UIDesignSystem.TEXT_MUTED)
	sync_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bag_list.add_child(sync_lbl)

	if _bag_tab == "items":
		var items := InventoryManager.get_enriched_items()
		if items.is_empty():
			var empty_lbl := Label.new()
			empty_lbl.text = LocalizationManager.tr_key(
				"bag_empty",
				"Túi đồ đang trống. Hãy mở rương và hoàn thành nhiệm vụ trên Đảo Chữ Cái để thu thập vật phẩm!"
			)
			empty_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			bag_list.add_child(empty_lbl)
			return
		for item in items:
			var item_id := str(item.get("id", ""))
			var card := PanelContainer.new()
			card.add_theme_stylebox_override(
				"panel",
				UIDesignSystem.make_panel_style(Color(0.11, 0.17, 0.3, 0.96), UIDesignSystem.BORDER_DEFAULT, 10, 1, 12, 8)
			)
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 12)
			var icon := TextureRect.new()
			icon.custom_minimum_size = Vector2(40, 40)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.texture = _resolve_item_icon(item_id)
			row.add_child(icon)

			var info_col := VBoxContainer.new()
			info_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var title := Label.new()
			title.text = "%s (%s)  x%d  [%s]" % [
				str(item.get("name_vi", item_id)),
				str(item.get("name_en", "")),
				int(item.get("quantity", 1)),
				str(item.get("rarity", "common")).to_upper()
			]
			var note := Label.new()
			note.text = "%s\nNguồn: %s" % [str(item.get("description_vi", "")), str(item.get("acquisition_source_vi", ""))]
			note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			note.add_theme_font_size_override("font_size", 12)
			note.add_theme_color_override("font_color", UIDesignSystem.TEXT_MUTED)
			info_col.add_child(title)
			info_col.add_child(note)
			row.add_child(info_col)

			if bool(item.get("usable", false)):
				var use_btn := Button.new()
				use_btn.text = LocalizationManager.tr_key("btn_use_item", "Sử dụng")
				use_btn.custom_minimum_size = Vector2(96, 36)
				use_btn.focus_mode = Control.FOCUS_NONE
				var check := InventoryManager.can_use_item(item_id)
				UIDesignSystem.apply_button_variant(use_btn, "confirm" if bool(check.get("ok", false)) else "secondary")
				use_btn.pressed.connect(func() -> void:
					InventoryManager.use_item(item_id)
					_populate_bag()
				)
				row.add_child(use_btn)

			card.add_child(row)
			bag_list.add_child(card)
	elif _bag_tab == "achievements":
		for ach in DataRepository.achievements_ordered:
			var aid := str(ach.get("id", ""))
			var unlocked := GameStateManager.unlocked_achievements.has(aid)
			var card := PanelContainer.new()
			card.add_theme_stylebox_override(
				"panel",
				UIDesignSystem.make_panel_style(
					Color(0.12, 0.22, 0.24, 0.96) if unlocked else Color(0.11, 0.15, 0.24, 0.92),
					UIDesignSystem.SUCCESS if unlocked else UIDesignSystem.BORDER_DEFAULT,
					10, 1, 12, 8
				)
			)
			var lbl := Label.new()
			lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			var rw: Dictionary = ach.get("rewards", {})
			lbl.text = "%s %s (%s)\n%s | Thưởng: +%d EXP, +%d Gold" % [
				"[Đạt được]" if unlocked else "[Chưa mở]",
				str(ach.get("title_vi", aid)),
				str(ach.get("title_en", "")),
				str(ach.get("description_vi", "")),
				int(rw.get("exp", 0)),
				int(rw.get("gold", 0))
			]
			lbl.add_theme_color_override("font_color", UIDesignSystem.SUCCESS if unlocked else UIDesignSystem.TEXT_LIGHT)
			card.add_child(lbl)
			bag_list.add_child(card)
	else:
		if GameStateManager.reward_history.is_empty():
			var empty_h := Label.new()
			empty_h.text = "Chưa có phần thưởng nào được ghi nhận."
			bag_list.add_child(empty_h)
		else:
			for i in range(GameStateManager.reward_history.size() - 1, -1, -1):
				var entry: Dictionary = GameStateManager.reward_history[i]
				var lbl := Label.new()
				lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				lbl.add_theme_font_size_override("font_size", 13)
				lbl.text = "• [%s] %s: +%d EXP, +%d Gold, +%d Sao" % [
					str(entry.get("source_type", "")),
					str(entry.get("source_id", "")),
					int(entry.get("exp", 0)),
					int(entry.get("gold", 0)),
					int(entry.get("stars", 0))
				]
				bag_list.add_child(lbl)


func _resolve_item_icon(item_id: String) -> Texture2D:
	if item_id.contains("crystal"):
		return load("res://assets/environments/alphabet_island/magic_crystal.svg")
	if item_id.contains("letter"):
		return load("res://assets/environments/alphabet_island/lost_letter_glow.svg")
	return load("res://assets/icons/backpack_icon.svg")


func _apply_responsive() -> void:
	var vp: Vector2 = get_viewport().get_visible_rect().size
	var safe := ResponsiveHelper.get_safe_area_margins(get_viewport())
	var top_pad := int(safe["top"])
	var left_pad := int(safe["left"])
	var right_pad := int(safe["right"])
	var bottom_pad := int(safe["bottom"])

	top_bar.offset_left = 10.0 + float(left_pad)
	top_bar.offset_right = -10.0 - float(right_pad)
	top_bar.offset_top = 8.0 + float(top_pad)
	top_bar.offset_bottom = 66.0 + float(top_pad)

	var compact := vp.x < 780.0
	area_title_label.visible = vp.x >= 720.0
	settings_btn.visible = vp.x >= 680.0
	quest_tracker_panel.offset_left = 10.0 + float(left_pad)
	quest_tracker_panel.offset_right = minf(330.0, vp.x - 20.0 - float(right_pad))
	quest_tracker_panel.offset_top = 72.0 + float(top_pad)
	quest_tracker_panel.offset_bottom = 146.0 + float(top_pad)

	var dock_w := minf(756.0, vp.x - 24.0 - float(left_pad + right_pad))
	bottom_dock.offset_left = -dock_w * 0.5
	bottom_dock.offset_right = dock_w * 0.5
	bottom_dock.offset_bottom = -10.0 - float(bottom_pad)
	bottom_dock.offset_top = -62.0 - float(bottom_pad)

	# Keep touch Joystick & RightPad safely above BottomDock with zero overlap
	var touch_bottom_base := 74.0 + float(bottom_pad)
	var joy_sz := 122.0 if vp.x < 680.0 else 140.0
	joystick.offset_left = 14.0 + float(left_pad)
	joystick.offset_right = 14.0 + float(left_pad) + joy_sz
	joystick.offset_bottom = -touch_bottom_base
	joystick.offset_top = -touch_bottom_base - joy_sz

	touch_right_pad.offset_right = -14.0 - float(right_pad)
	touch_right_pad.offset_left = -14.0 - float(right_pad) - (126.0 if vp.x < 680.0 else 138.0)
	touch_right_pad.offset_bottom = -touch_bottom_base
	touch_right_pad.offset_top = -touch_bottom_base - 156.0

	if compact:
		save_btn.visible = false
	else:
		save_btn.visible = true
	var short_dock := vp.x < 700.0
	learn_btn.text = LocalizationManager.tr_key("btn_learn", "Học tập") if short_dock else ("%s [L]" % LocalizationManager.tr_key("btn_learn", "Học tập"))
	minigames_btn.text = LocalizationManager.tr_key("btn_minigames", "Trò chơi") if short_dock else ("%s [G]" % LocalizationManager.tr_key("btn_minigames", "Trò chơi"))

	var modal_half_w := minf(330.0, (vp.x - 28.0) * 0.5)
	quest_log_modal.offset_left = -modal_half_w
	quest_log_modal.offset_right = modal_half_w
	var bag_half_w := minf(280.0, (vp.x - 28.0) * 0.5)
	bag_modal.offset_left = -bag_half_w
	bag_modal.offset_right = bag_half_w

	var hub_half_w := minf(460.0, (vp.x - 24.0) * 0.5)
	var hub_half_h := minf(290.0, (vp.y - 36.0) * 0.5)
	learning_hub_modal.offset_left = -hub_half_w
	learning_hub_modal.offset_right = hub_half_w
	learning_hub_modal.offset_top = -hub_half_h
	learning_hub_modal.offset_bottom = hub_half_h

	_sync_overlay_visibility()
