class_name WorldCardWidget
extends PanelContainer
## Reusable World / Area Card displaying status icon, title, subtitle, and selection feedback.

signal selected(card_id: String)

var card_id: String = ""
var _btn: Button = null


func setup_world_entry(id_str: String, title_str: String, subtitle_str: String, is_active: bool, is_locked: bool) -> void:
	card_id = id_str
	for c in get_children():
		c.queue_free()

	var border_col := UIDesignSystem.PRIMARY if is_active else UIDesignSystem.LOCKED_DARK
	add_theme_stylebox_override("panel", UIDesignSystem.make_panel_style(Color(0.11, 0.17, 0.30, 0.96), border_col, 10, 2, 8, 6))

	_btn = Button.new()
	_btn.flat = true
	_btn.custom_minimum_size = Vector2(180, 42)
	_btn.text = ("%s (%s)" % [title_str, subtitle_str]) if not subtitle_str.is_empty() else title_str
	_btn.disabled = is_locked
	if is_active:
		UIDesignSystem.apply_button_variant(_btn, "primary")
	else:
		UIDesignSystem.apply_button_variant(_btn, "disabled" if is_locked else "secondary")
	UIAnimator.attach_button_feedback(_btn)
	_btn.pressed.connect(func() -> void: selected.emit(card_id))
	add_child(_btn)
