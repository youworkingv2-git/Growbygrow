extends Control
## World Map Screen (#3): Interactive Alphabet Island map showing all 5 areas,
## connecting paths, start/quest indicators, Locked/Unlocked/InProgress/Completed states,
## and 5 future worlds extension preview.

var _selected_area_id: String = ""
var _node_buttons: Dictionary = {}

@onready var map_canvas: Control = $MainVBox/BodySplit/MapCanvasContainer/MapCanvas
@onready var connections_layer: Control = $MainVBox/BodySplit/MapCanvasContainer/MapCanvas/ConnectionsLayer
@onready var nodes_layer: Control = $MainVBox/BodySplit/MapCanvasContainer/MapCanvas/NodesLayer
@onready var body_split: BoxContainer = $MainVBox/BodySplit
@onready var info_title: Label = $MainVBox/BodySplit/InfoPanel/Margin/VBox/AreaTitle
@onready var info_status: Label = $MainVBox/BodySplit/InfoPanel/Margin/VBox/StatusBadge
@onready var info_desc: Label = $MainVBox/BodySplit/InfoPanel/Margin/VBox/AreaDesc
@onready var info_unlock: Label = $MainVBox/BodySplit/InfoPanel/Margin/VBox/UnlockHint
@onready var travel_btn: Button = $MainVBox/BodySplit/InfoPanel/Margin/VBox/TravelBtn
@onready var back_btn: Button = $MainVBox/HeaderBar/BackToAreaBtn
@onready var future_worlds_row: HBoxContainer = $MainVBox/FutureWorldsBar/Scroll/Row
@onready var locked_popup: PanelContainer = $AreaLockedPopup
@onready var locked_reason_label: Label = $AreaLockedPopup/Margin/VBox/ReasonLabel
@onready var locked_close_btn: Button = $AreaLockedPopup/Margin/VBox/CloseBtn


func _ready() -> void:
	locked_popup.visible = false
	locked_close_btn.pressed.connect(func() -> void: locked_popup.visible = false)
	travel_btn.pressed.connect(_on_travel_pressed)
	back_btn.pressed.connect(func() -> void: SceneRouter.enter_area(GameStateManager.current_area_id))
	EventBus.viewport_breakpoint_changed.connect(func(_b: String, _s: Vector2) -> void: _apply_responsive())
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
		btn.custom_minimum_size = Vector2(150, 68)
		btn.clip_text = false

		var badge := ""
		if bool(area.get("is_start_area", false)):
			badge += "[Start] "
		if _area_has_active_or_available_quest(aid):
			badge += "[!] "
		var status_text := _status_label(status)
		btn.text = "%s%s\n(%s)" % [badge, LocalizationManager.pick_text(area, "name"), status_text]

		match status:
			"locked":
				btn.modulate = Color(0.65, 0.68, 0.78, 0.92)
			"completed":
				btn.modulate = Color(0.55, 1.0, 0.65, 1.0)
			"in_progress":
				btn.modulate = Color(1.0, 0.92, 0.45, 1.0)
			_:
				btn.modulate = Color(0.7, 0.92, 1.0, 1.0)

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
	for child in connections_layer.get_children():
		child.queue_free()

	# Draw connecting path lines between linked areas
	var drawn_pairs: Dictionary = {}
	for area in DataRepository.areas_ordered:
		var a_id := str(area.get("id", ""))
		var p1 := _normalized_to_canvas(area.get("map_pos", {}), sz)
		for target_id_var in area.get("connected_areas", []):
			var b_id := str(target_id_var)
			var pair_key := a_id + "|" + b_id if a_id < b_id else b_id + "|" + a_id
			if drawn_pairs.has(pair_key):
				continue
			drawn_pairs[pair_key] = true
			var b_area := DataRepository.get_area(b_id)
			if b_area.is_empty():
				continue
			var p2 := _normalized_to_canvas(b_area.get("map_pos", {}), sz)
			var line := Line2D.new()
			line.width = 6.0
			var both_open := GameStateManager.is_area_unlocked(a_id) and GameStateManager.is_area_unlocked(b_id)
			line.default_color = Color("#FBBF24") if both_open else Color(0.45, 0.5, 0.62, 0.65)
			line.add_point(p1)
			line.add_point(p2)
			connections_layer.add_child(line)

	for area in DataRepository.areas_ordered:
		var aid := str(area.get("id", ""))
		var btn: Button = _node_buttons.get(aid, null)
		if btn != null:
			var center := _normalized_to_canvas(area.get("map_pos", {}), sz)
			btn.position = center - btn.size * 0.5


func _normalized_to_canvas(pos_dict: Dictionary, sz: Vector2) -> Vector2:
	var nx := clampf(float(pos_dict.get("x", 0.5)), 0.12, 0.88)
	var ny := clampf(float(pos_dict.get("y", 0.5)), 0.16, 0.84)
	return Vector2(nx * sz.x, ny * sz.y)


func _on_area_node_clicked(area_id: String) -> void:
	_select_area(area_id)
	if not GameStateManager.is_area_unlocked(area_id):
		var area := DataRepository.get_area(area_id)
		var cond: Dictionary = area.get("unlock_condition", {})
		locked_reason_label.text = str(cond.get("description_vi", "Hoàn thành nhiệm vụ trước để mở khu vực này!"))
		locked_popup.visible = true


func _select_area(area_id: String) -> void:
	_selected_area_id = area_id
	var area := DataRepository.get_area(area_id)
	if area.is_empty():
		return
	var status := GameStateManager.get_area_status(area_id)
	info_title.text = "%s (%s)" % [str(area.get("name_vi", "")), str(area.get("name_en", ""))]
	info_status.text = "Trạng thái: " + _status_label(status)
	info_desc.text = LocalizationManager.pick_text(area, "description")
	var cond: Dictionary = area.get("unlock_condition", {})
	if status == "locked":
		info_unlock.visible = true
		info_unlock.text = "Điều kiện mở: " + str(cond.get("description_vi", ""))
		travel_btn.text = "Đang bị khóa"
		travel_btn.disabled = true
	else:
		info_unlock.visible = false
		travel_btn.text = "Đi tới khu vực này!"
		travel_btn.disabled = false


func _on_travel_pressed() -> void:
	if _selected_area_id.is_empty():
		return
	if not SceneRouter.enter_area(_selected_area_id):
		var area := DataRepository.get_area(_selected_area_id)
		locked_reason_label.text = str(area.get("unlock_condition", {}).get("description_vi", ""))
		locked_popup.visible = true


func _build_future_worlds_bar() -> void:
	for c in future_worlds_row.get_children():
		c.queue_free()
	for w in DataRepository.worlds:
		var lbl := Button.new()
		var active := bool(w.get("is_mvp_active", false))
		lbl.text = ("[Active] %s" if active else "[Khóa] %s (Sắp ra mắt)") % str(w.get("name_en", ""))
		lbl.disabled = not active
		lbl.custom_minimum_size = Vector2(180, 38)
		future_worlds_row.add_child(lbl)


func _status_label(status: String) -> String:
	match status:
		"locked": return "Chưa mở khóa"
		"unlocked": return "Đã mở khóa"
		"in_progress": return "Đang khám phá"
		"completed": return "Đã hoàn thành"
		_: return status


func _apply_responsive() -> void:
	var vp := get_viewport_rect().size
	body_split.vertical = vp.x < 860.0
	call_deferred("_layout_map_nodes")
