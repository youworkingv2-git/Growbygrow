class_name GameListenAndFind
extends MiniGameController
## GAME 01 - LISTEN AND FIND (Nghe và tìm hình đúng)
## Skill: Listening | Easy: 2 cards, Medium: 3 cards, Hard: 4-5 cards.

var _current_item: Dictionary = {}
var _resolved: bool = false
var _choice_buttons: Array[Button] = []
var _audio_status_lbl: Label
var _hint_lbl: Label
var _prompt_lbl: Label
var _cards_row: HBoxContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 14)
	add_child(root)

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

	var play_btn := _make_action_button("Nghe từ (Space)", Color(0.15, 0.52, 0.86, 1))
	play_btn.pressed.connect(_play_target_audio)
	audio_bar.add_child(play_btn)

	var hint_btn := _make_action_button("Gợi ý (H)", Color(0.84, 0.56, 0.16, 1))
	hint_btn.pressed.connect(request_hint)
	audio_bar.add_child(hint_btn)

	_audio_status_lbl = Label.new()
	_audio_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_audio_status_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_audio_status_lbl.add_theme_font_size_override("font_size", 14)
	_audio_status_lbl.add_theme_color_override("font_color", Color(0.32, 0.38, 0.48, 1))
	root.add_child(_audio_status_lbl)

	_hint_lbl = Label.new()
	_hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_lbl.add_theme_font_size_override("font_size", 17)
	_hint_lbl.add_theme_color_override("font_color", Color(0.62, 0.36, 0.05, 1))
	root.add_child(_hint_lbl)

	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(center)

	_cards_row = HBoxContainer.new()
	_cards_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_cards_row.add_theme_constant_override("separation", 16)
	center.add_child(_cards_row)


func render_item(item: Dictionary, index: int, total: int) -> void:
	_current_item = item
	_resolved = false
	_choice_buttons.clear()
	for c in _cards_row.get_children():
		c.queue_free()

	_prompt_lbl.text = "Câu %d/%d — Professor Owl đọc: hãy nghe và chọn đúng hình!" % [index + 1, total]
	_hint_lbl.text = ""
	status_hint_changed.emit("Phím tắt: Space để nghe lại, phím 1–5 để chọn nhanh.")

	var choices: Array = item.get("choices", [])
	for i in range(choices.size()):
		if typeof(choices[i]) != TYPE_DICTIONARY:
			continue
		var ch: Dictionary = choices[i]
		var card := _build_image_choice_card(ch, i)
		_cards_row.add_child(card)

	_play_target_audio()


func _build_image_choice_card(ch: Dictionary, idx: int) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(185, 210)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.add_theme_stylebox_override("normal", _make_fantasy_card(Color(0.99, 0.97, 0.92, 1), Color(0.75, 0.6, 0.3, 1)))
	btn.add_theme_stylebox_override("hover", _make_fantasy_card(Color(0.92, 0.96, 1.0, 1), Color(0.24, 0.56, 0.92, 1)))

	var vb := VBoxContainer.new()
	vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 8)
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(vb)

	var badge := Label.new()
	badge.text = "[%d]" % (idx + 1)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 14)
	badge.add_theme_color_override("font_color", Color(0.45, 0.45, 0.52, 1))
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(badge)

	var tex_rect := TextureRect.new()
	tex_rect.custom_minimum_size = Vector2(118, 118)
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tex := _load_vocab_texture(str(ch.get("image_path", "")))
	if tex != null:
		tex_rect.texture = tex
	vb.add_child(tex_rect)

	var lbl := Label.new()
	lbl.text = str(ch.get("meaning_vi", ""))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color(0.18, 0.24, 0.36, 1))
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(lbl)

	btn.pressed.connect(func() -> void:
		_on_choice_selected(ch, btn)
	)
	_choice_buttons.append(btn)
	return btn


func _play_target_audio() -> void:
	if audio == null or _current_item.is_empty():
		return
	var target_word := str(_current_item.get("target_word", ""))
	var res := audio.play_word_or_sentence(str(_current_item.get("audio_path", "")), target_word)
	var src := str(res.get("source", ""))
	if src == "missing_asset":
		_audio_status_lbl.text = "Âm đọc mẫu: \"%s\" (%s) — %s" % [
			target_word.capitalize(),
			str(_current_item.get("ipa", "")),
			str(res.get("message_vi", ""))
		]
	else:
		_audio_status_lbl.text = str(res.get("message_vi", ""))


func on_hint_requested() -> void:
	var target_word := str(_current_item.get("target_word", ""))
	var ipa := str(_current_item.get("ipa", ""))
	_hint_lbl.text = "Gợi ý của Buddy: Bắt đầu bằng chữ '%s' (%s) — %s" % [
		target_word.substr(0, 1).to_upper(),
		ipa,
		str(_current_item.get("meaning_vi", ""))
	]
	_play_target_audio()


func _on_choice_selected(ch: Dictionary, btn: Button) -> void:
	if _resolved or _input_locked or session == null:
		return
	var is_correct := bool(ch.get("is_correct", false))
	var chosen_word := str(ch.get("word", ""))
	var target_word := str(_current_item.get("target_word", "")).capitalize()
	var meaning_vi := str(_current_item.get("meaning_vi", ""))
	var ex_en := str(_current_item.get("example_sentence", ""))
	var audio_path := str(_current_item.get("audio_path", ""))

	audio.play_sfx("correct" if is_correct else "wrong")
	if is_correct:
		_resolved = true
		btn.add_theme_stylebox_override("normal", _make_fantasy_card(Color(0.84, 0.98, 0.86, 1), Color(0.18, 0.72, 0.34, 1)))
	else:
		btn.add_theme_stylebox_override("normal", _make_fantasy_card(Color(1.0, 0.88, 0.88, 1), Color(0.84, 0.25, 0.25, 1)))
		# Also replay target word immediately when wrong
		_play_target_audio()

	var expl := "Từ '%s' (%s) có nghĩa là '%s'." % [target_word, str(_current_item.get("ipa", "")), meaning_vi]
	var fb := session.record_answer(
		chosen_word,
		is_correct,
		target_word,
		meaning_vi,
		expl,
		ex_en,
		audio_path,
		target_word
	)
	round_feedback_ready.emit(fb)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var k := (event as InputEventKey).keycode
		if k == KEY_SPACE:
			_play_target_audio()
			get_viewport().set_input_as_handled()
		elif k == KEY_H and not _input_locked:
			request_hint()
			get_viewport().set_input_as_handled()
		elif not _input_locked and k >= KEY_1 and k <= KEY_5:
			var idx := int(k - KEY_1)
			if idx < _choice_buttons.size():
				_choice_buttons[idx].pressed.emit()
				get_viewport().set_input_as_handled()
