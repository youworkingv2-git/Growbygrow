extends CanvasLayer
## Persistent Area HUD: Quest tracker, player stats, Map button,
## Mobile Virtual Controls, and Quest Complete / Area Unlock toast.

var _joystick_active: bool = false
var _joystick_origin: Vector2 = Vector2.ZERO

@onready var area_name_label: Label = %AreaNameLabel
@onready var stats_label: Label = %HudStatsLabel
@onready var quest_label: Label = %HudQuestLabel
@onready var map_btn: Button = %MapButton
@onready var interact_btn: Button = %MobileInteractButton
@onready var joystick_area: Control = %MobileJoystickArea
@onready var joystick_knob: ColorRect = %JoystickKnob
@onready var toast_panel: PanelContainer = %ToastPanel
@onready var toast_label: Label = %ToastLabel

func _ready() -> void:
	toast_panel.visible = false
	map_btn.pressed.connect(func(): GameManager.go_to_world_map())
	interact_btn.pressed.connect(func(): InteractionManager.trigger_current())
	joystick_area.gui_input.connect(_gui_input_joystick)

	EventBus.quest_log_updated.connect(_refresh_hud)
	EventBus.quest_completed.connect(_on_quest_completed)
	EventBus.area_unlocked.connect(_on_area_unlocked)
	EventBus.error_occurred.connect(_on_error_occurred)
	_refresh_hud()

func _refresh_hud() -> void:
	var info := GameManager.get_area_info(GameManager.current_area_id)
	area_name_label.text = "🏝️ " + info.get("name_en", "Alphabet Island")
	var p := SaveManager.player_data
	stats_label.text = "⭐ %d  |  🪙 %d  |  💎 %d" % [p.get("exp", 0), p.get("gold", 0), p.get("magic_crystals", 0)]
	var q := QuestManager.get_active_quest_summary()
	if q.is_empty():
		quest_label.text = "✅ Đã hoàn thành tất cả nhiệm vụ mẫu!"
	else:
		quest_label.text = "📜 %s: %s" % [q["name_vi"], q["step_description_vi"]]

func _on_quest_completed(quest_id: String, reward: Dictionary) -> void:
	var q: Dictionary = QuestManager.quests_by_id.get(quest_id, {})
	_show_toast("🎉 Hoàn thành %s! (+%d EXP, +%d Gold, +%d Crystal)" % [
		q.get("name_vi", quest_id),
		reward.get("exp", 0),
		reward.get("gold", 0),
		reward.get("magic_crystals", 0)
	])
	_refresh_hud()

func _on_area_unlocked(area_id: String) -> void:
	var info := GameManager.get_area_info(area_id)
	_show_toast("🔓 Đã mở khóa khu vực mới: %s!" % info.get("name_en", area_id))

func _on_error_occurred(_code: String, msg: String) -> void:
	_show_toast("⚠️ " + msg)

func _show_toast(msg: String) -> void:
	toast_label.text = msg
	toast_panel.visible = true
	await get_tree().create_timer(3.5).timeout
	if is_instance_valid(toast_panel):
		toast_panel.visible = false

func _gui_input_joystick(event: InputEvent) -> void:
	var player := get_tree().get_first_node_in_group("player") as PlayerController
	if player == null:
		return
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			_joystick_active = true
			_joystick_origin = joystick_area.size * 0.5
		else:
			_joystick_active = false
			player.set_mobile_input(Vector2.ZERO)
			if joystick_knob != null:
				joystick_knob.position = _joystick_origin - joystick_knob.size * 0.5
	elif (event is InputEventScreenDrag or event is InputEventMouseMotion) and _joystick_active:
		var delta_vec: Vector2 = event.position - _joystick_origin
		var clamped := delta_vec.limit_length(45.0)
		if joystick_knob != null:
			joystick_knob.position = _joystick_origin + clamped - joystick_knob.size * 0.5
		player.set_mobile_input(clamped / 45.0)
