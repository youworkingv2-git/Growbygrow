extends PanelContainer
class_name LearningHubModal
## 2D Learning Hub & Interactive 4-Skill Lesson Runner layered cleanly over the 3D world.
## Never disturbs 3D player position or camera.

signal closed()

var _current_tab: String = "lessons"
var _vocab_topic_filter: String = "all"
var _selected_letter_id: String = "letter_a"
var _selected_grammar_id: String = "gram_07"

# Active Lesson / Review Runner state
var _in_runner: bool = false
var _runner_is_review: bool = false
var _runner_title: String = ""
var _runner_questions: Array[Dictionary] = []
var _runner_index: int = 0
var _runner_attempt_count: int = 0
var _runner_hint_used: bool = false
var _runner_question_start_ms: int = 0
var _runner_assembled_tokens: Array[String] = []
var _runner_can_proceed: bool = false
var _runner_text_input: LineEdit = null

@onready var header_title: Label = $Margin/RootVBox/Header/Title
@onready var accent_btn: Button = $Margin/RootVBox/Header/AccentBtn
@onready var close_btn: Button = $Margin/RootVBox/Header/CloseBtn

@onready var tab_bar: HBoxContainer = $Margin/RootVBox/TabBar
@onready var tab_lessons_btn: Button = $Margin/RootVBox/TabBar/LessonsBtn
@onready var tab_phonics_btn: Button = $Margin/RootVBox/TabBar/PhonicsBtn
@onready var tab_vocab_btn: Button = $Margin/RootVBox/TabBar/VocabBtn
@onready var tab_grammar_btn: Button = $Margin/RootVBox/TabBar/GrammarBtn
@onready var tab_progress_btn: Button = $Margin/RootVBox/TabBar/ProgressBtn

@onready var content_scroll: ScrollContainer = $Margin/RootVBox/ContentScroll
@onready var content_vbox: VBoxContainer = $Margin/RootVBox/ContentScroll/ContentVBox


func _ready() -> void:
	visible = false
	add_theme_stylebox_override(
		"panel",
		UIDesignSystem.make_panel_style(Color(0.07, 0.11, 0.21, 0.99), UIDesignSystem.PRIMARY, 16, 2, 0, 0)
	)
	UIDesignSystem.apply_button_variant(close_btn, "close")
	UIDesignSystem.apply_button_variant(accent_btn, "secondary")
	for b: Button in [tab_lessons_btn, tab_phonics_btn, tab_vocab_btn, tab_grammar_btn, tab_progress_btn, accent_btn, close_btn]:
		b.focus_mode = Control.FOCUS_NONE
		UIAnimator.attach_button_feedback(b)

	close_btn.pressed.connect(close_modal)
	accent_btn.pressed.connect(_toggle_accent)
	tab_lessons_btn.pressed.connect(func() -> void: _switch_tab("lessons"))
	tab_phonics_btn.pressed.connect(func() -> void: _switch_tab("phonics"))
	tab_vocab_btn.pressed.connect(func() -> void: _switch_tab("vocab"))
	tab_grammar_btn.pressed.connect(func() -> void: _switch_tab("grammar"))
	tab_progress_btn.pressed.connect(func() -> void: _switch_tab("progress"))

	_refresh_accent_button()


func open_hub(initial_lesson_id: String = "") -> void:
	_in_runner = false
	_refresh_accent_button()
	UIAnimator.animate_popup_open(self)
	if not initial_lesson_id.is_empty():
		start_lesson_runner(initial_lesson_id)
	else:
		_switch_tab("lessons")


func close_modal() -> void:
	_in_runner = false
	UIAnimator.animate_popup_close(self, func() -> void:
		closed.emit()
	)


func _toggle_accent() -> void:
	SettingsManager.preferred_accent = "en-GB" if SettingsManager.preferred_accent == "en-US" else "en-US"
	SettingsManager.save_settings()
	_refresh_accent_button()
	_render_current_view()


func _refresh_accent_button() -> void:
	accent_btn.text = "Giọng: Anh-Anh (UK)" if SettingsManager.preferred_accent == "en-GB" else "Giọng: Anh-Mỹ (US)"


func _switch_tab(tab_name: String) -> void:
	_in_runner = false
	_current_tab = tab_name
	_update_tab_styles()
	_render_current_view()


func _update_tab_styles() -> void:
	tab_bar.visible = not _in_runner
	var map := {
		"lessons": tab_lessons_btn,
		"phonics": tab_phonics_btn,
		"vocab": tab_vocab_btn,
		"grammar": tab_grammar_btn,
		"progress": tab_progress_btn
	}
	for key in map.keys():
		var btn: Button = map[key]
		UIDesignSystem.apply_button_variant(btn, "primary" if key == _current_tab else "secondary")


func _clear_content() -> void:
	for c in content_vbox.get_children():
		c.queue_free()
	content_scroll.scroll_vertical = 0


func _render_current_view() -> void:
	if _in_runner:
		_render_runner_question()
		return
	match _current_tab:
		"lessons":
			_render_lessons_tab()
		"phonics":
			_render_phonics_tab()
		"vocab":
			_render_vocab_tab()
		"grammar":
			_render_grammar_tab()
		"progress":
			_render_progress_tab()


func _make_card(bg: Color = Color(0.11, 0.17, 0.30, 0.96), border: Color = UIDesignSystem.BORDER_DEFAULT) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UIDesignSystem.make_panel_style(bg, border, 12, 1, 14, 10))
	return p


func _make_label(txt: String, size_px: int = 15, col: Color = UIDesignSystem.TEXT_LIGHT) -> Label:
	var lbl := Label.new()
	lbl.text = txt
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", size_px)
	lbl.add_theme_color_override("font_color", col)
	return lbl


# =============================================================================
# TAB 1: CURRICULUM & LESSONS + SMART REVIEW
# =============================================================================
func _render_lessons_tab() -> void:
	_clear_content()
	header_title.text = "TRUNG TÂM HỌC TIẾNG ANH - LỘ TRÌNH & BÀI HỌC"

	# Smart Spaced Repetition Review Banner
	var due_batch := LearningEngine.get_review_question_batch(6)
	var rev_card := _make_card(Color(0.12, 0.22, 0.38, 0.98), UIDesignSystem.TEXT_GOLD)
	var rev_row := HBoxContainer.new()
	rev_row.add_theme_constant_override("separation", 12)
	var rev_col := VBoxContainer.new()
	rev_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rev_col.add_child(_make_label("Ôn Tập Thông Minh (Spaced Repetition)", 17, UIDesignSystem.TEXT_GOLD))
	rev_col.add_child(_make_label("Hệ thống tự chọn %d câu hỏi dựa trên từ vựng mới học và từ bé hay nhầm." % due_batch.size(), 13, UIDesignSystem.TEXT_MUTED))
	rev_row.add_child(rev_col)
	var rev_btn := Button.new()
	rev_btn.text = "Ôn tập ngay"
	rev_btn.custom_minimum_size = Vector2(130, 44)
	UIDesignSystem.apply_button_variant(rev_btn, "reward")
	rev_btn.disabled = due_batch.is_empty()
	rev_btn.pressed.connect(func() -> void: _start_review_runner())
	rev_row.add_child(rev_btn)
	rev_card.add_child(rev_row)
	content_vbox.add_child(rev_card)

	# Prompt 05 Mini-Game Arcade Launcher Card
	var mg_card := _make_card(Color(0.14, 0.24, 0.36, 0.98), UIDesignSystem.PRIMARY)
	var mg_row := HBoxContainer.new()
	mg_row.add_theme_constant_override("separation", 12)
	var mg_col := VBoxContainer.new()
	mg_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mg_col.add_child(_make_label("Trung Tâm 8 Mini-Game Tiếng Anh", 17, UIDesignSystem.PRIMARY))
	mg_col.add_child(_make_label("Học từ vựng, phát âm, nghe-nói-đọc-viết qua 8 trò chơi phiêu lưu dùng chung dữ liệu Learning Engine.", 13, UIDesignSystem.TEXT_MUTED))
	mg_row.add_child(mg_col)
	var mg_btn := Button.new()
	mg_btn.text = "Mở Trò Chơi"
	mg_btn.custom_minimum_size = Vector2(130, 44)
	UIDesignSystem.apply_button_variant(mg_btn, "confirm")
	mg_btn.pressed.connect(func() -> void:
		close_modal()
		MiniGameManager.open_arcade_launcher()
	)
	mg_row.add_child(mg_btn)
	mg_card.add_child(mg_row)
	content_vbox.add_child(mg_card)

	# Learning Path Levels overview
	var levels_card := _make_card()
	var lv_box := VBoxContainer.new()
	lv_box.add_theme_constant_override("separation", 6)
	lv_box.add_child(_make_label("Lộ trình 4 giai đoạn (Learning Path)", 16, UIDesignSystem.PRIMARY))
	for lv in LearningEngine.path_manager.get_levels():
		var status_txt := "Đang mở" if str(lv.get("status", "")) == "active" else "Mở rộng ở các World sau"
		var col := UIDesignSystem.SUCCESS if str(lv.get("status", "")) == "active" else UIDesignSystem.TEXT_MUTED
		lv_box.add_child(_make_label("• %s — [%s]" % [str(lv.get("title_vi", "")), status_txt], 13, col))
	levels_card.add_child(lv_box)
	content_vbox.add_child(levels_card)

	# World 01 Topics & Lessons
	for topic in LearningEngine.path_manager.get_topics_for_world("world_01"):
		var t_id := str(topic.get("id", ""))
		var topic_done := LearningEngine.progress_manager.completed_topics.has(t_id)
		var topic_header := "%s (%s)" % [str(topic.get("title_vi", "")), "Đã hoàn thành" if topic_done else "Đang mở"]
		content_vbox.add_child(_make_label(topic_header, 16, UIDesignSystem.TEXT_GOLD))

		for ls in LearningEngine.path_manager.get_lessons_for_topic(t_id):
			var lid := str(ls.get("id", ""))
			var done := LearningEngine.progress_manager.is_lesson_completed(lid)
			var qid := str(ls.get("quest_id", ""))
			var card := _make_card(
				Color(0.10, 0.21, 0.22, 0.96) if done else Color(0.11, 0.17, 0.30, 0.96),
				UIDesignSystem.SUCCESS if done else UIDesignSystem.BORDER_DEFAULT
			)
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 12)
			var col_info := VBoxContainer.new()
			col_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var status_tag := "[Đã xong] " if done else ""
			col_info.add_child(_make_label(status_tag + str(ls.get("title_vi", "")), 16, UIDesignSystem.TEXT_LIGHT))
			col_info.add_child(_make_label(str(ls.get("summary_vi", "")), 13, UIDesignSystem.TEXT_MUTED))
			var rw: Dictionary = ls.get("rewards", {})
			var meta_str := "Hoạt động: %d | Thưởng lần đầu: +%d EXP, +%d Gold" % [
				(ls.get("activities", []) as Array).size(),
				int(rw.get("exp", 0)),
				int(rw.get("gold", 0))
			]
			if not qid.is_empty():
				meta_str += " | Gắn với Quest: " + qid
			col_info.add_child(_make_label(meta_str, 12, Color(0.65, 0.86, 1.0, 1.0)))
			row.add_child(col_info)

			var start_btn := Button.new()
			start_btn.text = "Học lại" if done else "Bắt đầu"
			start_btn.custom_minimum_size = Vector2(120, 44)
			UIDesignSystem.apply_button_variant(start_btn, "secondary" if done else "confirm")
			start_btn.pressed.connect(func() -> void: start_lesson_runner(lid))
			row.add_child(start_btn)
			card.add_child(row)
			content_vbox.add_child(card)


# =============================================================================
# TAB 2: ALPHABET (26 LETTERS) & PHONICS
# =============================================================================
func _render_phonics_tab() -> void:
	_clear_content()
	header_title.text = "BẢNG CHỮ CÁI A-Z & NGỮ ÂM (PHONICS)"

	content_vbox.add_child(_make_label("Chạm vào từng chữ cái để xem rõ Tên chữ cái (Letter Name) và Âm cơ bản (Letter Sound):", 14, UIDesignSystem.TEXT_MUTED))

	var grid := GridContainer.new()
	grid.columns = 7 if get_viewport().get_visible_rect().size.x >= 760.0 else 5
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)

	for l in LearningEngine.phonics_manager.get_all_letters():
		var lid := str(l.get("id", ""))
		var btn := Button.new()
		btn.text = "%s%s" % [str(l.get("letter_upper", "")), str(l.get("letter_lower", ""))]
		btn.custom_minimum_size = Vector2(58, 42)
		btn.focus_mode = Control.FOCUS_NONE
		UIDesignSystem.apply_button_variant(btn, "primary" if lid == _selected_letter_id else "secondary")
		btn.pressed.connect(func() -> void:
			_selected_letter_id = lid
			_render_phonics_tab()
		)
		grid.add_child(btn)
	content_vbox.add_child(grid)

	# Selected Letter Detail Card
	var sel_letter: Dictionary = LearningEngine.content_repo.alphabet_by_id.get(_selected_letter_id, {})
	if not sel_letter.is_empty():
		var detail := _make_card(Color(0.12, 0.19, 0.34, 0.98), UIDesignSystem.PRIMARY)
		var dv := VBoxContainer.new()
		dv.add_theme_constant_override("separation", 8)
		var up := str(sel_letter.get("letter_upper", ""))
		var lo := str(sel_letter.get("letter_lower", ""))
		var name_ipa := LearningEngine.phonics_manager.get_letter_name_ipa(sel_letter)
		var snd_ipa := str(sel_letter.get("letter_sound_ipa", ""))
		dv.add_child(_make_label("Chữ %s / %s  (%s)" % [up, lo, str(sel_letter.get("letter_type", ""))], 20, UIDesignSystem.TEXT_GOLD))
		dv.add_child(_make_label("• Tên chữ cái (Letter Name): %s   |   • Âm cơ bản (Letter Sound): %s" % [name_ipa, snd_ipa], 15, Color(0.55, 0.90, 1.0, 1.0)))
		var extras: Array = sel_letter.get("additional_sounds", [])
		if not extras.is_empty():
			dv.add_child(_make_label("• Âm khác (học ở bậc cao hơn): " + ", ".join(PackedStringArray(extras)), 13, UIDesignSystem.TEXT_MUTED))
		dv.add_child(_make_label("• Lưu ý sư phạm: " + str(sel_letter.get("exception_note_vi", "")), 14, UIDesignSystem.TEXT_LIGHT))
		dv.add_child(_make_label("• Cách đặt miệng: " + str(sel_letter.get("mouth_hint_vi", "")), 14, UIDesignSystem.SUCCESS))

		# Audio row (separate Letter Name vs Letter Sound + anchor word + honest asset status)
		var first_anchor_word := ""
		var anchor_ids_arr: Array = sel_letter.get("anchor_word_ids", [])
		if not anchor_ids_arr.is_empty():
			var w0 := LearningEngine.vocabulary_manager.get_word(str(anchor_ids_arr[0]))
			first_anchor_word = str(w0.get("word", ""))

		var audio_row := HFlowContainer.new()
		audio_row.add_theme_constant_override("h_separation", 8)
		audio_row.add_theme_constant_override("v_separation", 6)
		if AudioManager.can_use_browser_tts():
			var tts_name_btn := Button.new()
			tts_name_btn.text = "Nghe tên chữ (%s)" % up
			UIDesignSystem.apply_button_variant(tts_name_btn, "primary")
			tts_name_btn.pressed.connect(func() -> void: AudioManager.speak_browser_tts_fallback(up, SettingsManager.preferred_accent, 0.86))
			audio_row.add_child(tts_name_btn)

			if not first_anchor_word.is_empty():
				var tts_sound_btn := Button.new()
				tts_sound_btn.text = "Nghe âm qua từ '%s'" % first_anchor_word
				UIDesignSystem.apply_button_variant(tts_sound_btn, "confirm")
				tts_sound_btn.pressed.connect(func() -> void: AudioManager.speak_browser_tts_fallback(first_anchor_word, SettingsManager.preferred_accent, 0.80))
				audio_row.add_child(tts_sound_btn)
		if audio_row.get_child_count() > 0:
			dv.add_child(audio_row)
		var audio_note := _make_label("Audio .ogg thu sẵn: Đang chờ bổ sung (hỗ trợ nghe mẫu qua TTS trình duyệt + phiên âm IPA).", 12, Color(1.0, 0.82, 0.45, 1.0))
		dv.add_child(audio_note)

		# Anchor word illustrations
		var anchor_row := HFlowContainer.new()
		anchor_row.add_theme_constant_override("h_separation", 10)
		anchor_row.add_theme_constant_override("v_separation", 8)
		for wid_var in anchor_ids_arr:
			var w := LearningEngine.vocabulary_manager.get_word(str(wid_var))
			if not w.is_empty():
				var chip := _make_card(Color(0.08, 0.13, 0.24, 0.96), UIDesignSystem.BORDER_DEFAULT)
				var hb := HBoxContainer.new()
				hb.add_theme_constant_override("separation", 8)
				var tex_rect := TextureRect.new()
				tex_rect.custom_minimum_size = Vector2(44, 44)
				tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				var img_path := str(w.get("image_path", ""))
				if ResourceLoader.exists(img_path):
					tex_rect.texture = load(img_path)
				hb.add_child(tex_rect)
				var w_en := str(w.get("word", ""))
				var chip_lbl := _make_label("%s (%s)\n%s" % [w_en, LearningEngine.vocabulary_manager.get_ipa_for_accent(w), str(w.get("meaning_vi", ""))], 13)
				chip_lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
				hb.add_child(chip_lbl)
				if AudioManager.can_use_browser_tts():
					var w_btn := Button.new()
					w_btn.text = "Nghe"
					w_btn.custom_minimum_size = Vector2(58, 34)
					UIDesignSystem.apply_button_variant(w_btn, "secondary")
					w_btn.pressed.connect(func() -> void: AudioManager.speak_browser_tts_fallback(w_en, SettingsManager.preferred_accent, 0.82))
					hb.add_child(w_btn)
				chip.add_child(hb)
				anchor_row.add_child(chip)
		dv.add_child(anchor_row)
		detail.add_child(dv)
		content_vbox.add_child(detail)

	# Phonics Units (Short/Long Vowels, Digraphs, Blending)
	content_vbox.add_child(_make_label("Nhóm âm Phonics & Ghép vần cơ bản:", 16, UIDesignSystem.TEXT_GOLD))
	for unit in LearningEngine.phonics_manager.get_phonics_units():
		var ucard := _make_card()
		var uv := VBoxContainer.new()
		uv.add_theme_constant_override("separation", 4)
		var top_u := HBoxContainer.new()
		top_u.add_theme_constant_override("separation", 8)
		var title_u := _make_label("[%s] %s" % [str(unit.get("category", "")), str(unit.get("title_vi", ""))], 15, UIDesignSystem.PRIMARY)
		title_u.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		top_u.add_child(title_u)
		var ex_words: PackedStringArray = []
		var ex_strs: PackedStringArray = []
		for ex_var in unit.get("examples", []):
			if typeof(ex_var) == TYPE_DICTIONARY:
				var ex: Dictionary = ex_var
				var segs: PackedStringArray = PackedStringArray(ex.get("segments", []))
				var ew := str(ex.get("word", ""))
				if not ew.is_empty():
					ex_words.append(ew)
				ex_strs.append("%s (%s)" % [ew, "-".join(segs)])
		if AudioManager.can_use_browser_tts() and not ex_words.is_empty():
			var u_btn := Button.new()
			u_btn.text = "Nghe mẫu"
			u_btn.custom_minimum_size = Vector2(88, 32)
			UIDesignSystem.apply_button_variant(u_btn, "secondary")
			var speak_sample := ", ".join(ex_words)
			u_btn.pressed.connect(func() -> void: AudioManager.speak_browser_tts_fallback(speak_sample, SettingsManager.preferred_accent, 0.80))
			top_u.add_child(u_btn)
		uv.add_child(top_u)
		uv.add_child(_make_label(str(unit.get("explanation_vi", "")), 13, UIDesignSystem.TEXT_MUTED))
		if not ex_strs.is_empty():
			uv.add_child(_make_label("Ví dụ ghép âm: " + " | ".join(ex_strs), 13, UIDesignSystem.SUCCESS))
		ucard.add_child(uv)
		content_vbox.add_child(ucard)


# =============================================================================
# TAB 3: VOCABULARY MANAGER (32 REUSABLE WORDS)
# =============================================================================
func _render_vocab_tab() -> void:
	_clear_content()
	header_title.text = "KHO TỪ VỰNG PRE-A1 (%d TỪ)" % LearningEngine.content_repo.vocab_ordered.size()

	var filter_row := HBoxContainer.new()
	filter_row.add_theme_constant_override("separation", 6)
	var topics: Array[String] = ["all"]
	topics.append_array(LearningEngine.vocabulary_manager.get_topics())
	for t in topics:
		var fb := Button.new()
		fb.text = "Tất cả" if t == "all" else t.capitalize()
		fb.focus_mode = Control.FOCUS_NONE
		UIDesignSystem.apply_button_variant(fb, "primary" if _vocab_topic_filter == t else "secondary")
		fb.pressed.connect(func() -> void:
			_vocab_topic_filter = t
			_render_vocab_tab()
		)
		filter_row.add_child(fb)
	content_vbox.add_child(filter_row)

	var words := LearningEngine.vocabulary_manager.get_all_words() if _vocab_topic_filter == "all" else LearningEngine.vocabulary_manager.get_words_by_topic(_vocab_topic_filter)
	for w in words:
		var wid := str(w.get("id", ""))
		var word_en := str(w.get("word", ""))
		var status := str(w.get("learning_status", "new"))
		var card := _make_card()
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)

		var img := TextureRect.new()
		img.custom_minimum_size = Vector2(60, 60)
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var img_path := str(w.get("image_path", ""))
		if ResourceLoader.exists(img_path):
			img.texture = load(img_path)
		row.add_child(img)

		var col := VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.add_child(_make_label("%s (%s) — %s  [%s]" % [
			word_en.capitalize(),
			LearningEngine.vocabulary_manager.get_ipa_for_accent(w),
			str(w.get("meaning_vi", "")),
			status.to_upper()
		], 15, UIDesignSystem.TEXT_GOLD))
		col.add_child(_make_label("Ví dụ: %s (%s)" % [
			str(w.get("example_sentence", "")),
			str(w.get("example_translation", ""))
		], 13, UIDesignSystem.TEXT_MUTED))
		row.add_child(col)

		if AudioManager.can_use_browser_tts():
			var listen_btn := Button.new()
			listen_btn.text = "Nghe"
			listen_btn.custom_minimum_size = Vector2(68, 40)
			UIDesignSystem.apply_button_variant(listen_btn, "secondary")
			listen_btn.pressed.connect(func() -> void: AudioManager.speak_browser_tts_fallback(word_en, SettingsManager.preferred_accent))
			row.add_child(listen_btn)

		var prac_btn := Button.new()
		prac_btn.text = "Luyện"
		prac_btn.custom_minimum_size = Vector2(76, 40)
		UIDesignSystem.apply_button_variant(prac_btn, "confirm")
		prac_btn.pressed.connect(func() -> void: _start_single_word_practice(wid))
		row.add_child(prac_btn)

		card.add_child(row)
		content_vbox.add_child(card)


# =============================================================================
# TAB 4: GRAMMAR & DYNAMIC SUBSTITUTION BUILDER
# =============================================================================
func _render_grammar_tab() -> void:
	_clear_content()
	header_title.text = "NGỮ PHÁP CƠ BẢN (15 CẤU TRÚC & THAY THẾ TỪ)"

	for g in LearningEngine.grammar_manager.get_all_structures():
		var gid := str(g.get("id", ""))
		var is_sel := gid == _selected_grammar_id
		var card := _make_card(
			Color(0.12, 0.19, 0.34, 0.98) if is_sel else Color(0.11, 0.17, 0.30, 0.96),
			UIDesignSystem.PRIMARY if is_sel else UIDesignSystem.BORDER_DEFAULT
		)
		var gv := VBoxContainer.new()
		gv.add_theme_constant_override("separation", 6)

		var top_row := HBoxContainer.new()
		top_row.add_child(_make_label(str(g.get("structure", "")), 17, UIDesignSystem.TEXT_GOLD))
		top_row.get_child(0).size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var toggle_btn := Button.new()
		toggle_btn.text = "Đang xem" if is_sel else "Tập ghép câu"
		UIDesignSystem.apply_button_variant(toggle_btn, "primary" if is_sel else "secondary")
		toggle_btn.pressed.connect(func() -> void:
			_selected_grammar_id = gid
			_render_grammar_tab()
		)
		top_row.add_child(toggle_btn)
		gv.add_child(top_row)

		gv.add_child(_make_label(str(g.get("explanation_vi", "")), 14, UIDesignSystem.TEXT_LIGHT))
		for ex_var in g.get("example_sentences", []):
			if typeof(ex_var) == TYPE_DICTIONARY:
				var ex: Dictionary = ex_var
				gv.add_child(_make_label("• %s -> %s" % [str(ex.get("en", "")), str(ex.get("vi", ""))], 13, Color(0.65, 0.88, 1.0, 1.0)))

		if is_sel:
			var subs := LearningEngine.grammar_manager.generate_substitution_sentences(gid)
			if not subs.is_empty():
				gv.add_child(_make_label("Thay thế từ để tạo câu mới tự động:", 14, UIDesignSystem.SUCCESS))
				for s in subs:
					gv.add_child(_make_label("   + " + s, 14, UIDesignSystem.SUCCESS))
			for m_var in g.get("common_mistakes_vi", []):
				gv.add_child(_make_label("Lỗi hay gặp: " + str(m_var), 13, Color(1.0, 0.72, 0.55, 1.0)))

		card.add_child(gv)
		content_vbox.add_child(card)


# =============================================================================
# TAB 5: PROGRESS, ASSESSMENT & 4 SKILLS
# =============================================================================
func _render_progress_tab() -> void:
	_clear_content()
	header_title.text = "TIẾN ĐỘ HỌC TẬP & ĐÁNH GIÁ 4 KỸ NĂNG"

	var pm := LearningEngine.progress_manager
	var summary_card := _make_card(Color(0.11, 0.19, 0.34, 0.98), UIDesignSystem.PRIMARY)
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 6)
	sv.add_child(_make_label("Phân tách Điểm Học Tập vs Điểm Trò Chơi:", 16, UIDesignSystem.TEXT_GOLD))
	sv.add_child(_make_label("• Learning Score (Kết quả học tập): %d điểm" % pm.total_learning_score, 15, UIDesignSystem.SUCCESS))
	sv.add_child(_make_label("• Game Score (Điểm thưởng trò chơi): %d điểm | Player EXP: %d | Gold: %d" % [
		pm.total_game_score, GameStateManager.exp, GameStateManager.gold
	], 14, UIDesignSystem.TEXT_LIGHT))
	sv.add_child(_make_label("• Bài học đã hoàn thành: %d / %d   |   Chủ đề xong: %d" % [
		pm.completed_lessons.size(),
		LearningEngine.content_repo.lessons_ordered.size(),
		pm.completed_topics.size()
	], 14, Color(0.65, 0.88, 1.0, 1.0)))
	summary_card.add_child(sv)
	content_vbox.add_child(summary_card)

	var skill_card := _make_card()
	var skv := VBoxContainer.new()
	skv.add_theme_constant_override("separation", 6)
	skv.add_child(_make_label("Thống kê 4 kỹ năng (Listening, Speaking, Reading, Writing):", 16, UIDesignSystem.TEXT_GOLD))
	for sk in ["listening", "speaking", "reading", "writing"]:
		var st: Dictionary = pm.skill_stats.get(sk, {})
		var att := int(st.get("attempts", 0))
		var cor := int(st.get("correct", 0))
		var acc := float(st.get("accuracy_pct", 0.0))
		skv.add_child(_make_label("• %s: %d lượt | Đúng lần đầu: %d | Độ chính xác: %.1f%%" % [
			sk.capitalize(), att, cor, acc
		], 14))
	skill_card.add_child(skv)
	content_vbox.add_child(skill_card)

	var missed := pm.get_frequently_missed_items()
	var miss_card := _make_card()
	var mv := VBoxContainer.new()
	mv.add_theme_constant_override("separation", 4)
	mv.add_child(_make_label("Từ vựng cần luyện tập thêm (Wrong History):", 15, Color(1.0, 0.78, 0.45, 1.0)))
	if missed.is_empty():
		mv.add_child(_make_label("Chưa có từ nào trả lời sai gần đây!", 13, UIDesignSystem.TEXT_MUTED))
	else:
		for m in missed.slice(0, 6):
			mv.add_child(_make_label("• %s — Sai %d lần | Mastery %.1f%% (%s)" % [
				str(m.get("item_id", "")), int(m.get("wrong_count", 0)), float(m.get("mastery_score", 0.0)), str(m.get("status", ""))
			], 13))
	miss_card.add_child(mv)
	content_vbox.add_child(miss_card)


# =============================================================================
# INTERACTIVE LESSON & REVIEW RUNNER
# =============================================================================
func start_lesson_runner(lesson_id: String) -> void:
	var lesson := LearningEngine.path_manager.get_lesson(lesson_id)
	var qs := LearningEngine.start_lesson(lesson_id)
	if qs.is_empty():
		_switch_tab("lessons")
		return
	_in_runner = true
	_runner_is_review = false
	_runner_title = str(lesson.get("title_vi", lesson_id))
	_runner_questions = qs
	_runner_index = 0
	_reset_question_state()
	_update_tab_styles()
	_render_runner_question()


func _start_review_runner() -> void:
	var qs := LearningEngine.get_review_question_batch(6)
	if qs.is_empty():
		return
	_in_runner = true
	_runner_is_review = true
	_runner_title = "Ôn tập thông minh (Spaced Repetition)"
	_runner_questions = qs
	_runner_index = 0
	_reset_question_state()
	_update_tab_styles()
	_render_runner_question()


func _start_single_word_practice(word_id: String) -> void:
	var qs: Array[Dictionary] = []
	for sk in ["reading", "writing", "listening"]:
		var q := LearningEngine.question_manager.build_reusable_vocab_question(word_id, sk)
		if not q.is_empty():
			qs.append(q)
	if qs.is_empty():
		return
	_in_runner = true
	_runner_is_review = true
	_runner_title = "Luyện tập từ vựng đa kỹ năng"
	_runner_questions = qs
	_runner_index = 0
	_reset_question_state()
	_update_tab_styles()
	_render_runner_question()


func _reset_question_state() -> void:
	_runner_attempt_count = 0
	_runner_hint_used = false
	_runner_question_start_ms = Time.get_ticks_msec()
	_runner_assembled_tokens.clear()
	_runner_can_proceed = false
	_runner_text_input = null


func _render_runner_question(feedback_override: Dictionary = {}) -> void:
	_clear_content()
	if _runner_index >= _runner_questions.size():
		_render_runner_complete()
		return

	var q: Dictionary = _runner_questions[_runner_index]
	var skill := str(q.get("skill", "reading"))
	var atype := str(q.get("activity_type", ""))
	header_title.text = "%s (%d/%d)" % [_runner_title, _runner_index + 1, _runner_questions.size()]

	# Top Runner Controls
	var nav_row := HBoxContainer.new()
	nav_row.add_theme_constant_override("separation", 8)
	var back_btn := Button.new()
	back_btn.text = "< Thoát bài"
	UIDesignSystem.apply_button_variant(back_btn, "secondary")
	back_btn.pressed.connect(func() -> void: _switch_tab("lessons"))
	nav_row.add_child(back_btn)

	nav_row.add_child(_make_label("Kỹ năng: %s" % skill.to_upper(), 14, UIDesignSystem.TEXT_GOLD))
	nav_row.get_child(1).size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var hint_btn := Button.new()
	hint_btn.text = "Gợi ý"
	UIDesignSystem.apply_button_variant(hint_btn, "reward")
	hint_btn.pressed.connect(func() -> void:
		_runner_hint_used = true
		_render_runner_question({ "hint_banner": _build_hint_text(q) })
	)
	nav_row.add_child(hint_btn)
	content_vbox.add_child(nav_row)

	# Prompt Card
	var pcard := _make_card(Color(0.11, 0.18, 0.33, 0.98), UIDesignSystem.PRIMARY)
	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 8)
	pv.add_child(_make_label(str(q.get("prompt_vi", "")), 18, UIDesignSystem.TEXT_LIGHT))

	var img_path := str(q.get("image_path", ""))
	if not img_path.is_empty() and ResourceLoader.exists(img_path) and not atype.contains("choose_image"):
		var pic := TextureRect.new()
		pic.custom_minimum_size = Vector2(96, 96)
		pic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pic.texture = load(img_path)
		pv.add_child(pic)

	if q.has("text_en") and not str(q.get("text_en", "")).is_empty():
		pv.add_child(_make_label(str(q.get("text_en", "")), 22, UIDesignSystem.TEXT_GOLD))
	if q.has("pattern") and not str(q.get("pattern", "")).is_empty():
		pv.add_child(_make_label(str(q.get("pattern", "")), 24, UIDesignSystem.TEXT_GOLD))
	if q.has("sentence_template") and not str(q.get("sentence_template", "")).is_empty():
		pv.add_child(_make_label(str(q.get("sentence_template", "")), 20, UIDesignSystem.TEXT_GOLD))
	if q.has("target_text_en") and not str(q.get("target_text_en", "")).is_empty():
		pv.add_child(_make_label(str(q.get("target_text_en", "")), 22, UIDesignSystem.TEXT_GOLD))
	if q.has("ipa") and not str(q.get("ipa", "")).is_empty():
		pv.add_child(_make_label("Phát âm IPA: " + str(q.get("ipa", "")), 14, Color(0.60, 0.88, 1.0, 1.0)))

	# Audio Playback Row for Listening / Speaking / Vocabulary
	if skill == "listening" or skill == "speaking":
		var audio_bar := HBoxContainer.new()
		audio_bar.add_theme_constant_override("separation", 8)
		var play_btn := Button.new()
		play_btn.text = "Nghe âm thanh mẫu"
		UIDesignSystem.apply_button_variant(play_btn, "primary")
		play_btn.pressed.connect(func() -> void:
			var res := AudioManager.play_learning_audio(str(q.get("audio_path", "")), SettingsManager.preferred_accent)
			if not bool(res.get("played_bundled", false)):
				if AudioManager.can_use_browser_tts():
					var tts_txt := str(q.get("transcript_en", q.get("target_text_en", "")))
					AudioManager.speak_browser_tts_fallback(tts_txt, SettingsManager.preferred_accent)
		)
		audio_bar.add_child(play_btn)
		var audio_note := "Chưa có file âm thanh thu sẵn; hỗ trợ TTS trình duyệt + đọc chữ/IPA." if AudioManager.can_use_browser_tts() else "Chưa có file âm thanh thu sẵn (asset đang chờ bổ sung)."
		audio_bar.add_child(_make_label(audio_note, 12, Color(1.0, 0.82, 0.45, 1.0)))
		pv.add_child(audio_bar)

	pcard.add_child(pv)
	content_vbox.add_child(pcard)

	if feedback_override.has("hint_banner"):
		var hcard := _make_card(Color(0.20, 0.18, 0.08, 0.96), UIDesignSystem.TEXT_GOLD)
		hcard.add_child(_make_label("Gợi ý từ Buddy: " + str(feedback_override["hint_banner"]), 14, UIDesignSystem.TEXT_GOLD))
		content_vbox.add_child(hcard)

	# Activity Input Area by Skill / Type
	if not _runner_can_proceed:
		_build_activity_input_ui(q, skill, atype)

	# Assessment Feedback Panel
	if feedback_override.has("is_correct"):
		var is_ok := bool(feedback_override.get("is_correct", false))
		var fcard := _make_card(
			Color(0.08, 0.24, 0.16, 0.98) if is_ok else Color(0.26, 0.13, 0.13, 0.98),
			UIDesignSystem.SUCCESS if is_ok else Color(1.0, 0.55, 0.35, 1.0)
		)
		var fv := VBoxContainer.new()
		fv.add_theme_constant_override("separation", 6)
		fv.add_child(_make_label(str(feedback_override.get("headline_vi", "")), 16, UIDesignSystem.SUCCESS if is_ok else Color(1.0, 0.78, 0.50, 1.0)))
		fv.add_child(_make_label("Đáp án đúng: " + str(feedback_override.get("correct_answer", "")), 15, UIDesignSystem.TEXT_LIGHT))
		fv.add_child(_make_label("Giải thích: " + str(feedback_override.get("explanation_vi", "")), 14, UIDesignSystem.TEXT_MUTED))

		if is_ok:
			var next_btn := Button.new()
			next_btn.text = "Hoàn thành bài!" if _runner_index + 1 >= _runner_questions.size() else "Câu tiếp theo >"
			next_btn.custom_minimum_size = Vector2(180, 44)
			UIDesignSystem.apply_button_variant(next_btn, "confirm")
			next_btn.pressed.connect(func() -> void:
				_runner_index += 1
				_reset_question_state()
				_render_runner_question()
			)
			fv.add_child(next_btn)
		else:
			fv.add_child(_make_label("Hãy xem đáp án ở trên và chọn lại để ghi nhớ nhé!", 13, Color(1.0, 0.85, 0.55, 1.0)))

		fcard.add_child(fv)
		content_vbox.add_child(fcard)


func _build_activity_input_ui(q: Dictionary, skill: String, atype: String) -> void:
	if skill == "speaking":
		var cap := LearningEngine.speaking_manager.get_capability_report()
		var scard := _make_card(Color(0.10, 0.15, 0.28, 0.96), UIDesignSystem.BORDER_DEFAULT)
		var sv := VBoxContainer.new()
		sv.add_theme_constant_override("separation", 8)
		sv.add_child(_make_label("Hướng dẫn khẩu hình: " + str(q.get("mouth_hint_vi", "")), 14, UIDesignSystem.SUCCESS))
		sv.add_child(_make_label(str(cap.get("status_vi", "")), 12, Color(1.0, 0.82, 0.45, 1.0)))
		var btn_row := HBoxContainer.new()
		btn_row.add_theme_constant_override("separation", 10)
		var ok_btn := Button.new()
		ok_btn.text = "Con đã đọc theo rõ ràng!"
		ok_btn.custom_minimum_size = Vector2(200, 44)
		UIDesignSystem.apply_button_variant(ok_btn, "confirm")
		ok_btn.pressed.connect(func() -> void: _submit_answer(q, "practiced_clear"))
		var retry_btn := Button.new()
		retry_btn.text = "Con muốn luyện thêm"
		retry_btn.custom_minimum_size = Vector2(180, 44)
		UIDesignSystem.apply_button_variant(retry_btn, "secondary")
		retry_btn.pressed.connect(func() -> void: _submit_answer(q, "need_more_practice"))
		btn_row.add_child(ok_btn)
		btn_row.add_child(retry_btn)
		sv.add_child(btn_row)
		scard.add_child(sv)
		content_vbox.add_child(scard)
		return

	if atype in ["listen_arrange_sentence", "arrange_words_sentence", "assemble_letters_word"]:
		var is_letters := (atype == "assemble_letters_word")
		var pool_arr: Array = q.get("tiles", q.get("tokens", [])).duplicate()
		if not is_letters and atype != "arrange_words_sentence":
			pool_arr.shuffle()
		elif atype == "listen_arrange_sentence":
			pool_arr.shuffle()

		var built_lbl := _make_label("Đang ghép: " + ("".join(PackedStringArray(_runner_assembled_tokens)) if is_letters else " ".join(PackedStringArray(_runner_assembled_tokens))), 18, UIDesignSystem.TEXT_GOLD)
		content_vbox.add_child(built_lbl)

		var tiles_row := HBoxContainer.new()
		tiles_row.add_theme_constant_override("separation", 8)
		for tk_var in pool_arr:
			var tk := str(tk_var)
			var tb := Button.new()
			tb.text = tk
			tb.custom_minimum_size = Vector2(56, 44)
			UIDesignSystem.apply_button_variant(tb, "secondary")
			tb.pressed.connect(func() -> void:
				_runner_assembled_tokens.append(tk)
				_render_runner_question()
			)
			tiles_row.add_child(tb)
		content_vbox.add_child(tiles_row)

		var act_row := HBoxContainer.new()
		act_row.add_theme_constant_override("separation", 10)
		var clear_btn := Button.new()
		clear_btn.text = "Xóa ghép lại"
		UIDesignSystem.apply_button_variant(clear_btn, "secondary")
		clear_btn.pressed.connect(func() -> void:
			_runner_assembled_tokens.clear()
			_render_runner_question()
		)
		var check_btn := Button.new()
		check_btn.text = "Kiểm tra"
		UIDesignSystem.apply_button_variant(check_btn, "confirm")
		check_btn.disabled = _runner_assembled_tokens.is_empty()
		check_btn.pressed.connect(func() -> void:
			var joined := "".join(PackedStringArray(_runner_assembled_tokens)) if is_letters else " ".join(PackedStringArray(_runner_assembled_tokens))
			_submit_answer(q, joined)
		)
		act_row.add_child(clear_btn)
		act_row.add_child(check_btn)
		content_vbox.add_child(act_row)
		return

	if atype == "type_simple_sentence":
		_runner_text_input = LineEdit.new()
		_runner_text_input.placeholder_text = "Nhập câu (ví dụ: I like milk.)"
		_runner_text_input.custom_minimum_size = Vector2(0, 44)
		content_vbox.add_child(_runner_text_input)
		var chips_row := HBoxContainer.new()
		chips_row.add_theme_constant_override("separation", 8)
		for ch_var in q.get("starter_chips", []):
			var ch := str(ch_var)
			var cb := Button.new()
			cb.text = "+ " + ch
			UIDesignSystem.apply_button_variant(cb, "secondary")
			cb.pressed.connect(func() -> void:
				if _runner_text_input != null:
					var cur := _runner_text_input.text.strip_edges()
					_runner_text_input.text = ch if cur.is_empty() else (cur + " " + ch)
			)
			chips_row.add_child(cb)
		content_vbox.add_child(chips_row)
		var submit_btn := Button.new()
		submit_btn.text = "Nộp câu"
		submit_btn.custom_minimum_size = Vector2(140, 44)
		UIDesignSystem.apply_button_variant(submit_btn, "confirm")
		submit_btn.pressed.connect(func() -> void:
			if _runner_text_input != null:
				_submit_answer(q, _runner_text_input.text)
		)
		content_vbox.add_child(submit_btn)
		return

	if atype == "fill_missing_letter" or atype == "fill_word_in_sentence":
		var list_key := "letter_choices" if atype == "fill_missing_letter" else "word_choices"
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		for ch_var in q.get(list_key, []):
			var val := str(ch_var)
			var btn := Button.new()
			btn.text = val
			btn.custom_minimum_size = Vector2(88, 48)
			UIDesignSystem.apply_button_variant(btn, "secondary")
			btn.pressed.connect(func() -> void: _submit_answer(q, val))
			row.add_child(btn)
		content_vbox.add_child(row)
		return

	# Standard Multiple-Choice Options (with image support if word_id present on option)
	var opts_row := HBoxContainer.new()
	opts_row.add_theme_constant_override("separation", 10)
	for opt_var in q.get("options", []):
		if typeof(opt_var) != TYPE_DICTIONARY:
			continue
		var opt: Dictionary = opt_var
		var oid := str(opt.get("id", ""))
		var label_txt := str(opt.get("label_vi", opt.get("label_en", oid)))
		var obtn := Button.new()
		obtn.text = label_txt
		obtn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		obtn.custom_minimum_size = Vector2(120, 74)
		var opt_wid := str(opt.get("word_id", ""))
		if not opt_wid.is_empty():
			var w := LearningEngine.vocabulary_manager.get_word(opt_wid)
			var w_img := str(w.get("image_path", ""))
			if not w_img.is_empty() and ResourceLoader.exists(w_img):
				obtn.icon = load(w_img)
				obtn.expand_icon = true
		UIDesignSystem.apply_button_variant(obtn, "secondary")
		obtn.pressed.connect(func() -> void: _submit_answer(q, oid))
		opts_row.add_child(obtn)
	content_vbox.add_child(opts_row)


func _submit_answer(q: Dictionary, selected_answer: String) -> void:
	_runner_attempt_count += 1
	var elapsed := Time.get_ticks_msec() - _runner_question_start_ms
	var feedback := LearningEngine.submit_question_answer(
		q,
		selected_answer,
		elapsed,
		_runner_attempt_count,
		_runner_hint_used
	)
	_runner_can_proceed = bool(feedback.get("can_proceed", false))
	_render_runner_question(feedback)


func _render_runner_complete() -> void:
	var summary := {}
	if not _runner_is_review:
		summary = LearningEngine.complete_active_lesson()

	var card := _make_card(Color(0.08, 0.24, 0.16, 0.98), UIDesignSystem.SUCCESS)
	var cv := VBoxContainer.new()
	cv.add_theme_constant_override("separation", 10)
	cv.add_child(_make_label("HOÀN THÀNH BÀI HỌC!", 22, UIDesignSystem.SUCCESS))
	cv.add_child(_make_label("Bài: " + _runner_title, 16, UIDesignSystem.TEXT_GOLD))
	if not summary.is_empty():
		var exp_g := int(summary.get("exp_granted", 0))
		var gold_g := int(summary.get("gold_granted", 0))
		if exp_g > 0 or gold_g > 0:
			cv.add_child(_make_label("Phần thưởng hoàn thành lần đầu: +%d EXP | +%d Gold" % [exp_g, gold_g], 15, UIDesignSystem.TEXT_GOLD))
		else:
			cv.add_child(_make_label("Bé đã ôn lại bài học này thành công! Tiến trình ghi nhớ đã được cập nhật.", 14, UIDesignSystem.TEXT_LIGHT))
	else:
		cv.add_child(_make_label("Phiên ôn tập đã hoàn tất và cập nhật lịch Spaced Repetition!", 14, UIDesignSystem.TEXT_LIGHT))

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 10)
	var list_btn := Button.new()
	list_btn.text = "Về danh sách bài"
	UIDesignSystem.apply_button_variant(list_btn, "secondary")
	list_btn.pressed.connect(func() -> void: _switch_tab("lessons"))
	var world_btn := Button.new()
	world_btn.text = "Quay lại thế giới 3D"
	UIDesignSystem.apply_button_variant(world_btn, "confirm")
	world_btn.pressed.connect(close_modal)
	btn_row.add_child(list_btn)
	btn_row.add_child(world_btn)
	cv.add_child(btn_row)
	card.add_child(cv)
	content_vbox.add_child(card)


func _build_hint_text(q: Dictionary) -> String:
	var wid := str(q.get("word_id", ""))
	if not wid.is_empty():
		var w := LearningEngine.vocabulary_manager.get_word(wid)
		if not w.is_empty():
			return "Từ này nghĩa là '%s', phát âm %s." % [str(w.get("meaning_vi", "")), LearningEngine.vocabulary_manager.get_ipa_for_accent(w)]
	return str(q.get("explanation_vi", "Hãy đọc kỹ câu hỏi và thử lại nhé!"))
