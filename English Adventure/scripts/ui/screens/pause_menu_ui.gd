class_name PauseMenuUI
extends Control
## Pause Menu (#12): Resume, World Map, Quest Log, Settings, and safe Save & Exit.

signal resumed()
signal world_map_requested()
signal quests_requested()
signal settings_requested()
signal save_and_exit_requested()

@onready var card: PanelContainer = $Center/Card
@onready var title_label: Label = $Center/Card/Margin/VBox/TitleLabel
@onready var resume_btn: Button = $Center/Card/Margin/VBox/Buttons/ResumeBtn
@onready var map_btn: Button = $Center/Card/Margin/VBox/Buttons/MapBtn
@onready var quests_btn: Button = $Center/Card/Margin/VBox/Buttons/QuestsBtn
@onready var settings_btn: Button = $Center/Card/Margin/VBox/Buttons/SettingsBtn
@onready var save_exit_btn: Button = $Center/Card/Margin/VBox/Buttons/SaveExitBtn


func _ready() -> void:
	visible = false
	UIDesignSystem.apply_button_variant(resume_btn, "confirm")
	UIDesignSystem.apply_button_variant(map_btn, "primary")
	UIDesignSystem.apply_button_variant(quests_btn, "secondary")
	UIDesignSystem.apply_button_variant(settings_btn, "secondary")
	UIDesignSystem.apply_button_variant(save_exit_btn, "reward")
	for b: Button in [resume_btn, map_btn, quests_btn, settings_btn, save_exit_btn]:
		UIAnimator.attach_button_feedback(b)

	resume_btn.pressed.connect(close_pause)
	map_btn.pressed.connect(func() -> void:
		close_pause()
		world_map_requested.emit()
	)
	quests_btn.pressed.connect(func() -> void:
		close_pause()
		quests_requested.emit()
	)
	settings_btn.pressed.connect(func() -> void:
		settings_requested.emit()
	)
	save_exit_btn.pressed.connect(func() -> void:
		save_and_exit_requested.emit()
	)
	EventBus.ui_locale_changed.connect(func(_l: String) -> void: _refresh_texts())


func open_pause() -> void:
	_refresh_texts()
	visible = true
	EventBus.pause_toggled.emit(true)
	UIAnimator.animate_popup_open(card)


func close_pause() -> void:
	UIAnimator.animate_popup_close(card, func() -> void:
		visible = false
		EventBus.pause_toggled.emit(false)
		resumed.emit()
	)


func _refresh_texts() -> void:
	title_label.text = LocalizationManager.tr_key("pause_title", "TẠM DỪNG")
	resume_btn.text = LocalizationManager.tr_key("pause_resume", "Tiếp tục chơi")
	map_btn.text = LocalizationManager.tr_key("pause_map", "Bản đồ Đảo")
	quests_btn.text = LocalizationManager.tr_key("pause_quests", "Sổ tay Nhiệm vụ")
	settings_btn.text = LocalizationManager.tr_key("pause_settings", "Cài đặt")
	save_exit_btn.text = LocalizationManager.tr_key("pause_save_exit", "Lưu & Về Menu Chính")
