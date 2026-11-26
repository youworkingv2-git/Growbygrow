class_name MiniGameUI
extends CanvasLayer
## Global 2D Fantasy Cartoon Mini-Game Overlay & Arcade Launcher.
## Handles the 8-stage session flow cleanly while pausing 3D gameplay underneath.

var _session: MiniGameSession = null
var _active_controller: MiniGameController = null
var _arcade_mode: bool = false
var _selected_diff_override: String = "auto"

var _backdrop: ColorRect
var _shell: PanelContainer
var _title_lbl: Label
var _progress_lbl: Label
var _progress_bar: ProgressBar
var _diff_pill: Label
var _bgm_toggle_btn: Button
var _close_btn: Button

# Stage containers
var _arcade_scroll: ScrollContainer
var _arcade_grid: GridContainer

var _intro_panel: VBoxContainer
var _intro_heading: Label
var _intro_obj_lbl: Label
var _intro_instr_lbl: Label
var _intro_diff_opt: OptionButton
var _intro_start_btn: Button

var _gameplay_vbox: VBoxContainer
var _game_host: Control
var _status_hint_lbl: Label
var _feedback_panel: PanelContainer
var _fb_title_lbl: Label
var _fb_detail_lbl: Label
var _fb_example_lbl: Label
var _fb_replay_btn: Button
var _fb_next_btn: Button
var _fb_retry_btn: Button

var _summary_panel: VBoxContainer
var _sum_stars_lbl: Label
var _sum_stats_lbl: Label
var _sum_rewards_lbl: Label
var _sum_replay_btn: Button
var _sum_return_btn: Button


func _ready() -> void:
	layer = 25
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = true
	_build_ui()
	_backdrop.visible = false

	MiniGameManager.launch_modal_requested.connect(_on_launch_session)
	MiniGameManager.close_modal_requested.connect(_on_close_requested)
	MiniGameManager.launch_arcade_requested.connect(open_arcade)


func is_overlay_visible() -> bool:
	return _backdrop != null and _backdrop.visible


func _build_ui() -> void:
	_backdrop = ColorRect.new()
	_backdrop.theme = UIManager.shared_theme if (UIManager != null and UIManager.shared_theme != null) else UIDesignSystem.build_global_theme()
	_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_backdrop.color = Color(0.05, 0.08, 0.16, 0.72)
	add_child(_backdrop)

	var margin_wrap := MarginContainer.new()
	margin_wrap.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin_wrap.add_theme_constant_override("margin_left", 28)
	margin_wrap.add_theme_constant_override("margin_right", 28)
	margin_wrap.add_theme_constant_override("margin_top", 22)
	margin_wrap.add_theme_constant_override("margin_bottom", 22)
	_backdrop.add_child(margin_wrap)

	_shell = PanelContainer.new()
	var shell_sb := StyleBoxFlat.new()
	shell_sb.bg_color = Color(0.98, 0.96, 0.91, 1.0)
	shell_sb.border_color = Color(0.82, 0.64, 0.24, 1.0)
	shell_sb.set_border_width_all(4)
	shell_sb.set_corner_radius_all(22)
	shell_sb.content_margin_left = 20
	shell_sb.content_margin_right = 20
	shell_sb.content_margin_top = 16
	shell_sb.content_margin_bottom = 16
	_shell.add_theme_stylebox_override("panel", shell_sb)
	margin_wrap.add_child(_shell)

	var root_vb := VBoxContainer.new()
	root_vb.add_theme_constant_override("separation", 12)
	_shell.add_child(root_vb)

	# Header
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	root_vb.add_child(header)

	_title_lbl = Label.new()
	_title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_lbl.add_theme_font_size_override("font_size", 24)
	_title_lbl.add_theme_color_override("font_color", Color(0.14, 0.22, 0.4, 1))
	header.add_child(_title_lbl)

	_diff_pill = Label.new()
	_diff_pill.add_theme_font_size_override("font_size", 15)
	_diff_pill.add_theme_color_override("font_color", Color(0.56, 0.34, 0.08, 1))
	header.add_child(_diff_pill)

	_progress_lbl = Label.new()
	_progress_lbl.add_theme_font_size_override("font_size", 16)
	_progress_lbl.add_theme_color_override("font_color", Color(0.2, 0.38, 0.58, 1))
	header.add_child(_progress_lbl)

	_bgm_toggle_btn = _styled_btn("Nhạc nền: Bật", Color(0.32, 0.46, 0.68, 1), Vector2(130, 40))
	_bgm_toggle_btn.pressed.connect(_toggle_bgm_mute)
	header.add_child(_bgm_toggle_btn)

	_close_btn = _styled_btn("Thoát (Esc)", Color(0.76, 0.28, 0.26, 1), Vector2(116, 40))
	_close_btn.pressed.connect(_on_exit_pressed)
	header.add_child(_close_btn)

	_progress_bar = ProgressBar.new()
	_progress_bar.custom_minimum_size = Vector2(0, 12)
	_progress_bar.show_percentage = false
	root_vb.add_child(_progress_bar)

	# 1. Arcade Launcher view
	_arcade_scroll = ScrollContainer.new()
	_arcade_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vb.add_child(_arcade_scroll)

	_arcade_grid = GridContainer.new()
	_arcade_grid.columns = 2
	_arcade_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_arcade_grid.add_theme_constant_override("h_separation", 16)
	_arcade_grid.add_theme_constant_override("v_separation", 14)
	_arcade_scroll.add_child(_arcade_grid)

	# 2. Intro + Learning Objective + Instructions view
	_intro_panel = VBoxContainer.new()
	_intro_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_intro_panel.alignment = BoxContainer.ALIGNMENT_CENTER
	_intro_panel.add_theme_constant_override("separation", 14)
	root_vb.add_child(_intro_panel)

	_intro_heading = Label.new()
	_intro_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_intro_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_intro_heading.add_theme_font_size_override("font_size", 26)
	_intro_heading.add_theme_color_override("font_color", Color(0.14, 0.26, 0.52, 1))
	_intro_panel.add_child(_intro_heading)

	var intro_card := PanelContainer.new()
	var ic_sb := StyleBoxFlat.new()
	ic_sb.bg_color = Color(0.93, 0.96, 1.0, 1)
	ic_sb.border_color = Color(0.32, 0.56, 0.86, 1)
	ic_sb.set_border_width_all(2)
	ic_sb.set_corner_radius_all(16)
	ic_sb.content_margin_left = 18
	ic_sb.content_margin_right = 18
	ic_sb.content_margin_top = 14
	ic_sb.content_margin_bottom = 14
	intro_card.add_theme_stylebox_override("panel", ic_sb)
	_intro_panel.add_child(intro_card)

	var ic_vb := VBoxContainer.new()
	ic_vb.add_theme_constant_override("separation", 10)
	intro_card.add_child(ic_vb)

	_intro_obj_lbl = Label.new()
	_intro_obj_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_intro_obj_lbl.add_theme_font_size_override("font_size", 19)
	_intro_obj_lbl.add_theme_color_override("font_color", Color(0.12, 0.24, 0.42, 1))
	ic_vb.add_child(_intro_obj_lbl)

	_intro_instr_lbl = Label.new()
	_intro_instr_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_intro_instr_lbl.add_theme_font_size_override("font_size", 18)
	_intro_instr_lbl.add_theme_color_override("font_color", Color(0.24, 0.3, 0.4, 1))
	ic_vb.add_child(_intro_instr_lbl)

	var diff_row := HBoxContainer.new()
	diff_row.alignment = BoxContainer.ALIGNMENT_CENTER
	diff_row.add_theme_constant_override("separation", 12)
	_intro_panel.add_child(diff_row)

	var dl := Label.new()
	dl.text = "Độ khó:"
	dl.add_theme_font_size_override("font_size", 17)
	dl.add_theme_color_override("font_color", Color(0.2, 0.24, 0.34, 1))
	diff_row.add_child(dl)

	_intro_diff_opt = OptionButton.new()
	_intro_diff_opt.custom_minimum_size = Vector2(220, 40)
	_intro_diff_opt.add_item("Thích ứng tự động (Auto)", 0)
	_intro_diff_opt.set_item_metadata(0, "auto")
	_intro_diff_opt.add_item("Dễ (Làm quen)", 1)
	_intro_diff_opt.set_item_metadata(1, "easy")
	_intro_diff_opt.add_item("Vừa (Thử thách)", 2)
	_intro_diff_opt.set_item_metadata(2, "medium")
	_intro_diff_opt.add_item("Nâng cao (Hard)", 3)
	_intro_diff_opt.set_item_metadata(3, "hard")
	_intro_diff_opt.item_selected.connect(_on_intro_diff_changed)
	diff_row.add_child(_intro_diff_opt)

	var start_center := CenterContainer.new()
	_intro_panel.add_child(start_center)
	_intro_start_btn = _styled_btn("Bắt đầu thử thách!", Color(0.16, 0.64, 0.34, 1), Vector2(250, 54))
	_intro_start_btn.pressed.connect(_start_gameplay_stage)
	start_center.add_child(_intro_start_btn)

	# 3. Gameplay + Immediate Feedback view
	_gameplay_vbox = VBoxContainer.new()
	_gameplay_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_gameplay_vbox.add_theme_constant_override("separation", 10)
	root_vb.add_child(_gameplay_vbox)

	_game_host = Control.new()
	_game_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_gameplay_vbox.add_child(_game_host)

	_status_hint_lbl = Label.new()
	_status_hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_hint_lbl.add_theme_font_size_override("font_size", 14)
	_status_hint_lbl.add_theme_color_override("font_color", Color(0.38, 0.42, 0.5, 1))
	_gameplay_vbox.add_child(_status_hint_lbl)

	_feedback_panel = PanelContainer.new()
	_feedback_panel.visible = false
	_gameplay_vbox.add_child(_feedback_panel)

	var fb_hb := HBoxContainer.new()
	fb_hb.add_theme_constant_override("separation", 14)
	_feedback_panel.add_child(fb_hb)

	var fb_text_vb := VBoxContainer.new()
	fb_text_vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fb_text_vb.add_theme_constant_override("separation", 4)
	fb_hb.add_child(fb_text_vb)

	_fb_title_lbl = Label.new()
	_fb_title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_fb_title_lbl.add_theme_font_size_override("font_size", 19)
	fb_text_vb.add_child(_fb_title_lbl)

	_fb_detail_lbl = Label.new()
	_fb_detail_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_fb_detail_lbl.add_theme_font_size_override("font_size", 16)
	_fb_detail_lbl.add_theme_color_override("font_color", Color(0.16, 0.22, 0.34, 1))
	fb_text_vb.add_child(_fb_detail_lbl)

	_fb_example_lbl = Label.new()
	_fb_example_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_fb_example_lbl.add_theme_font_size_override("font_size", 15)
	_fb_example_lbl.add_theme_color_override("font_color", Color(0.28, 0.36, 0.46, 1))
	fb_text_vb.add_child(_fb_example_lbl)

	var fb_btns := HBoxContainer.new()
	fb_btns.alignment = BoxContainer.ALIGNMENT_END
	fb_btns.add_theme_constant_override("separation", 10)
	fb_hb.add_child(fb_btns)

	_fb_replay_btn = _styled_btn("Nghe lại", Color(0.18, 0.52, 0.86, 1), Vector2(110, 44))
	_fb_replay_btn.pressed.connect(_replay_feedback_audio)
	fb_btns.add_child(_fb_replay_btn)

	_fb_retry_btn = _styled_btn("Thử lại", Color(0.84, 0.54, 0.16, 1), Vector2(110, 44))
	_fb_retry_btn.pressed.connect(func() -> void:
		_feedback_panel.visible = false
	)
	fb_btns.add_child(_fb_retry_btn)

	_fb_next_btn = _styled_btn("Tiếp tục", Color(0.16, 0.64, 0.34, 1), Vector2(130, 44))
	_fb_next_btn.pressed.connect(_advance_next)
	fb_btns.add_child(_fb_next_btn)

	# 4. Result Summary + Reward view
	_summary_panel = VBoxContainer.new()
	_summary_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_summary_panel.alignment = BoxContainer.ALIGNMENT_CENTER
	_summary_panel.add_theme_constant_override("separation", 14)
	root_vb.add_child(_summary_panel)

	_sum_stars_lbl = Label.new()
	_sum_stars_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sum_stars_lbl.add_theme_font_size_override("font_size", 34)
	_sum_stars_lbl.add_theme_color_override("font_color", Color(0.84, 0.58, 0.1, 1))
	_summary_panel.add_child(_sum_stars_lbl)

	_sum_stats_lbl = Label.new()
	_sum_stats_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sum_stats_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sum_stats_lbl.add_theme_font_size_override("font_size", 20)
	_sum_stats_lbl.add_theme_color_override("font_color", Color(0.14, 0.22, 0.38, 1))
	_summary_panel.add_child(_sum_stats_lbl)

	_sum_rewards_lbl = Label.new()
	_sum_rewards_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sum_rewards_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sum_rewards_lbl.add_theme_font_size_override("font_size", 20)
	_sum_rewards_lbl.add_theme_color_override("font_color", Color(0.14, 0.52, 0.26, 1))
	_summary_panel.add_child(_sum_rewards_lbl)

	var sum_btns := HBoxContainer.new()
	sum_btns.alignment = BoxContainer.ALIGNMENT_CENTER
	sum_btns.add_theme_constant_override("separation", 16)
	_summary_panel.add_child(sum_btns)

	_sum_replay_btn = _styled_btn("Chơi lại", Color(0.2, 0.52, 0.86, 1), Vector2(160, 50))
	_sum_replay_btn.pressed.connect(_replay_current_minigame)
	sum_btns.add_child(_sum_replay_btn)

	_sum_return_btn = _styled_btn("Quay lại phiêu lưu", Color(0.16, 0.64, 0.34, 1), Vector2(220, 50))
	_sum_return_btn.pressed.connect(_return_to_world)
	sum_btns.add_child(_sum_return_btn)


func _styled_btn(text_val: String, bg: Color, min_sz: Vector2) -> Button:
	var btn := Button.new()
	btn.text = text_val
	btn.custom_minimum_size = min_sz
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.add_theme_font_size_override("font_size", 17)
	btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = bg.lightened(0.25)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	var hsb := sb.duplicate() as StyleBoxFlat
	hsb.bg_color = bg.lightened(0.12)
	var psb := sb.duplicate() as StyleBoxFlat
	psb.bg_color = bg.darkened(0.12)
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", hsb)
	btn.add_theme_stylebox_override("pressed", psb)
	return btn


func open_arcade() -> void:
	if MiniGameManager.is_minigame_active():
		return
	_arcade_mode = true
	_session = null
	_backdrop.visible = true
	EventBus.pause_toggled.emit(true)
	AppLogger.info("MiniGameUI", "Opened Arcade Launcher")
	_title_lbl.text = "TRUNG TÂM TRÒ CHƠI TIẾNG ANH (8 MINI-GAMES)"
	_diff_pill.text = "Dữ liệu đồng bộ Learning Engine"
	_progress_lbl.text = ""
	_progress_bar.visible = false
	_bgm_toggle_btn.visible = false
	_close_btn.text = "Đóng (Esc)"

	_arcade_scroll.visible = true
	_intro_panel.visible = false
	_gameplay_vbox.visible = false
	_summary_panel.visible = false
	_populate_arcade_cards()


func _populate_arcade_cards() -> void:
	for c in _arcade_grid.get_children():
		c.queue_free()

	for entry in MiniGameManager.get_all_minigames():
		var gid := str(entry.get("id", ""))
		var status := str(entry.get("availability_status", ""))
		var is_template := (status == "planned_template")

		var card := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.95, 0.94, 0.9, 1) if is_template else Color(1.0, 0.99, 0.95, 1)
		sb.border_color = Color(0.72, 0.72, 0.76, 1) if is_template else Color(0.8, 0.62, 0.24, 1)
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(16)
		sb.content_margin_left = 14
		sb.content_margin_right = 14
		sb.content_margin_top = 12
		sb.content_margin_bottom = 12
		card.add_theme_stylebox_override("panel", sb)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_arcade_grid.add_child(card)

		var vb := VBoxContainer.new()
		vb.add_theme_constant_override("separation", 6)
		card.add_child(vb)

		var rec := GameStateManager.get_minigame_record(gid)
		var stars := int(rec.get("best_stars", 0))
		var plays := int(rec.get("plays", 0))
		var tag := "[Mở rộng Prompt 06+]" if is_template else ("[Ưu tiên]" if status == "playable_core" else "[Mở rộng]")

		var name_lbl := Label.new()
		name_lbl.text = "%s — %s  %s" % [str(entry.get("name_en", gid)), str(entry.get("name_vi", "")), tag]
		name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_lbl.add_theme_font_size_override("font_size", 18)
		name_lbl.add_theme_color_override("font_color", Color(0.14, 0.24, 0.44, 1) if not is_template else Color(0.45, 0.46, 0.52, 1))
		vb.add_child(name_lbl)

		var skills_arr: Array = entry.get("learning_skills", [])
		var skill_str := ", ".join(skills_arr)
		var desc_lbl := Label.new()
		desc_lbl.text = "%s\nKỹ năng: %s | Lượt chơi: %d | Sao cao nhất: %d/3" % [
			str(entry.get("description_vi", "")), skill_str, plays, stars
		]
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.add_theme_font_size_override("font_size", 14)
		desc_lbl.add_theme_color_override("font_color", Color(0.3, 0.34, 0.42, 1))
		vb.add_child(desc_lbl)

		if not is_template:
			var play_btn := _styled_btn("Chơi ngay", Color(0.16, 0.56, 0.86, 1), Vector2(130, 38))
			play_btn.pressed.connect(func() -> void:
				AppLogger.info("MiniGameUI", "Arcade play clicked: " + gid)
				_arcade_mode = false
				MiniGameManager.start_minigame(gid, { "source_type": "arcade", "bypass_unlock": true }, _selected_diff_override)
			)
			vb.add_child(play_btn)


func _on_launch_session(sess: MiniGameSession) -> void:
	_arcade_mode = false
	_session = sess
	_backdrop.visible = true
	_bgm_toggle_btn.visible = true
	_progress_bar.visible = true
	_close_btn.text = "Thoát (Esc)"

	_clear_controller()

	var entry := sess.registry_entry
	_title_lbl.text = "%s (%s)" % [str(entry.get("name_en", "")), str(entry.get("name_vi", ""))]
	_diff_pill.text = "Độ khó: %s" % str(sess.difficulty_config.get("label_vi", sess.difficulty_tier))
	_progress_lbl.text = "0/%d" % sess.items.size()
	_progress_bar.max_value = maxf(1.0, float(sess.items.size()))
	_progress_bar.value = 0.0

	_arcade_scroll.visible = false
	_intro_panel.visible = true
	_gameplay_vbox.visible = false
	_summary_panel.visible = false

	var intro_en := str(entry.get("intro_en", entry.get("intro_prompt_en", "Let's play and learn!")))
	var intro_vi := str(entry.get("intro_vi", ""))
	_intro_heading.text = "Buddy & Professor Owl: \"%s\"%s" % [intro_en, ("\n" + intro_vi if not intro_vi.is_empty() else "")]
	_intro_obj_lbl.text = "Mục tiêu học tập: %s" % str(entry.get("objective_vi", entry.get("learning_objective_vi", "")))
	_intro_instr_lbl.text = "Hướng dẫn: %s" % str(entry.get("instructions_vi", ""))

	for i in range(_intro_diff_opt.item_count):
		if str(_intro_diff_opt.get_item_metadata(i)) == sess.difficulty_tier:
			_intro_diff_opt.select(i)
			break


func _on_intro_diff_changed(idx: int) -> void:
	if _session == null:
		return
	var chosen_tier := str(_intro_diff_opt.get_item_metadata(idx))
	var resolved := MiniGameDifficulty.resolve_adaptive_tier(_session.minigame_id, chosen_tier)
	var cfg := MiniGameDifficulty.get_config_for(_session.minigame_id, resolved)
	if _session.launch_context.has("mode"):
		cfg["mode"] = str(_session.launch_context.get("mode"))
	var items := MiniGameDataProvider.build_items_for(_session.minigame_id, cfg, _session.launch_context)
	if not items.is_empty():
		_session.difficulty_tier = resolved
		_session.difficulty_config = cfg
		_session.set_items(items)
		_diff_pill.text = "Độ khó: %s" % str(cfg.get("label_vi", resolved))
		_progress_bar.max_value = maxf(1.0, float(items.size()))


func _start_gameplay_stage() -> void:
	if _session == null:
		return
	_session.begin_gameplay()
	_intro_panel.visible = false
	_gameplay_vbox.visible = true
	_summary_panel.visible = false
	_feedback_panel.visible = false

	_clear_controller()
	var ctrl := MiniGameFactory.create_controller(_session.minigame_id)
	if ctrl == null:
		EventBus.toast_requested.emit("Không tải được giao diện mini-game!", "warning")
		_return_to_world()
		return
	_active_controller = ctrl
	_active_controller.bind_session(_session, MiniGameManager.audio)
	_active_controller.round_feedback_ready.connect(_on_round_feedback)
	_active_controller.round_completed.connect(_advance_next)
	_active_controller.status_hint_changed.connect(func(h: String) -> void:
		_status_hint_lbl.text = h
	)
	_game_host.add_child(_active_controller)
	_active_controller.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_refresh_progress_header()
	_active_controller.start_current_round()


func _refresh_progress_header() -> void:
	if _session == null:
		return
	var cur := mini(_session.current_index + 1, _session.items.size())
	_progress_lbl.text = "Câu %d/%d | Điểm học: %d" % [cur, _session.items.size(), _session.learning_score]
	_progress_bar.value = float(_session.current_index)
	_diff_pill.text = "Độ khó: %s" % _session.difficulty_tier.capitalize()


func _on_round_feedback(fb: Dictionary) -> void:
	_feedback_panel.visible = true
	var is_ok := bool(fb.get("is_correct", false))
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.86, 0.98, 0.88, 1) if is_ok else Color(1.0, 0.91, 0.89, 1)
	sb.border_color = Color(0.18, 0.72, 0.34, 1) if is_ok else Color(0.84, 0.28, 0.24, 1)
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(14)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	_feedback_panel.add_theme_stylebox_override("panel", sb)

	_fb_title_lbl.text = str(fb.get("headline_vi", ""))
	_fb_title_lbl.add_theme_color_override("font_color", Color(0.08, 0.44, 0.18, 1) if is_ok else Color(0.66, 0.16, 0.14, 1))
	_fb_detail_lbl.text = "Đáp án: %s — %s" % [str(fb.get("full_answer_line", "")), str(fb.get("explanation_vi", ""))]
	_fb_example_lbl.text = str(fb.get("example_line", ""))
	_fb_example_lbl.visible = not _fb_example_lbl.text.is_empty()

	_fb_retry_btn.visible = (not is_ok) and bool(fb.get("allow_retry", true))
	_fb_next_btn.visible = is_ok or bool(fb.get("can_proceed", false))
	_refresh_progress_header()


func _replay_feedback_audio() -> void:
	if _session == null:
		return
	var fb := _session.last_feedback
	MiniGameManager.audio.play_word_or_sentence(
		str(fb.get("replay_audio_path", "")),
		str(fb.get("transcript_en", fb.get("correct_answer", "")))
	)


func _advance_next() -> void:
	if _session == null:
		return
	_feedback_panel.visible = false
	if _session.advance_to_next_item():
		_refresh_progress_header()
		if _active_controller != null:
			_active_controller.start_current_round()
	else:
		_show_summary_stage()


func _show_summary_stage() -> void:
	var result := MiniGameManager.complete_active_session()
	if result == null:
		_return_to_world()
		return
	MiniGameManager.audio.play_sfx("reward")
	_progress_bar.value = _progress_bar.max_value
	_gameplay_vbox.visible = false
	_summary_panel.visible = true

	var stars_str := ""
	for i in range(3):
		stars_str += "[*] " if i < result.stars else "[ ] "
	_sum_stars_lbl.text = "%s  (%d/3 Sao)" % [stars_str.strip_edges(), result.stars]

	_sum_stats_lbl.text = (
		"Đúng: %d/%d  |  Trả lời ngay lần đầu: %d  |  Sai: %d  |  Gợi ý: %d\n"
		+ "Điểm Học Tập (Learning Score): %d  |  Điểm Trò Chơi (Game Score): %d\n"
		+ "Độ chính xác: %.1f%%  |  Thời gian: %.1fs"
	) % [
		result.correct_answers, result.total_items, result.first_try_correct,
		result.incorrect_answers, result.hints_used,
		result.learning_score, result.game_score,
		result.accuracy, float(result.completion_time_ms) / 1000.0
	]

	var rew := result.reward_summary
	var crystal_dict: Dictionary = rew.get("crystal_granted", {})
	var crystal_line := ""
	if not crystal_dict.is_empty():
		crystal_line = "  +  1 %s" % str(crystal_dict.get("name_vi", "Magic Crystal"))
	var replay_note := " (Phần thưởng ôn tập)" if bool(rew.get("is_replay", false)) else " (Hoàn thành lần đầu!)"
	_sum_rewards_lbl.text = "Phần thưởng: +%d EXP  |  +%d Gold%s%s" % [
		int(rew.get("exp_granted", 0)),
		int(rew.get("gold_granted", 0)),
		crystal_line,
		replay_note
	]


func _replay_current_minigame() -> void:
	if _session == null:
		return
	var mg_id := _session.minigame_id
	var ctx := _session.launch_context.duplicate(true)
	MiniGameManager.close_active_session()
	MiniGameManager.start_minigame(mg_id, ctx, _selected_diff_override)


func _return_to_world() -> void:
	_clear_controller()
	MiniGameManager.close_active_session()


func _on_exit_pressed() -> void:
	AppLogger.info("MiniGameUI", "Exit requested (arcade_mode=%s)" % str(_arcade_mode))
	if _arcade_mode:
		_arcade_mode = false
		_backdrop.visible = false
		EventBus.pause_toggled.emit(false)
		return
	_return_to_world()


func _on_close_requested() -> void:
	_clear_controller()
	_session = null
	_arcade_mode = false
	_backdrop.visible = false


func _clear_controller() -> void:
	if _active_controller != null and is_instance_valid(_active_controller):
		_active_controller.queue_free()
	_active_controller = null


func _toggle_bgm_mute() -> void:
	var music_idx := AudioServer.get_bus_index(AudioManager.BUS_MUSIC)
	if music_idx < 0:
		return
	var muted := AudioServer.is_bus_mute(music_idx)
	AudioServer.set_bus_mute(music_idx, not muted)
	_bgm_toggle_btn.text = "Nhạc nền: Bật" if muted else "Nhạc nền: Tắt"


func _input(event: InputEvent) -> void:
	if not is_overlay_visible():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var k := (event as InputEventKey).keycode
		if k == KEY_ESCAPE:
			_on_exit_pressed()
			get_viewport().set_input_as_handled()
		elif (k == KEY_ENTER or k == KEY_KP_ENTER) and _intro_panel.visible:
			_start_gameplay_stage()
			get_viewport().set_input_as_handled()
