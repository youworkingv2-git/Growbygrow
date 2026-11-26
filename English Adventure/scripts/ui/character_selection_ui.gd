extends Control
## Character Selection Screen (#3): Boy Adventurer vs Girl Adventurer, equal abilities,
## large illustration, descriptions, selection glow/pulse, nickname input, Back & Confirm guards.

const RANDOM_NAMES_BOY := ["Leo", "Minh", "Nam", "Khang", "Binh"]
const RANDOM_NAMES_GIRL := ["Mia", "Linh", "An", "Vy", "Chi"]

var _selected_gender: String = "boy"
var _is_submitting: bool = false

@onready var root_margin: MarginContainer = $RootMargin
@onready var back_btn: Button = $RootMargin/Scroll/VBox/HeaderRow/BackBtn
@onready var boy_card: PanelContainer = $RootMargin/Scroll/VBox/CardsRow/BoyCard
@onready var girl_card: PanelContainer = $RootMargin/Scroll/VBox/CardsRow/GirlCard
@onready var boy_select_btn: Button = $RootMargin/Scroll/VBox/CardsRow/BoyCard/Margin/VBox/SelectBoyBtn
@onready var girl_select_btn: Button = $RootMargin/Scroll/VBox/CardsRow/GirlCard/Margin/VBox/SelectGirlBtn
@onready var boy_preview: SubViewportContainer = $RootMargin/Scroll/VBox/CardsRow/BoyCard/Margin/VBox/Preview
@onready var girl_preview: SubViewportContainer = $RootMargin/Scroll/VBox/CardsRow/GirlCard/Margin/VBox/Preview
@onready var boy_desc: Label = $RootMargin/Scroll/VBox/CardsRow/BoyCard/Margin/VBox/Desc
@onready var girl_desc: Label = $RootMargin/Scroll/VBox/CardsRow/GirlCard/Margin/VBox/Desc
@onready var cards_row: BoxContainer = $RootMargin/Scroll/VBox/CardsRow
@onready var nickname_input: LineEdit = $RootMargin/Scroll/VBox/BottomPanel/Margin/VBox/NameRow/NicknameInput
@onready var random_name_btn: Button = $RootMargin/Scroll/VBox/BottomPanel/Margin/VBox/NameRow/RandomNameBtn
@onready var confirm_btn: Button = $RootMargin/Scroll/VBox/BottomPanel/Margin/VBox/ConfirmBtn
@onready var selected_info_label: Label = $RootMargin/Scroll/VBox/BottomPanel/Margin/VBox/SelectedInfoLabel


func _ready() -> void:
	UIDesignSystem.apply_button_variant(back_btn, "back")
	UIDesignSystem.apply_button_variant(random_name_btn, "secondary")
	UIDesignSystem.apply_button_variant(confirm_btn, "confirm")
	for b: Button in [back_btn, boy_select_btn, girl_select_btn, random_name_btn, confirm_btn]:
		UIAnimator.attach_button_feedback(b)

	back_btn.pressed.connect(func() -> void: SceneRouter.go_to_main_menu())
	boy_select_btn.pressed.connect(func() -> void: _select_character("boy"))
	girl_select_btn.pressed.connect(func() -> void: _select_character("girl"))
	random_name_btn.pressed.connect(_on_random_name_pressed)
	confirm_btn.pressed.connect(_on_confirm_pressed)
	EventBus.viewport_breakpoint_changed.connect(_on_breakpoint_changed)

	var boy_cfg := DataRepository.get_character_config("boy")
	var girl_cfg := DataRepository.get_character_config("girl")
	boy_desc.text = str(boy_cfg.get("description_vi", "Thích khám phá mọi ngóc ngách trên Đảo Chữ Cái cùng Buddy."))
	girl_desc.text = str(girl_cfg.get("description_vi", "Ham học hỏi, nhanh nhẹn và luôn sẵn sàng giúp đỡ cư dân."))

	_select_character(GameStateManager.selected_character)
	nickname_input.text = "Leo" if _selected_gender == "boy" else "Mia"
	_apply_responsive_layout()


func _select_character(gender: String) -> void:
	_selected_gender = gender
	var is_boy := gender == "boy"

	var selected_style := UIDesignSystem.make_panel_style(Color(0.14, 0.25, 0.44, 0.98), UIDesignSystem.SECONDARY, 16, 3, 0, 0)
	var idle_style := UIDesignSystem.make_panel_style(Color(0.1, 0.16, 0.28, 0.88), UIDesignSystem.BORDER_DEFAULT, 16, 2, 0, 0)
	boy_card.add_theme_stylebox_override("panel", selected_style if is_boy else idle_style)
	girl_card.add_theme_stylebox_override("panel", selected_style if not is_boy else idle_style)

	boy_card.modulate = Color.WHITE if is_boy else Color(0.84, 0.88, 0.94, 0.92)
	girl_card.modulate = Color.WHITE if not is_boy else Color(0.84, 0.88, 0.94, 0.92)

	UIDesignSystem.apply_button_variant(boy_select_btn, "reward" if is_boy else "primary")
	UIDesignSystem.apply_button_variant(girl_select_btn, "reward" if not is_boy else "primary")
	boy_select_btn.text = "Đang chọn Leo [OK]" if is_boy else "Chọn Leo"
	girl_select_btn.text = "Đang chọn Mia [OK]" if not is_boy else "Chọn Mia"

	var cfg := DataRepository.get_character_config(gender)
	selected_info_label.text = "Đã chọn: %s — %s" % [
		str(cfg.get("name_vi", gender)),
		str(cfg.get("stats_note_vi", ""))
	]

	var active_preview := boy_preview if is_boy else girl_preview
	UIAnimator.animate_pulse_once(active_preview)


func _on_random_name_pressed() -> void:
	var pool := RANDOM_NAMES_BOY if _selected_gender == "boy" else RANDOM_NAMES_GIRL
	nickname_input.text = pool[randi() % pool.size()]


func _on_confirm_pressed() -> void:
	if _is_submitting:
		return
	var nick := nickname_input.text.strip_edges()
	if nick.length() < 2:
		UIManager.show_notification("Biệt danh cần tối thiểu 2 ký tự — đã điền tên gợi ý giúp bạn!", "warning")
		nick = "Leo" if _selected_gender == "boy" else "Mia"
		nickname_input.text = nick
		return
	_is_submitting = true
	confirm_btn.disabled = true
	GameStateManager.set_character_profile(_selected_gender, nick)
	if not GameStateManager.world_intro_seen:
		SceneRouter.go_to_world_introduction()
	else:
		SceneRouter.enter_area("welcome_village")


func _on_breakpoint_changed(_bp: String, _size: Vector2) -> void:
	_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	ResponsiveHelper.apply_safe_margin_to_container(root_margin, get_viewport(), 18)
	var vp := get_viewport().get_visible_rect().size
	cards_row.vertical = vp.x < 720.0
	var compact_h := vp.y < 540.0
	boy_preview.custom_minimum_size = Vector2(96, 108) if compact_h else Vector2(128, 150)
	girl_preview.custom_minimum_size = Vector2(96, 108) if compact_h else Vector2(128, 150)
