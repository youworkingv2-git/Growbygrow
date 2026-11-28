class_name NpcController
extends Area3D
## Data-driven 3D NPC actor supporting full state machine (Idle, NoticePlayer, Talking,
## QuestAvailable !, QuestInProgress ..., QuestCompleted ?, Celebrating), 3D character rigs,
## subtle idle animations, quest ground halo, proximity-only nameplates, and dialogue hooks.

enum NpcState {
	IDLE,
	NOTICE_PLAYER,
	TALKING,
	QUEST_AVAILABLE,
	QUEST_IN_PROGRESS,
	QUEST_COMPLETED,
	CELEBRATING
}

const PROXIMITY_LABEL_RADIUS_SQ: float = 24.0 # Show NPC nameplate within ~4.9m or when focused

var npc_id: String = ""
var npc_data: Dictionary = {}
var current_state: NpcState = NpcState.IDLE
var _rig: CharacterRig3D = null
var _idle_t: float = 0.0
var _is_talking: bool = false
var _is_speaking_audio: bool = false
var _celebrate_timer: float = 0.0
var _quest_aura_ring: MeshInstance3D = null

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
	name_label.visible = false
	_build_quest_aura_ring()
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
		_is_speaking_audio = false
		if _rig != null and is_instance_valid(_rig):
			_rig.set_speaking(false)
		_refresh_badge()
	)
	EventBus.voice_playback_started.connect(func(speaker_id: String, _txt: String, _meta: Dictionary) -> void:
		if speaker_id == npc_id:
			_is_talking = true
			_is_speaking_audio = true
			_refresh_badge()
	)
	EventBus.voice_playback_finished.connect(func(speaker_id: String, _meta: Dictionary) -> void:
		if speaker_id == npc_id or _is_speaking_audio:
			_is_speaking_audio = false
			if _rig != null and is_instance_valid(_rig):
				_rig.set_speaking(false)
	)
	EventBus.ui_locale_changed.connect(func(_l: String) -> void: _refresh_visuals())
	if not npc_data.is_empty():
		_refresh_visuals()


func _build_quest_aura_ring() -> void:
	_quest_aura_ring = MeshInstance3D.new()
	_quest_aura_ring.name = "QuestAuraRing"
	var tm := TorusMesh.new()
	tm.inner_radius = 0.56
	tm.outer_radius = 0.65
	tm.rings = 16
	tm.ring_segments = 8
	_quest_aura_ring.mesh = tm
	var sm := StandardMaterial3D.new()
	sm.albedo_color = Color(0.98, 0.78, 0.22, 0.72)
	sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm.emission_enabled = true
	sm.emission = Color(0.98, 0.78, 0.22)
	sm.emission_energy_multiplier = 1.1
	_quest_aura_ring.material_override = sm
	_quest_aura_ring.position = Vector3(0, 0.03, 0)
	_quest_aura_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_quest_aura_ring.visible = false
	add_child(_quest_aura_ring)


func _process(delta: float) -> void:
	_idle_t += delta
	if _celebrate_timer > 0.0:
		_celebrate_timer = maxf(0.0, _celebrate_timer - delta)
		if _celebrate_timer == 0.0:
			_refresh_badge()

	var player_node := get_tree().get_first_node_in_group("player") as Node3D
	var dist_sq := 9999.0
	var is_near := false
	if player_node != null and is_instance_valid(player_node):
		dist_sq = global_position.distance_squared_to(player_node.global_position)
		is_near = focus_ring.visible or _is_talking or dist_sq <= PROXIMITY_LABEL_RADIUS_SQ

	if _rig != null and is_instance_valid(_rig):
		_rig.update_blink_and_breath(delta, _idle_t)
		if _rig.body_pivot != null:
			var bob_speed := 5.5 if current_state == NpcState.CELEBRATING else 2.2
			var bob_amp := 0.055 if current_state == NpcState.CELEBRATING else 0.024
			_rig.body_pivot.position.y = sin(_idle_t * bob_speed) * bob_amp
			# Subtle weight-shift sway
			_rig.body_pivot.rotation.z = sin(_idle_t * 1.15) * 0.032
		if _rig.head_pivot != null:
			# Turn head gently toward player when nearby before full body rotation on interaction
			var target_head_yaw := sin(_idle_t * 1.1) * 0.14
			if player_node != null and is_instance_valid(player_node) and dist_sq <= 36.0 and not (_is_talking or focus_ring.visible):
				var pd := Vector2(player_node.global_position.x - global_position.x, player_node.global_position.z - global_position.z)
				if pd.length_squared() > 0.04:
					target_head_yaw = clampf(wrapf(atan2(pd.x, pd.y) - visual_slot.rotation.y, -PI, PI), -0.68, 0.68)
			_rig.head_pivot.rotation.y = lerp_angle(_rig.head_pivot.rotation.y, target_head_yaw, minf(1.0, delta * 4.5))
		if _rig.left_arm_pivot != null and _rig.right_arm_pivot != null:
			if _is_talking or _is_speaking_audio:
				_rig.left_arm_pivot.rotation.x = -0.32 + sin(_idle_t * 5.2) * 0.24
				_rig.right_arm_pivot.rotation.x = -0.26 + cos(_idle_t * 4.6) * 0.22
				_rig.right_arm_pivot.rotation.z = -0.18 - absf(sin(_idle_t * 3.8)) * 0.16
			elif current_state == NpcState.CELEBRATING:
				_rig.left_arm_pivot.rotation.z = 0.75 + sin(_idle_t * 9.0) * 0.25
				_rig.right_arm_pivot.rotation.z = -0.75 - sin(_idle_t * 9.0) * 0.25
			else:
				var sway := sin(_idle_t * 2.0) * 0.08
				_rig.left_arm_pivot.rotation.x = lerpf(_rig.left_arm_pivot.rotation.x, sway, minf(1.0, delta * 5.0))
				_rig.right_arm_pivot.rotation.x = lerpf(_rig.right_arm_pivot.rotation.x, -sway, minf(1.0, delta * 5.0))
				_rig.left_arm_pivot.rotation.z = lerpf(_rig.left_arm_pivot.rotation.z, 0.0, minf(1.0, delta * 5.0))
				_rig.right_arm_pivot.rotation.z = lerpf(_rig.right_arm_pivot.rotation.z, 0.0, minf(1.0, delta * 5.0))
		if _is_speaking_audio:
			_rig.set_speaking(true, delta)
		if _rig.aura_mesh != null:
			_rig.aura_mesh.rotation.y += delta * 1.2

	if quest_badge.visible:
		quest_badge.position.y = 2.46 + sin(_idle_t * 3.6) * 0.08
	if _quest_aura_ring != null and _quest_aura_ring.visible:
		_quest_aura_ring.rotation.y -= delta * 0.9
		var pulse := 1.0 + sin(_idle_t * 2.8) * 0.05
		_quest_aura_ring.scale = Vector3(pulse, 1.0, pulse)

	if player_node != null and is_instance_valid(player_node):
		if focus_ring.visible or _is_talking:
			var d := Vector2(player_node.global_position.x - global_position.x, player_node.global_position.z - global_position.z)
			if d.length_squared() > 0.04:
				var target_yaw := atan2(d.x, d.y)
				visual_slot.rotation.y = lerp_angle(visual_slot.rotation.y, target_yaw, minf(1.0, delta * 5.5))
		else:
			visual_slot.rotation.y = lerp_angle(visual_slot.rotation.y, 0.0, minf(1.0, delta * 3.0))

	name_label.visible = is_near
	if focus_ring.visible:
		focus_ring.rotation.y += delta * 1.6


func _refresh_visuals() -> void:
	var override_glb := str(npc_data.get("model_3d_path", ""))
	if not override_glb.is_empty():
		visual_slot.override_model_path = override_glb
	_rig = CharacterRig3D.build_character(npc_id)
	var loaded: Node3D = visual_slot.attach_or_placeholder(_rig)
	if not (loaded is CharacterRig3D):
		_rig = null
	name_label.text = LocalizationManager.pick_text(npc_data, "name")
	LabelBackdrop3D.apply_to_label(name_label, true, focus_ring.visible)
	_refresh_badge()


func _refresh_badge() -> void:
	if npc_id.is_empty():
		quest_badge.visible = false
		if _quest_aura_ring != null:
			_quest_aura_ring.visible = false
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
		_set_quest_aura_color(Color(0.18, 0.85, 0.45, 0.72))
		if not _is_talking and _celebrate_timer <= 0.0:
			current_state = NpcState.QUEST_COMPLETED
	elif not avail_q.is_empty():
		quest_badge.visible = true
		quest_badge.text = "!"
		quest_badge.modulate = Color("#FBBF24")
		_set_quest_aura_color(Color(0.98, 0.76, 0.16, 0.75))
		if not _is_talking and _celebrate_timer <= 0.0:
			current_state = NpcState.QUEST_AVAILABLE
	elif is_target:
		quest_badge.visible = true
		quest_badge.text = "..."
		quest_badge.modulate = Color("#38BDF8")
		_set_quest_aura_color(Color(0.24, 0.74, 0.98, 0.65))
		if not _is_talking and _celebrate_timer <= 0.0:
			current_state = NpcState.QUEST_IN_PROGRESS
	else:
		quest_badge.visible = false
		if _quest_aura_ring != null:
			_quest_aura_ring.visible = false
		if not _is_talking and _celebrate_timer <= 0.0:
			current_state = NpcState.NOTICE_PLAYER if focus_ring.visible else NpcState.IDLE


func _set_quest_aura_color(col: Color) -> void:
	if _quest_aura_ring == null:
		return
	_quest_aura_ring.visible = not focus_ring.visible
	if _quest_aura_ring.material_override is StandardMaterial3D:
		var sm := _quest_aura_ring.material_override as StandardMaterial3D
		sm.albedo_color = col
		sm.emission = Color(col.r, col.g, col.b)


func set_talking(talking: bool) -> void:
	_is_talking = talking
	_refresh_badge()


func set_focused(is_focused: bool) -> void:
	focus_ring.visible = is_focused
	LabelBackdrop3D.apply_to_label(name_label, true, is_focused)
	_refresh_badge()


func get_interaction_metadata() -> Dictionary:
	return {
		"id": npc_id,
		"type": "npc",
		"title": LocalizationManager.pick_text(npc_data, "name"),
		"node": self
	}
