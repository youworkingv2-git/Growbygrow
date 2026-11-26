extends Control
## World Map Screen for Alphabet Island: displays all 5 areas, status badges,
## area detail panel, and blocks locked area entry.

var selected_area_id: String = "welcome_village"

@onready var area_buttons_container: HBoxContainer = %AreaButtonsContainer
@onready var detail_title: Label = %DetailTitle
@onready var detail_status: Label = %DetailStatus
@onready var detail_desc: Label = %DetailDesc
@onready var enter_btn: Button = %EnterAreaButton
@onready var stats_label: Label = %StatsLabel
@onready var quest_label: Label = %QuestSummaryLabel
@onready var lock_warning: Label = %LockWarningLabel

func _ready() -> void:
	enter_btn.pressed.connect(_on_enter_area_pressed)
	if lock_warning != null:
		lock_warning.visible = false
	_populate_map()
	_update_header_stats()
	_select_area(SaveManager.player_data.get("current_area_id", "welcome_village"))

func _populate_map() -> void:
	for child in area_buttons_container.get_children():
		child.queue_free()

	for area in GameManager.get_all_areas():
		var aid: String = area["id"]
		var status := GameManager.get_area_status(aid)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(190, 96)
		var icon_txt := "🔒 " if status == "Locked" else ("✅ " if status == "Completed" else "🏝️ ")
		btn.text = "%s%s\n[%s]" % [icon_txt, area["name_en"], status]
		btn.pressed.connect(func(): _select_area(aid))
		area_buttons_container.add_child(btn)

func _select_area(area_id: String) -> void:
	selected_area_id = area_id
	var info := GameManager.get_area_info(area_id)
	var status := GameManager.get_area_status(area_id)
	detail_title.text = "%s (%s)" % [info.get("name_en", ""), info.get("name_vi", "")]
	detail_status.text = "Trạng thái: " + status
	detail_desc.text = info.get("description_vi", "")

	if status == "Locked":
		enter_btn.disabled = true
		enter_btn.text = "🔒 Khu vực đang khóa"
		if lock_warning != null:
			lock_warning.visible = true
			lock_warning.text = "Hãy hoàn thành nhiệm vụ trước để mở khóa khu vực này!"
	else:
		enter_btn.disabled = false
		enter_btn.text = "Khám phá ngay!"
		if lock_warning != null:
			lock_warning.visible = false

func _on_enter_area_pressed() -> void:
	GameManager.enter_area(selected_area_id)

func _update_header_stats() -> void:
	var p := SaveManager.player_data
	stats_label.text = "👤 %s  |  ⭐ EXP: %d  |  🪙 Gold: %d  |  💎 Crystals: %d" % [
		p.get("player_name", "Adventurer"),
		p.get("exp", 0),
		p.get("gold", 0),
		p.get("magic_crystals", 0)
	]
	var q := QuestManager.get_active_quest_summary()
	if q.is_empty():
		quest_label.text = "🎉 Bạn đã hoàn thành tất cả nhiệm vụ mẫu của Alphabet Island!"
	else:
		quest_label.text = "📜 %s (%d/%d): %s" % [
			q["name_vi"],
			q["step_index"] + 1,
			q["total_steps"],
			q["step_description_vi"]
		]
