class_name NpcController
extends Area3D
## Data-driven 3D NPC actor supporting quest badges (!, ?), 3D character rigs,
## subtle idle animations, ground focus ring, and dialogue hooks.

var npc_id: String = ""
var npc_data: Dictionary = {}
var _rig: CharacterRig3D = null
var _idle_t: float = 0.0

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
	EventBus.quest_completed.connect(func(_qid: String, _r: Dictionary) -> void: _refresh_badge())
	EventBus.ui_locale_changed.connect(func(_l: String) -> void: _refresh_visuals())
	if not npc_data.is_empty():
		_refresh_visuals()


func _process(delta: float) -> void:
	_idle_t += delta
	if _rig != null and is_instance_valid(_rig):
		if _rig.body_pivot != null:
			_rig.body_pivot.position.y = sin(_idle_t * 2.2) * 0.03
		if _rig.head_pivot != null:
			_rig.head_pivot.rotation.y = sin(_idle_t * 1.1) * 0.12
		if _rig.aura_mesh != null:
			_rig.aura_mesh.rotation.y += delta * 1.2
	if quest_badge.visible:
		quest_badge.position.y = 2.05 + sin(_idle_t * 3.6) * 0.10
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
	_refresh_badge()


func _refresh_badge() -> void:
	if npc_id.is_empty():
		quest_badge.visible = false
		return
	var avail_q := QuestManager.has_available_quest_for_npc(npc_id)
	if not avail_q.is_empty():
		quest_badge.visible = true
		quest_badge.text = "!"
		quest_badge.modulate = Color("#FBBF24")
	elif QuestManager.is_npc_current_target(npc_id):
		quest_badge.visible = true
		quest_badge.text = "?"
		quest_badge.modulate = Color("#22C55E")
	else:
		quest_badge.visible = false


func set_focused(is_focused: bool) -> void:
	focus_ring.visible = is_focused


func get_interaction_metadata() -> Dictionary:
	return {
		"id": npc_id,
		"type": "npc",
		"title": LocalizationManager.pick_text(npc_data, "name"),
		"node": self
	}
