extends PanelContainer
## Shared Dialogue UI supporting speaker portrait (AvatarBadge), speaker name,
## typewriter text reveal, bilingual EN + VI scrollable display, Continue and Skip buttons.

signal next_requested()
signal close_requested()

var _full_vi_text: String = ""
var _char_timer: float = 0.0
var _revealed_chars: int = 0
var _is_typing: bool = false

@onready var portrait: TextureRect = $Margin/HBox/Portrait
@onready var speaker_label: Label = $Margin/HBox/TextCol/SpeakerName
@onready var text_en_label: Label = $Margin/HBox/TextCol/Scroll/Lines/TextEn
@onready var text_vi_label: Label = $Margin/HBox/TextCol/Scroll/Lines/TextVi
@onready var next_btn: Button = $Margin/HBox/TextCol/ButtonsRow/NextBtn
@onready var close_btn: Button = $Margin/HBox/TextCol/ButtonsRow/CloseBtn


func _ready() -> void:
	visible = false
	UIDesignSystem.apply_button_variant(next_btn, "primary")
	UIDesignSystem.apply_button_variant(close_btn, "secondary")
	UIAnimator.attach_button_feedback(next_btn)
	UIAnimator.attach_button_feedback(close_btn)
	next_btn.pressed.connect(_on_next_pressed)
	close_btn.pressed.connect(func() -> void: close_requested.emit())


func show_line(line_data: Dictionary, index: int, total: int, allow_close: bool = true) -> void:
	visible = true
	close_btn.visible = allow_close
	close_btn.text = LocalizationManager.tr_key("btn_skip", "Bỏ qua")

	var speaker_id := str(line_data.get("speaker", ""))
	var tex_path := str(line_data.get("portrait", ""))
	if not tex_path.is_empty() and ResourceLoader.exists(tex_path):
		portrait.texture = load(tex_path)
	elif not speaker_id.is_empty():
		portrait.texture = AvatarBadge.get_npc_texture(speaker_id)

	speaker_label.text = LocalizationManager.pick_text(line_data, "speaker_name")
	var en_txt := str(line_data.get("text_en", ""))
	text_en_label.visible = not en_txt.is_empty()
	text_en_label.text = en_txt

	_full_vi_text = str(line_data.get("text_vi", ""))
	if UIAnimator.is_reduced():
		_is_typing = false
		text_vi_label.text = _full_vi_text
	else:
		_revealed_chars = 0
		_char_timer = 0.0
		_is_typing = true
		text_vi_label.text = ""
	next_btn.text = LocalizationManager.tr_key("btn_finish", "Hoàn tất") if index >= total - 1 else LocalizationManager.tr_key("btn_continue", "Tiếp tục >")


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var kc: Key = (event as InputEventKey).keycode
		if kc == KEY_E or kc == KEY_ENTER or kc == KEY_KP_ENTER or kc == KEY_SPACE:
			get_viewport().set_input_as_handled()
			_on_next_pressed()


func _process(delta: float) -> void:
	if not visible or not _is_typing:
		return
	_char_timer += delta
	var target_chars := int(_char_timer * 55.0)
	if target_chars >= _full_vi_text.length():
		_revealed_chars = _full_vi_text.length()
		text_vi_label.text = _full_vi_text
		_is_typing = false
	elif target_chars > _revealed_chars:
		_revealed_chars = target_chars
		text_vi_label.text = _full_vi_text.substr(0, _revealed_chars)


func _on_next_pressed() -> void:
	if _is_typing:
		_is_typing = false
		text_vi_label.text = _full_vi_text
	else:
		next_requested.emit()
