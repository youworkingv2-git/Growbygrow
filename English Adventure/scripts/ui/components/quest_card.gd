class_name QuestCardWidget
extends PanelContainer
## Reusable Quest Card displaying Quest Type (Main/Side), Name, Description,
## Giver NPC Avatar, Objectives with numeric progress (3/5), Learning Objectives,
## Rewards, and Locked/Available/Accepted/InProgress/Completed/Claimed state.

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
	var detailed := QuestManager.get_detailed_quest_status(qid)
	var qtype := str(quest_data.get("quest_type", "main"))
	var type_tag := "[Phụ] " if qtype == "side" else "[Chính] "

	var giver_id := str(quest_data.get("giver_npc_id", ""))
	var giver_cfg: Dictionary = DataRepository.npcs_by_id.get(giver_id, {})
	var portrait_path := str(giver_cfg.get("sprite_path", "res://assets/characters/npcs/professor_owl.svg"))
	if ResourceLoader.exists(portrait_path):
		npc_avatar.texture = load(portrait_path)

	title_label.text = "%s%s (%s)" % [type_tag, str(quest_data.get("title_vi", qid)), str(quest_data.get("title_en", ""))]
	giver_label.text = "Người giao: %s" % str(giver_cfg.get("name_vi", giver_id))
	desc_label.text = LocalizationManager.pick_text(quest_data, "description")

	var status_info := _status_visual(detailed)
	status_badge.text = str(status_info["label"])
	status_badge.add_theme_color_override("font_color", status_info["color"])

	var border_col: Color = status_info["border"]
	add_theme_stylebox_override("panel", UIDesignSystem.make_panel_style(Color(0.11, 0.18, 0.31, 0.96), border_col, 12, 2, 0, 0))

	var steps: Array = quest_data.get("steps", [])
	var total_steps := maxi(1, steps.size())
	var done_steps := 0
	for st_var in steps:
		if typeof(st_var) != TYPE_DICTIONARY:
			continue
		var st: Dictionary = st_var
		var prog := QuestManager.get_objective_progress(qid, str(st.get("id", "")))
		if detailed in ["completed", "claimed"] or bool(prog.get("completed", false)):
			done_steps += 1

	progress_bar.max_value = float(total_steps)
	progress_bar.value = float(done_steps)
	progress_label.text = "%d/%d" % [done_steps, total_steps]

	for c in objectives_box.get_children():
		c.queue_free()
	for i in range(steps.size()):
		var st: Dictionary = steps[i]
		if bool(st.get("hidden", false)) and detailed in ["locked", "available"]:
			continue
		var sid := str(st.get("id", ""))
		var prog := QuestManager.get_objective_progress(qid, sid)
		var cur_n := int(prog.get("current", 0))
		var tgt_n := int(prog.get("target", 1))
		var is_done := (detailed in ["completed", "claimed"]) or bool(prog.get("completed", false))
		var step_lbl := Label.new()
		step_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		step_lbl.add_theme_font_size_override("font_size", 14)
		var mark := "[ ]"
		var col := UIDesignSystem.TEXT_MUTED
		if is_done:
			mark = "[OK]"
			col = UIDesignSystem.SUCCESS
		elif detailed in ["accepted", "in_progress"]:
			mark = "[>>]"
			col = UIDesignSystem.SECONDARY_LIGHT
		var count_txt := " (%d/%d)" % [tgt_n if is_done else cur_n, tgt_n] if tgt_n > 1 else ""
		var opt_txt := " (Phụ)" if bool(st.get("optional", false)) else ""
		step_lbl.text = "%s %s%s%s" % [mark, LocalizationManager.pick_text(st, "title"), count_txt, opt_txt]
		step_lbl.add_theme_color_override("font_color", col)
		objectives_box.add_child(step_lbl)

	var learn_objs: Array = quest_data.get("learning_objectives_vi", [])
	if not learn_objs.is_empty():
		var lo_lbl := Label.new()
		lo_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lo_lbl.add_theme_font_size_override("font_size", 13)
		lo_lbl.add_theme_color_override("font_color", Color(0.56, 0.86, 1.0, 1))
		lo_lbl.text = "Mục tiêu tiếng Anh: " + "; ".join(learn_objs)
		objectives_box.add_child(lo_lbl)

	var rewards: Dictionary = quest_data.get("rewards", {})
	rewards_row.set_rewards(rewards)


func _status_visual(status: String) -> Dictionary:
	match status:
		"claimed":
			return {
				"label": "[OK] " + LocalizationManager.tr_key("quest_claimed", "Đã nhận thưởng"),
				"color": UIDesignSystem.SUCCESS,
				"border": UIDesignSystem.SUCCESS
			}
		"completed":
			return {
				"label": "[!] " + LocalizationManager.tr_key("quest_completed", "Chờ nhận thưởng"),
				"color": Color(0.99, 0.84, 0.25, 1),
				"border": Color(0.99, 0.84, 0.25, 1)
			}
		"accepted", "in_progress":
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
