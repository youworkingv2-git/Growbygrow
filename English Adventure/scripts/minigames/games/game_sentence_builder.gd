class_name GameSentenceBuilder
extends MiniGameController
## GAME 04 (Priority) - SENTENCE BUILDER (Xây dựng câu tiếng Anh)
## Skill: Reading + Writing + Grammar
## Includes Vietnamese translation, grammar note, full sentence audio, and accepted_variants.

var _current_item: Dictionary = {}
var _tokens_scrambled: Array[String] = []
var _used_token_indices: Array[int] = []
var _resolved: bool = false

var _prompt_lbl: Label
var _meaning_lbl: Label
var _grammar_lbl: Label
var _answer_row: HBoxContainer
var _bank_row: HBoxContainer


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

	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _make_fantasy_card(Color(0.95, 0.97, 1.0, 1), Color(0.32, 0.56, 0.86, 1)))
	root.add_child(card)

	var card_vb := VBoxContainer.new()
	card_vb.add_theme_constant_override("separation", 6)
	card.add_child(card_vb)

	_meaning_lbl = Label.new()
	_meaning_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_meaning_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_meaning_lbl.add_theme_font_size_override("font_size", 20)
	_meaning_lbl.add_theme_color_override("font_color", Color(0.12, 0.32, 0.58, 1))
	card_vb.add_child(_meaning_lbl)

	_grammar_lbl = Label.new()
	_grammar_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_grammar_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_grammar_lbl.add_theme_font_size_override("font_size", 15)
	_grammar_lbl.add_theme_color_override("font_color", Color(0.34, 0.38, 0.48, 1))
	card_vb.add_child(_grammar_lbl)

	var answer_panel := PanelContainer.new()
	answer_panel.custom_minimum_size = Vector2(0, 74)
	answer_panel.add_theme_stylebox_override("panel", _make_fantasy_card(Color(1.0, 0.98, 0.93, 1), Color(0.78, 0.62, 0.28, 1), 14))
	root.add_child(answer_panel)

	_answer_row = HBoxContainer.new()
	_answer_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_answer_row.add_theme_constant_override("separation", 10)
	answer_panel.add_child(_answer_row)

	var bank_center := CenterContainer.new()
	bank_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(bank_center)
	_bank_row = HBoxContainer.new()
	_bank_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_bank_row.add_theme_constant_override("separation", 12)
	bank_center.add_child(_bank_row)

	var btns := HBoxContainer.new()
	btns.alignment = BoxContainer.ALIGNMENT_CENTER
	btns.add_theme_constant_override("separation", 12)
	root.add_child(btns)

	var hear_btn := _make_action_button("Nghe câu mẫu", Color(0.15, 0.52, 0.86, 1))
	hear_btn.pressed.connect(_play_sentence_audio)
	btns.add_child(hear_btn)

	var hint_btn := _make_action_button("Gợi ý từ kế", Color(0.84, 0.56, 0.16, 1))
	hint_btn.pressed.connect(request_hint)
	btns.add_child(hint_btn)

	var clear_btn := _make_action_button("Xếp lại", Color(0.65, 0.34, 0.28, 1))
	clear_btn.pressed.connect(_clear_tokens)
	btns.add_child(clear_btn)

	var submit_btn := _make_action_button("Kiểm tra câu", Color(0.16, 0.66, 0.36, 1))
	submit_btn.pressed.connect(_submit_sentence)
	btns.add_child(submit_btn)


func render_item(item: Dictionary, index: int, total: int) -> void:
	_current_item = item
	_resolved = false
	_tokens_scrambled.clear()
	_used_token_indices.clear()
	for t_var in item.get("tokens_scrambled", []):
		_tokens_scrambled.append(str(t_var))

	_prompt_lbl.text = "Câu %d/%d — Ghép các từ thành câu tiếng Anh hoàn chỉnh!" % [index + 1, total]
	_meaning_lbl.text = "Nghĩa tiếng Việt: \"%s\"" % str(item.get("meaning_vi", ""))
	_grammar_lbl.text = "Cấu trúc: %s" % str(item.get("explanation_vi", ""))
	status_hint_changed.emit("Chạm các thẻ từ để xếp thành câu. Nhấn vào từ đã xếp để bỏ xuống.")
	_rebuild_rows()


func _rebuild_rows() -> void:
	for c in _answer_row.get_children():
		c.queue_free()
	for c in _bank_row.get_children():
		c.queue_free()

	if _used_token_indices.is_empty():
		var placeholder := Label.new()
		placeholder.text = "(Chạm các thẻ từ bên dưới để xếp câu tại đây...)"
		placeholder.add_theme_font_size_override("font_size", 16)
		placeholder.add_theme_color_override("font_color", Color(0.55, 0.5, 0.44, 1))
		_answer_row.add_child(placeholder)
	else:
		for pos_i in range(_used_token_indices.size()):
			var tok_idx := _used_token_indices[pos_i]
			var b := _make_token_btn(_tokens_scrambled[tok_idx], true)
			b.pressed.connect(func() -> void:
				_remove_from_answer(pos_i)
			)
			_answer_row.add_child(b)

	for i in range(_tokens_scrambled.size()):
		var is_used := _used_token_indices.has(i)
		var b := _make_token_btn(_tokens_scrambled[i], false)
		b.disabled = is_used
		if is_used:
			b.modulate = Color(0.7, 0.7, 0.7, 0.35)
		b.pressed.connect(func() -> void:
			_add_to_answer(i)
		)
		_bank_row.add_child(b)


func _make_token_btn(word_text: String, placed: bool) -> Button:
	var btn := Button.new()
	btn.text = word_text
	btn.custom_minimum_size = Vector2(92, 48)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.add_theme_font_size_override("font_size", 20)
	if placed:
		btn.add_theme_stylebox_override("normal", _make_fantasy_card(Color(0.84, 0.94, 1.0, 1), Color(0.2, 0.54, 0.88, 1), 12))
		btn.add_theme_color_override("font_color", Color(0.1, 0.22, 0.44, 1))
	else:
		btn.add_theme_stylebox_override("normal", _make_fantasy_card(Color(1.0, 0.95, 0.78, 1), Color(0.8, 0.58, 0.16, 1), 12))
		btn.add_theme_stylebox_override("hover", _make_fantasy_card(Color(1.0, 0.98, 0.88, 1), Color(0.24, 0.56, 0.92, 1), 12))
		btn.add_theme_color_override("font_color", Color(0.26, 0.18, 0.06, 1))
	return btn


func _add_to_answer(idx: int) -> void:
	if _resolved or _used_token_indices.has(idx):
		return
	audio.play_sfx("click")
	_used_token_indices.append(idx)
	_rebuild_rows()


func _remove_from_answer(pos_i: int) -> void:
	if _resolved or pos_i < 0 or pos_i >= _used_token_indices.size():
		return
	_used_token_indices.remove_at(pos_i)
	_rebuild_rows()


func _clear_tokens() -> void:
	if _resolved:
		return
	_used_token_indices.clear()
	_rebuild_rows()


func on_hint_requested() -> void:
	if _resolved:
		return
	var correct_tokens: Array = _current_item.get("tokens_correct", [])
	var next_pos := _used_token_indices.size()
	if next_pos >= correct_tokens.size():
		return
	var needed := str(correct_tokens[next_pos])
	for i in range(_tokens_scrambled.size()):
		if not _used_token_indices.has(i) and _tokens_scrambled[i] == needed:
			_add_to_answer(i)
			status_hint_changed.emit("Gợi ý: Từ thứ %d là \"%s\"." % [next_pos + 1, needed])
			return


func _submit_sentence() -> void:
	if _resolved or _input_locked or session == null:
		return
	if _used_token_indices.size() < _tokens_scrambled.size():
		status_hint_changed.emit("Bé hãy xếp đủ tất cả các từ trước khi kiểm tra nhé!")
		return

	var parts: Array[String] = []
	for idx in _used_token_indices:
		parts.append(_tokens_scrambled[idx])
	var built_sentence := " ".join(parts)
	var normalized := _normalize(built_sentence)

	var target := str(_current_item.get("target_sentence", ""))
	var is_correct := (normalized == _normalize(target))
	if not is_correct:
		for v_var in _current_item.get("accepted_variants", []):
			if normalized == _normalize(str(v_var)):
				is_correct = true
				break

	audio.play_sfx("correct" if is_correct else "wrong")
	if is_correct:
		_resolved = true
		_play_sentence_audio()

	var fb := session.record_answer(
		built_sentence,
		is_correct,
		target,
		str(_current_item.get("meaning_vi", "")),
		str(_current_item.get("explanation_vi", "")),
		target,
		str(_current_item.get("audio_path", "")),
		target
	)
	round_feedback_ready.emit(fb)


func _play_sentence_audio() -> void:
	if audio == null or _current_item.is_empty():
		return
	audio.play_word_or_sentence(str(_current_item.get("audio_path", "")), str(_current_item.get("target_sentence", "")))


func _normalize(s: String) -> String:
	var out := s.strip_edges().to_lower()
	for p in [".", "!", "?"]:
		out = out.replace(p, "")
	while out.contains("  "):
		out = out.replace("  ", " ")
	return out.strip_edges()
