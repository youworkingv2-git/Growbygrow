extends Control
## Main Menu Screen (#2): Logo, Alphabet Island illustration, Continue (guarded by valid save),
## New Game (with confirmation when save exists), World Map, Settings, and Platform-aware Quit.

@onready var safe_margin: MarginContainer = $SafeMargin
@onready var layout_box: BoxContainer = $SafeMargin/Center/MenuPanel/Margin/LayoutBox
@onready var hero_stage: Panel = $SafeMargin/Center/MenuPanel/Margin/LayoutBox/HeroCol/HeroStage
@onready var buddy_sprite: TextureRect = $SafeMargin/Center/MenuPanel/Margin/LayoutBox/HeroCol/HeroStage/BuddySprite
@onready var status_label: Label = $SafeMargin/Center/MenuPanel/Margin/LayoutBox/HeroCol/StatusLabel
@onready var title_label: Label = $SafeMargin/Center/MenuPanel/Margin/LayoutBox/ActionsCol/TitleLabel
@onready var subtitle_label: Label = $SafeMargin/Center/MenuPanel/Margin/LayoutBox/ActionsCol/SubtitleLabel
@onready var continue_btn: Button = $SafeMargin/Center/MenuPanel/Margin/LayoutBox/ActionsCol/Buttons/ContinueBtn
@onready var new_game_btn: Button = $SafeMargin/Center/MenuPanel/Margin/LayoutBox/ActionsCol/Buttons/NewGameBtn
@onready var world_map_btn: Button = $SafeMargin/Center/MenuPanel/Margin/LayoutBox/ActionsCol/Buttons/WorldMapBtn
@onready var settings_btn: Button = $SafeMargin/Center/MenuPanel/Margin/LayoutBox/ActionsCol/Buttons/SettingsBtn
@onready var quit_btn: Button = $SafeMargin/Center/MenuPanel/Margin/LayoutBox/ActionsCol/Buttons/QuitBtn

var _float_time: float = 0.0


func _ready() -> void:
	UIDesignSystem.apply_button_variant(continue_btn, "reward")
	UIDesignSystem.apply_button_variant(new_game_btn, "primary")
	UIDesignSystem.apply_button_variant(world_map_btn, "secondary")
	UIDesignSystem.apply_button_variant(settings_btn, "secondary")
	UIDesignSystem.apply_button_variant(quit_btn, "close")

	for b: Button in [continue_btn, new_game_btn, world_map_btn, settings_btn, quit_btn]:
		UIAnimator.attach_button_feedback(b)

	continue_btn.pressed.connect(_on_continue_pressed)
	new_game_btn.pressed.connect(_on_new_game_pressed)
	world_map_btn.pressed.connect(func() -> void: SceneRouter.go_to_world_map())
	settings_btn.pressed.connect(func() -> void: UIManager.open_settings(false))
	quit_btn.pressed.connect(_on_quit_pressed)

	EventBus.ui_locale_changed.connect(func(_l: String) -> void: _refresh_state())
	EventBus.viewport_breakpoint_changed.connect(func(_b: String, _s: Vector2) -> void: _apply_responsive())

	_refresh_state()
	_apply_responsive()


func _process(delta: float) -> void:
	if not UIAnimator.is_reduced():
		_float_time += delta
		buddy_sprite.position.y = 32.0 + sin(_float_time * 3.0) * 5.0


func _refresh_state() -> void:
	var has_save := SaveLoadManager.has_saved_profile()
	title_label.text = LocalizationManager.tr_key("app_title", "ENGLISH ADVENTURE")
	subtitle_label.text = LocalizationManager.tr_key("app_subtitle", "Cuộc Phiêu Lưu Học Tiếng Anh Kỳ Thú")
	settings_btn.text = LocalizationManager.tr_key("menu_settings", "Cài đặt")
	world_map_btn.text = LocalizationManager.tr_key("menu_world_map", "Bản Đồ Đảo")
	quit_btn.text = LocalizationManager.tr_key("menu_quit", "Thoát game")
	quit_btn.visible = not OS.has_feature("web")

	continue_btn.disabled = not has_save
	world_map_btn.disabled = not has_save

	if has_save:
		var area_cfg := DataRepository.get_area(GameStateManager.current_area_id)
		var area_name := LocalizationManager.pick_text(area_cfg, "name")
		if area_name.is_empty():
			area_name = GameStateManager.current_area_id
		status_label.text = "%s (Lv.%d) — %s" % [GameStateManager.nickname, GameStateManager.level, area_name]
		continue_btn.text = LocalizationManager.tr_key("menu_continue", "Tiếp tục Phiêu Lưu")
		new_game_btn.text = LocalizationManager.tr_key("menu_new_game_restart", "Chơi lại từ đầu")
	else:
		status_label.text = LocalizationManager.tr_key("menu_no_save_hint", "Chưa có hành trình đã lưu — hãy bấm Bắt đầu Phiêu lưu mới!")
		continue_btn.text = LocalizationManager.tr_key("menu_continue", "Tiếp tục Phiêu Lưu")
		new_game_btn.text = LocalizationManager.tr_key("menu_new_game", "Bắt đầu Phiêu lưu mới")


func _on_continue_pressed() -> void:
	if not SaveLoadManager.has_saved_profile():
		return
	if not GameStateManager.world_intro_seen:
		SceneRouter.go_to_world_introduction()
	else:
		SceneRouter.enter_area(GameStateManager.current_area_id)


func _on_new_game_pressed() -> void:
	if SaveLoadManager.has_saved_profile():
		var body_tpl := LocalizationManager.tr_key(
			"confirm_new_game_body",
			"Bạn đã có dữ liệu phiêu lưu của %s. Nếu bắt đầu lại từ đầu, tiến trình cũ sẽ được thay thế. Bạn chắc chắn chứ?"
		)
		UIManager.show_confirmation(
			LocalizationManager.tr_key("confirm_new_game_title", "Bắt đầu hành trình mới?"),
			body_tpl % GameStateManager.nickname,
			func() -> void: _start_fresh_adventure(),
			Callable(),
			LocalizationManager.tr_key("btn_yes_confirm", "Đồng ý"),
			LocalizationManager.tr_key("btn_cancel", "Hủy bỏ"),
			true
		)
	else:
		_start_fresh_adventure()


func _start_fresh_adventure() -> void:
	SaveLoadManager.delete_save()
	GameStateManager.reset_new_game()
	SceneRouter.go_to_character_selection()


func _on_quit_pressed() -> void:
	if OS.has_feature("web"):
		UIManager.show_notification(LocalizationManager.tr_key("menu_quit_web_hint", "Bạn có thể đóng tab trình duyệt để rời game bất cứ lúc nào!"), "info")
		return
	UIManager.show_confirmation(
		LocalizationManager.tr_key("confirm_quit_title", "Thoát English Adventure?"),
		LocalizationManager.tr_key("confirm_quit_body", "Tiến trình của bạn đã được lưu an toàn. Bạn muốn thoát khỏi trò chơi?"),
		func() -> void:
			GameStateManager.save_now("quit")
			get_tree().quit()
	)


func _apply_responsive() -> void:
	ResponsiveHelper.apply_safe_margin_to_container(safe_margin, get_viewport(), 14)
	var vp := get_viewport().get_visible_rect().size
	layout_box.vertical = vp.x < 700.0
	hero_stage.custom_minimum_size = Vector2(240, 150) if (vp.y < 520.0 or vp.x < 440.0) else Vector2(280, 210)
