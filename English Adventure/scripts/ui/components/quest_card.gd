class_name QuestCardWidget
extends PanelContainer
## Reusable Quest Card displaying Quest Name, Description, Giver NPC Avatar,
## Objectives, Step Progress, Rewards, and Locked/Available/Active/Completed state.

@onready var npc_avatar: TextureRect = $Margin/VBox/Header/NpcAvatar
@onready var title_label: Label = $Margin/VBox/Header/TitleCol/TitleLabel
@onready var giver_label: Label = $Margin/VBox/Header/TitleCol/GiverLabel
@onready var status_badge: Label = $Margin/VBox/Header/StatusBadge
@onready var desc_label: Label = $Margin/VBox/DescLabel
@onready var progress_bar: ProgressBar = $Margin/VBox/ProgressRow/ProgressBar
@onready var progress_label: Label = $Margin/VBox/ProgressRow/ProgressLabel
@onready var objectives_box: VBoxContainer = $Margin/VBox/ObjectivesBox
@onready var rewards_row: RewardDisplay = $Margin/VBox/RewardsRow


func setup_quest(quest_data: Dictionary) -> void:
	var qid := str(quest_data.get("id", ""))
	var status := QuestManager.get_quest_status(qid)

	var giver_id := str(quest_data.get("giver_npc_id", ""))
	var giver_cfg: Dictionary = DataRepository.npcs_by_id.get(giver_id, {})
	var portrait_path := str(giver_cfg.get("sprite_path", "res://assets/characters/npcs/professor_owl.svg"))
	if ResourceLoader.exists(portrait_path):
		npc_avatar.texture = load(portrait_path)

	title_label.text = "%s (%s)" % [str(quest_data.get("title_vi", qid)), str(quest_data.get("title_en", ""))]
	giver_label.text = "Người giao: %s" % str(giver_cfg.get("name_vi", giver_id))
	desc_label.text = LocalizationManager.pick_text(quest_data, "description")

	var status_info := _status_visual(status)
	status_badge.text = str(status_info["label"])
	status_badge.add_theme_color_override("font_color", status_info["color"])

	var border_col: Color = status_info["border"]
	add_theme_stylebox_override("panel", UIDesignSystem.make_panel_style(Color(0.11, 0.18, 0.31, 0.96), border_col, 12, 2, 0, 0))

	var steps: Array = quest_data.get("steps", [])
	var total_steps := maxi(1, steps.size())
	var current_idx := 0
	if status == "completed":
		current_idx = total_steps
	elif status == "active":
		var q_state: Dictionary = GameStateManager.active_quests.get(qid, {})
		current_idx = clampi(int(q_state.get("step_index", 0)), 0, total_steps)

	progress_bar.max_value = float(total_steps)
	progress_bar.value = float(current_idx)
	progress_label.text = "%d/%d" % [current_idx, total_steps]

	for c in objectives_box.get_children():
		c.queue_free()
	for i in range(steps.size()):
		var st: Dictionary = steps[i]
		var step_lbl := Label.new()
		step_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		step_lbl.add_theme_font_size_override("font_size", 14)
		var mark := "[ ]"
		var col := UIDesignSystem.TEXT_MUTED
		if status == "completed" or i < current_idx:
			mark = "[OK]"
			col = UIDesignSystem.SUCCESS
		elif status == "active" and i == current_idx:
			mark = "[>>]"
			col = UIDesignSystem.SECONDARY_LIGHT
		step_lbl.text = "%s %s" % [mark, LocalizationManager.pick_text(st, "title")]
		step_lbl.add_theme_color_override("font_color", col)
		objectives_box.add_child(step_lbl)

	var rewards: Dictionary = quest_data.get("rewards", {})
	rewards_row.set_rewards(rewards)


func _status_visual(status: String) -> Dictionary:
	match status:
		"completed":
			return {
				"label": "[OK] " + LocalizationManager.tr_key("quest_completed", "Đã hoàn thành"),
				"color": UIDesignSystem.SUCCESS,
				"border": UIDesignSystem.SUCCESS
			}
		"active":
			return {
				"label": "[>>] " + LocalizationManager.tr_key("quest_active", "Đang thực hiện"),
				"color": UIDesignSystem.SECONDARY_LIGHT,
				"border": UIDesignSystem.SECONDARY
			}
		"available":
			return {
				"label": "[!] " + LocalizationManager.tr_key("quest_available", "Có thể nhận"),
				"color": UIDesignSystem.PRIMARY_LIGHT,
				"border": UIDesignSystem.PRIMARY
			}
		_:
			return {
				"label": "[Khóa] " + LocalizationManager.tr_key("quest_locked", "Chưa mở"),
				"color": UIDesignSystem.LOCKED,
				"border": UIDesignSystem.LOCKED_DARK
			}
