class_name AdventureConfirmDialog
extends Control
## Reusable Confirmation Dialog for important or destructive actions (New Game overwrite, Quit, Save & Exit).

signal confirmed()
signal cancelled()

@onready var card: PanelContainer = $Center/Card
@onready var title_label: Label = $Center/Card/Margin/VBox/TitleLabel
@onready var body_label: Label = $Center/Card/Margin/VBox/BodyLabel
@onready var cancel_btn: Button = $Center/Card/Margin/VBox/Buttons/CancelBtn
@onready var confirm_btn: Button = $Center/Card/Margin/VBox/Buttons/ConfirmBtn


func _ready() -> void:
	visible = false
	card.add_theme_stylebox_override("panel", UIDesignSystem.make_panel_style(Color(0.08, 0.13, 0.24, 1.0), UIDesignSystem.BORDER_DEFAULT, 14, 2, 0, 0))
	UIDesignSystem.apply_button_variant(cancel_btn, "secondary")
	UIDesignSystem.apply_button_variant(confirm_btn, "confirm")
	UIAnimator.attach_button_feedback(cancel_btn)
	UIAnimator.attach_button_feedback(confirm_btn)
	cancel_btn.pressed.connect(_on_cancel)
	confirm_btn.pressed.connect(_on_confirm)


func show_dialog(title_text: String, body_text: String, confirm_text: String = "", cancel_text: String = "", danger: bool = false) -> void:
	title_label.text = title_text
	body_label.text = body_text
	confirm_btn.text = confirm_text if not confirm_text.is_empty() else LocalizationManager.tr_key("btn_yes_confirm", "Đồng ý")
	cancel_btn.text = cancel_text if not cancel_text.is_empty() else LocalizationManager.tr_key("btn_cancel", "Hủy bỏ")
	UIDesignSystem.apply_button_variant(confirm_btn, "close" if danger else "confirm")
	visible = true
	UIAnimator.animate_popup_open(card)


func _on_confirm() -> void:
	UIAnimator.animate_popup_close(card, func() -> void:
		visible = false
		confirmed.emit()
	)


func _on_cancel() -> void:
	UIAnimator.animate_popup_close(card, func() -> void:
		visible = false
		cancelled.emit()
	)
