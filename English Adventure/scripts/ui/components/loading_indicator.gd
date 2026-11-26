class_name LoadingIndicatorWidget
extends HBoxContainer
## Reusable Loading Indicator with spinning compass/star badge and status text.

@onready var spinner: TextureRect = $Spinner
@onready var label: Label = $Label


func _ready() -> void:
	spinner.pivot_offset = spinner.size * 0.5
	spinner.resized.connect(func() -> void: spinner.pivot_offset = spinner.size * 0.5)


func _process(delta: float) -> void:
	if visible and not SettingsManager.reduced_motion:
		spinner.rotation += delta * 3.2


func set_loading_text(msg: String) -> void:
	if label != null:
		label.text = msg
