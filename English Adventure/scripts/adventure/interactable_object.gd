class_name InteractableObject
extends Area3D
## Shared 3D interactable component for Signposts, Treasure Chests, Lost Letters,
## Magic Crystals, Doors, Gates, and Area Portals.

@export var object_id: String = ""
@export var object_type: String = "signpost"   # signpost | chest | lost_letter | crystal | gate | portal
@export var target_area_id: String = ""         # Used when object_type == "portal"
@export var target_spawn_pos: Vector2 = Vector2(-1, -1)

var object_data: Dictionary = {}
var _pulse_time: float = 0.0
var _prop_root: Node3D = null

@onready var visual_slot: Asset3DSlot = $VisualSlot
@onready var label: Label3D = $Label3D
@onready var focus_ring: MeshInstance3D = $FocusRing


func setup_from_data(data: Dictionary) -> void:
	object_data = data
	object_id = str(data.get("id", ""))
	object_type = str(data.get("object_type", "signpost"))
	if is_node_ready():
		_refresh_visuals()


func setup_portal(portal_id: String, dest_area_id: String, dest_spawn: Vector2) -> void:
	object_id = portal_id
	object_type = "portal"
	target_area_id = dest_area_id
	target_spawn_pos = dest_spawn
	var area_cfg := DataRepository.get_area(dest_area_id)
	object_data = {
		"id": portal_id,
		"object_type": "portal",
		"title_vi": "Cổng tới " + str(area_cfg.get("name_vi", dest_area_id)),
		"title_en": "To " + str(area_cfg.get("name_en", dest_area_id))
	}
	if is_node_ready():
		_refresh_visuals()


func _ready() -> void:
	focus_ring.visible = false
	EventBus.ui_locale_changed.connect(func(_l: String) -> void: _refresh_visuals())
	EventBus.area_unlocked.connect(func(_aid: String) -> void: _refresh_visuals())
	if not object_data.is_empty():
		_refresh_visuals()


func _process(delta: float) -> void:
	_pulse_time += delta
	if _prop_root != null and is_instance_valid(_prop_root):
		var token := _prop_root.get_node_or_null("FloatToken") as Node3D
		if token != null:
			token.position.y = 0.95 + sin(_pulse_time * 3.0) * 0.14
			token.rotation.y += delta * 1.4
		var rune_ring := _prop_root.get_node_or_null("RuneRing") as Node3D
		if rune_ring != null:
			rune_ring.rotation.z += delta * 1.1
	if focus_ring.visible:
		focus_ring.rotation.y += delta * 1.8


func _refresh_visuals() -> void:
	var collected := GameStateManager.is_object_collected(object_id)
	label.text = LocalizationManager.pick_text(object_data, "title")
	LabelBackdrop3D.apply_to_label(label, false, focus_ring.visible)

	var override_glb := str(object_data.get("model_3d_path", ""))
	if not override_glb.is_empty():
		visual_slot.override_model_path = override_glb

	var visual_kind := "signpost"
	match object_type:
		"chest": visual_kind = "chest"
		"lost_letter": visual_kind = "letter"
		"crystal": visual_kind = "crystal"
		"portal": visual_kind = "portal"
		_: visual_kind = "signpost"

	_prop_root = PropFactory3D.build_interactable_prop(visual_kind)
	var loaded: Node3D = visual_slot.attach_or_placeholder(_prop_root)
	_prop_root = loaded

	match object_type:
		"chest":
			var lid := _prop_root.get_node_or_null("LidPivot") as Node3D
			if lid != null:
				lid.rotation_degrees.x = -68.0 if collected else 0.0
		"lost_letter", "crystal":
			visible = not collected
			monitoring = not collected
			monitorable = not collected
		"portal":
			var unlocked := GameStateManager.is_area_unlocked(target_area_id)
			var veil := _prop_root.get_node_or_null("PortalVeil") as MeshInstance3D
			if veil != null:
				veil.visible = unlocked


func set_focused(is_focused: bool) -> void:
	focus_ring.visible = is_focused
	LabelBackdrop3D.apply_to_label(label, false, is_focused)


func get_interaction_metadata() -> Dictionary:
	return {
		"id": object_id,
		"type": object_type,
		"title": LocalizationManager.pick_text(object_data, "title"),
		"node": self
	}
