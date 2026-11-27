class_name BuddyController
extends Node3D
## 3D Companion Dragon Buddy with 7 expression states, wing-flapping & tail-wag animation,
## smooth 3D follow behavior, bilingual tips, and reactive learning/quest feedback.

enum BuddyMood { IDLE, HAPPY, SAD, SURPRISED, THINKING, TALKING, CELEBRATING }

@export var follow_offset: Vector3 = Vector3(-1.45, 1.35, 0.0)
@export var follow_speed: float = 5.5

var current_mood: BuddyMood = BuddyMood.IDLE
var target_node: Node3D = null
var _hover_time: float = 0.0
var _rig: CharacterRig3D = null
var _is_speaking_audio: bool = false

@onready var visual_slot: Asset3DSlot = $VisualSlot
@onready var speech_layer: CanvasLayer = $SpeechLayer
@onready var mood_badge: Label = $SpeechLayer/MoodBadge
@onready var speech_panel: PanelContainer = $SpeechLayer/SpeechBubble
@onready var speech_label: Label = $SpeechLayer/SpeechBubble/Margin/Label
@onready var hide_timer: Timer = $HideSpeechTimer


func _ready() -> void:
	speech_panel.visible = false
	mood_badge.visible = false
	hide_timer.timeout.connect(func() -> void: speech_panel.visible = false)

	var cfg := DataRepository.buddy_config
	var override_glb := str(cfg.get("model_3d_path", ""))
	if not override_glb.is_empty():
		visual_slot.override_model_path = override_glb
	_rig = CharacterRig3D.build_character("buddy")
	var loaded: Node3D = visual_slot.attach_or_placeholder(_rig)
	if not (loaded is CharacterRig3D):
		_rig = null

	EventBus.quest_completed.connect(_on_quest_completed)
	EventBus.quest_reward_claimed.connect(_on_quest_claimed)
	EventBus.area_unlocked.connect(_on_area_unlocked)
	EventBus.buddy_state_changed.connect(_on_buddy_state_changed)
	EventBus.voice_playback_started.connect(func(speaker_id: String, _txt: String, _meta: Dictionary) -> void:
		if speaker_id == "buddy":
			_is_speaking_audio = true
			set_mood(BuddyMood.TALKING)
	)
	EventBus.voice_playback_finished.connect(func(_speaker_id: String, _meta: Dictionary) -> void:
		if _is_speaking_audio:
			_is_speaking_audio = false
			if _rig != null and is_instance_valid(_rig):
				_rig.set_speaking(false)
	)
	EventBus.minigame_answered.connect(func(_mg: String, att: Dictionary) -> void:
		if bool(att.get("is_correct", false)):
			set_mood(BuddyMood.HAPPY)
		else:
			set_mood(BuddyMood.THINKING)
	)
	set_mood(BuddyMood.IDLE)


func attach_to_player(player: Node3D) -> void:
	target_node = player
	global_position = player.global_position + follow_offset


func set_mood(mood: BuddyMood) -> void:
	current_mood = mood
	var expr := "neutral"
	match mood:
		BuddyMood.IDLE:
			mood_badge.text = ""
			expr = "neutral"
		BuddyMood.HAPPY:
			mood_badge.text = "^_^"
			expr = "happy"
		BuddyMood.SAD:
			mood_badge.text = "T_T"
			expr = "thinking"
		BuddyMood.SURPRISED:
			mood_badge.text = "!"
			expr = "surprised"
		BuddyMood.THINKING:
			mood_badge.text = "?"
			expr = "thinking"
		BuddyMood.TALKING:
			mood_badge.text = "..."
			expr = "encouraging"
		BuddyMood.CELEBRATING:
			mood_badge.text = "*"
			expr = "excited"
	mood_badge.visible = not mood_badge.text.is_empty()
	if _rig != null:
		_rig.set_expression(expr)


func set_mood_by_name(state_name: String) -> void:
	match state_name.to_lower():
		"happy": set_mood(BuddyMood.HAPPY)
		"sad": set_mood(BuddyMood.SAD)
		"surprised": set_mood(BuddyMood.SURPRISED)
		"thinking": set_mood(BuddyMood.THINKING)
		"talking": set_mood(BuddyMood.TALKING)
		"celebrating": set_mood(BuddyMood.CELEBRATING)
		_: set_mood(BuddyMood.IDLE)


func speak_tip(message: String, mood_name: String = "happy", duration_sec: float = 5.0) -> void:
	set_mood_by_name(mood_name)
	speech_label.text = message
	speech_panel.visible = true
	hide_timer.start(duration_sec)


func offer_contextual_help() -> void:
	GameStateManager.mark_npc_met("buddy", "buddy_help")
	QuestManager.report_npc_talk("buddy")

	for q_done in DataRepository.quests_ordered:
		var qid_done := str(q_done.get("id", ""))
		if QuestManager.get_detailed_quest_status(qid_done) == "completed":
			var turn_in_id := str(q_done.get("turn_in_npc_id", ""))
			var turn_in_cfg: Dictionary = DataRepository.npcs_by_id.get(turn_in_id, {})
			var turn_in_name := LocalizationManager.pick_text(turn_in_cfg, "name")
			if turn_in_name.is_empty():
				turn_in_name = "NPC"
			speak_tip(
				"Xong mục tiêu rồi! Gặp %s và bấm [E], hoặc bấm Nhiệm vụ [Tab] -> Nhận thưởng!" % turn_in_name,
				"celebrating",
				6.5
			)
			return

	var q: Dictionary = QuestManager.get_next_suggested_quest()
	if not q.is_empty():
		var qid := str(q.get("id", ""))
		var status := QuestManager.get_quest_status(qid)
		var q_area_id := str(q.get("area_id", ""))
		var q_area_cfg := DataRepository.get_area(q_area_id)
		var q_area_name := LocalizationManager.pick_text(q_area_cfg, "name")
		if status == "active":
			var step := QuestManager.get_current_step(qid)
			var step_type := str(step.get("type", ""))
			var step_title := LocalizationManager.pick_text(step, "title")
			var prog := QuestManager.get_objective_progress(qid, str(step.get("id", "")))
			var tgt := int(prog.get("target", 1))
			var suffix := " (%d/%d)" % [int(prog.get("current", 0)), tgt] if tgt > 1 else ""
			var msg := _build_actionable_step_hint(step, step_type, step_title, suffix, q_area_id, q_area_name)
			speak_tip(msg, "thinking", 7.0)
			return
		elif status == "available":
			var npc_id := str(q.get("giver_npc_id", ""))
			var npc_cfg: Dictionary = DataRepository.npcs_by_id.get(npc_id, {})
			var npc_name := LocalizationManager.pick_text(npc_cfg, "name")
			var npc_area_id := str(npc_cfg.get("area_id", q_area_id))
			var npc_area_name := LocalizationManager.pick_text(DataRepository.get_area(npc_area_id), "name")
			if not npc_area_id.is_empty() and npc_area_id != GameStateManager.current_area_id:
				speak_tip("Mở Bản đồ [M] tới %s, tìm %s và nhấn [E] để nhận nhiệm vụ!" % [npc_area_name, npc_name], "happy", 6.5)
			else:
				speak_tip("Đi lại gần %s và nhấn [E] (hoặc nút Tương tác) để nhận nhiệm vụ!" % npc_name, "happy", 6.0)
			return
	var area_greetings: Dictionary = DataRepository.buddy_config.get("area_greetings", {})
	var greeting: Variant = area_greetings.get(GameStateManager.current_area_id, {})
	if typeof(greeting) == TYPE_DICTIONARY and not greeting.is_empty():
		speak_tip(LocalizationManager.pick_text(greeting, "text"), str(greeting.get("state", "happy")), 6.0)
	else:
		speak_tip("Cậu đang làm rất tốt! Hãy thử mở Bản đồ [M] hoặc Trò chơi [G] để khám phá thêm nhé!", "happy", 5.0)


func _build_actionable_step_hint(
	step: Dictionary,
	step_type: String,
	step_title: String,
	suffix: String,
	q_area_id: String,
	q_area_name: String
) -> String:
	var target_id := str(step.get("target_id", ""))
	if step_type == "visit_area":
		var dest_name := LocalizationManager.pick_text(DataRepository.get_area(target_id), "name")
		if dest_name.is_empty():
			dest_name = q_area_name
		return "Mở Bản đồ [M] chọn '%s' hoặc đi qua Cổng Dịch Chuyển (vòng sáng xanh) để tới đó!" % dest_name

	if not q_area_id.is_empty() and q_area_id != GameStateManager.current_area_id and step_type in ["collect_tag", "interact_object", "talk_to_npc", "return_to_npc"]:
		return "Mở Bản đồ [M] tới '%s' trước, sau đó %s%s!" % [q_area_name, step_title, suffix]

	match step_type:
		"collect_tag":
			return "Tìm các bục đá có huy hiệu vàng phát sáng trên mặt đất ở %s, lại gần rồi nhấn [E] (hoặc Tương tác) để nhặt!%s" % [q_area_name, suffix]
		"interact_object":
			return "Tìm vật thể phát sáng/rương báu ở %s (%s%s), đi lại gần rồi nhấn [E] (hoặc Tương tác)!" % [q_area_name, step_title, suffix]
		"complete_minigame":
			return "Bấm nút Trò chơi [G] ở thanh dưới (hoặc mở Nhiệm vụ [Tab]) để chơi mini-game: %s%s!" % [step_title, suffix]
		"learn_vocabulary":
			return "Bấm Học tập [L] hoặc Trò chơi [G] ở thanh dưới để hoàn thành: %s%s!" % [step_title, suffix]
		"talk_to_npc", "return_to_npc":
			var npc_cfg: Dictionary = DataRepository.npcs_by_id.get(target_id, {})
			var npc_name := LocalizationManager.pick_text(npc_cfg, "name")
			if npc_name.is_empty():
				return "Hãy %s%s bằng cách lại gần NPC và nhấn [E]!" % [step_title, suffix]
			return "Đi lại gần %s và nhấn [E] (hoặc nút Tương tác)!%s" % [npc_name, suffix]
		_:
			return "Buddy gợi ý: Hãy %s%s nhé!" % [step_title, suffix]


func _process(delta: float) -> void:
	_hover_time += delta
	if target_node != null and is_instance_valid(target_node):
		var desired := target_node.global_position + follow_offset
		global_position = global_position.lerp(desired, minf(1.0, delta * follow_speed))
		var look_dir := Vector2(target_node.global_position.x - global_position.x, target_node.global_position.z - global_position.z)
		if look_dir.length_squared() > 0.02:
			var yaw := atan2(look_dir.x, look_dir.y)
			visual_slot.rotation.y = lerp_angle(visual_slot.rotation.y, yaw, minf(1.0, delta * 6.0))

	visual_slot.position.y = sin(_hover_time * 3.8) * 0.16
	if _rig != null and is_instance_valid(_rig):
		var flap_speed := 15.0 if current_mood == BuddyMood.CELEBRATING else 8.5
		var flap_amp := 0.55 if current_mood == BuddyMood.CELEBRATING else 0.32
		if _rig.left_wing_pivot != null:
			_rig.left_wing_pivot.rotation.z = sin(_hover_time * flap_speed) * flap_amp
		if _rig.right_wing_pivot != null:
			_rig.right_wing_pivot.rotation.z = -sin(_hover_time * flap_speed) * flap_amp
		if _rig.tail_pivot != null:
			_rig.tail_pivot.rotation.y = sin(_hover_time * 5.2) * 0.28
		if _is_speaking_audio:
			_rig.set_speaking(true, delta)
		if current_mood == BuddyMood.CELEBRATING:
			visual_slot.rotation.z = sin(_hover_time * 10.0) * 0.14
		else:
			visual_slot.rotation.z = lerpf(visual_slot.rotation.z, 0.0, minf(1.0, delta * 8.0))

	_update_screen_bubble()


func _update_screen_bubble() -> void:
	var cam := get_viewport().get_camera_3d()
	if cam == null or (not speech_panel.visible and not mood_badge.visible):
		return
	var world_anchor := global_position + Vector3(0.0, 1.35 + visual_slot.position.y, 0.0)
	if cam.is_position_behind(world_anchor):
		speech_panel.modulate.a = 0.0
		mood_badge.modulate.a = 0.0
		return
	speech_panel.modulate.a = 1.0
	mood_badge.modulate.a = 1.0
	var screen_pt := cam.unproject_position(world_anchor)
	var vp_size := get_viewport().get_visible_rect().size
	var bubble_w := speech_panel.size.x if speech_panel.size.x > 10.0 else 260.0
	var bubble_h := speech_panel.size.y if speech_panel.size.y > 10.0 else 68.0
	var bx := clampf(screen_pt.x - bubble_w * 0.5, 12.0, maxf(12.0, vp_size.x - bubble_w - 12.0))
	var by := clampf(screen_pt.y - bubble_h - 14.0, 74.0, maxf(74.0, vp_size.y - bubble_h - 120.0))
	speech_panel.position = Vector2(bx, by)
	mood_badge.position = Vector2(clampf(screen_pt.x + 18.0, 12.0, vp_size.x - 56.0), clampf(screen_pt.y - 24.0, 64.0, vp_size.y - 40.0))


func _on_quest_completed(_quest_id: String, _rewards: Dictionary) -> void:
	speak_tip("Hoan hô! Chúng ta hoàn thành nhiệm vụ rồi! Hãy nhận thưởng nhé!", "celebrating", 4.5)


func _on_quest_claimed(_quest_id: String, _rewards: Dictionary) -> void:
	speak_tip("Tuyệt vời! Phần thưởng đã vào túi đồ rồi!", "celebrating", 4.0)


func _on_area_unlocked(area_id: String) -> void:
	var area_cfg := DataRepository.get_area(area_id)
	var area_name := LocalizationManager.pick_text(area_cfg, "name")
	speak_tip("Tuyệt vời! Khu vực mới '" + area_name + "' đã mở khóa!", "surprised", 5.0)


func _on_buddy_state_changed(state_name: String, message: String) -> void:
	if message.is_empty():
		set_mood_by_name(state_name)
	else:
		speak_tip(message, state_name, 5.0)
