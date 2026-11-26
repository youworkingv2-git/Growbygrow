class_name SettingsModalUI
extends Control
## Shared Settings Screen (#17): Music & SFX sliders, Language, Fullscreen,
## Desktop Resolution, Control Mode, Reduced Motion, Save Settings, and Back to Main Menu.

signal closed()
signal main_menu_requested()

@onready var card: PanelContainer = $Center/Card
@onready var card_vbox: VBoxContainer = $Center/Card/Margin/VBox
@onready var title_label: Label = $Center/Card/Margin/VBox/Header/TitleLabel
@onready var close_btn: Button = $Center/Card/Margin/VBox/Header/CloseBtn

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

@onready var fullscreen_check: CheckButton = $Center/Card/Margin/VBox/Scroll/Form/FullscreenCheck
@onready var reduced_motion_check: CheckButton = $Center/Card/Margin/VBox/Scroll/Form/ReducedMotionCheck

@onready var main_menu_btn: Button = $Center/Card/Margin/VBox/Footer/MainMenuBtn
@onready var save_btn: Button = $Center/Card/Margin/VBox/Footer/SaveBtn


func _ready() -> void:
	visible = false
	UIDesignSystem.apply_button_variant(close_btn, "close")
	UIDesignSystem.apply_button_variant(main_menu_btn, "secondary")
	UIDesignSystem.apply_button_variant(save_btn, "confirm")
	for b: Button in [close_btn, main_menu_btn, save_btn]:
		UIAnimator.attach_button_feedback(b)

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

	music_slider.value_changed.connect(func(v: float) -> void:
		SettingsManager.music_volume = v
		music_val.text = "%d%%" % int(round(v * 100.0))
		AudioManager.set_bus_linear_volume(AudioServer.get_bus_index(AudioManager.BUS_MUSIC), v)
	)
	sfx_slider.value_changed.connect(func(v: float) -> void:
		SettingsManager.sfx_volume = v
		sfx_val.text = "%d%%" % int(round(v * 100.0))
		AudioManager.set_bus_linear_volume(AudioServer.get_bus_index(AudioManager.BUS_SFX), v)
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


func open_modal(show_main_menu_button: bool = true) -> void:
	main_menu_btn.visible = show_main_menu_button
	_apply_responsive()
	_sync_from_settings()
	_refresh_texts()
	visible = true
	UIAnimator.animate_popup_open(card)


func _apply_responsive() -> void:
	var vp := get_viewport().get_visible_rect().size
	var cw := minf(540.0, vp.x - 28.0)
	var ch := minf(430.0, vp.y - 32.0)
	card.custom_minimum_size = Vector2(cw, ch)
	card_vbox.custom_minimum_size = Vector2(maxf(260.0, cw - 44.0), maxf(240.0, ch - 36.0))


func close_modal() -> void:
	UIAnimator.animate_popup_close(card, func() -> void:
		visible = false
		closed.emit()
	)


func _sync_from_settings() -> void:
	music_slider.value = SettingsManager.music_volume
	music_val.text = "%d%%" % int(round(SettingsManager.music_volume * 100.0))
	sfx_slider.value = SettingsManager.sfx_volume
	sfx_val.text = "%d%%" % int(round(SettingsManager.sfx_volume * 100.0))

	lang_option.selected = 1 if SettingsManager.language == "en" else 0
	var mode_idx := ["auto", "keyboard", "touch"].find(SettingsManager.control_mode)
	control_option.selected = maxi(0, mode_idx)
	res_option.selected = clampi(SettingsManager.resolution_index, 0, SettingsManager.RESOLUTION_PRESETS.size() - 1)
	res_option.disabled = not SettingsManager.supports_resolution_change()

	fullscreen_check.button_pressed = SettingsManager.fullscreen
	fullscreen_check.disabled = not SettingsManager.supports_fullscreen_toggle()
	reduced_motion_check.button_pressed = SettingsManager.reduced_motion


func _refresh_texts() -> void:
	title_label.text = LocalizationManager.tr_key("settings_title", "CÀI ĐẶT TRÒ CHƠI")
	close_btn.text = LocalizationManager.tr_key("btn_close", "Đóng")
	music_label.text = LocalizationManager.tr_key("settings_music", "Âm lượng Nhạc nền")
	sfx_label.text = LocalizationManager.tr_key("settings_sfx", "Âm lượng Hiệu ứng")
	lang_label.text = LocalizationManager.tr_key("settings_language", "Ngôn ngữ hướng dẫn")
	control_label.text = LocalizationManager.tr_key("settings_controls", "Chế độ điều khiển")
	res_label.text = LocalizationManager.tr_key("settings_resolution", "Độ phân giải")
	fullscreen_check.text = LocalizationManager.tr_key("settings_fullscreen", "Toàn màn hình")
	reduced_motion_check.text = LocalizationManager.tr_key("settings_reduced_motion", "Giảm hiệu ứng chuyển động")
	save_btn.text = LocalizationManager.tr_key("settings_save", "Lưu cài đặt")
	main_menu_btn.text = LocalizationManager.tr_key("settings_main_menu", "Về Menu Chính")
	audio_note_label.visible = not AudioManager.has_bundled_audio_assets
	audio_note_label.text = LocalizationManager.tr_key("settings_audio_missing", AudioManager.missing_audio_notice)


func _on_save_pressed() -> void:
	if SettingsManager.save_settings():
		EventBus.toast_requested.emit(LocalizationManager.tr_key("settings_saved_toast", "Đã lưu cài đặt!"), "success")


func _on_main_menu_pressed() -> void:
	close_modal()
	main_menu_requested.emit()
