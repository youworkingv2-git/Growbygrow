extends Control
## Character Selection Screen: Boy Adventurer vs Girl Adventurer.

var selected_gender: String = "boy"

@onready var boy_card: PanelContainer = %BoyCard
@onready var girl_card: PanelContainer = %GirlCard
@onready var name_input: LineEdit = %NameInput
@onready var confirm_btn: Button = %ConfirmButton
@onready var boy_btn: Button = %SelectBoyButton
@onready var girl_btn: Button = %SelectGirlButton

func _ready() -> void:
	boy_btn.pressed.connect(func(): _select_gender("boy"))
	girl_btn.pressed.connect(func(): _select_gender("girl"))
	confirm_btn.pressed.connect(_on_confirm_pressed)
	_select_gender("boy")

func _select_gender(gender: String) -> void:
	selected_gender = gender
	if boy_card != null and girl_card != null:
		boy_card.modulate = Color(1, 1, 1, 1) if gender == "boy" else Color(0.75, 0.75, 0.75, 0.9)
		girl_card.modulate = Color(1, 1, 1, 1) if gender == "girl" else Color(0.75, 0.75, 0.75, 0.9)
		var target_card := boy_card if gender == "boy" else girl_card
		var tw := create_tween()
		tw.tween_property(target_card, "scale", Vector2(1.05, 1.05), 0.12)
		tw.tween_property(target_card, "scale", Vector2(1.0, 1.0), 0.12)

func _on_confirm_pressed() -> void:
	var player_name := name_input.text.strip_edges()
	if player_name == "":
		player_name = "Nhà Thám Hiểm"
	SaveManager.set_character(selected_gender, player_name)
	EventBus.player_gender_selected.emit(selected_gender, player_name)
	GameManager.enter_area("welcome_village")
