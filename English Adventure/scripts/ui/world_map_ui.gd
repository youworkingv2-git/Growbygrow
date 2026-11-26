extends Control
## World Map Screen (#5): Interactive Alphabet Island map showing all 5 areas,
## connecting paths, start/quest indicators, Locked/Unlocked/InProgress/Completed states,
## area illustrations, related quests, and 5 future worlds extension preview.

const AREA_ART := {
	"welcome_village": "res://assets/environments/alphabet_island/owl_house.svg",
	"alphabet_meadow": "res://assets/environments/alphabet_island/lost_letter_glow.svg",
	"letter_cave": "res://assets/environments/alphabet_island/cave_arch.svg",
	"crystal_lake": "res://assets/environments/alphabet_island/magic_crystal.svg",
	"shadow_gate": "res://assets/environments/alphabet_island/shadow_gate.svg"
}

var _selected_area_id: String = ""
var _node_buttons: Dictionary = {}

@onready var main_margin: MarginContainer = $MainMargin
@onready var map_canvas: Control = $MainMargin/MainVBox/BodySplit/MapCanvasContainer/MapCanvas
@onready var map_3d_viewport: SubViewport = $MainMargin/MainVBox/BodySplit/MapCanvasContainer/MapCanvas/Map3DViewportContainer/SubViewport
@onready var map_3d_scene: AlphabetIsland3DMap = $MainMargin/MainVBox/BodySplit/MapCanvasContainer/MapCanvas/Map3DViewportContainer/SubViewport/AlphabetIsland3DMap
@onready var connections_layer: Control = $MainMargin/MainVBox/BodySplit/MapCanvasContainer/MapCanvas/ConnectionsLayer
@onready var nodes_layer: Control = $MainMargin/MainVBox/BodySplit/MapCanvasContainer/MapCanvas/NodesLayer
@onready var body_split: BoxContainer = $MainMargin/MainVBox/BodySplit
@onready var area_illustration: TextureRect = $MainMargin/MainVBox/BodySplit/InfoPanel/Margin/VBox/AreaHeader/AreaIllustration
@onready var info_title: Label = $MainMargin/MainVBox/BodySplit/InfoPanel/Margin/VBox/AreaHeader/TitleCol/AreaTitle
@onready var info_status: Label = $MainMargin/MainVBox/BodySplit/InfoPanel/Margin/VBox/AreaHeader/TitleCol/StatusBadge
@onready var info_desc: Label = $MainMargin/MainVBox/BodySplit/InfoPanel/Margin/VBox/Scroll/Details/AreaDesc
@onready var related_quests_box: VBoxContainer = $MainMargin/MainVBox/BodySplit/InfoPanel/Margin/VBox/Scroll/Details/RelatedQuestsBox
@onready var info_unlock: Label = $MainMargin/MainVBox/BodySplit/InfoPanel/Margin/VBox/Scroll/Details/UnlockHint
@onready var travel_btn: Button = $MainMargin/MainVBox/BodySplit/InfoPanel/Margin/VBox/TravelBtn
@onready var main_menu_btn: Button = $MainMargin/MainVBox/HeaderBar/MainMenuBtn
@onready var settings_btn: Button = $MainMargin/MainVBox/HeaderBar/SettingsBtn
@onready var back_btn: Button = $MainMargin/MainVBox/HeaderBar/BackToAreaBtn
@onready var future_worlds_row: HBoxContainer = $MainMargin/MainVBox/FutureWorldsBar/Scroll/Row
@onready var locked_popup: PanelContainer = $AreaLockedPopup
@onready var locked_reason_label: Label = $AreaLockedPopup/Margin/VBox/ReasonLabel
@onready var locked_close_btn: Button = $AreaLockedPopup/Margin/VBox/CloseBtn


func _ready() -> void:
	locked_popup.visible = false
	locked_popup.add_theme_stylebox_override("panel", UIDesignSystem.make_panel_style(Color(0.08, 0.13, 0.24, 1.0), UIDesignSystem.BORDER_DEFAULT, 14, 2, 0, 0))
	UIDesignSystem.apply_button_variant(main_menu_btn, "secondary")
	UIDesignSystem.apply_button_variant(settings_btn, "secondary")
	UIDesignSystem.apply_button_variant(back_btn, "back")
	UIDesignSystem.apply_button_variant(locked_close_btn, "primary")
	for b: Button in [main_menu_btn, settings_btn, back_btn, travel_btn, locked_close_btn]:
		UIAnimator.attach_button_feedback(b)

	locked_close_btn.pressed.connect(func() -> void: UIAnimator.animate_popup_close(locked_popup))
	travel_btn.pressed.connect(_on_travel_pressed)
	main_menu_btn.pressed.connect(func() -> void: SceneRouter.go_to_main_menu())
	settings_btn.pressed.connect(func() -> void: UIManager.open_settings(true))
	back_btn.pressed.connect(func() -> void: SceneRouter.enter_area(GameStateManager.current_area_id))
	EventBus.viewport_breakpoint_changed.connect(func(_b: String, _s: Vector2) -> void: _apply_responsive())
	EventBus.ui_locale_changed.connect(func(_l: String) -> void:
		_build_area_nodes()
		_build_future_worlds_bar()
		_select_area(_selected_area_id)
		call_deferred("_layout_map_nodes")
	)
	map_canvas.resized.connect(_layout_map_nodes)

	_build_area_nodes()
	_build_future_worlds_bar()
	_select_area(GameStateManager.current_area_id)
	_apply_responsive()
	call_deferred("_layout_map_nodes")


func _build_area_nodes() -> void:
	for child in nodes_layer.get_children():
		child.queue_free()
	_node_buttons.clear()

	for area in DataRepository.areas_ordered:
		var aid := str(area.get("id", ""))
		var status := GameStateManager.get_area_status(aid)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(142, 62)
		btn.clip_text = false

		var badge := ""
		if bool(area.get("is_start_area", false)):
			badge += "[Start] "
		if _area_has_active_or_available_quest(aid):
			badge += "[!] "
		if status == "locked":
			badge = "[Khóa] "
		elif status == "completed":
			badge = "[OK] " + badge
		var status_text := _status_label(status)
		btn.text = "%s%s\n(%s)" % [badge, LocalizationManager.pick_text(area, "name"), status_text]

		match status:
			"locked":
				UIDesignSystem.apply_button_variant(btn, "disabled")
			"completed":
				UIDesignSystem.apply_button_variant(btn, "confirm")
			"in_progress":
				UIDesignSystem.apply_button_variant(btn, "reward")
			_:
				UIDesignSystem.apply_button_variant(btn, "primary")

		UIAnimator.attach_button_feedback(btn)
		btn.pressed.connect(func() -> void: _on_area_node_clicked(aid))
		nodes_layer.add_child(btn)
		_node_buttons[aid] = btn


func _area_has_active_or_available_quest(area_id: String) -> bool:
	for q in DataRepository.quests_ordered:
		if str(q.get("area_id", "")) == area_id:
			var st := QuestManager.get_quest_status(str(q.get("id", "")))
			if st == "available" or st == "active":
				return true
	return false


func _layout_map_nodes() -> void:
	var sz := map_canvas.size
	if sz.x < 50.0 or sz.y < 50.0:
		return

	var compact := sz.x < 520.0
	var btn_sz := Vector2(106, 48) if compact else Vector2(144, 58)
	var vp_sz := Vector2(map_3d_viewport.size)

	for area in DataRepository.areas_ordered:
		var aid := str(area.get("id", ""))
		var btn: Button = _node_buttons.get(aid, null)
		if btn != null:
			btn.custom_minimum_size = btn_sz
			btn.size = btn_sz
			btn.add_theme_font_size_override("font_size", 11 if compact else 12)
			var center := _normalized_to_canvas(area.get("map_pos", {}), sz)
			if map_3d_scene != null and vp_sz.x > 10.0 and vp_sz.y > 10.0:
				var p3d := map_3d_scene.get_area_screen_position(aid)
				if p3d != Vector2.ZERO:
					center = Vector2(
						clampf((p3d.x / vp_sz.x) * sz.x, btn_sz.x * 0.55, sz.x - btn_sz.x * 0.55),
						clampf((p3d.y / vp_sz.y) * sz.y, btn_sz.y * 0.55, sz.y - btn_sz.y * 0.55)
					)
			btn.position = center - btn.size * 0.5


func _process(_delta: float) -> void:
	if visible:
		_layout_map_nodes()


func _normalized_to_canvas(pos_dict: Dictionary, sz: Vector2) -> Vector2:
	var nx := clampf(float(pos_dict.get("x", 0.5)), 0.14, 0.86)
	var ny := clampf(float(pos_dict.get("y", 0.5)), 0.18, 0.82)
	return Vector2(nx * sz.x, ny * sz.y)


func _on_area_node_clicked(area_id: String) -> void:
	_select_area(area_id)
	var btn: Button = _node_buttons.get(area_id, null)
	if btn != null:
		UIAnimator.animate_pulse_once(btn)
	if not GameStateManager.is_area_unlocked(area_id):
		var area := DataRepository.get_area(area_id)
		var cond: Dictionary = area.get("unlock_condition", {})
		locked_reason_label.text = str(cond.get("description_vi", "Hoàn thành nhiệm vụ trước để mở khu vực này!"))
		UIAnimator.animate_popup_open(locked_popup)


func _select_area(area_id: String) -> void:
	_selected_area_id = area_id
	if map_3d_scene != null:
		map_3d_scene.focus_area(area_id)
		map_3d_scene.refresh_states()
	for aid_var in _node_buttons.keys():
		var aid := str(aid_var)
		var b: Button = _node_buttons[aid]
		b.modulate = Color(1.12, 1.12, 1.12, 1.0) if aid == area_id else Color(0.92, 0.94, 0.98, 0.92)

	var area := DataRepository.get_area(area_id)
	if area.is_empty():
		return

	var art_path := str(AREA_ART.get(area_id, AREA_ART["welcome_village"]))
	if ResourceLoader.exists(art_path):
		area_illustration.texture = load(art_path)

	var status := GameStateManager.get_area_status(area_id)
	info_title.text = "%s (%s)" % [str(area.get("name_vi", "")), str(area.get("name_en", ""))]
	info_status.text = "Trạng thái: " + _status_label(status)
	info_status.add_theme_color_override("font_color", _status_color(status))
	info_desc.text = LocalizationManager.pick_text(area, "description")

	for c in related_quests_box.get_children():
		c.queue_free()
	var found_quest := false
	for q in DataRepository.quests_ordered:
		if str(q.get("area_id", "")) == area_id:
			found_quest = true
			var qid := str(q.get("id", ""))
			var qst := QuestManager.get_quest_status(qid)
			var qlbl := Label.new()
			qlbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			qlbl.add_theme_font_size_override("font_size", 13)
			var tag := "[OK]" if qst == "completed" else ("[>>]" if qst == "active" else ("[!] " if qst == "available" else "[Khóa]"))
			qlbl.text = "%s %s" % [tag, str(q.get("title_vi", qid))]
			qlbl.add_theme_color_override("font_color", UIDesignSystem.SUCCESS if qst == "completed" else UIDesignSystem.TEXT_LIGHT)
			related_quests_box.add_child(qlbl)
	if not found_quest:
		var none_lbl := Label.new()
		none_lbl.add_theme_font_size_override("font_size", 13)
		none_lbl.add_theme_color_override("font_color", UIDesignSystem.TEXT_MUTED)
		none_lbl.text = "• Khu vực tự do khám phá / câu chuyện mở rộng"
		related_quests_box.add_child(none_lbl)

	var cond: Dictionary = area.get("unlock_condition", {})
	if status == "locked":
		info_unlock.visible = true
		info_unlock.text = "Điều kiện mở: " + str(cond.get("description_vi", ""))
		travel_btn.text = "Đang bị khóa"
		travel_btn.disabled = true
		UIDesignSystem.apply_button_variant(travel_btn, "disabled")
	else:
		info_unlock.visible = false
		travel_btn.text = "Đi tới khu vực này!"
		travel_btn.disabled = false
		UIDesignSystem.apply_button_variant(travel_btn, "confirm")


func _on_travel_pressed() -> void:
	if _selected_area_id.is_empty():
		return
	if not SceneRouter.enter_area(_selected_area_id):
		var area := DataRepository.get_area(_selected_area_id)
		locked_reason_label.text = str(area.get("unlock_condition", {}).get("description_vi", ""))
		UIAnimator.animate_popup_open(locked_popup)


func _build_future_worlds_bar() -> void:
	for c in future_worlds_row.get_children():
		c.queue_free()
	for w in DataRepository.worlds:
		var active := bool(w.get("is_mvp_active", false))
		var card := WorldCardWidget.new()
		card.setup_world_entry(
			str(w.get("id", "")),
			str(w.get("name_en", "")),
			"Đang mở" if active else "Sắp ra mắt",
			active,
			not active
		)
		future_worlds_row.add_child(card)


func _status_label(status: String) -> String:
	match status:
		"locked": return LocalizationManager.tr_key("status_locked", "Chưa mở khóa")
		"unlocked": return LocalizationManager.tr_key("status_unlocked", "Đã mở khóa")
		"in_progress": return LocalizationManager.tr_key("status_in_progress", "Đang khám phá")
		"completed": return LocalizationManager.tr_key("status_completed", "Đã hoàn thành")
		_: return status


func _status_color(status: String) -> Color:
	match status:
		"locked": return UIDesignSystem.ERROR
		"completed": return UIDesignSystem.SUCCESS
		"in_progress": return UIDesignSystem.SECONDARY_LIGHT
		_: return UIDesignSystem.PRIMARY_LIGHT


func _apply_responsive() -> void:
	ResponsiveHelper.apply_safe_margin_to_container(main_margin, get_viewport(), 14)
	var vp := get_viewport().get_visible_rect().size
	body_split.vertical = vp.x < 860.0
	call_deferred("_layout_map_nodes")
