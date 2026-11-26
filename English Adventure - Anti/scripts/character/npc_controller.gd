extends Area2D
class_name NPCController
## Data-driven NPC that loads metadata from npcs_world1.json and integrates
## with InteractionManager, DialogueManager, and QuestManager.

const NPCS_DATA_PATH := "res://data/npcs/npcs_world1.json"

@export var npc_id: String = "professor_owl"

var npc_data: Dictionary = {}
@onready var sprite: Sprite2D = $Sprite2D
@onready var name_label: Label = $NameLabel
@onready var prompt_label: Label = $PromptLabel

func _ready() -> void:
	_load_npc_data()
	if not _should_appear():
		visible = false
		monitoring = false
		return

	if prompt_label != null:
		prompt_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _load_npc_data() -> void:
	if not FileAccess.file_exists(NPCS_DATA_PATH):
		return
	var file := FileAccess.open(NPCS_DATA_PATH, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) == TYPE_DICTIONARY and parsed.has("npcs"):
		for npc in parsed["npcs"]:
			if npc.get("id", "") == npc_id:
				npc_data = npc
				break

	if not npc_data.is_empty():
		if name_label != null:
			name_label.text = npc_data.get("name_en", npc_id)
		var spath: String = npc_data.get("sprite_path", "")
		if sprite != null and spath != "" and ResourceLoader.exists(spath):
			sprite.texture = load(spath)

func _should_appear() -> bool:
	var cond: Dictionary = npc_data.get("appear_condition", { "type": "always" })
	if cond.get("type", "always") == "area_unlocked":
		return SaveManager.is_area_unlocked(cond.get("area_id", ""))
	return true

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
	SaveManager.mark_npc_met(npc_id)
	var dlg_id: String = npc_data.get("default_dialogue_id", "")
	if dlg_id != "":
		DialogueManager.start_dialogue(dlg_id)
	EventBus.interaction_triggered.emit(npc_id)
