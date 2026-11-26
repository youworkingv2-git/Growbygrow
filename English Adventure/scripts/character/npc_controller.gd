class_name NpcController
extends Area3D
## Data-driven 3D NPC actor supporting full state machine (Idle, NoticePlayer, Talking,
## QuestAvailable !, QuestInProgress ..., QuestCompleted ?, Celebrating), 3D character rigs,
## subtle idle animations, ground focus ring, and dialogue hooks.

enum NpcState {
	IDLE,
	NOTICE_PLAYER,
	TALKING,
	QUEST_AVAILABLE,
	QUEST_IN_PROGRESS,
	QUEST_COMPLETED,
	CELEBRATING
}

var npc_id: String = ""
var npc_data: Dictionary = {}
var current_state: NpcState = NpcState.IDLE
var _rig: CharacterRig3D = null
var _idle_t: float = 0.0
var _is_talking: bool = false
var _celebrate_timer: float = 0.0

@onready var visual_slot: Asset3DSlot = $VisualSlot
@onready var name_label: Label3D = $NameLabel3D
@onready var quest_badge: Label3D = $QuestBadge3D
@onready var focus_ring: MeshInstance3D = $FocusRing


func setup(data: Dictionary) -> void:
	npc_data = data
	npc_id = str(data.get("id", ""))
	if is_node_ready():
		_refresh_visuals()


func _ready() -> void:
	focus_ring.visible = false
	EventBus.quest_started.connect(func(_qid: String) -> void: _refresh_badge())
	EventBus.quest_step_updated.connect(func(_qid: String, _idx: int) -> void: _refresh_badge())
	EventBus.quest_objective_updated.connect(func(_qid: String, _oid: String, _c: int, _t: int) -> void: _refresh_badge())
	EventBus.quest_completed.connect(func(_qid: String, _r: Dictionary) -> void: _refresh_badge())
	EventBus.quest_reward_claimed.connect(func(_qid: String, _r: Dictionary) -> void:
		_celebrate_timer = 3.0
		_refresh_badge()
	)
	EventBus.dialogue_ended.connect(func(_did: String) -> void:
		_is_talking = false
		_refresh_badge()
	)
	EventBus.ui_locale_changed.connect(func(_l: String) -> void: _refresh_visuals())
	if not npc_data.is_empty():
		_refresh_visuals()


func _process(delta: float) -> void:
	_idle_t += delta
	if _celebrate_timer > 0.0:
		_celebrate_timer = maxf(0.0, _celebrate_timer - delta)
		if _celebrate_timer == 0.0:
			_refresh_badge()

	if _rig != null and is_instance_valid(_rig):
		if _rig.body_pivot != null:
			var bob_speed := 5.5 if current_state == NpcState.CELEBRATING else 2.2
			var bob_amp := 0.06 if current_state == NpcState.CELEBRATING else 0.03
			_rig.body_pivot.position.y = sin(_idle_t * bob_speed) * bob_amp
		if _rig.head_pivot != null:
			_rig.head_pivot.rotation.y = sin(_idle_t * 1.1) * 0.12
		if _rig.aura_mesh != null:
			_rig.aura_mesh.rotation.y += delta * 1.2
	if quest_badge.visible:
		quest_badge.position.y = 2.05 + sin(_idle_t * 3.6) * 0.10
	if focus_ring.visible:
		focus_ring.rotation.y += delta * 1.6
		var player_node := get_tree().get_first_node_in_group("player") as Node3D
		if player_node != null and is_instance_valid(player_node):
			var d := Vector2(player_node.global_position.x - global_position.x, player_node.global_position.z - global_position.z)
			if d.length_squared() > 0.04:
				var target_yaw := atan2(d.x, d.y)
				visual_slot.rotation.y = lerp_angle(visual_slot.rotation.y, target_yaw, minf(1.0, delta * 5.5))
	else:
		visual_slot.rotation.y = lerp_angle(visual_slot.rotation.y, 0.0, minf(1.0, delta * 3.0))


func _refresh_visuals() -> void:
	var override_glb := str(npc_data.get("model_3d_path", ""))
	if not override_glb.is_empty():
		visual_slot.override_model_path = override_glb
	_rig = CharacterRig3D.build_character(npc_id)
	var loaded: Node3D = visual_slot.attach_or_placeholder(_rig)
	if not (loaded is CharacterRig3D):
		_rig = null
	name_label.text = LocalizationManager.pick_text(npc_data, "name")
	_refresh_badge()


func _refresh_badge() -> void:
	if npc_id.is_empty():
		quest_badge.visible = false
		current_state = NpcState.IDLE
		return

	if _is_talking:
		current_state = NpcState.TALKING
	elif _celebrate_timer > 0.0:
		current_state = NpcState.CELEBRATING

	var turn_in_q := QuestManager.is_npc_turn_in_ready(npc_id)
	var avail_q := QuestManager.has_available_quest_for_npc(npc_id)
	var is_target := QuestManager.is_npc_current_target(npc_id)

	if not turn_in_q.is_empty():
		quest_badge.visible = true
		quest_badge.text = "?"
		quest_badge.modulate = Color("#22C55E")
		if not _is_talking and _celebrate_timer <= 0.0:
			current_state = NpcState.QUEST_COMPLETED
	elif not avail_q.is_empty():
		quest_badge.visible = true
		quest_badge.text = "!"
		quest_badge.modulate = Color("#FBBF24")
		if not _is_talking and _celebrate_timer <= 0.0:
			current_state = NpcState.QUEST_AVAILABLE
	elif is_target:
		quest_badge.visible = true
		quest_badge.text = "..."
		quest_badge.modulate = Color("#38BDF8")
		if not _is_talking and _celebrate_timer <= 0.0:
			current_state = NpcState.QUEST_IN_PROGRESS
	else:
		quest_badge.visible = false
		if not _is_talking and _celebrate_timer <= 0.0:
			current_state = NpcState.NOTICE_PLAYER if focus_ring.visible else NpcState.IDLE


func set_talking(talking: bool) -> void:
	_is_talking = talking
	_refresh_badge()


func set_focused(is_focused: bool) -> void:
	focus_ring.visible = is_focused
	_refresh_badge()


func get_interaction_metadata() -> Dictionary:
	return {
		"id": npc_id,
		"type": "npc",
		"title": LocalizationManager.pick_text(npc_data, "name"),
		"node": self
	}
