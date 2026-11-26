class_name GameMemoryQuest
extends MiniGameController
## GAME 07 - MEMORY QUEST (Trí nhớ phiêu lưu)
## Skill: Listening + Reading + Vocabulary
## Supports 3/4/6 pairs and 3 modes: Word<->Image, Word<->VI, Audio<->Image.

var _pairs: Array[Dictionary] = []
var _mode: String = "word_image"
var _cards: Array[Dictionary] = [] # { word_id, kind, pair_data, revealed, matched, btn }
var _flipped_indices: Array[int] = []
var _locked: bool = false
var _matched_pairs: int = 0

var _prompt_lbl: Label
var _status_lbl: Label
var _grid: GridContainer
var _mode_btn: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var top := HBoxContainer.new()
	top.alignment = BoxContainer.ALIGNMENT_CENTER
	top.add_theme_constant_override("separation", 14)
	root.add_child(top)

	_prompt_lbl = Label.new()
	_prompt_lbl.add_theme_font_size_override("font_size", 20)
	_prompt_lbl.add_theme_color_override("font_color", Color(0.14, 0.2, 0.34, 1))
	top.add_child(_prompt_lbl)

	_mode_btn = _make_action_button("Chế độ: Từ ↔ Hình", Color(0.36, 0.44, 0.78, 1))
	_mode_btn.pressed.connect(_cycle_mode)
	top.add_child(_mode_btn)

	_status_lbl = Label.new()
	_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_lbl.add_theme_font_size_override("font_size", 17)
	_status_lbl.add_theme_color_override("font_color", Color(0.16, 0.44, 0.28, 1))
	root.add_child(_status_lbl)

	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(center)
	_grid = GridContainer.new()
	_grid.add_theme_constant_override("h_separation", 12)
	_grid.add_theme_constant_override("v_separation", 12)
	center.add_child(_grid)


func render_item(item: Dictionary, _index: int, _total: int) -> void:
	_pairs.clear()
	for p_var in item.get("pairs", []):
		if typeof(p_var) == TYPE_DICTIONARY:
			_pairs.append(p_var as Dictionary)
	_mode = str(item.get("mode", "word_image"))
	if not (_mode in ["word_image", "word_vi", "audio_image"]):
		_mode = "word_image"
	_setup_deck()


func _cycle_mode() -> void:
	if _mode == "word_image":
		_mode = "word_vi"
	elif _mode == "word_vi":
		_mode = "audio_image"
	else:
		_mode = "word_image"
	_setup_deck()


func _setup_deck() -> void:
	_cards.clear()
	_flipped_indices.clear()
	_locked = false
	_matched_pairs = 0
	for c in _grid.get_children():
		c.queue_free()

	var mode_label := "Từ ↔ Hình" if _mode == "word_image" else ("Từ ↔ Nghĩa Việt" if _mode == "word_vi" else "Nghe âm ↔ Hình")
	_mode_btn.text = "Chế độ: " + mode_label
	_prompt_lbl.text = "Tìm %d cặp thẻ phép thuật (%s)!" % [_pairs.size(), mode_label]
	_status_lbl.text = "Lật 2 thẻ bất kỳ để tìm cặp từ vựng khớp nhau."
	status_hint_changed.emit("Kết hợp ghi nhớ vị trí thẻ và ý nghĩa/phát âm của từng từ.")

	var total_cards := _pairs.size() * 2
	_grid.columns = 3 if total_cards <= 6 else 4

	var deck: Array[Dictionary] = []
	for p in _pairs:
		var wid := str(p.get("word_id", ""))
		deck.append({
			"word_id": wid,
			"kind": "a",
			"pair_data": p,
			"revealed": false,
			"matched": false
		})
		deck.append({
			"word_id": wid,
			"kind": "b",
			"pair_data": p,
			"revealed": false,
			"matched": false
		})
	deck.shuffle()

	for idx in range(deck.size()):
		var card_info := deck[idx]
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(148, 114)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.pressed.connect(func() -> void:
			_on_card_pressed(idx)
		)
		card_info["btn"] = btn
		_cards.append(card_info)
		_grid.add_child(btn)
		_refresh_card_visual(idx)


func _refresh_card_visual(idx: int) -> void:
	var c := _cards[idx]
	var btn: Button = c["btn"]
	for ch in btn.get_children():
		ch.queue_free()

	var revealed := bool(c.get("revealed", false))
	var matched := bool(c.get("matched", false))
	if not revealed and not matched:
		btn.text = "?"
		btn.add_theme_font_size_override("font_size", 32)
		btn.add_theme_stylebox_override("normal", _make_fantasy_card(Color(0.22, 0.42, 0.72, 1), Color(0.86, 0.72, 0.34, 1), 14))
		btn.add_theme_stylebox_override("hover", _make_fantasy_card(Color(0.28, 0.5, 0.82, 1), Color(1.0, 0.84, 0.42, 1), 14))
		btn.add_theme_color_override("font_color", Color(1.0, 0.94, 0.72, 1))
		btn.disabled = false
		return

	var bg := Color(0.82, 0.96, 0.85, 1) if matched else Color(1.0, 0.98, 0.92, 1)
	var bd := Color(0.18, 0.7, 0.34, 1) if matched else Color(0.24, 0.54, 0.88, 1)
	btn.add_theme_stylebox_override("normal", _make_fantasy_card(bg, bd, 14))
	btn.add_theme_stylebox_override("disabled", _make_fantasy_card(bg, bd, 14))
	btn.add_theme_color_override("font_color", Color(0.12, 0.22, 0.38, 1))
	btn.disabled = matched

	var p: Dictionary = c.get("pair_data", {})
	var kind := str(c.get("kind", "a"))
	if kind == "a":
		if _mode == "audio_image":
			btn.text = "Nghe từ\n♪"
			btn.add_theme_font_size_override("font_size", 20)
		else:
			btn.text = "%s\n%s" % [str(p.get("word", "")).capitalize(), str(p.get("ipa", ""))]
			btn.add_theme_font_size_override("font_size", 18)
	else:
		if _mode == "word_vi":
			btn.text = str(p.get("meaning_vi", ""))
			btn.add_theme_font_size_override("font_size", 18)
		else:
			btn.text = ""
			var vb := VBoxContainer.new()
			vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			vb.alignment = BoxContainer.ALIGNMENT_CENTER
			vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
			btn.add_child(vb)
			var tex_r := TextureRect.new()
			tex_r.custom_minimum_size = Vector2(76, 76)
			tex_r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tex_r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex_r.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tex_r.texture = _load_vocab_texture(str(p.get("image_path", "")))
			vb.add_child(tex_r)


func _on_card_pressed(idx: int) -> void:
	if _locked or idx < 0 or idx >= _cards.size():
		return
	var c := _cards[idx]
	if bool(c.get("revealed", false)) or bool(c.get("matched", false)):
		return

	c["revealed"] = true
	_flipped_indices.append(idx)
	_refresh_card_visual(idx)
	audio.play_sfx("click")

	var p: Dictionary = c.get("pair_data", {})
	if str(c.get("kind", "")) == "a":
		audio.play_word_or_sentence(str(p.get("audio_path", "")), str(p.get("word", "")))

	if _flipped_indices.size() < 2:
		return

	_locked = true
	var idx_a := _flipped_indices[0]
	var idx_b := _flipped_indices[1]
	var ca := _cards[idx_a]
	var cb := _cards[idx_b]
	var is_match := str(ca.get("word_id", "")) == str(cb.get("word_id", ""))
	var pa: Dictionary = ca.get("pair_data", {})

	if is_match:
		ca["matched"] = true
		cb["matched"] = true
		_matched_pairs += 1
		_refresh_card_visual(idx_a)
		_refresh_card_visual(idx_b)
		audio.play_sfx("correct")
		audio.play_word_or_sentence(str(pa.get("audio_path", "")), str(pa.get("word", "")))
		_status_lbl.text = "Ghép đúng! %s — %s" % [str(pa.get("word", "")).capitalize(), str(pa.get("meaning_vi", ""))]
		_flipped_indices.clear()
		_locked = false

		if session != null:
			var word_en := str(pa.get("word", "")).capitalize()
			var fb := session.record_answer(
				word_en,
				true,
				word_en,
				str(pa.get("meaning_vi", "")),
				"%s (%s) nghĩa là %s." % [word_en, str(pa.get("ipa", "")), str(pa.get("meaning_vi", ""))],
				str(pa.get("example_sentence", "")),
				str(pa.get("audio_path", "")),
				word_en
			)
			if _matched_pairs >= _pairs.size():
				round_feedback_ready.emit(fb)
	else:
		audio.play_sfx("wrong")
		_status_lbl.text = "Chưa trùng cặp rồi — hãy nhớ vị trí 2 thẻ nhé!"
		if session != null:
			var word_a := str(pa.get("word", "")).capitalize()
			session.record_answer(
				str((cb.get("pair_data", {}) as Dictionary).get("word", "")),
				false,
				word_a,
				str(pa.get("meaning_vi", "")),
				"Thẻ này là '%s' (%s)." % [word_a, str(pa.get("meaning_vi", ""))],
				"",
				str(pa.get("audio_path", "")),
				word_a
			)
		var timer := get_tree().create_timer(0.95)
		timer.timeout.connect(func() -> void:
			if idx_a < _cards.size() and idx_b < _cards.size():
				_cards[idx_a]["revealed"] = false
				_cards[idx_b]["revealed"] = false
				_refresh_card_visual(idx_a)
				_refresh_card_visual(idx_b)
			_flipped_indices.clear()
			_locked = false
		)
