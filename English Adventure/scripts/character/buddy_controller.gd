class_name BuddyController
extends Node2D
## Companion dragon Buddy with 7 expression states, smooth follow behavior,
## bilingual tips, and extensible voice hook for Prompt 03+.

enum BuddyMood { IDLE, HAPPY, SAD, SURPRISED, THINKING, TALKING, CELEBRATING }

@export var follow_offset: Vector2 = Vector2(-56.0, -44.0)
@export var follow_speed: float = 5.5

var current_mood: BuddyMood = BuddyMood.IDLE
var target_node: Node2D = null
var _hover_time: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var mood_badge: Label = $MoodBadge
@onready var speech_panel: PanelContainer = $SpeechBubble
@onready var speech_label: Label = $SpeechBubble/Margin/Label
@onready var hide_timer: Timer = $HideSpeechTimer


func _ready() -> void:
	speech_panel.visible = false
	hide_timer.timeout.connect(func() -> void: speech_panel.visible = false)
	EventBus.quest_completed.connect(_on_quest_completed)
	EventBus.area_unlocked.connect(_on_area_unlocked)
	EventBus.buddy_state_changed.connect(_on_buddy_state_changed)
	set_mood(BuddyMood.IDLE)


func attach_to_player(player: Node2D) -> void:
	target_node = player
	global_position = player.global_position + follow_offset


func set_mood(mood: BuddyMood) -> void:
	current_mood = mood
	match mood:
		BuddyMood.IDLE:
			mood_badge.text = ""
			sprite.modulate = Color.WHITE
		BuddyMood.HAPPY:
			mood_badge.text = "^_^"
			sprite.modulate = Color(1.0, 1.0, 0.95)
		BuddyMood.SAD:
			mood_badge.text = "T_T"
			sprite.modulate = Color(0.85, 0.9, 1.0)
		BuddyMood.SURPRISED:
			mood_badge.text = "!"
			sprite.modulate = Color(1.0, 0.98, 0.85)
		BuddyMood.THINKING:
			mood_badge.text = "?"
			sprite.modulate = Color(0.92, 0.96, 1.0)
		BuddyMood.TALKING:
			mood_badge.text = "..."
			sprite.modulate = Color.WHITE
		BuddyMood.CELEBRATING:
			mood_badge.text = "*"
			sprite.modulate = Color(1.0, 0.96, 0.78)


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
	# Future voice integration hook (Prompt 03+): play_buddy_voice(voice_key)


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
	if target_node != null:
		var desired := target_node.global_position + follow_offset
		global_position = global_position.lerp(desired, minf(1.0, delta * follow_speed))
		sprite.flip_h = target_node.global_position.x < global_position.x
	sprite.position.y = sin(_hover_time * 4.0) * 6.0
	if current_mood == BuddyMood.CELEBRATING:
		sprite.rotation = sin(_hover_time * 12.0) * 0.12
	else:
		sprite.rotation = 0.0


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
