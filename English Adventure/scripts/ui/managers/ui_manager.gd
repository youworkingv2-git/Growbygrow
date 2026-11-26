extends Node
## Centralized UI Manager (Autoload):
## - Applies unified Fantasy Adventure Theme to root Viewport
## - Manages global Non-blocking Notification Stack (§4.13)
## - Hosts reusable Settings Modal, Confirmation Dialog, Tooltip, and Loading Indicator.

const CONFIRM_SCENE := preload("res://scenes/ui/common/confirmation_dialog.tscn")
const SETTINGS_SCENE := preload("res://scenes/ui/settings/settings_modal.tscn")
const LOADING_SCENE := preload("res://scenes/ui/common/loading_indicator.tscn")

var _overlay_layer: CanvasLayer = null
var _notif_stack: VBoxContainer = null
var _confirm_dialog: AdventureConfirmDialog = null
var _settings_modal: SettingsModalUI = null
var _loading_panel: PanelContainer = null
var _loading_widget: LoadingIndicatorWidget = null
var _tooltip_panel: PanelContainer = null
var _tooltip_label: Label = null

var _confirm_on_ok: Callable = Callable()
var _confirm_on_cancel: Callable = Callable()


func _ready() -> void:
	get_tree().root.theme = UIDesignSystem.build_global_theme()
	_build_global_overlay()
	_connect_events()


func _build_global_overlay() -> void:
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.layer = 90
	add_child(_overlay_layer)

	# Non-blocking notification stack (top-center)
	var notif_anchor := MarginContainer.new()
	notif_anchor.set_anchors_preset(Control.PRESET_TOP_WIDE)
	notif_anchor.offset_top = 74.0
	notif_anchor.offset_bottom = 260.0
	notif_anchor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay_layer.add_child(notif_anchor)

	var center_box := CenterContainer.new()
	center_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	notif_anchor.add_child(center_box)

	_notif_stack = VBoxContainer.new()
	_notif_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_notif_stack.add_theme_constant_override("separation", 6)
	center_box.add_child(_notif_stack)

	# Shared Tooltip
	_tooltip_panel = PanelContainer.new()
	_tooltip_panel.visible = false
	_tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tooltip_panel.add_theme_stylebox_override(
		"panel",
		UIDesignSystem.make_panel_style(Color(0.06, 0.1, 0.19, 0.96), UIDesignSystem.SECONDARY, 8, 1, 10, 6)
	)
	_tooltip_label = Label.new()
	_tooltip_label.add_theme_font_size_override("font_size", 13)
	_tooltip_panel.add_child(_tooltip_label)
	_overlay_layer.add_child(_tooltip_panel)

	# Shared Loading Indicator (non-blocking badge bottom-left/top-right)
	_loading_panel = PanelContainer.new()
	_loading_panel.visible = false
	_loading_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_loading_panel.set_anchors_preset(Control.PRESET_CENTER)
	_loading_panel.add_theme_stylebox_override(
		"panel",
		UIDesignSystem.make_panel_style(Color(0.08, 0.13, 0.24, 0.95), UIDesignSystem.PRIMARY, 12, 2, 16, 12)
	)
	_loading_widget = LOADING_SCENE.instantiate() as LoadingIndicatorWidget
	_loading_panel.add_child(_loading_widget)
	_overlay_layer.add_child(_loading_panel)

	# Shared Settings Modal
	_settings_modal = SETTINGS_SCENE.instantiate() as SettingsModalUI
	_settings_modal.main_menu_requested.connect(func() -> void:
		request_exit_to_main_menu()
	)
	_overlay_layer.add_child(_settings_modal)

	# Shared Confirmation Dialog
	_confirm_dialog = CONFIRM_SCENE.instantiate() as AdventureConfirmDialog
	_confirm_dialog.confirmed.connect(func() -> void:
		if _confirm_on_ok.is_valid():
			var cb := _confirm_on_ok
			_confirm_on_ok = Callable()
			_confirm_on_cancel = Callable()
			cb.call()
	)
	_confirm_dialog.cancelled.connect(func() -> void:
		if _confirm_on_cancel.is_valid():
			var cb := _confirm_on_cancel
			_confirm_on_ok = Callable()
			_confirm_on_cancel = Callable()
			cb.call()
	)
	_overlay_layer.add_child(_confirm_dialog)


func _connect_events() -> void:
	EventBus.quest_started.connect(func(qid: String) -> void:
		var q: Dictionary = DataRepository.quests_by_id.get(qid, {})
		var q_title := LocalizationManager.pick_text(q, "title")
		show_notification(LocalizationManager.tr_key("notif_quest_started", "Nhiệm vụ mới: %s") % q_title, "info")
	)
	EventBus.quest_completed.connect(func(qid: String, _rw: Dictionary) -> void:
		var q: Dictionary = DataRepository.quests_by_id.get(qid, {})
		var q_title := LocalizationManager.pick_text(q, "title")
		show_notification(LocalizationManager.tr_key("notif_quest_completed", "Hoàn thành: %s!") % q_title, "success")
	)
	EventBus.area_unlocked.connect(func(aid: String) -> void:
		var area := DataRepository.get_area(aid)
		var a_name := LocalizationManager.pick_text(area, "name")
		show_notification(LocalizationManager.tr_key("notif_area_unlocked", "Đã mở khu vực: %s!") % a_name, "reward")
	)
	EventBus.item_collected.connect(func(item_id: String, qty: int) -> void:
		var item_dict: Dictionary = GameStateManager.inventory.get(item_id, {})
		var i_name := LocalizationManager.pick_text(item_dict, "name")
		if i_name.is_empty():
			i_name = item_id
		show_notification(LocalizationManager.tr_key("notif_item_collected", "Nhận vật phẩm: %s x%d") % [i_name, qty], "reward")
	)
	EventBus.level_up.connect(func(new_lv: int) -> void:
		show_notification(LocalizationManager.tr_key("notif_level_up", "Lên cấp %d! Tuyệt vời!") % new_lv, "reward")
	)
	EventBus.achievement_unlocked.connect(func(_id: String, title: String) -> void:
		show_notification(LocalizationManager.tr_key("notif_achievement", "Thành tựu mới: %s") % title, "reward")
	)
	EventBus.toast_requested.connect(func(msg: String, kind: String) -> void:
		show_notification(msg, kind)
	)


func show_notification(message: String, kind: String = "info", duration: float = 3.0) -> void:
	if _notif_stack == null or message.is_empty():
		return
	while _notif_stack.get_child_count() >= 3:
		_notif_stack.get_child(0).queue_free()

	var border_col := UIDesignSystem.PRIMARY
	var text_col := UIDesignSystem.TEXT_LIGHT
	match kind:
		"success":
			border_col = UIDesignSystem.SUCCESS
		"reward":
			border_col = UIDesignSystem.SECONDARY
			text_col = UIDesignSystem.TEXT_GOLD
		"warning":
			border_col = UIDesignSystem.WARNING
		"error":
			border_col = UIDesignSystem.ERROR

	var banner := PanelContainer.new()
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.add_theme_stylebox_override(
		"panel",
		UIDesignSystem.make_panel_style(Color(0.07, 0.11, 0.21, 0.94), border_col, 10, 2, 16, 8)
	)
	var lbl := Label.new()
	lbl.text = message
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.add_theme_color_override("font_color", text_col)
	lbl.add_theme_font_size_override("font_size", 15)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.add_child(lbl)
	_notif_stack.add_child(banner)

	if not UIAnimator.is_reduced():
		banner.modulate.a = 0.0
		var tw_in := banner.create_tween()
		tw_in.tween_property(banner, "modulate:a", 1.0, 0.18)

	var timer := get_tree().create_timer(duration)
	timer.timeout.connect(func() -> void:
		if not is_instance_valid(banner):
			return
		if UIAnimator.is_reduced():
			banner.queue_free()
		else:
			var tw_out := banner.create_tween()
			tw_out.tween_property(banner, "modulate:a", 0.0, 0.22)
			tw_out.finished.connect(func() -> void:
				if is_instance_valid(banner):
					banner.queue_free()
			)
	)


func show_confirmation(
	title_text: String,
	body_text: String,
	on_confirm: Callable,
	on_cancel: Callable = Callable(),
	confirm_label: String = "",
	cancel_label: String = "",
	danger: bool = false
) -> void:
	_confirm_on_ok = on_confirm
	_confirm_on_cancel = on_cancel
	_confirm_dialog.show_dialog(title_text, body_text, confirm_label, cancel_label, danger)


func open_settings(show_main_menu_btn: bool = true) -> void:
	_settings_modal.open_modal(show_main_menu_btn)


func is_modal_open() -> bool:
	return _settings_modal.visible or _confirm_dialog.visible


func show_loading(msg: String = "Đang tải...") -> void:
	_loading_widget.set_loading_text(msg)
	_loading_panel.visible = true


func hide_loading() -> void:
	_loading_panel.visible = false


func show_tooltip(text_str: String, screen_pos: Vector2) -> void:
	_tooltip_label.text = text_str
	_tooltip_panel.position = screen_pos + Vector2(12, 12)
	_tooltip_panel.visible = true


func hide_tooltip() -> void:
	_tooltip_panel.visible = false


func request_exit_to_main_menu() -> void:
	var has_active := not GameStateManager.active_quests.is_empty()
	if has_active:
		show_confirmation(
			LocalizationManager.tr_key("confirm_exit_menu_title", "Quay về Menu Chính?"),
			LocalizationManager.tr_key("confirm_exit_menu_body", "Bạn đang có nhiệm vụ chưa hoàn thành. Game sẽ lưu toàn bộ tiến trình trước khi quay về Menu Chính."),
			func() -> void:
				GameStateManager.save_now("save_and_exit_menu")
				SceneRouter.go_to_main_menu()
		)
	else:
		GameStateManager.save_now("exit_to_menu")
		SceneRouter.go_to_main_menu()
