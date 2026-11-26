extends Node
## Manages data-driven bilingual (VI/EN) dialogues for Buddy, Professor Owl, and NPCs.

const DIALOGUES_PATH := "res://data/dialogue/dialogues_world1.json"

var dialogues: Dictionary = {}
var is_active: bool = false
var current_dialogue_id: String = ""
var current_lines: Array = []
var current_index: int = 0
var current_complete_event: String = ""

func _ready() -> void:
	_load_dialogues()

func _load_dialogues() -> void:
	if not FileAccess.file_exists(DIALOGUES_PATH):
		push_error("Missing dialogues file: " + DIALOGUES_PATH)
		return
	var file := FileAccess.open(DIALOGUES_PATH, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) == TYPE_DICTIONARY and parsed.has("dialogues"):
		dialogues = parsed["dialogues"]

func start_dialogue(dialogue_id: String) -> bool:
	if is_active:
		return false
	if not dialogues.has(dialogue_id):
		push_warning("Dialogue ID not found: " + dialogue_id)
		return false

	var dlg: Dictionary = dialogues[dialogue_id]
	current_dialogue_id = dialogue_id
	current_lines = dlg.get("lines", [])
	current_complete_event = dlg.get("on_complete_event", "")
	current_index = 0

	if current_lines.is_empty():
		return false

	is_active = true
	EventBus.dialogue_started.emit(dialogue_id)
	return true

func get_current_line() -> Dictionary:
	if not is_active or current_index >= current_lines.size():
		return {}
	return current_lines[current_index]

func advance_line() -> bool:
	if not is_active:
		return false
	current_index += 1
	if current_index >= current_lines.size():
		end_dialogue()
		return false
	return true

func end_dialogue() -> void:
	if not is_active:
		return
	var finished_id := current_dialogue_id
	var complete_evt := current_complete_event
	is_active = false
	current_dialogue_id = ""
	current_lines = []
	current_index = 0
	current_complete_event = ""
	EventBus.dialogue_ended.emit(finished_id, complete_evt)
