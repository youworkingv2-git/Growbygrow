extends Control
## Character Selection Screen (#1): Boy Adventurer vs Girl Adventurer, equal abilities,
## large preview, selection pulse effect, nickname input, and profile save.

const RANDOM_NAMES_BOY := ["Leo", "Minh", "Nam", "Khang", "Binh"]
const RANDOM_NAMES_GIRL := ["Mia", "Linh", "An", "Vy", "Chi"]

var _selected_gender: String = "boy"

@onready var boy_card: PanelContainer = $RootMargin/VBox/CardsRow/BoyCard
@onready var girl_card: PanelContainer = $RootMargin/VBox/CardsRow/GirlCard
@onready var boy_select_btn: Button = $RootMargin/VBox/CardsRow/BoyCard/Margin/VBox/SelectBoyBtn
@onready var girl_select_btn: Button = $RootMargin/VBox/CardsRow/GirlCard/Margin/VBox/SelectGirlBtn
@onready var boy_preview: TextureRect = $RootMargin/VBox/CardsRow/BoyCard/Margin/VBox/Preview
@onready var girl_preview: TextureRect = $RootMargin/VBox/CardsRow/GirlCard/Margin/VBox/Preview
@onready var cards_row: BoxContainer = $RootMargin/VBox/CardsRow
@onready var nickname_input: LineEdit = $RootMargin/VBox/BottomPanel/VBox/NameRow/NicknameInput
@onready var random_name_btn: Button = $RootMargin/VBox/BottomPanel/VBox/NameRow/RandomNameBtn
@onready var confirm_btn: Button = $RootMargin/VBox/BottomPanel/VBox/ConfirmBtn
@onready var selected_info_label: Label = $RootMargin/VBox/BottomPanel/VBox/SelectedInfoLabel


func _ready() -> void:
	boy_select_btn.pressed.connect(func() -> void: _select_character("boy"))
	girl_select_btn.pressed.connect(func() -> void: _select_character("girl"))
	random_name_btn.pressed.connect(_on_random_name_pressed)
	confirm_btn.pressed.connect(_on_confirm_pressed)
	EventBus.viewport_breakpoint_changed.connect(_on_breakpoint_changed)

	_select_character(GameStateManager.selected_character)
	nickname_input.text = "Leo" if _selected_gender == "boy" else "Mia"
	_apply_responsive_layout()


func _select_character(gender: String) -> void:
	_selected_gender = gender
	var is_boy := gender == "boy"
	boy_card.modulate = Color.WHITE if is_boy else Color(0.82, 0.86, 0.92, 0.9)
	girl_card.modulate = Color.WHITE if not is_boy else Color(0.82, 0.86, 0.92, 0.9)
	boy_select_btn.text = "Đang chọn [OK]" if is_boy else "Chọn Leo"
	girl_select_btn.text = "Đang chọn [OK]" if not is_boy else "Chọn Mia"

	var cfg := DataRepository.get_character_config(gender)
	selected_info_label.text = "%s — %s" % [
		str(cfg.get("name_vi", gender)),
		str(cfg.get("stats_note_vi", ""))
	]

	var active_preview := boy_preview if is_boy else girl_preview
	var tw := create_tween()
	tw.tween_property(active_preview, "scale", Vector2(1.08, 1.08), 0.12)
	tw.tween_property(active_preview, "scale", Vector2.ONE, 0.15)


func _on_random_name_pressed() -> void:
	var pool := RANDOM_NAMES_BOY if _selected_gender == "boy" else RANDOM_NAMES_GIRL
	nickname_input.text = pool[randi() % pool.size()]


func _on_confirm_pressed() -> void:
	var nick := nickname_input.text.strip_edges()
	if nick.length() < 2:
		nick = "Leo" if _selected_gender == "boy" else "Mia"
	GameStateManager.set_character_profile(_selected_gender, nick)
	if not GameStateManager.world_intro_seen:
		SceneRouter.go_to_world_introduction()
	else:
		SceneRouter.enter_area("welcome_village")


func _on_breakpoint_changed(_bp: String, _size: Vector2) -> void:
	_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	var vp := get_viewport_rect().size
	cards_row.vertical = vp.x < 720.0
