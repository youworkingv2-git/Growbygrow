class_name GameSoundDetective
extends MiniGameController
## GAME 05 - SOUND DETECTIVE (Thám tử âm thanh)
## Skill: Listening + Phonics | Distinguishes Letter Name vs Letter Sound + safe word phonics.

var _current_item: Dictionary = {}
var _resolved: bool = false
var _buttons: Array[Button] = []

var _prompt_lbl: Label
var _badge_lbl: Label
var _audio_lbl: Label
var _choices_row: HBoxContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 14)
	add_child(root)

	_badge_lbl = Label.new()
	_badge_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_badge_lbl.add_theme_font_size_override("font_size", 16)
	_badge_lbl.add_theme_color_override("font_color", Color(0.58, 0.34, 0.08, 1))
	root.add_child(_badge_lbl)

	_prompt_lbl = Label.new()
	_prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_prompt_lbl.add_theme_font_size_override("font_size", 22)
	_prompt_lbl.add_theme_color_override("font_color", Color(0.14, 0.2, 0.34, 1))
	root.add_child(_prompt_lbl)

	var audio_bar := HBoxContainer.new()
	audio_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	audio_bar.add_theme_constant_override("separation", 12)
	root.add_child(audio_bar)

	var play_btn := _make_action_button("Nghe manh mối âm thanh (Space)", Color(0.16, 0.5, 0.84, 1))
	play_btn.pressed.connect(_play_clue_audio)
	audio_bar.add_child(play_btn)

	var hint_btn := _make_action_button("Gợi ý thám tử", Color(0.84, 0.56, 0.16, 1))
	hint_btn.pressed.connect(request_hint)
	audio_bar.add_child(hint_btn)

	_audio_lbl = Label.new()
	_audio_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_audio_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_audio_lbl.add_theme_font_size_override("font_size", 15)
	_audio_lbl.add_theme_color_override("font_color", Color(0.3, 0.36, 0.46, 1))
	root.add_child(_audio_lbl)

	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(center)
	_choices_row = HBoxContainer.new()
	_choices_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_choices_row.add_theme_constant_override("separation", 18)
	center.add_child(_choices_row)


func render_item(item: Dictionary, index: int, total: int) -> void:
	_current_item = item
	_resolved = false
	_buttons.clear()
	for c in _choices_row.get_children():
		c.queue_free()

	var mode := str(item.get("mode", "letter_sound"))
	var mode_tag := "ÂM CHỮ CÁI (Letter Sound)" if mode == "letter_sound" else ("TÊN CHỮ CÁI (Letter Name)" if mode == "letter_name" else "PHÂN BIỆT TỪ (Phonics)")
	_badge_lbl.text = "Vụ án %d/%d — Chế độ: %s" % [index + 1, total, mode_tag]
	_prompt_lbl.text = str(item.get("prompt_vi", ""))
	status_hint_changed.emit("Phân biệt rõ Tên chữ cái (/eɪ/, /biː/) và Âm chữ cái (/æ/, /b/).")

	for i in range((item.get("choices", []) as Array).size()):
		var ch: Dictionary = (item.get("choices", []) as Array)[i]
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(150, 140)
		btn.text = "[%d]\n%s" % [i + 1, str(ch.get("label", ""))]
		btn.add_theme_font_size_override("font_size", 28)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.add_theme_stylebox_override("normal", _make_fantasy_card(Color(0.99, 0.97, 0.92, 1), Color(0.74, 0.58, 0.28, 1), 16))
		btn.add_theme_stylebox_override("hover", _make_fantasy_card(Color(0.9, 0.95, 1.0, 1), Color(0.22, 0.54, 0.88, 1), 16))
		btn.add_theme_color_override("font_color", Color(0.15, 0.22, 0.36, 1))
		btn.pressed.connect(func() -> void:
			_on_pick(ch, btn)
		)
		_choices_row.add_child(btn)
		_buttons.append(btn)

	_play_clue_audio()


func _play_clue_audio() -> void:
	if audio == null or _current_item.is_empty():
		return
	var speak_t := str(_current_item.get("speak_text", ""))
	var res := audio.play_word_or_sentence(str(_current_item.get("audio_path", "")), speak_t)
	_audio_lbl.text = "Manh mối IPA: %s — %s" % [str(_current_item.get("target_ipa", "")), str(res.get("message_vi", ""))]


func on_hint_requested() -> void:
	_audio_lbl.text = "Gợi ý thám tử: %s" % str(_current_item.get("explanation_vi", ""))
	_play_clue_audio()


func _on_pick(ch: Dictionary, btn: Button) -> void:
	if _resolved or session == null:
		return
	var is_correct := bool(ch.get("is_correct", false))
	audio.play_sfx("correct" if is_correct else "wrong")
	if is_correct:
		_resolved = true
		btn.add_theme_stylebox_override("normal", _make_fantasy_card(Color(0.84, 0.98, 0.86, 1), Color(0.2, 0.72, 0.34, 1), 16))
	else:
		btn.add_theme_stylebox_override("normal", _make_fantasy_card(Color(1.0, 0.88, 0.88, 1), Color(0.84, 0.24, 0.24, 1), 16))
		_play_clue_audio()

	var target := str(_current_item.get("target_label", ""))
	var expl := str(_current_item.get("explanation_vi", ""))
	var fb := session.record_answer(
		str(ch.get("label", "")),
		is_correct,
		target,
		str(_current_item.get("target_ipa", "")),
		expl,
		str(_current_item.get("speak_text", "")),
		str(_current_item.get("audio_path", "")),
		str(_current_item.get("speak_text", ""))
	)
	round_feedback_ready.emit(fb)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var k := (event as InputEventKey).keycode
		if k == KEY_SPACE:
			_play_clue_audio()
			get_viewport().set_input_as_handled()
		elif k >= KEY_1 and k <= KEY_4:
			var idx := int(k - KEY_1)
			if idx < _buttons.size():
				_buttons[idx].pressed.emit()
				get_viewport().set_input_as_handled()
