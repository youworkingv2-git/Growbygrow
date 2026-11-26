class_name DialogueManager
extends Node
## Shared data-driven Dialogue Manager handling bilingual lines, speaker metadata,
## typewriter speed, and quest trigger callbacks.

signal line_changed(line_data: Dictionary, index: int, total: int)
signal sequence_finished(dialogue_id: String)

var _current_id: String = ""
var _lines: Array = []
var _index: int = 0
var _active: bool = false


func is_active() -> bool:
	return _active


func start_dialogue(dialogue_id: String) -> bool:
	var raw_lines: Variant = DataRepository.dialogues_by_id.get(dialogue_id, [])
	if typeof(raw_lines) != TYPE_ARRAY or raw_lines.is_empty():
		AppLogger.warn("DialogueManager", "Missing or empty dialogue_id: " + dialogue_id)
		return false
	_current_id = dialogue_id
	_lines = raw_lines
	_index = 0
	_active = true
	EventBus.dialogue_started.emit(dialogue_id)
	_emit_current_line()
	return true


func start_custom_message(title_vi: String, message_vi: String, speaker_id: String = "buddy") -> void:
	_current_id = "custom_msg"
	_lines = [{
		"speaker_id": speaker_id,
		"speaker_name_vi": title_vi,
		"speaker_name_en": title_vi,
		"portrait": "res://assets/characters/buddy/buddy_dragon.svg",
		"buddy_state": "talking",
		"text_en": "",
		"text_vi": message_vi
	}]
	_index = 0
	_active = true
	EventBus.dialogue_started.emit(_current_id)
	_emit_current_line()


func next_line() -> void:
	if not _active:
		return
	_index += 1
	if _index >= _lines.size():
		close_dialogue()
	else:
		_emit_current_line()


func close_dialogue() -> void:
	if not _active:
		return
	var finished_id := _current_id
	_active = false
	_lines = []
	_index = 0
	EventBus.dialogue_ended.emit(finished_id)
	sequence_finished.emit(finished_id)


func _emit_current_line() -> void:
	var line: Dictionary = _lines[_index]
	var buddy_state := str(line.get("buddy_state", "idle"))
	EventBus.buddy_state_changed.emit(buddy_state, "")
	line_changed.emit(line, _index, _lines.size())
