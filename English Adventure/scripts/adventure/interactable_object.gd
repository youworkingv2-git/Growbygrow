class_name InteractableObject
extends Area2D
## Shared interactable component for Signposts, Treasure Chests, Lost Letters,
## Magic Crystals, Doors, Gates, and Area Portals.

@export var object_id: String = ""
@export var object_type: String = "signpost"   # signpost | chest | lost_letter | crystal | gate | portal
@export var target_area_id: String = ""         # Used when object_type == "portal"
@export var target_spawn_pos: Vector2 = Vector2(-1, -1)

var object_data: Dictionary = {}
var _pulse_time: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var focus_ring: ColorRect = $FocusRing


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
	if object_type == "lost_letter" or object_type == "crystal" or object_type == "portal":
		_pulse_time += delta
		sprite.position.y = sin(_pulse_time * 3.5) * 4.0


func _refresh_visuals() -> void:
	var collected := GameStateManager.is_object_collected(object_id)
	label.text = LocalizationManager.pick_text(object_data, "title")

	match object_type:
		"signpost":
			sprite.texture = load("res://assets/environments/alphabet_island/signpost.svg")
		"chest":
			var chest_path := "res://assets/environments/alphabet_island/treasure_chest_open.svg" if collected else "res://assets/environments/alphabet_island/treasure_chest_closed.svg"
			sprite.texture = load(chest_path)
		"lost_letter":
			sprite.texture = load("res://assets/environments/alphabet_island/lost_letter_glow.svg")
			visible = not collected
			monitoring = not collected
			monitorable = not collected
		"crystal":
			sprite.texture = load("res://assets/environments/alphabet_island/magic_crystal.svg")
			visible = not collected
			monitoring = not collected
			monitorable = not collected
		"gate":
			sprite.texture = load("res://assets/environments/alphabet_island/shadow_gate.svg")
		"portal":
			sprite.texture = load("res://assets/environments/alphabet_island/portal_pad.svg")
			var unlocked := GameStateManager.is_area_unlocked(target_area_id)
			sprite.modulate = Color.WHITE if unlocked else Color(0.55, 0.5, 0.7, 0.85)


func set_focused(is_focused: bool) -> void:
	focus_ring.visible = is_focused


func get_interaction_metadata() -> Dictionary:
	return {
		"id": object_id,
		"type": object_type,
		"title": LocalizationManager.pick_text(object_data, "title"),
		"node": self
	}
