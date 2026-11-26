extends Control
## World Introduction Screen (#4): Segmented story intro of Alphabet Island,
## The Silent Shadow, Professor Owl & Buddy with island illustration and Back/Skip/Continue.

var _lines: Array = []
var _index: int = 0

@onready var safe_margin: MarginContainer = $SafeMargin
@onready var center_panel: PanelContainer = $SafeMargin/Center/CenterPanel
@onready var center_vbox: VBoxContainer = $SafeMargin/Center/CenterPanel/Margin/VBox
@onready var portrait: SubViewportContainer = $SafeMargin/Center/CenterPanel/Margin/VBox/SpeakerRow/Portrait
@onready var speaker_stage: Diorama3DStage = $SafeMargin/Center/CenterPanel/Margin/VBox/SpeakerRow/Portrait/SubViewport/SpeakerStage3D
@onready var speaker_label: Label = $SafeMargin/Center/CenterPanel/Margin/VBox/SpeakerRow/SpeakerInfo/SpeakerName
@onready var text_en_label: Label = $SafeMargin/Center/CenterPanel/Margin/VBox/DialogueCard/Margin/Texts/TextEnLabel
@onready var text_vi_label: Label = $SafeMargin/Center/CenterPanel/Margin/VBox/DialogueCard/Margin/Texts/TextViLabel
@onready var progress_bar: ProgressBar = $SafeMargin/Center/CenterPanel/Margin/VBox/StepProgress
@onready var progress_label: Label = $SafeMargin/Center/CenterPanel/Margin/VBox/FooterRow/ProgressLabel
@onready var prev_btn: Button = $SafeMargin/Center/CenterPanel/Margin/VBox/FooterRow/PrevBtn
@onready var next_btn: Button = $SafeMargin/Center/CenterPanel/Margin/VBox/FooterRow/NextBtn
@onready var skip_btn: Button = $SafeMargin/Center/CenterPanel/Margin/VBox/HeaderRow/SkipBtn


func _ready() -> void:
	ResponsiveHelper.apply_safe_margin_to_container(safe_margin, get_viewport(), 18)
	UIDesignSystem.apply_button_variant(skip_btn, "secondary")
	UIDesignSystem.apply_button_variant(prev_btn, "back")
	UIDesignSystem.apply_button_variant(next_btn, "reward")
	for b: Button in [skip_btn, prev_btn, next_btn]:
		UIAnimator.attach_button_feedback(b)

	var raw: Variant = DataRepository.dialogues_by_id.get("world_intro", [])
	if typeof(raw) == TYPE_ARRAY:
		_lines = raw

	prev_btn.pressed.connect(_on_prev_pressed)
	next_btn.pressed.connect(_on_next_pressed)
	skip_btn.pressed.connect(_finish_intro)
	EventBus.viewport_breakpoint_changed.connect(func(_b: String, _s: Vector2) -> void: _apply_responsive())
	_apply_responsive()
	_show_current_line()


func _apply_responsive() -> void:
	ResponsiveHelper.apply_safe_margin_to_container(safe_margin, get_viewport(), 14)
	var vp := get_viewport().get_visible_rect().size
	var panel_w := minf(680.0, vp.x - 32.0)
	var inner_w := maxf(260.0, panel_w - 48.0)
	center_panel.custom_minimum_size = Vector2(panel_w, minf(420.0, vp.y - 36.0))
	center_vbox.custom_minimum_size = Vector2(inner_w, 0.0)


func _show_current_line() -> void:
	if _lines.is_empty():
		_finish_intro()
		return
	var line: Dictionary = _lines[_index]
	var speaker_id := str(line.get("speaker_id", "professor_owl"))
	if speaker_stage != null:
		speaker_stage.set_character("buddy" if "buddy" in speaker_id else "professor_owl")
	speaker_label.text = LocalizationManager.pick_text(line, "speaker_name")
	text_en_label.text = str(line.get("text_en", ""))
	text_vi_label.text = str(line.get("text_vi", ""))

	progress_bar.max_value = float(_lines.size())
	progress_bar.value = float(_index + 1)
	progress_label.text = "%d / %d" % [_index + 1, _lines.size()]
	prev_btn.text = "< Trước" if _index > 0 else "< Đổi nhân vật"
	next_btn.text = "Vào Làng Khởi Đầu!" if _index >= _lines.size() - 1 else "Tiếp tục >"
	UIAnimator.animate_pulse_once(portrait)


func _on_prev_pressed() -> void:
	if _index > 0:
		_index -= 1
		_show_current_line()
	else:
		SceneRouter.go_to_character_selection()


func _on_next_pressed() -> void:
	_index += 1
	if _index >= _lines.size():
		_finish_intro()
	else:
		_show_current_line()


func _finish_intro() -> void:
	GameStateManager.world_intro_seen = true
	GameStateManager.save_now("world_intro_completed")
	SceneRouter.enter_area("welcome_village")
