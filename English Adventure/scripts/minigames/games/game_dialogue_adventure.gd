class_name GameDialogueAdventure
extends MiniGameController
## GAME 08 - DIALOGUE ADVENTURE (Hội thoại phiêu lưu)
## Skill: Listening + Speaking + Reading
## Data-driven bilingual scenarios from dialogue_adventures.json with NPC voice & optional speaking toggle.

var _current_item: Dictionary = {}
var _resolved: bool = false
var _speak_practice_mode: bool = false

var _scenario_picker: OptionButton
var _npc_name_lbl: Label
var _npc_en_lbl: Label
var _npc_vi_lbl: Label
var _options_col: VBoxContainer
var _speak_toggle: CheckButton


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 12)
	add_child(root)

	var top := HBoxContainer.new()
	top.alignment = BoxContainer.ALIGNMENT_CENTER
	top.add_theme_constant_override("separation", 12)
	root.add_child(top)

	var sc_lbl := Label.new()
	sc_lbl.text = "Tình huống:"
	sc_lbl.add_theme_font_size_override("font_size", 17)
	sc_lbl.add_theme_color_override("font_color", Color(0.18, 0.24, 0.36, 1))
	top.add_child(sc_lbl)

	_scenario_picker = OptionButton.new()
	_scenario_picker.custom_minimum_size = Vector2(260, 40)
	var scenarios := MiniGameDataProvider.get_dialogue_scenarios()
	for s_i in range(scenarios.size()):
		var sc := scenarios[s_i]
		_scenario_picker.add_item("%s — %s" % [str(sc.get("title_en", "")), str(sc.get("title_vi", ""))], s_i)
		_scenario_picker.set_item_metadata(s_i, str(sc.get("id", "")))
	_scenario_picker.item_selected.connect(_on_scenario_switched)
	top.add_child(_scenario_picker)

	_speak_toggle = CheckButton.new()
	_speak_toggle.text = "Đọc to câu trả lời"
	_speak_toggle.button_pressed = false
	_speak_toggle.add_theme_color_override("font_color", Color(0.16, 0.22, 0.36, 1))
	_speak_toggle.add_theme_color_override("font_hover_color", Color(0.12, 0.28, 0.56, 1))
	_speak_toggle.add_theme_color_override("font_pressed_color", Color(0.12, 0.38, 0.22, 1))
	_speak_toggle.add_theme_color_override("font_hover_pressed_color", Color(0.12, 0.38, 0.22, 1))
	_speak_toggle.toggled.connect(func(pressed: bool) -> void:
		_speak_practice_mode = pressed
	)
	top.add_child(_speak_toggle)

	var npc_card := PanelContainer.new()
	npc_card.add_theme_stylebox_override("panel", _make_fantasy_card(Color(0.95, 0.97, 1.0, 1), Color(0.28, 0.52, 0.86, 1), 16))
	root.add_child(npc_card)

	var npc_vb := VBoxContainer.new()
	npc_vb.add_theme_constant_override("separation", 6)
	npc_card.add_child(npc_vb)

	var npc_head := HBoxContainer.new()
	npc_head.add_theme_constant_override("separation", 12)
	npc_vb.add_child(npc_head)

	_npc_name_lbl = Label.new()
	_npc_name_lbl.add_theme_font_size_override("font_size", 18)
	_npc_name_lbl.add_theme_color_override("font_color", Color(0.14, 0.34, 0.64, 1))
	npc_head.add_child(_npc_name_lbl)

	var play_npc_btn := _make_action_button("Nghe NPC nói", Color(0.16, 0.52, 0.86, 1))
	play_npc_btn.custom_minimum_size = Vector2(140, 38)
	play_npc_btn.pressed.connect(_play_npc_line)
	npc_head.add_child(play_npc_btn)

	_npc_en_lbl = Label.new()
	_npc_en_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_npc_en_lbl.add_theme_font_size_override("font_size", 24)
	_npc_en_lbl.add_theme_color_override("font_color", Color(0.1, 0.16, 0.28, 1))
	npc_vb.add_child(_npc_en_lbl)

	_npc_vi_lbl = Label.new()
	_npc_vi_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_npc_vi_lbl.add_theme_font_size_override("font_size", 17)
	_npc_vi_lbl.add_theme_color_override("font_color", Color(0.32, 0.38, 0.48, 1))
	npc_vb.add_child(_npc_vi_lbl)

	var reply_lbl := Label.new()
	reply_lbl.text = "Chọn câu trả lời phù hợp nhất:"
	reply_lbl.add_theme_font_size_override("font_size", 18)
	reply_lbl.add_theme_color_override("font_color", Color(0.18, 0.24, 0.36, 1))
	root.add_child(reply_lbl)

	_options_col = VBoxContainer.new()
	_options_col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_options_col.add_theme_constant_override("separation", 10)
	root.add_child(_options_col)


func render_item(item: Dictionary, index: int, total: int) -> void:
	_current_item = item
	_resolved = false
	for c in _options_col.get_children():
		c.queue_free()

	var sc_id := str(item.get("scenario_id", ""))
	for i in range(_scenario_picker.item_count):
		if str(_scenario_picker.get_item_metadata(i)) == sc_id:
			_scenario_picker.select(i)
			break

	_npc_name_lbl.text = "%s (Lượt %d/%d):" % [str(item.get("npc_name", "NPC")), index + 1, total]
	_npc_en_lbl.text = "\"%s\"" % str(item.get("npc_line_en", ""))
	_npc_vi_lbl.text = "Nghĩa: %s" % str(item.get("npc_line_vi", ""))
	status_hint_changed.emit("Chọn câu đáp lại tự nhiên; bật 'Đọc to câu trả lời' để luyện nói thêm.")

	var opts: Array = (item.get("options", []) as Array).duplicate(true)
	opts.shuffle()
	for opt_var in opts:
		if typeof(opt_var) != TYPE_DICTIONARY:
			continue
		var opt: Dictionary = opt_var
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 62)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.text = "  %s   (%s)" % [str(opt.get("text_en", "")), str(opt.get("text_vi", ""))]
		btn.add_theme_font_size_override("font_size", 18)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.add_theme_stylebox_override("normal", _make_fantasy_card(Color(1.0, 0.98, 0.92, 1), Color(0.76, 0.6, 0.28, 1), 14))
		btn.add_theme_stylebox_override("hover", _make_fantasy_card(Color(0.9, 0.96, 1.0, 1), Color(0.22, 0.54, 0.88, 1), 14))
		btn.add_theme_stylebox_override("pressed", _make_fantasy_card(Color(0.84, 0.94, 1.0, 1), Color(0.18, 0.48, 0.86, 1), 14))
		btn.add_theme_color_override("font_color", Color(0.14, 0.2, 0.32, 1))
		btn.add_theme_color_override("font_hover_color", Color(0.1, 0.2, 0.4, 1))
		btn.add_theme_color_override("font_pressed_color", Color(0.08, 0.24, 0.48, 1))
		btn.pressed.connect(func() -> void:
			_on_option_chosen(opt, btn)
		)
		_options_col.add_child(btn)

	_play_npc_line()


func _on_scenario_switched(idx: int) -> void:
	if session == null:
		return
	var sc_id := str(_scenario_picker.get_item_metadata(idx))
	var new_items := MiniGameDataProvider.build_items_for("dialogue_adventure", session.difficulty_config, { "scenario_id": sc_id })
	if not new_items.is_empty():
		session.set_items(new_items)
		start_current_round()


func _play_npc_line() -> void:
	if audio == null or _current_item.is_empty():
		return
	audio.play_word_or_sentence("", str(_current_item.get("npc_line_en", "")))


func _on_option_chosen(opt: Dictionary, btn: Button) -> void:
	if _resolved or session == null:
		return
	var is_correct := bool(opt.get("is_correct", false))
	var chosen_en := str(opt.get("text_en", ""))
	if _speak_practice_mode and audio != null:
		audio.play_word_or_sentence("", chosen_en)

	audio.play_sfx("correct" if is_correct else "wrong")
	if is_correct:
		_resolved = true
		btn.add_theme_stylebox_override("normal", _make_fantasy_card(Color(0.84, 0.98, 0.86, 1), Color(0.2, 0.72, 0.34, 1), 14))
	else:
		btn.add_theme_stylebox_override("normal", _make_fantasy_card(Color(1.0, 0.88, 0.88, 1), Color(0.84, 0.24, 0.24, 1), 14))

	var correct_opt := _find_correct_option()
	var correct_en := str(correct_opt.get("text_en", chosen_en))
	var correct_vi := str(correct_opt.get("text_vi", ""))
	var expl := str(opt.get("feedback_vi", _current_item.get("explanation_vi", "")))
	if _speak_practice_mode and is_correct:
		expl += " (Hãy đọc to câu \"%s\" cùng nhân vật nhé!)" % correct_en

	var fb := session.record_answer(
		chosen_en,
		is_correct,
		correct_en,
		correct_vi,
		expl,
		"%s -> %s" % [str(_current_item.get("npc_line_en", "")), correct_en],
		"",
		correct_en
	)
	round_feedback_ready.emit(fb)


func _find_correct_option() -> Dictionary:
	for opt_var in _current_item.get("options", []):
		if typeof(opt_var) == TYPE_DICTIONARY and bool((opt_var as Dictionary).get("is_correct", false)):
			return opt_var as Dictionary
	return {}
