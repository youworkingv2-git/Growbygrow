class_name BuddyController
extends Node3D
## 3D Companion Dragon Buddy with 7 expression states, wing-flapping & tail-wag animation,
## smooth 3D follow behavior, bilingual tips, and screen-projected speech bubble.

enum BuddyMood { IDLE, HAPPY, SAD, SURPRISED, THINKING, TALKING, CELEBRATING }

@export var follow_offset: Vector3 = Vector3(-1.25, 1.45, 0.35)
@export var follow_speed: float = 5.5

var current_mood: BuddyMood = BuddyMood.IDLE
var target_node: Node3D = null
var _hover_time: float = 0.0
var _rig: CharacterRig3D = null

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
	EventBus.area_unlocked.connect(_on_area_unlocked)
	EventBus.buddy_state_changed.connect(_on_buddy_state_changed)
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
	var q: Dictionary = QuestManager.get_next_suggested_quest()
	if not q.is_empty():
		var qid := str(q.get("id", ""))
		var status := QuestManager.get_quest_status(qid)
		if status == "active":
			var step := QuestManager.get_current_step(qid)
			var step_title := LocalizationManager.pick_text(step, "title")
			speak_tip("Gợi ý: Hãy " + step_title + " nhé!", "thinking", 6.0)
			return
		elif status == "available":
			var npc_id := str(q.get("giver_npc_id", ""))
			var npc_cfg: Dictionary = DataRepository.npcs_by_id.get(npc_id, {})
			var npc_name := LocalizationManager.pick_text(npc_cfg, "name")
			speak_tip("Hãy tìm gặp " + npc_name + " để nhận nhiệm vụ mới!", "happy", 6.0)
			return
	var area_greetings: Dictionary = DataRepository.buddy_config.get("area_greetings", {})
	var greeting: Variant = area_greetings.get(GameStateManager.current_area_id, {})
	if typeof(greeting) == TYPE_DICTIONARY and not greeting.is_empty():
		speak_tip(LocalizationManager.pick_text(greeting, "text"), str(greeting.get("state", "happy")), 6.0)
	else:
		speak_tip("Cậu đang làm rất tốt! Hãy thử mở Bản đồ để khám phá thêm nhé!", "happy", 5.0)


func _process(delta: float) -> void:
	_hover_time += delta
	if target_node != null and is_instance_valid(target_node):
		var desired := target_node.global_position + follow_offset
		global_position = global_position.lerp(desired, minf(1.0, delta * follow_speed))
		var look_dir := Vector2(target_node.global_position.x - global_position.x, target_node.global_position.z - global_position.z)
		if look_dir.length_squared() > 0.02:
			var yaw := atan2(look_dir.x, look_dir.y)
			visual_slot.rotation.y = lerp_angle(visual_slot.rotation.y, yaw, minf(1.0, delta * 6.0))

	# 3D Dragon Hover, Wing Flap & Tail Wag
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
		if current_mood == BuddyMood.CELEBRATING:
			visual_slot.rotation.z = sin(_hover_time * 10.0) * 0.14
		else:
			visual_slot.rotation.z = lerpf(visual_slot.rotation.z, 0.0, minf(1.0, delta * 8.0))

	_update_screen_bubble()


func _update_screen_bubble() -> void:
	var cam := get_viewport().get_camera_3d()
	if cam == null or not speech_panel.visible and not mood_badge.visible:
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
	speak_tip("Hoan hô! Chúng ta làm được rồi!", "celebrating", 4.5)


func _on_area_unlocked(area_id: String) -> void:
	var area_cfg := DataRepository.get_area(area_id)
	var area_name := LocalizationManager.pick_text(area_cfg, "name")
	speak_tip("Tuyệt vời! Khu vực mới '" + area_name + "' đã mở khóa!", "surprised", 5.0)


func _on_buddy_state_changed(state_name: String, message: String) -> void:
	if message.is_empty():
		set_mood_by_name(state_name)
	else:
		speak_tip(message, state_name, 5.0)
