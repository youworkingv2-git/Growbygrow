class_name InteractableObject
extends Area3D
## Shared 3D interactable component for Signposts, Treasure Chests, Lost Letters,
## Magic Crystals, Doors, Gates, and Area Portals with proximity-only nameplates
## and collection sparkle feedback.

const PROXIMITY_LABEL_RADIUS_SQ: float = 36.0 # Show nameplate within ~6.0m or when focused

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
	label.visible = false
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

	var is_near := focus_ring.visible or (object_type == "portal")
	if not is_near:
		var player_node := get_tree().get_first_node_in_group("player") as Node3D
		if player_node != null and is_instance_valid(player_node):
			is_near = global_position.distance_squared_to(player_node.global_position) <= PROXIMITY_LABEL_RADIUS_SQ
	label.visible = is_near


func spawn_collect_fx() -> void:
	if SettingsManager.graphics_quality == "low":
		return
	var parent_node := get_parent()
	if parent_node == null:
		return
	var burst := CPUParticles3D.new()
	burst.position = global_position + Vector3(0, 0.9, 0)
	burst.one_shot = true
	burst.explosiveness = 0.92
	burst.amount = 18
	burst.lifetime = 0.85
	burst.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	burst.emission_sphere_radius = 0.35
	burst.direction = Vector3(0, 1, 0)
	burst.spread = 70.0
	burst.initial_velocity_min = 2.0
	burst.initial_velocity_max = 4.2
	burst.gravity = Vector3(0, -5.0, 0)
	burst.scale_amount_min = 0.06
	burst.scale_amount_max = 0.14
	var sm := SphereMesh.new()
	sm.radius = 0.5
	sm.height = 1.0
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#FFE36E")
	mat.emission_enabled = true
	mat.emission = Color("#FFCA3A")
	mat.emission_energy_multiplier = 2.0
	sm.material = mat
	burst.mesh = sm
	parent_node.add_child(burst)
	burst.emitting = true
	var t := parent_node.get_tree().create_timer(1.2)
	t.timeout.connect(func() -> void:
		if is_instance_valid(burst):
			burst.queue_free()
	)


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
