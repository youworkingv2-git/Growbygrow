class_name DialogueManager
extends Node
## Shared data-driven Dialogue Manager handling bilingual lines, choices,
## seen-dialogue tracking, speaker metadata, and quest/minigame action triggers.

signal line_changed(line_data: Dictionary, index: int, total: int)
signal sequence_finished(dialogue_id: String)
signal action_requested(action_data: Dictionary)

var _current_id: String = ""
var _lines: Array = []
var _index: int = 0
var _active: bool = false


func is_active() -> bool:
	return _active


func is_dialogue_seen(dialogue_id: String) -> bool:
	return GameStateManager.seen_dialogues.has(dialogue_id)


func start_dialogue(dialogue_id: String) -> bool:
	var raw_lines: Variant = DataRepository.dialogues_by_id.get(dialogue_id, [])
	if typeof(raw_lines) != TYPE_ARRAY or (raw_lines as Array).is_empty():
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
	var current_line: Dictionary = _lines[_index] if _index < _lines.size() else {}
	var choices: Array = current_line.get("choices", [])
	if not choices.is_empty():
		# Choices require explicit selection
		return
	_index += 1
	if _index >= _lines.size():
		close_dialogue()
	else:
		_emit_current_line()


func select_choice(choice_index: int) -> void:
	if not _active or _index < 0 or _index >= _lines.size():
		return
	var line: Dictionary = _lines[_index]
	var choices: Array = line.get("choices", [])
	if choice_index < 0 or choice_index >= choices.size():
		return
	var choice: Dictionary = choices[choice_index]
	var quest_action := str(choice.get("quest_action", ""))
	var next_dlg := str(choice.get("next_dialogue_id", ""))

	if not quest_action.is_empty():
		action_requested.emit(choice.duplicate(true))

	if not next_dlg.is_empty() and DataRepository.dialogues_by_id.has(next_dlg):
		GameStateManager.mark_dialogue_seen(_current_id)
		_current_id = next_dlg
		_lines = DataRepository.dialogues_by_id.get(next_dlg, [])
		_index = 0
		_emit_current_line()
	else:
		close_dialogue()


func close_dialogue() -> void:
	if not _active:
		return
	var finished_id := _current_id
	if finished_id != "custom_msg":
		GameStateManager.mark_dialogue_seen(finished_id)
	_active = false
	_lines = []
	_index = 0
	EventBus.dialogue_ended.emit(finished_id)
	EventBus.dialogue_completed.emit(finished_id)
	sequence_finished.emit(finished_id)


func _emit_current_line() -> void:
	if _index < 0 or _index >= _lines.size():
		close_dialogue()
		return
	var line: Dictionary = _lines[_index]
	var line_out := line.duplicate(true)
	line_out["_dialogue_id"] = _current_id
	line_out["_seen_before"] = is_dialogue_seen(_current_id)
	var buddy_state := str(line.get("buddy_state", "idle"))
	EventBus.buddy_state_changed.emit(buddy_state, "")
	line_changed.emit(line_out, _index, _lines.size())
