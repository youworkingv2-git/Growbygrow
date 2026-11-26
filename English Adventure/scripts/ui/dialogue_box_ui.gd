extends PanelContainer
## Shared Dialogue UI supporting speaker portrait, typewriter text reveal,
## bilingual EN + VI toggleable display, English voice playback,
## interactive Dialogue Choices (with Quest/MiniGame actions), Continue and Skip buttons.

signal next_requested()
signal close_requested()
signal choice_selected(choice_index: int)

var _full_vi_text: String = ""
var _current_en_text: String = ""
var _char_timer: float = 0.0
var _revealed_chars: int = 0
var _is_typing: bool = false
var _show_vi: bool = true
var _has_choices: bool = false

var _choices_flow: HFlowContainer = null
var _vi_toggle_btn: Button = null
var _voice_btn: Button = null

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
	_build_dynamic_controls()


func _build_dynamic_controls() -> void:
	var text_col := $Margin/HBox/TextCol as VBoxContainer
	var btns_row := $Margin/HBox/TextCol/ButtonsRow as HBoxContainer

	_voice_btn = Button.new()
	_voice_btn.custom_minimum_size = Vector2(106, 36)
	_voice_btn.focus_mode = Control.FOCUS_NONE
	_voice_btn.text = LocalizationManager.tr_key("btn_play_voice", "Nghe thoại")
	UIDesignSystem.apply_button_variant(_voice_btn, "secondary")
	_voice_btn.pressed.connect(_on_play_voice)
	btns_row.add_child(_voice_btn)
	btns_row.move_child(_voice_btn, 0)

	_vi_toggle_btn = Button.new()
	_vi_toggle_btn.custom_minimum_size = Vector2(126, 36)
	_vi_toggle_btn.focus_mode = Control.FOCUS_NONE
	UIDesignSystem.apply_button_variant(_vi_toggle_btn, "secondary")
	_vi_toggle_btn.pressed.connect(_on_toggle_vi)
	btns_row.add_child(_vi_toggle_btn)
	btns_row.move_child(_vi_toggle_btn, 1)
	_refresh_vi_toggle_label()

	_choices_flow = HFlowContainer.new()
	_choices_flow.add_theme_constant_override("h_separation", 10)
	_choices_flow.add_theme_constant_override("v_separation", 8)
	_choices_flow.visible = false
	text_col.add_child(_choices_flow)
	var row_idx := btns_row.get_index()
	text_col.move_child(_choices_flow, row_idx)


func show_line(line_data: Dictionary, index: int, total: int, allow_close: bool = true) -> void:
	visible = true
	var seen_before := bool(line_data.get("_seen_before", false))
	close_btn.visible = allow_close or seen_before
	close_btn.text = LocalizationManager.tr_key("btn_skip", "Bỏ qua")

	var speaker_id := str(line_data.get("speaker_id", line_data.get("speaker", "")))
	var tex_path := str(line_data.get("portrait", ""))
	if not tex_path.is_empty() and ResourceLoader.exists(tex_path):
		portrait.texture = load(tex_path)
	elif not speaker_id.is_empty():
		portrait.texture = AvatarBadge.get_npc_texture(speaker_id)

	speaker_label.text = LocalizationManager.pick_text(line_data, "speaker_name")
	_current_en_text = str(line_data.get("text_en", ""))
	text_en_label.visible = not _current_en_text.is_empty()
	text_en_label.text = _current_en_text
	if _voice_btn != null:
		_voice_btn.visible = not _current_en_text.is_empty()

	_full_vi_text = str(line_data.get("text_vi", ""))
	text_vi_label.visible = _show_vi and not _full_vi_text.is_empty()
	if UIAnimator.is_reduced():
		_is_typing = false
		text_vi_label.text = _full_vi_text
	else:
		_revealed_chars = 0
		_char_timer = 0.0
		_is_typing = true
		text_vi_label.text = ""

	var choices: Array = line_data.get("choices", [])
	_has_choices = not choices.is_empty()
	_populate_choices(choices)
	next_btn.visible = not _has_choices
	next_btn.text = LocalizationManager.tr_key("btn_finish", "Hoàn tất") if index >= total - 1 else LocalizationManager.tr_key("btn_continue", "Tiếp tục >")


func _populate_choices(choices: Array) -> void:
	if _choices_flow == null:
		return
	for c in _choices_flow.get_children():
		c.queue_free()
	_choices_flow.visible = not choices.is_empty()
	for i in range(choices.size()):
		if typeof(choices[i]) != TYPE_DICTIONARY:
			continue
		var ch: Dictionary = choices[i]
		var en_txt := str(ch.get("text_en", ""))
		var vi_txt := str(ch.get("text_vi", ""))
		var btn := Button.new()
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size = Vector2(180, 42)
		btn.text = "%s (%s)" % [en_txt, vi_txt] if (_show_vi and not vi_txt.is_empty()) else en_txt
		var act := str(ch.get("quest_action", ""))
		UIDesignSystem.apply_button_variant(btn, "confirm" if not act.is_empty() else "primary")
		UIAnimator.attach_button_feedback(btn)
		var idx := i
		btn.pressed.connect(func() -> void:
			choice_selected.emit(idx)
		)
		_choices_flow.add_child(btn)


func _on_toggle_vi() -> void:
	_show_vi = not _show_vi
	_refresh_vi_toggle_label()
	text_vi_label.visible = _show_vi and not _full_vi_text.is_empty()
	if _is_typing:
		_is_typing = false
		text_vi_label.text = _full_vi_text


func _refresh_vi_toggle_label() -> void:
	if _vi_toggle_btn == null:
		return
	_vi_toggle_btn.text = LocalizationManager.tr_key("btn_toggle_vi_on", "Tiếng Việt: BẬT") if _show_vi else LocalizationManager.tr_key("btn_toggle_vi_off", "Tiếng Việt: TẮT")


func _on_play_voice() -> void:
	if _current_en_text.is_empty():
		return
	if MiniGameManager != null and MiniGameManager.audio != null:
		MiniGameManager.audio.play_word_or_sentence("", _current_en_text)


func _unhandled_input(event: InputEvent) -> void:
	if not visible or UIManager.is_modal_open():
		return
	var p := get_parent()
	if p != null and p.has_method("is_blocking_overlay_above_dialogue") and bool(p.call("is_blocking_overlay_above_dialogue")):
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var kc: Key = (event as InputEventKey).keycode
		if not _has_choices and (kc == KEY_E or kc == KEY_ENTER or kc == KEY_KP_ENTER or kc == KEY_SPACE):
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
	elif not _has_choices:
		next_requested.emit()
