class_name GameWordMatching
extends MiniGameController
## GAME 03 (Priority) - WORD MATCHING (Ghép từ với hình ảnh / nghĩa tiếng Việt)
## Skill: Reading | Modes: 1) English Word <-> Image, 2) English Word <-> Vietnamese.

var _current_item: Dictionary = {}
var _mode: String = "word_image"
var _pairs: Array[Dictionary] = []
var _matched_ids: Dictionary = {}
var _selected_left_id: String = ""
var _selected_right_id: String = ""
var _left_buttons: Dictionary = {}
var _right_buttons: Dictionary = {}

var _prompt_lbl: Label
var _status_lbl: Label
var _timer_lbl: Label
var _left_col: VBoxContainer
var _right_col: VBoxContainer
var _mode_btn: Button
var _soft_timer_left: float = 0.0
var _timer_active: bool = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 12)
	add_child(root)

	var top := HBoxContainer.new()
	top.alignment = BoxContainer.ALIGNMENT_CENTER
	top.add_theme_constant_override("separation", 14)
	root.add_child(top)

	_prompt_lbl = Label.new()
	_prompt_lbl.add_theme_font_size_override("font_size", 20)
	_prompt_lbl.add_theme_color_override("font_color", Color(0.14, 0.2, 0.34, 1))
	top.add_child(_prompt_lbl)

	_mode_btn = _make_action_button("Đổi chế độ: Từ ↔ Hình", Color(0.36, 0.44, 0.78, 1))
	_mode_btn.pressed.connect(_toggle_mode)
	top.add_child(_mode_btn)

	_timer_lbl = Label.new()
	_timer_lbl.add_theme_font_size_override("font_size", 17)
	_timer_lbl.add_theme_color_override("font_color", Color(0.55, 0.32, 0.1, 1))
	top.add_child(_timer_lbl)

	_status_lbl = Label.new()
	_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_lbl.add_theme_font_size_override("font_size", 17)
	_status_lbl.add_theme_color_override("font_color", Color(0.16, 0.42, 0.26, 1))
	root.add_child(_status_lbl)

	var board := HBoxContainer.new()
	board.alignment = BoxContainer.ALIGNMENT_CENTER
	board.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board.add_theme_constant_override("separation", 40)
	root.add_child(board)

	_left_col = VBoxContainer.new()
	_left_col.alignment = BoxContainer.ALIGNMENT_CENTER
	_left_col.add_theme_constant_override("separation", 12)
	board.add_child(_left_col)

	_right_col = VBoxContainer.new()
	_right_col.alignment = BoxContainer.ALIGNMENT_CENTER
	_right_col.add_theme_constant_override("separation", 12)
	board.add_child(_right_col)


func _process(delta: float) -> void:
	if not _timer_active:
		return
	_soft_timer_left = maxf(0.0, _soft_timer_left - delta)
	if _soft_timer_left > 0.0:
		_timer_lbl.text = "Gợi ý thời gian: %ds" % int(ceil(_soft_timer_left))
	else:
		_timer_lbl.text = "Thoải mái hoàn thành nhé!"
		_timer_active = false


func render_item(item: Dictionary, _index: int, _total: int) -> void:
	_current_item = item
	_mode = str(item.get("mode", "word_image"))
	if _mode != "word_vi":
		_mode = "word_image"
	_pairs.clear()
	for p_var in item.get("pairs", []):
		if typeof(p_var) == TYPE_DICTIONARY:
			_pairs.append(p_var as Dictionary)

	_matched_ids.clear()
	_selected_left_id = ""
	_selected_right_id = ""
	_soft_timer_left = float(session.difficulty_config.get("soft_timer_sec", 0)) if session != null else 0.0
	_timer_active = _soft_timer_left > 0.0
	_timer_lbl.visible = _timer_active
	_status_lbl.text = "Chạm 1 thẻ bên trái rồi chạm thẻ tương ứng bên phải!"
	status_hint_changed.emit("Không phạt thời gian cho người mới học; ghép đúng hết để nhận sao.")

	_rebuild_columns()


func _toggle_mode() -> void:
	_mode = "word_vi" if _mode == "word_image" else "word_image"
	_mode_btn.text = "Đổi chế độ: Từ ↔ Nghĩa Việt" if _mode == "word_vi" else "Đổi chế độ: Từ ↔ Hình"
	_selected_left_id = ""
	_selected_right_id = ""
	_rebuild_columns()


func _rebuild_columns() -> void:
	for c in _left_col.get_children():
		c.queue_free()
	for c in _right_col.get_children():
		c.queue_free()
	_left_buttons.clear()
	_right_buttons.clear()

	_mode_btn.text = "Đổi chế độ: Từ ↔ Nghĩa Việt" if _mode == "word_vi" else "Đổi chế độ: Từ ↔ Hình"
	_prompt_lbl.text = "Ghép %d cặp thẻ đúng (%s):" % [_pairs.size(), "Từ ↔ Nghĩa" if _mode == "word_vi" else "Từ ↔ Hình"]

	var left_list := _pairs.duplicate(true)
	var right_list := _pairs.duplicate(true)
	left_list.shuffle()
	right_list.shuffle()

	for p in left_list:
		var wid := str(p.get("word_id", ""))
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(230, 74)
		btn.text = "%s\n%s" % [str(p.get("word", "")).capitalize(), str(p.get("ipa", ""))]
		btn.add_theme_font_size_override("font_size", 19)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_style_card(btn, _matched_ids.has(wid), false)
		btn.disabled = _matched_ids.has(wid)
		btn.pressed.connect(func() -> void:
			_on_left_clicked(wid, p)
		)
		_left_col.add_child(btn)
		_left_buttons[wid] = btn

	for p in right_list:
		var wid := str(p.get("word_id", ""))
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(230, 74)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		if _mode == "word_vi":
			btn.text = str(p.get("meaning_vi", ""))
			btn.add_theme_font_size_override("font_size", 19)
		else:
			var hb := HBoxContainer.new()
			hb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			hb.alignment = BoxContainer.ALIGNMENT_CENTER
			hb.add_theme_constant_override("separation", 10)
			hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
			btn.add_child(hb)
			var tex_r := TextureRect.new()
			tex_r.custom_minimum_size = Vector2(56, 56)
			tex_r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tex_r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex_r.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tex_r.texture = _load_vocab_texture(str(p.get("image_path", "")))
			hb.add_child(tex_r)
		_style_card(btn, _matched_ids.has(wid), false)
		btn.disabled = _matched_ids.has(wid)
		btn.pressed.connect(func() -> void:
			_on_right_clicked(wid)
		)
		_right_col.add_child(btn)
		_right_buttons[wid] = btn


func _style_card(btn: Button, matched: bool, selected: bool) -> void:
	if matched:
		btn.add_theme_stylebox_override("normal", _make_fantasy_card(Color(0.82, 0.96, 0.85, 1), Color(0.2, 0.7, 0.34, 1), 14))
		btn.add_theme_stylebox_override("disabled", _make_fantasy_card(Color(0.82, 0.96, 0.85, 1), Color(0.2, 0.7, 0.34, 1), 14))
		btn.add_theme_color_override("font_color", Color(0.1, 0.38, 0.18, 1))
	elif selected:
		btn.add_theme_stylebox_override("normal", _make_fantasy_card(Color(0.84, 0.92, 1.0, 1), Color(0.18, 0.52, 0.9, 1), 14))
		btn.add_theme_color_override("font_color", Color(0.08, 0.22, 0.45, 1))
	else:
		btn.add_theme_stylebox_override("normal", _make_fantasy_card(Color(0.99, 0.97, 0.92, 1), Color(0.75, 0.6, 0.3, 1), 14))
		btn.add_theme_stylebox_override("hover", _make_fantasy_card(Color(0.94, 0.96, 1.0, 1), Color(0.32, 0.58, 0.88, 1), 14))
		btn.add_theme_color_override("font_color", Color(0.16, 0.2, 0.3, 1))


func _on_left_clicked(wid: String, pair_data: Dictionary) -> void:
	if _matched_ids.has(wid):
		return
	if not _selected_left_id.is_empty() and _left_buttons.has(_selected_left_id):
		_style_card(_left_buttons[_selected_left_id], false, false)
	_selected_left_id = wid
	_style_card(_left_buttons[wid], false, true)
	if audio != null:
		audio.play_word_or_sentence(str(pair_data.get("audio_path", "")), str(pair_data.get("word", "")))
	_check_pair()


func _on_right_clicked(wid: String) -> void:
	if _matched_ids.has(wid):
		return
	if not _selected_right_id.is_empty() and _right_buttons.has(_selected_right_id):
		_style_card(_right_buttons[_selected_right_id], false, false)
	_selected_right_id = wid
	_style_card(_right_buttons[wid], false, true)
	_check_pair()


func _check_pair() -> void:
	if _selected_left_id.is_empty() or _selected_right_id.is_empty():
		return
	var left_pair := _find_pair(_selected_left_id)
	var right_pair := _find_pair(_selected_right_id)
	var is_match := (_selected_left_id == _selected_right_id)

	if is_match:
		audio.play_sfx("correct")
		_matched_ids[_selected_left_id] = true
		var lb: Button = _left_buttons[_selected_left_id]
		var rb: Button = _right_buttons[_selected_right_id]
		_style_card(lb, true, false)
		_style_card(rb, true, false)
		lb.disabled = true
		rb.disabled = true
		_status_lbl.text = "Chính xác! %s = %s" % [str(left_pair.get("word", "")).capitalize(), str(left_pair.get("meaning_vi", ""))]
		_status_lbl.add_theme_color_override("font_color", Color(0.12, 0.56, 0.24, 1))
	else:
		audio.play_sfx("wrong")
		_status_lbl.text = "Chưa khớp rồi! '%s' nghĩa là '%s'. Thử cặp khác nhé!" % [
			str(left_pair.get("word", "")).capitalize(),
			str(left_pair.get("meaning_vi", ""))
		]
		_status_lbl.add_theme_color_override("font_color", Color(0.76, 0.24, 0.18, 1))
		_style_card(_left_buttons[_selected_left_id], false, false)
		_style_card(_right_buttons[_selected_right_id], false, false)

	# Record learning progress for each matched/attempted pair
	if session != null:
		var word_en := str(left_pair.get("word", "")).capitalize()
		var meaning := str(left_pair.get("meaning_vi", ""))
		var fb := session.record_answer(
			str(right_pair.get("word", "")),
			is_match,
			word_en,
			meaning,
			"%s (%s) nghĩa là %s." % [word_en, str(left_pair.get("ipa", "")), meaning],
			str(left_pair.get("example_sentence", "")),
			str(left_pair.get("audio_path", "")),
			word_en
		)
		_selected_left_id = ""
		_selected_right_id = ""
		if _matched_ids.size() >= _pairs.size():
			_timer_active = false
			round_feedback_ready.emit(fb)
	else:
		_selected_left_id = ""
		_selected_right_id = ""


func _find_pair(wid: String) -> Dictionary:
	for p in _pairs:
		if str(p.get("word_id", "")) == wid:
			return p
	return {}
