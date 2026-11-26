extends Area2D
class_name InteractableObject
## Shared interactable component for Signposts, Letter Stones, Treasure Chests,
## Magic Crystals, Area Portals, and The Shadow Gate.

@export var object_id: String = "signpost_village"
@export var display_name: String = "Biển Chỉ Dẫn"
@export var interaction_type: String = "dialogue" # "dialogue", "portal", "collectible", "shadow_gate"
@export var dialogue_id: String = "dlg_signpost_village"
@export var target_area_id: String = ""
@export var one_time_collect: bool = false

@onready var prompt_label: Label = $PromptLabel
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if one_time_collect and SaveManager.has_collected_item(object_id):
		queue_free()
		return
	if prompt_label != null:
		prompt_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if prompt_label != null:
			prompt_label.visible = true
		InteractionManager.register_nearby(self)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if prompt_label != null:
			prompt_label.visible = false
		InteractionManager.unregister_nearby(self)

func interact() -> void:
	EventBus.interaction_triggered.emit(object_id)

	match interaction_type:
		"portal":
			if target_area_id != "":
				GameManager.enter_area(target_area_id)
		"collectible":
			if SaveManager.add_collected_item(object_id):
				SaveManager.player_data["magic_crystals"] = SaveManager.player_data.get("magic_crystals", 0) + 1
				SaveManager.save_game()
			if dialogue_id != "":
				DialogueManager.start_dialogue(dialogue_id)
			if one_time_collect:
				queue_free()
		_:
			if dialogue_id != "":
				DialogueManager.start_dialogue(dialogue_id)
