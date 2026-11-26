extends CanvasLayer
## Shared Dialogue Box UI with bilingual EN/VI text and typewriter effect.

var _full_text: String = ""
var _char_index: int = 0
var _typing: bool = false
var _type_timer: float = 0.0

@onready var panel: PanelContainer = %DialoguePanel
@onready var avatar_rect: TextureRect = %SpeakerAvatar
@onready var speaker_label: Label = %SpeakerNameLabel
@onready var text_en_label: Label = %TextEnLabel
@onready var text_vi_label: Label = %TextViLabel
@onready var next_btn: Button = %NextButton
@onready var close_btn: Button = %CloseButton

func _ready() -> void:
	panel.visible = false
	next_btn.pressed.connect(_on_next_pressed)
	close_btn.pressed.connect(func(): DialogueManager.end_dialogue())
	EventBus.dialogue_started.connect(_on_dialogue_started)
	EventBus.dialogue_ended.connect(_on_dialogue_ended)

func _process(delta: float) -> void:
	if not _typing:
		return
	_type_timer += delta
	if _type_timer >= 0.02:
		_type_timer = 0.0
		_char_index += 1
		text_vi_label.text = _full_text.substr(0, _char_index)
		if _char_index >= _full_text.length():
			_typing = false

func _on_dialogue_started(_dialogue_id: String) -> void:
	panel.visible = true
	_render_current_line()

func _on_dialogue_ended(_dialogue_id: String, _evt: String) -> void:
	panel.visible = false
	_typing = false

func _render_current_line() -> void:
	var line := DialogueManager.get_current_line()
	if line.is_empty():
		return
	speaker_label.text = line.get("speaker_name", "")
	text_en_label.text = line.get("text_en", "")
	_full_text = line.get("text_vi", "")
	_char_index = 0
	text_vi_label.text = ""
	_typing = true

	var avatar_path: String = line.get("avatar", "")
	if avatar_path != "" and ResourceLoader.exists(avatar_path):
		avatar_rect.texture = load(avatar_path)

func _on_next_pressed() -> void:
	if _typing:
		_typing = false
		text_vi_label.text = _full_text
		return
	if DialogueManager.advance_line():
		_render_current_line()
