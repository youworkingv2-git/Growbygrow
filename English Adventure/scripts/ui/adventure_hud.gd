extends CanvasLayer
## Adventure HUD integrating Status Bar, Quest Tracker, Interact Prompt, Touch Controls,
## Quest Intro/Completed Popups, Area Locked/Unlocked Popups, Quest Log, and Inventory Bag.

signal interact_pressed()
signal jump_pressed()
signal buddy_help_pressed()
signal joystick_changed(vec: Vector2)
signal quest_accepted(quest_id: String)

var _pending_intro_quest_id: String = ""
var _pending_unlocked_area_id: String = ""

@onready var avatar_icon: TextureRect = $TopBar/Margin/Row/ProfileBox/Avatar
@onready var player_info_label: Label = $TopBar/Margin/Row/ProfileBox/PlayerInfo
@onready var area_title_label: Label = $TopBar/Margin/Row/AreaTitle
@onready var map_btn: Button = $TopBar/Margin/Row/Actions/MapBtn
@onready var quests_btn: Button = $TopBar/Margin/Row/Actions/QuestsBtn
@onready var bag_btn: Button = $TopBar/Margin/Row/Actions/BagBtn
@onready var save_btn: Button = $TopBar/Margin/Row/Actions/SaveBtn
@onready var top_row: BoxContainer = $TopBar/Margin/Row

@onready var quest_tracker_panel: PanelContainer = $QuestTracker
@onready var tracker_title: Label = $QuestTracker/Margin/VBox/Title
@onready var tracker_step: Label = $QuestTracker/Margin/VBox/StepLabel

@onready var interact_banner: Button = $InteractBanner
@onready var toast_panel: PanelContainer = $ToastPanel
@onready var toast_label: Label = $ToastPanel/Margin/Label
@onready var toast_timer: Timer = $ToastTimer

@onready var mobile_controls: Control = $MobileControls
@onready var joystick: Control = $MobileControls/VirtualJoystick
@onready var touch_interact_btn: Button = $MobileControls/RightPad/TouchInteractBtn
@onready var touch_jump_btn: Button = $MobileControls/RightPad/TouchJumpBtn
@onready var buddy_btn: Button = $MobileControls/RightPad/BuddyBtn
@onready var desktop_buddy_btn: Button = $DesktopBuddyBtn

@onready var dialogue_box: PanelContainer = $DialogueBox

@onready var quest_intro_popup: PanelContainer = $QuestIntroPopup
@onready var qi_title: Label = $QuestIntroPopup/Margin/VBox/Title
@onready var qi_desc: Label = $QuestIntroPopup/Margin/VBox/Desc
@onready var qi_reward: Label = $QuestIntroPopup/Margin/VBox/Reward
@onready var qi_accept_btn: Button = $QuestIntroPopup/Margin/VBox/Buttons/AcceptBtn
@onready var qi_later_btn: Button = $QuestIntroPopup/Margin/VBox/Buttons/LaterBtn

@onready var quest_done_popup: PanelContainer = $QuestCompletedPopup
@onready var qd_title: Label = $QuestCompletedPopup/Margin/VBox/Title
@onready var qd_rewards: Label = $QuestCompletedPopup/Margin/VBox/Rewards
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


func _ready() -> void:
	_hide_all_modals()
	interact_banner.visible = false
	toast_panel.visible = false
	for btn: Button in [map_btn, quests_btn, bag_btn, save_btn, interact_banner, touch_interact_btn, touch_jump_btn, buddy_btn, desktop_buddy_btn]:
		btn.focus_mode = Control.FOCUS_NONE

	map_btn.pressed.connect(func() -> void: SceneRouter.go_to_world_map())
	quests_btn.pressed.connect(_open_quest_log)
	bag_btn.pressed.connect(_open_bag)
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

	qi_accept_btn.pressed.connect(_on_accept_quest_pressed)
	qi_later_btn.pressed.connect(func() -> void: quest_intro_popup.visible = false)
	qd_continue_btn.pressed.connect(_on_quest_done_continue)
	al_close_btn.pressed.connect(func() -> void: area_locked_popup.visible = false)
	au_stay_btn.pressed.connect(func() -> void: area_unlocked_popup.visible = false)
	au_travel_btn.pressed.connect(func() -> void:
		area_unlocked_popup.visible = false
		if not _pending_unlocked_area_id.is_empty():
			SceneRouter.enter_area(_pending_unlocked_area_id)
	)
	quest_log_close_btn.pressed.connect(func() -> void: quest_log_modal.visible = false)
	bag_close_btn.pressed.connect(func() -> void: bag_modal.visible = false)
	toast_timer.timeout.connect(func() -> void: toast_panel.visible = false)

	EventBus.progress_updated.connect(_refresh_header)
	EventBus.quest_started.connect(func(_id: String) -> void: _refresh_quest_tracker())
	EventBus.quest_step_updated.connect(func(_id: String, _idx: int) -> void: _refresh_quest_tracker())
	EventBus.quest_completed.connect(_on_quest_completed)
	EventBus.area_locked_attempted.connect(_on_area_locked_attempted)
	EventBus.area_unlocked.connect(_on_area_unlocked)
	EventBus.viewport_breakpoint_changed.connect(func(_b: String, _s: Vector2) -> void: _apply_responsive())

	_refresh_header()
	_refresh_quest_tracker()
	_apply_responsive()


func _hide_all_modals() -> void:
	quest_intro_popup.visible = false
	quest_done_popup.visible = false
	area_locked_popup.visible = false
	area_unlocked_popup.visible = false
	quest_log_modal.visible = false
	bag_modal.visible = false


func set_area_header(area_data: Dictionary) -> void:
	area_title_label.text = "%s (%s)" % [
		str(area_data.get("name_vi", "")),
		str(area_data.get("name_en", ""))
	]


func set_focused_target(meta: Dictionary) -> void:
	if meta.is_empty():
		interact_banner.visible = false
		touch_interact_btn.disabled = true
		return
	var prefix := "Chạm: " if SceneRouter.is_mobile_or_compact() else "[E] Tương tác: "
	interact_banner.text = prefix + str(meta.get("title", ""))
	interact_banner.visible = true
	touch_interact_btn.disabled = false


func show_quest_intro(quest_id: String) -> void:
	var q: Dictionary = DataRepository.quests_by_id.get(quest_id, {})
	if q.is_empty():
		return
	_pending_intro_quest_id = quest_id
	qi_title.text = "Nhiệm vụ mới: %s (%s)" % [str(q.get("title_vi", "")), str(q.get("title_en", ""))]
	qi_desc.text = str(q.get("description_vi", ""))
	var rw: Dictionary = q.get("rewards", {})
	qi_reward.text = "Phần thưởng: +%d EXP | +%d Gold" % [int(rw.get("exp", 0)), int(rw.get("gold", 0))]
	quest_intro_popup.visible = true


func show_toast(msg: String) -> void:
	toast_label.text = msg
	toast_panel.visible = true
	toast_timer.start(3.0)


func _on_accept_quest_pressed() -> void:
	quest_intro_popup.visible = false
	if not _pending_intro_quest_id.is_empty():
		quest_accepted.emit(_pending_intro_quest_id)
		_pending_intro_quest_id = ""


func _on_quest_completed(quest_id: String, rewards: Dictionary) -> void:
	var q: Dictionary = DataRepository.quests_by_id.get(quest_id, {})
	qd_title.text = "Hoàn thành: %s!" % str(q.get("title_vi", quest_id))
	var rw_text := "+%d EXP   |   +%d Gold" % [int(rewards.get("exp", 0)), int(rewards.get("gold", 0))]
	var items: Array = rewards.get("items", [])
	if not items.is_empty():
		var item_names: Array[String] = []
		for it in items:
			item_names.append(str(it.get("name_vi", it.get("id", ""))))
		rw_text += "\nVật phẩm: " + ", ".join(item_names)
	qd_rewards.text = rw_text
	quest_done_popup.visible = true
	_refresh_quest_tracker()
	_refresh_header()


func _on_quest_done_continue() -> void:
	quest_done_popup.visible = false
	_show_next_pending_unlock()


func _on_area_locked_attempted(_area_id: String, reason_vi: String) -> void:
	al_reason.text = reason_vi
	area_locked_popup.visible = true


func _on_area_unlocked(area_id: String) -> void:
	if not quest_done_popup.visible:
		_show_area_unlocked_modal(area_id)


func _show_next_pending_unlock() -> void:
	if GameStateManager.pending_area_unlocked_popup.is_empty():
		return
	var aid: String = GameStateManager.pending_area_unlocked_popup.pop_front()
	_show_area_unlocked_modal(aid)


func _show_area_unlocked_modal(area_id: String) -> void:
	GameStateManager.pending_area_unlocked_popup.erase(area_id)
	var area := DataRepository.get_area(area_id)
	if area.is_empty():
		return
	_pending_unlocked_area_id = area_id
	au_title.text = "Mở khóa: %s!" % str(area.get("name_vi", area_id))
	au_desc.text = str(area.get("description_vi", ""))
	area_unlocked_popup.visible = true


func _refresh_header() -> void:
	var cfg := DataRepository.get_character_config(GameStateManager.selected_character)
	var path := str(cfg.get("sprite_path", ""))
	if ResourceLoader.exists(path):
		avatar_icon.texture = load(path)
	player_info_label.text = "%s  |  Lv.%d  |  EXP:%d  |  Gold:%d" % [
		GameStateManager.nickname, GameStateManager.level, GameStateManager.exp, GameStateManager.gold
	]


func _refresh_quest_tracker() -> void:
	var active_id := QuestManager.get_active_quest_id()
	if not active_id.is_empty():
		var q: Dictionary = DataRepository.quests_by_id.get(active_id, {})
		var step := QuestManager.get_current_step(active_id)
		tracker_title.text = "Nhiệm vụ: " + str(q.get("title_vi", ""))
		tracker_step.text = "• " + LocalizationManager.pick_text(step, "title")
		return

	var next_q := QuestManager.get_next_suggested_quest()
	if not next_q.is_empty():
		var npc_id := str(next_q.get("giver_npc_id", ""))
		var npc: Dictionary = DataRepository.npcs_by_id.get(npc_id, {})
		tracker_title.text = "Nhiệm vụ sẵn sàng: " + str(next_q.get("title_vi", ""))
		tracker_step.text = "• Gặp %s để nhận nhiệm vụ" % str(npc.get("name_vi", npc_id))
	else:
		tracker_title.text = "Tiến trình Đảo Chữ Cái"
		tracker_step.text = "• Bạn đã hoàn thành toàn bộ nhiệm vụ mẫu!"


func _open_quest_log() -> void:
	for c in quest_log_list.get_children():
		c.queue_free()
	for q in DataRepository.quests_ordered:
		var qid := str(q.get("id", ""))
		var status := QuestManager.get_quest_status(qid)
		var card := PanelContainer.new()
		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_bottom", 8)
		var lbl := Label.new()
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var status_vi := {
			"locked": "[Khóa] Chưa mở",
			"available": "[!] Có thể nhận",
			"active": "[>>] Đang thực hiện",
			"completed": "[OK] Đã hoàn thành"
		}.get(status, status)
		var step_info := ""
		if status == "active":
			var step := QuestManager.get_current_step(qid)
			step_info = "\nBước hiện tại: " + LocalizationManager.pick_text(step, "title")
		lbl.text = "[%s] %s (%s)\n%s%s" % [
			status_vi, str(q.get("title_vi", "")), str(q.get("title_en", "")),
			str(q.get("description_vi", "")), step_info
		]
		margin.add_child(lbl)
		card.add_child(margin)
		quest_log_list.add_child(card)
	quest_log_modal.visible = true


func _open_bag() -> void:
	for c in bag_list.get_children():
		c.queue_free()
	if GameStateManager.inventory.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "Túi đồ đang trống. Hãy mở rương và hoàn thành nhiệm vụ để thu thập vật phẩm!"
		empty_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		bag_list.add_child(empty_lbl)
	else:
		for item in GameStateManager.inventory.values():
			var lbl := Label.new()
			lbl.text = "• %s (%s)  x%d" % [
				str(item.get("name_vi", "")),
				str(item.get("name_en", "")),
				int(item.get("quantity", 1))
			]
			bag_list.add_child(lbl)
	bag_modal.visible = true


func _apply_responsive() -> void:
	var compact := SceneRouter.is_mobile_or_compact()
	mobile_controls.visible = compact or OS.has_feature("mobile")
	desktop_buddy_btn.visible = not mobile_controls.visible
	var vp: Vector2 = get_viewport().get_visible_rect().size
	top_row.vertical = vp.x < 780.0
	quest_tracker_panel.offset_top = 115.0 if top_row.vertical else 76.0
