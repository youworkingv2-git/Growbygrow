extends Control
## Splash Screen (#1): 3D Alphabet Island backdrop, animated logo reveal,
## loading indicator & progress bar, and smooth transition into Main Menu.

var _elapsed: float = 0.0
var _done: bool = false

@onready var root_margin: MarginContainer = $SafeMargin
@onready var card: PanelContainer = $SafeMargin/Center/Card
@onready var card_vbox: VBoxContainer = $SafeMargin/Center/Card/Margin/VBox
@onready var logo_box: VBoxContainer = $SafeMargin/Center/Card/Margin/VBox/LogoBox
@onready var loading_widget: LoadingIndicatorWidget = $SafeMargin/Center/Card/Margin/VBox/LoadingRow
@onready var progress_bar: ProgressBar = $SafeMargin/Center/Card/Margin/VBox/LoadingBar
@onready var status_label: Label = $SafeMargin/Center/Card/Margin/VBox/StatusLabel
@onready var skip_hint: Label = $SafeMargin/Center/Card/Margin/VBox/SkipHint


func _ready() -> void:
	card.add_theme_stylebox_override("panel", UIDesignSystem.make_panel_style(Color(0.07, 0.12, 0.23, 0.92), UIDesignSystem.PRIMARY, 16, 2, 0, 0))
	ResponsiveHelper.apply_safe_margin_to_container(root_margin, get_viewport(), 16)
	var vp := get_viewport().get_visible_rect().size
	var cw := minf(470.0, vp.x - 32.0)
	card.custom_minimum_size = Vector2(cw, 250.0)
	card_vbox.custom_minimum_size = Vector2(maxf(240.0, cw - 56.0), 0.0)
	var msg := LocalizationManager.tr_key("splash_loading", "Đang đánh thức Đảo Bảng Chữ Cái...")
	status_label.text = msg
	loading_widget.set_loading_text(msg)
	progress_bar.value = 0.0

	if not UIAnimator.is_reduced():
		logo_box.modulate.a = 0.0
		logo_box.scale = Vector2(0.9, 0.9)
		logo_box.pivot_offset = Vector2(180, 40)
		var tw := create_tween().set_parallel(true)
		tw.tween_property(logo_box, "modulate:a", 1.0, 0.35)
		tw.tween_property(logo_box, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	if _done:
		return
	_elapsed += delta
	var pct := clampf(_elapsed / 1.05, 0.0, 1.0) * 100.0
	progress_bar.value = pct
	if _elapsed >= 1.15:
		_finish_splash()


func _unhandled_input(event: InputEvent) -> void:
	if _done:
		return
	if (event is InputEventMouseButton and event.pressed) or (event is InputEventKey and event.pressed):
		_finish_splash()


func _finish_splash() -> void:
	if _done:
		return
	_done = true
	progress_bar.value = 100.0
	var ready_msg := LocalizationManager.tr_key("splash_ready", "Sẵn sàng phiêu lưu!")
	status_label.text = ready_msg
	loading_widget.set_loading_text(ready_msg)
	skip_hint.visible = false
	SceneRouter.go_to_main_menu()
