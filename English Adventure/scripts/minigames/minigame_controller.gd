class_name MiniGameController
extends Control
## Base Controller for all playable Mini-Game UI views.
## Subclasses override `render_item(item, index, total)` and emit `round_feedback_ready(feedback)`
## or `round_completed()` back to MiniGameUI.

signal round_feedback_ready(feedback: Dictionary)
signal round_completed()
signal status_hint_changed(hint_text: String)

var session: MiniGameSession = null
var audio: MiniGameAudioManager = null


func bind_session(active_session: MiniGameSession, audio_mgr: MiniGameAudioManager) -> void:
	session = active_session
	audio = audio_mgr


func start_current_round() -> void:
	if session == null:
		return
	var item := session.get_current_item()
	render_item(item, session.current_index, session.items.size())


func render_item(_item: Dictionary, _index: int, _total: int) -> void:
	pass


func request_hint() -> void:
	if session == null:
		return
	session.use_hint()
	on_hint_requested()


func on_hint_requested() -> void:
	pass


func _load_vocab_texture(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var res := load(path)
	if res is Texture2D:
		return res as Texture2D
	return null


func _make_fantasy_card(bg_color: Color = Color(0.98, 0.96, 0.9, 1.0), border_color: Color = Color(0.75, 0.58, 0.25, 1.0), radius: int = 16) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_color
	sb.border_color = border_color
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	return sb


func _make_action_button(text: String, bg_color: Color = Color(0.18, 0.48, 0.85, 1.0)) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(120, 48)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	var normal := StyleBoxFlat.new()
	normal.bg_color = bg_color
	normal.border_color = bg_color.lightened(0.25)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(12)
	normal.content_margin_left = 14
	normal.content_margin_right = 14
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = bg_color.lightened(0.12)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	return btn
