class_name SettingsModalUI
extends Control
## Shared Settings Screen (#17): Master, Music, SFX, NPC Voice, Learning Audio sliders,
## English Accent (en-US / en-GB), Speech Speed, Reset Audio Defaults, Language,
## Fullscreen, Desktop Resolution, Control Mode, Reduced Motion, and Back to Main Menu.

signal closed()
signal main_menu_requested()

@onready var card: PanelContainer = $Center/Card
@onready var card_vbox: VBoxContainer = $Center/Card/Margin/VBox
@onready var title_label: Label = $Center/Card/Margin/VBox/Header/TitleLabel
@onready var close_btn: Button = $Center/Card/Margin/VBox/Header/CloseBtn

@onready var form_vbox: VBoxContainer = $Center/Card/Margin/VBox/Scroll/Form
@onready var footer_hbox: HBoxContainer = $Center/Card/Margin/VBox/Footer

@onready var music_label: Label = $Center/Card/Margin/VBox/Scroll/Form/MusicRow/Label
@onready var music_slider: HSlider = $Center/Card/Margin/VBox/Scroll/Form/MusicRow/Slider
@onready var music_val: Label = $Center/Card/Margin/VBox/Scroll/Form/MusicRow/Val

@onready var sfx_label: Label = $Center/Card/Margin/VBox/Scroll/Form/SfxRow/Label
@onready var sfx_slider: HSlider = $Center/Card/Margin/VBox/Scroll/Form/SfxRow/Slider
@onready var sfx_val: Label = $Center/Card/Margin/VBox/Scroll/Form/SfxRow/Val

@onready var audio_note_label: Label = $Center/Card/Margin/VBox/Scroll/Form/AudioNoteLabel

@onready var lang_label: Label = $Center/Card/Margin/VBox/Scroll/Form/LangRow/Label
@onready var lang_option: OptionButton = $Center/Card/Margin/VBox/Scroll/Form/LangRow/Option

@onready var control_label: Label = $Center/Card/Margin/VBox/Scroll/Form/ControlRow/Label
@onready var control_option: OptionButton = $Center/Card/Margin/VBox/Scroll/Form/ControlRow/Option

@onready var res_label: Label = $Center/Card/Margin/VBox/Scroll/Form/ResRow/Label
@onready var res_option: OptionButton = $Center/Card/Margin/VBox/Scroll/Form/ResRow/Option

@onready var quality_label: Label = $Center/Card/Margin/VBox/Scroll/Form/QualityRow/Label
@onready var quality_option: OptionButton = $Center/Card/Margin/VBox/Scroll/Form/QualityRow/Option

@onready var cam_sens_label: Label = $Center/Card/Margin/VBox/Scroll/Form/CameraSensRow/Label
@onready var cam_sens_slider: HSlider = $Center/Card/Margin/VBox/Scroll/Form/CameraSensRow/Slider
@onready var cam_sens_val: Label = $Center/Card/Margin/VBox/Scroll/Form/CameraSensRow/Val

@onready var fullscreen_check: CheckButton = $Center/Card/Margin/VBox/Scroll/Form/FullscreenCheck
@onready var reduced_motion_check: CheckButton = $Center/Card/Margin/VBox/Scroll/Form/ReducedMotionCheck

@onready var main_menu_btn: Button = $Center/Card/Margin/VBox/Footer/MainMenuBtn
@onready var save_btn: Button = $Center/Card/Margin/VBox/Footer/SaveBtn

var _master_label: Label
var _master_slider: HSlider
var _master_val: Label

var _voice_label: Label
var _voice_slider: HSlider
var _voice_val: Label

var _learn_label: Label
var _learn_slider: HSlider
var _learn_val: Label

var _speed_label: Label
var _speed_slider: HSlider
var _speed_val: Label

var _accent_label: Label
var _accent_option: OptionButton
var _reset_audio_btn: Button
var _about_title_label: Label
var _about_info_label: Label
var _privacy_info_label: Label


func _ready() -> void:
	visible = false
	card.add_theme_stylebox_override("panel", UIDesignSystem.make_panel_style(Color(0.08, 0.13, 0.24, 1.0), UIDesignSystem.BORDER_DEFAULT, 14, 2, 0, 0))
	UIDesignSystem.apply_button_variant(close_btn, "close")
	UIDesignSystem.apply_button_variant(main_menu_btn, "secondary")
	UIDesignSystem.apply_button_variant(save_btn, "confirm")
	for b: Button in [close_btn, main_menu_btn, save_btn]:
		UIAnimator.attach_button_feedback(b)

	_build_extended_audio_controls()

	lang_option.clear()
	lang_option.add_item("Tiếng Việt (Mặc định)", 0)
	lang_option.add_item("English", 1)

	control_option.clear()
	control_option.add_item("Tự động theo thiết bị", 0)
	control_option.add_item("Bàn phím & Chuột", 1)
	control_option.add_item("Cảm ứng (Joystick)", 2)

	res_option.clear()
	for idx in range(SettingsManager.RESOLUTION_PRESETS.size()):
		var sz: Vector2i = SettingsManager.RESOLUTION_PRESETS[idx]
		res_option.add_item("%d x %d" % [sz.x, sz.y], idx)

	quality_option.clear()
	quality_option.add_item("Thấp (Mobile / Tiết kiệm pin)", 0)
	quality_option.add_item("Trung bình (Cân bằng)", 1)
	quality_option.add_item("Cao (Bóng đổ & Hiệu ứng đầy đủ)", 2)

	music_slider.value_changed.connect(func(v: float) -> void:
		SettingsManager.music_volume = v
		music_val.text = "%d%%" % int(round(v * 100.0))
		EventBus.settings_changed.emit()
	)
	sfx_slider.value_changed.connect(func(v: float) -> void:
		SettingsManager.sfx_volume = v
		sfx_val.text = "%d%%" % int(round(v * 100.0))
		EventBus.settings_changed.emit()
	)
	lang_option.item_selected.connect(func(idx: int) -> void:
		SettingsManager.language = "en" if idx == 1 else "vi"
		LocalizationManager.set_locale(SettingsManager.language)
		_refresh_texts()
	)
	control_option.item_selected.connect(func(idx: int) -> void:
		var modes := ["auto", "keyboard", "touch"]
		SettingsManager.control_mode = modes[clampi(idx, 0, 2)]
		EventBus.settings_changed.emit()
	)
	res_option.item_selected.connect(func(idx: int) -> void:
		SettingsManager.resolution_index = idx
		SettingsManager.apply_settings()
	)
	quality_option.item_selected.connect(func(idx: int) -> void:
		var levels := ["low", "medium", "high"]
		SettingsManager.graphics_quality = levels[clampi(idx, 0, 2)]
		EventBus.settings_changed.emit()
	)
	cam_sens_slider.value_changed.connect(func(v: float) -> void:
		SettingsManager.camera_sensitivity = clampf(v, 0.4, 2.0)
		cam_sens_val.text = "%d%%" % int(round(SettingsManager.camera_sensitivity * 100.0))
		EventBus.settings_changed.emit()
	)
	fullscreen_check.toggled.connect(func(pressed: bool) -> void:
		SettingsManager.fullscreen = pressed
		SettingsManager.apply_settings()
	)
	reduced_motion_check.toggled.connect(func(pressed: bool) -> void:
		SettingsManager.reduced_motion = pressed
		EventBus.settings_changed.emit()
	)

	close_btn.pressed.connect(close_modal)
	save_btn.pressed.connect(_on_save_pressed)
	main_menu_btn.pressed.connect(_on_main_menu_pressed)
	EventBus.ui_locale_changed.connect(func(_l: String) -> void: _refresh_texts())
	EventBus.viewport_breakpoint_changed.connect(func(_b: String, _s: Vector2) -> void: _apply_responsive())


func _build_extended_audio_controls() -> void:
	# Master Volume row at top of Form
	var master_row := _make_slider_row("Âm lượng Tổng (Master)", 0.0, 1.0, 0.05)
	_master_label = master_row["label"]
	_master_slider = master_row["slider"]
	_master_val = master_row["val"]
	_master_slider.value_changed.connect(func(v: float) -> void:
		SettingsManager.master_volume = v
		_master_val.text = "%d%%" % int(round(v * 100.0))
		EventBus.settings_changed.emit()
	)
	form_vbox.add_child(master_row["row"])
	form_vbox.move_child(master_row["row"], 0)

	# Insert Voice, Learning Audio, Speech Speed, and Accent right before AudioNoteLabel
	var note_idx := audio_note_label.get_index()

	var voice_row := _make_slider_row("Giọng nói NPC", 0.0, 1.0, 0.05)
	_voice_label = voice_row["label"]
	_voice_slider = voice_row["slider"]
	_voice_val = voice_row["val"]
	_voice_slider.value_changed.connect(func(v: float) -> void:
		SettingsManager.voice_volume = v
		_voice_val.text = "%d%%" % int(round(v * 100.0))
		EventBus.settings_changed.emit()
	)
	form_vbox.add_child(voice_row["row"])
	form_vbox.move_child(voice_row["row"], note_idx)

	var learn_row := _make_slider_row("Âm thanh Học tập", 0.15, 1.0, 0.05)
	_learn_label = learn_row["label"]
	_learn_slider = learn_row["slider"]
	_learn_val = learn_row["val"]
	_learn_slider.value_changed.connect(func(v: float) -> void:
		SettingsManager.learning_audio_volume = clampf(v, 0.15, 1.0)
		_learn_val.text = "%d%%" % int(round(SettingsManager.learning_audio_volume * 100.0))
		EventBus.settings_changed.emit()
	)
	form_vbox.add_child(learn_row["row"])
	form_vbox.move_child(learn_row["row"], note_idx + 1)

	var speed_row := _make_slider_row("Tốc độ đọc tiếng Anh", 0.65, 1.15, 0.05)
	_speed_label = speed_row["label"]
	_speed_slider = speed_row["slider"]
	_speed_val = speed_row["val"]
	_speed_slider.value_changed.connect(func(v: float) -> void:
		SettingsManager.speech_rate = clampf(v, 0.65, 1.15)
		_speed_val.text = "%.2fx" % SettingsManager.speech_rate
		EventBus.settings_changed.emit()
	)
	form_vbox.add_child(speed_row["row"])
	form_vbox.move_child(speed_row["row"], note_idx + 2)

	var acc_row := HBoxContainer.new()
	acc_row.add_theme_constant_override("separation", 12)
	_accent_label = Label.new()
	_accent_label.custom_minimum_size = Vector2(180, 0)
	_accent_label.text = "Phương ngữ chuẩn"
	acc_row.add_child(_accent_label)
	_accent_option = OptionButton.new()
	_accent_option.custom_minimum_size = Vector2(0, 40)
	_accent_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_accent_option.add_item("English – US (Mặc định)", 0)
	_accent_option.add_item("English – UK", 1)
	_accent_option.item_selected.connect(func(idx: int) -> void:
		SettingsManager.preferred_accent = "en-GB" if idx == 1 else "en-US"
		EventBus.settings_changed.emit()
	)
	acc_row.add_child(_accent_option)
	form_vbox.add_child(acc_row)
	form_vbox.move_child(acc_row, note_idx + 3)

	_reset_audio_btn = Button.new()
	_reset_audio_btn.custom_minimum_size = Vector2(140, 44)
	_reset_audio_btn.text = "Mặc định âm thanh"
	UIDesignSystem.apply_button_variant(_reset_audio_btn, "secondary")
	UIAnimator.attach_button_feedback(_reset_audio_btn)
	_reset_audio_btn.pressed.connect(func() -> void:
		SettingsManager.reset_audio_defaults()
		_sync_from_settings()
		EventBus.toast_requested.emit("Đã khôi phục cài đặt âm thanh mặc định!", "info")
	)
	footer_hbox.add_child(_reset_audio_btn)
	footer_hbox.move_child(_reset_audio_btn, 0)

	# Release Version, About & Child Privacy section at the bottom of Settings Form
	var about_sep := HSeparator.new()
	form_vbox.add_child(about_sep)

	_about_title_label = Label.new()
	_about_title_label.add_theme_font_size_override("font_size", 15)
	_about_title_label.add_theme_color_override("font_color", UIDesignSystem.TEXT_GOLD)
	form_vbox.add_child(_about_title_label)

	_about_info_label = Label.new()
	_about_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_about_info_label.add_theme_font_size_override("font_size", 13)
	form_vbox.add_child(_about_info_label)

	_privacy_info_label = Label.new()
	_privacy_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_privacy_info_label.add_theme_font_size_override("font_size", 12)
	_privacy_info_label.add_theme_color_override("font_color", Color(0.76, 0.85, 0.96, 1.0))
	form_vbox.add_child(_privacy_info_label)


func _make_slider_row(label_text: String, min_v: float, max_v: float, step_v: float) -> Dictionary:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var lbl := Label.new()
	lbl.custom_minimum_size = Vector2(180, 0)
	lbl.text = label_text
	row.add_child(lbl)

	var sl := HSlider.new()
	sl.custom_minimum_size = Vector2(0, 28)
	sl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sl.min_value = min_v
	sl.max_value = max_v
	sl.step = step_v
	row.add_child(sl)

	var val := Label.new()
	val.custom_minimum_size = Vector2(54, 0)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(val)
	return { "row": row, "label": lbl, "slider": sl, "val": val }


func open_modal(show_main_menu_button: bool = true) -> void:
	main_menu_btn.visible = show_main_menu_button
	_apply_responsive()
	_sync_from_settings()
	_refresh_texts()
	visible = true
	UIAnimator.animate_popup_open(card)


func _apply_responsive() -> void:
	var vp := get_viewport().get_visible_rect().size
	var cw := minf(600.0, vp.x - 28.0)
	var ch := minf(520.0, vp.y - 32.0)
	card.custom_minimum_size = Vector2(cw, ch)
	card_vbox.custom_minimum_size = Vector2(maxf(260.0, cw - 44.0), maxf(240.0, ch - 36.0))


func close_modal() -> void:
	UIAnimator.animate_popup_close(card, func() -> void:
		visible = false
		closed.emit()
	)


func _sync_from_settings() -> void:
	_master_slider.value = SettingsManager.master_volume
	_master_val.text = "%d%%" % int(round(SettingsManager.master_volume * 100.0))
	music_slider.value = SettingsManager.music_volume
	music_val.text = "%d%%" % int(round(SettingsManager.music_volume * 100.0))
	sfx_slider.value = SettingsManager.sfx_volume
	sfx_val.text = "%d%%" % int(round(SettingsManager.sfx_volume * 100.0))
	_voice_slider.value = SettingsManager.voice_volume
	_voice_val.text = "%d%%" % int(round(SettingsManager.voice_volume * 100.0))
	_learn_slider.value = SettingsManager.learning_audio_volume
	_learn_val.text = "%d%%" % int(round(SettingsManager.learning_audio_volume * 100.0))
	_speed_slider.value = SettingsManager.speech_rate
	_speed_val.text = "%.2fx" % SettingsManager.speech_rate
	_accent_option.selected = 1 if SettingsManager.preferred_accent == "en-GB" else 0

	lang_option.selected = 1 if SettingsManager.language == "en" else 0
	var mode_idx := ["auto", "keyboard", "touch"].find(SettingsManager.control_mode)
	control_option.selected = maxi(0, mode_idx)
	res_option.selected = clampi(SettingsManager.resolution_index, 0, SettingsManager.RESOLUTION_PRESETS.size() - 1)
	res_option.disabled = not SettingsManager.supports_resolution_change()
	var q_idx := ["low", "medium", "high"].find(SettingsManager.graphics_quality)
	quality_option.selected = maxi(0, q_idx)
	cam_sens_slider.value = SettingsManager.camera_sensitivity
	cam_sens_val.text = "%d%%" % int(round(SettingsManager.camera_sensitivity * 100.0))

	fullscreen_check.button_pressed = SettingsManager.fullscreen
	fullscreen_check.disabled = not SettingsManager.supports_fullscreen_toggle()
	reduced_motion_check.button_pressed = SettingsManager.reduced_motion


func _refresh_texts() -> void:
	var is_en: bool = str(LocalizationManager.get_locale()) == "en"
	title_label.text = LocalizationManager.tr_key("settings_title", "CÀI ĐẶT TRÒ CHƠI")
	close_btn.text = LocalizationManager.tr_key("btn_close", "Đóng")
	_master_label.text = LocalizationManager.tr_key("settings_master", "Âm lượng Tổng (Master)")
	music_label.text = LocalizationManager.tr_key("settings_music", "Âm lượng Nhạc nền")
	sfx_label.text = LocalizationManager.tr_key("settings_sfx", "Âm lượng Hiệu ứng")
	_voice_label.text = LocalizationManager.tr_key("settings_voice", "Giọng nói NPC")
	_learn_label.text = LocalizationManager.tr_key("settings_learning_audio", "Âm thanh Học tập")
	_speed_label.text = LocalizationManager.tr_key("settings_speech_rate", "Tốc độ đọc tiếng Anh")
	_accent_label.text = LocalizationManager.tr_key("settings_accent", "Phương ngữ chuẩn")
	_reset_audio_btn.text = LocalizationManager.tr_key("settings_reset_audio", "Mặc định âm thanh")
	lang_label.text = LocalizationManager.tr_key("settings_language", "Ngôn ngữ hướng dẫn")
	control_label.text = LocalizationManager.tr_key("settings_controls", "Chế độ điều khiển")
	res_label.text = LocalizationManager.tr_key("settings_resolution", "Độ phân giải")
	quality_label.text = LocalizationManager.tr_key("settings_graphics_quality", "Chất lượng đồ họa 3D")
	cam_sens_label.text = LocalizationManager.tr_key("settings_camera_sensitivity", "Độ nhạy Camera 3D")
	if quality_option.item_count >= 3:
		if is_en:
			quality_option.set_item_text(0, "Low (Mobile / Battery Saver)")
			quality_option.set_item_text(1, "Medium (Balanced)")
			quality_option.set_item_text(2, "High (Full Shadows & Effects)")
		else:
			quality_option.set_item_text(0, "Thấp (Mobile / Tiết kiệm pin)")
			quality_option.set_item_text(1, "Trung bình (Cân bằng)")
			quality_option.set_item_text(2, "Cao (Bóng đổ & Hiệu ứng đầy đủ)")
	fullscreen_check.text = LocalizationManager.tr_key("settings_fullscreen", "Toàn màn hình")
	reduced_motion_check.text = LocalizationManager.tr_key("settings_reduced_motion", "Giảm hiệu ứng chuyển động")
	save_btn.text = LocalizationManager.tr_key("settings_save", "Lưu cài đặt")
	main_menu_btn.text = LocalizationManager.tr_key("settings_main_menu", "Về Menu Chính")
	audio_note_label.visible = true
	audio_note_label.text = LocalizationManager.tr_key("settings_audio_learning_note", AudioManager.missing_audio_notice)
	if _about_title_label != null:
		_about_title_label.text = "Version & Child Privacy" if is_en else "Phiên bản & Quyền riêng tư trẻ em"
	if _about_info_label != null:
		_about_info_label.text = ReleaseInfo.get_about_summary_en() if is_en else ReleaseInfo.get_about_summary_vi()
	if _privacy_info_label != null:
		_privacy_info_label.text = (
			"Save storage: local offline profile (user://). Sync: %s" % SaveLoadManager.get_sync_status_summary()
			if is_en else
			"Lưu tiến trình cục bộ (Offline-First). Trạng thái: %s" % SaveLoadManager.get_sync_status_summary()
		)


func _on_save_pressed() -> void:
	if SettingsManager.save_settings():
		EventBus.toast_requested.emit(LocalizationManager.tr_key("settings_saved_toast", "Đã lưu cài đặt!"), "success")


func _on_main_menu_pressed() -> void:
	close_modal()
	main_menu_requested.emit()
