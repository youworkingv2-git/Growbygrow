class_name NpcController
extends Area2D
## Data-driven NPC actor supporting quest badges (!, ?), state indicators, and dialogue hooks.

var npc_id: String = ""
var npc_data: Dictionary = {}

@onready var sprite: Sprite2D = $Sprite2D
@onready var name_label: Label = $NameLabel
@onready var quest_badge: Label = $QuestBadge
@onready var focus_ring: ColorRect = $FocusRing


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


func _refresh_visuals() -> void:
	var sprite_path := str(npc_data.get("sprite_path", ""))
	if ResourceLoader.exists(sprite_path):
		sprite.texture = load(sprite_path)
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
