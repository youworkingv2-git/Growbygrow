class_name RewardDisplay
extends HFlowContainer
## Reusable Reward Display showing real EXP, Gold, Magic Crystals, and Item badges.

const ICON_GOLD := preload("res://assets/icons/gold_icon.svg")
const ICON_CRYSTAL := preload("res://assets/icons/crystal_icon.svg")
const ICON_STAR := preload("res://assets/environments/alphabet_island/magic_crystal.svg")


func set_rewards(rewards: Dictionary) -> void:
	for c in get_children():
		c.queue_free()

	var exp_val := int(rewards.get("exp", 0))
	var gold_val := int(rewards.get("gold", 0))
	var crystal_val := int(rewards.get("crystals", 0))
	var stars_val := int(rewards.get("stars", 0))
	var items: Array = rewards.get("items", [])

	for it_var in items:
		if typeof(it_var) == TYPE_DICTIONARY and str(it_var.get("id", "")).contains("crystal"):
			crystal_val += int(it_var.get("quantity", 1))

	if stars_val > 0:
		_add_badge(null, "Sao: +%d" % stars_val, UIDesignSystem.REWARD)
	if exp_val > 0:
		_add_badge(null, "+%d EXP" % exp_val, UIDesignSystem.PRIMARY_LIGHT)
	if gold_val > 0:
		_add_badge(ICON_GOLD, "+%d Gold" % gold_val, UIDesignSystem.SECONDARY_LIGHT)
	if crystal_val > 0:
		_add_badge(ICON_CRYSTAL, "+%d Pha lê" % crystal_val, UIDesignSystem.CRYSTAL)

	for it_var in items:
		if typeof(it_var) == TYPE_DICTIONARY:
			var iid := str(it_var.get("id", ""))
			if iid.contains("crystal"):
				continue
			var name_txt := LocalizationManager.pick_text(it_var, "name")
			if name_txt.is_empty():
				name_txt = str(it_var.get("name_vi", iid))
			_add_badge(ICON_STAR, "%s x%d" % [name_txt, int(it_var.get("quantity", 1))], UIDesignSystem.TEXT_LIGHT)


func _add_badge(icon_tex: Texture2D, text_str: String, text_col: Color) -> void:
	var chip := PanelContainer.new()
	chip.add_theme_stylebox_override(
		"panel",
		UIDesignSystem.make_panel_style(Color(0.11, 0.19, 0.33, 0.96), Color(0.32, 0.5, 0.78, 0.8), 10, 1, 10, 5)
	)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	if icon_tex != null:
		var tr := TextureRect.new()
		tr.custom_minimum_size = Vector2(20, 20)
		tr.texture = icon_tex
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(tr)
	var lbl := Label.new()
	lbl.text = text_str
	lbl.add_theme_color_override("font_color", text_col)
	lbl.add_theme_font_size_override("font_size", 14)
	row.add_child(lbl)
	chip.add_child(row)
	add_child(chip)
