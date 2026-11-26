extends Control
## World Introduction Screen (#2): Story intro of Lingua Realm, The Silent Shadow,
## Professor Owl & Buddy before entering Welcome Village.

var _lines: Array = []
var _index: int = 0

@onready var portrait: TextureRect = $CenterPanel/Margin/VBox/SpeakerRow/Portrait
@onready var speaker_label: Label = $CenterPanel/Margin/VBox/SpeakerRow/SpeakerInfo/SpeakerName
@onready var text_en_label: Label = $CenterPanel/Margin/VBox/TextEnLabel
@onready var text_vi_label: Label = $CenterPanel/Margin/VBox/TextViLabel
@onready var progress_label: Label = $CenterPanel/Margin/VBox/FooterRow/ProgressLabel
@onready var next_btn: Button = $CenterPanel/Margin/VBox/FooterRow/NextBtn
@onready var skip_btn: Button = $CenterPanel/Margin/VBox/HeaderRow/SkipBtn


func _ready() -> void:
	var raw: Variant = DataRepository.dialogues_by_id.get("world_intro", [])
	if typeof(raw) == TYPE_ARRAY:
		_lines = raw
	next_btn.pressed.connect(_on_next_pressed)
	skip_btn.pressed.connect(_finish_intro)
	_show_current_line()


func _show_current_line() -> void:
	if _lines.is_empty():
		_finish_intro()
		return
	var line: Dictionary = _lines[_index]
	var tex_path := str(line.get("portrait", "res://assets/characters/buddy/buddy_dragon.svg"))
	if ResourceLoader.exists(tex_path):
		portrait.texture = load(tex_path)
	speaker_label.text = LocalizationManager.pick_text(line, "speaker_name")
	text_en_label.text = str(line.get("text_en", ""))
	text_vi_label.text = str(line.get("text_vi", ""))
	progress_label.text = "%d / %d" % [_index + 1, _lines.size()]
	next_btn.text = "Vào Làng Khởi Đầu!" if _index >= _lines.size() - 1 else "Tiếp tục →"


func _on_next_pressed() -> void:
	_index += 1
	if _index >= _lines.size():
		_finish_intro()
	else:
		_show_current_line()


func _finish_intro() -> void:
	GameStateManager.world_intro_seen = true
	GameStateManager.save_now("world_intro_completed")
	SceneRouter.enter_area("welcome_village")
