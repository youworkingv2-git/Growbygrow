class_name GameWordBuilder
extends MiniGameController
## GAME 02 (Priority) - WORD BUILDER (Xây dựng từ vựng)
## Skill: Reading + Writing
## Supports tap/click tiles, keyboard typing, mobile virtual tap, hints, and audio + image clue.

var _current_item: Dictionary = {}
var _target_word: String = ""
var _available_tiles: Array[Dictionary] = [] # { letter, used }
var _selected_indices: Array[int] = []
var _resolved: bool = false

var _prompt_lbl: Label
var _meaning_lbl: Label
var _image_rect: TextureRect
var _slots_row: HBoxContainer
var _tiles_row: HBoxContainer
var _hint_lbl: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 12)
	add_child(root)

	_prompt_lbl = Label.new()
	_prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_lbl.add_theme_font_size_override("font_size", 21)
	_prompt_lbl.add_theme_color_override("font_color", Color(0.14, 0.2, 0.34, 1))
	root.add_child(_prompt_lbl)

	var clue_box := HBoxContainer.new()
	clue_box.alignment = BoxContainer.ALIGNMENT_CENTER
	clue_box.add_theme_constant_override("separation", 18)
	root.add_child(clue_box)

	var img_panel := PanelContainer.new()
	img_panel.add_theme_stylebox_override("panel", _make_fantasy_card(Color(1, 0.98, 0.94, 1), Color(0.8, 0.64, 0.3, 1)))
	clue_box.add_child(img_panel)

	_image_rect = TextureRect.new()
	_image_rect.custom_minimum_size = Vector2(110, 110)
	_image_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	img_panel.add_child(_image_rect)

	var info_col := VBoxContainer.new()
	info_col.alignment = BoxContainer.ALIGNMENT_CENTER
	info_col.add_theme_constant_override("separation", 8)
	clue_box.add_child(info_col)

	_meaning_lbl = Label.new()
	_meaning_lbl.add_theme_font_size_override("font_size", 22)
	_meaning_lbl.add_theme_color_override("font_color", Color(0.15, 0.36, 0.62, 1))
	info_col.add_child(_meaning_lbl)

	var clue_btns := HBoxContainer.new()
	clue_btns.add_theme_constant_override("separation", 10)
	info_col.add_child(clue_btns)

	var listen_btn := _make_action_button("Nghe từ", Color(0.16, 0.54, 0.86, 1))
	listen_btn.pressed.connect(_play_word_audio)
	clue_btns.add_child(listen_btn)

	var hint_btn := _make_action_button("Gợi ý 1 chữ", Color(0.84, 0.56, 0.16, 1))
	hint_btn.pressed.connect(request_hint)
	clue_btns.add_child(hint_btn)

	_hint_lbl = Label.new()
	_hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_lbl.add_theme_font_size_override("font_size", 16)
	_hint_lbl.add_theme_color_override("font_color", Color(0.62, 0.36, 0.05, 1))
	root.add_child(_hint_lbl)

	var slots_center := CenterContainer.new()
	root.add_child(slots_center)
	_slots_row = HBoxContainer.new()
	_slots_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_slots_row.add_theme_constant_override("separation", 10)
	slots_center.add_child(_slots_row)

	var tiles_center := CenterContainer.new()
	tiles_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(tiles_center)
	_tiles_row = HBoxContainer.new()
	_tiles_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_tiles_row.add_theme_constant_override("separation", 12)
	tiles_center.add_child(_tiles_row)

	var ctrl_row := HBoxContainer.new()
	ctrl_row.alignment = BoxContainer.ALIGNMENT_CENTER
	ctrl_row.add_theme_constant_override("separation", 14)
	root.add_child(ctrl_row)

	var undo_btn := _make_action_button("Xóa chữ cuối", Color(0.55, 0.45, 0.36, 1))
	undo_btn.pressed.connect(_undo_last)
	ctrl_row.add_child(undo_btn)

	var clear_btn := _make_action_button("Làm lại", Color(0.65, 0.32, 0.28, 1))
	clear_btn.pressed.connect(_clear_all)
	ctrl_row.add_child(clear_btn)

	var check_btn := _make_action_button("Kiểm tra (Enter)", Color(0.16, 0.66, 0.36, 1))
	check_btn.pressed.connect(_submit_word)
	ctrl_row.add_child(check_btn)


func render_item(item: Dictionary, index: int, total: int) -> void:
	_current_item = item
	_resolved = false
	_target_word = str(item.get("target_word", "")).to_upper()
	_available_tiles.clear()
	_selected_indices.clear()
	_hint_lbl.text = ""

	_prompt_lbl.text = "Từ %d/%d — Sắp xếp các chữ cái để sửa vật thể phép thuật!" % [index + 1, total]
	_meaning_lbl.text = "Nghĩa: %s  %s" % [str(item.get("meaning_vi", "")), str(item.get("ipa", ""))]
	_image_rect.texture = _load_vocab_texture(str(item.get("image_path", "")))
	status_hint_changed.emit("Chạm/click chữ cái hoặc gõ bàn phím A–Z, nhấn Enter để kiểm tra.")

	for l_var in item.get("letters_scrambled", []):
		_available_tiles.append({ "letter": str(l_var).to_upper(), "used": false })

	_rebuild_board()
	_play_word_audio()


func _rebuild_board() -> void:
	for c in _slots_row.get_children():
		c.queue_free()
	for c in _tiles_row.get_children():
		c.queue_free()

	for slot_i in range(_target_word.length()):
		var slot_btn := Button.new()
		slot_btn.custom_minimum_size = Vector2(60, 64)
		slot_btn.add_theme_font_size_override("font_size", 26)
		if slot_i < _selected_indices.size():
			var tile_idx := _selected_indices[slot_i]
			slot_btn.text = str(_available_tiles[tile_idx].get("letter", ""))
			slot_btn.add_theme_stylebox_override("normal", _make_fantasy_card(Color(0.86, 0.94, 1.0, 1), Color(0.2, 0.52, 0.88, 1), 12))
			slot_btn.add_theme_color_override("font_color", Color(0.1, 0.22, 0.44, 1))
			slot_btn.pressed.connect(func() -> void:
				_remove_slot(slot_i)
			)
		else:
			slot_btn.text = "_"
			slot_btn.add_theme_stylebox_override("normal", _make_fantasy_card(Color(0.95, 0.93, 0.88, 1), Color(0.68, 0.6, 0.45, 1), 12))
			slot_btn.add_theme_color_override("font_color", Color(0.5, 0.46, 0.4, 1))
		_slots_row.add_child(slot_btn)

	for t_i in range(_available_tiles.size()):
		var tile := _available_tiles[t_i]
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(64, 68)
		btn.text = str(tile.get("letter", ""))
		btn.add_theme_font_size_override("font_size", 26)
		var used := bool(tile.get("used", false))
		btn.disabled = used
		if used:
			btn.modulate = Color(0.7, 0.7, 0.7, 0.45)
			btn.add_theme_stylebox_override("disabled", _make_fantasy_card(Color(0.88, 0.86, 0.82, 1), Color(0.65, 0.62, 0.58, 1), 14))
		else:
			btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			btn.add_theme_stylebox_override("normal", _make_fantasy_card(Color(1.0, 0.94, 0.74, 1), Color(0.82, 0.56, 0.14, 1), 14))
			btn.add_theme_stylebox_override("hover", _make_fantasy_card(Color(1.0, 0.98, 0.84, 1), Color(0.24, 0.56, 0.92, 1), 14))
			btn.add_theme_color_override("font_color", Color(0.28, 0.18, 0.05, 1))
		btn.pressed.connect(func() -> void:
			_pick_tile(t_i)
		)
		_tiles_row.add_child(btn)


func _pick_tile(tile_idx: int) -> void:
	if _resolved or tile_idx < 0 or tile_idx >= _available_tiles.size():
		return
	if bool(_available_tiles[tile_idx].get("used", false)):
		return
	if _selected_indices.size() >= _target_word.length():
		return
	audio.play_sfx("click")
	_available_tiles[tile_idx]["used"] = true
	_selected_indices.append(tile_idx)
	_rebuild_board()


func _remove_slot(slot_i: int) -> void:
	if _resolved or slot_i < 0 or slot_i >= _selected_indices.size():
		return
	var tile_idx := _selected_indices[slot_i]
	_available_tiles[tile_idx]["used"] = false
	_selected_indices.remove_at(slot_i)
	_rebuild_board()


func _undo_last() -> void:
	if not _selected_indices.is_empty():
		_remove_slot(_selected_indices.size() - 1)


func _clear_all() -> void:
	if _resolved:
		return
	for t in _available_tiles:
		t["used"] = false
	_selected_indices.clear()
	_rebuild_board()


func on_hint_requested() -> void:
	if _resolved:
		return
	var next_pos := _selected_indices.size()
	if next_pos >= _target_word.length():
		_hint_lbl.text = "Gợi ý: Từ đúng bắt đầu bằng '%s', gồm %d chữ cái." % [_target_word.substr(0, 1), _target_word.length()]
		return
	var needed_char := _target_word.substr(next_pos, 1)
	for t_i in range(_available_tiles.size()):
		if not bool(_available_tiles[t_i].get("used", false)) and str(_available_tiles[t_i].get("letter", "")) == needed_char:
			_pick_tile(t_i)
			_hint_lbl.text = "Buddy đã đặt giúp chữ cái '%s' ở vị trí %d!" % [needed_char, next_pos + 1]
			return
	_hint_lbl.text = "Chữ tiếp theo là '%s' — hãy bỏ bớt chữ đặt nhầm nhé!" % needed_char


func _submit_word() -> void:
	if _resolved or _input_locked or session == null:
		return
	var built := ""
	for idx in _selected_indices:
		built += str(_available_tiles[idx].get("letter", ""))
	if built.length() < _target_word.length():
		_hint_lbl.text = "Bé hãy điền đủ %d chữ cái trước khi kiểm tra nhé!" % _target_word.length()
		return

	var is_correct := (built == _target_word)
	audio.play_sfx("correct" if is_correct else "wrong")
	if is_correct:
		_resolved = true
		_play_word_audio()

	var display := str(_current_item.get("display_word", _target_word)).capitalize()
	var meaning := str(_current_item.get("meaning_vi", ""))
	var expl := "Từ '%s' viết là %s, nghĩa là '%s'." % [display, _target_word, meaning]
	var fb := session.record_answer(
		built,
		is_correct,
		display,
		meaning,
		expl,
		str(_current_item.get("example_sentence", "")),
		str(_current_item.get("audio_path", "")),
		display
	)
	round_feedback_ready.emit(fb)


func _play_word_audio() -> void:
	if audio == null or _current_item.is_empty():
		return
	audio.play_word_or_sentence(str(_current_item.get("audio_path", "")), str(_current_item.get("display_word", "")))


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _resolved or _input_locked:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var ev := event as InputEventKey
		if ev.keycode == KEY_BACKSPACE:
			_undo_last()
			get_viewport().set_input_as_handled()
		elif ev.keycode == KEY_ENTER or ev.keycode == KEY_KP_ENTER:
			_submit_word()
			get_viewport().set_input_as_handled()
		elif ev.unicode >= 65 and ev.unicode <= 122:
			var ch := char(ev.unicode).to_upper()
			for t_i in range(_available_tiles.size()):
				if not bool(_available_tiles[t_i].get("used", false)) and str(_available_tiles[t_i].get("letter", "")) == ch:
					_pick_tile(t_i)
					get_viewport().set_input_as_handled()
					break
