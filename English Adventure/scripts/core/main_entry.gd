extends Control
## Splash Screen (#1): Logo reveal, Alphabet Island illustration, loading progress bar,
## and automatic transition into Main Menu once systems & save check finish.

var _elapsed: float = 0.0
var _done: bool = false

@onready var root_margin: MarginContainer = $SafeMargin
@onready var card: PanelContainer = $SafeMargin/Center/Card
@onready var card_vbox: VBoxContainer = $SafeMargin/Center/Card/Margin/VBox
@onready var logo_box: VBoxContainer = $SafeMargin/Center/Card/Margin/VBox/LogoBox
@onready var buddy_icon: TextureRect = $SafeMargin/Center/Card/Margin/VBox/LogoBox/VisualRow/BuddyIcon
@onready var progress_bar: ProgressBar = $SafeMargin/Center/Card/Margin/VBox/LoadingBar
@onready var status_label: Label = $SafeMargin/Center/Card/Margin/VBox/StatusLabel
@onready var skip_hint: Label = $SafeMargin/Center/Card/Margin/VBox/SkipHint


func _ready() -> void:
	ResponsiveHelper.apply_safe_margin_to_container(root_margin, get_viewport(), 16)
	var vp := get_viewport().get_visible_rect().size
	var cw := minf(460.0, vp.x - 32.0)
	card.custom_minimum_size = Vector2(cw, 280.0)
	card_vbox.custom_minimum_size = Vector2(maxf(240.0, cw - 56.0), 0.0)
	status_label.text = LocalizationManager.tr_key("splash_loading", "Đang đánh thức Đảo Bảng Chữ Cái...")
	progress_bar.value = 0.0

	if not UIAnimator.is_reduced():
		logo_box.modulate.a = 0.0
		logo_box.scale = Vector2(0.9, 0.9)
		logo_box.pivot_offset = Vector2(180, 70)
		var tw := create_tween().set_parallel(true)
		tw.tween_property(logo_box, "modulate:a", 1.0, 0.35)
		tw.tween_property(logo_box, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	if _done:
		return
	_elapsed += delta
	var pct := clampf(_elapsed / 0.95, 0.0, 1.0) * 100.0
	progress_bar.value = pct
	if not UIAnimator.is_reduced():
		buddy_icon.position.y = sin(_elapsed * 4.5) * 4.0
	if _elapsed >= 1.05:
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
	status_label.text = LocalizationManager.tr_key("splash_ready", "Sẵn sàng phiêu lưu!")
	skip_hint.visible = false
	SceneRouter.go_to_main_menu()
