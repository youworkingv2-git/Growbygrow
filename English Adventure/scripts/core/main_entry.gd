extends Control
## Boot / Entry Screen: routes new players to Character Selection and returning players
## to Continue / World Map / New Adventure.

@onready var continue_btn: Button = $CenterCard/Margin/VBox/Buttons/ContinueBtn
@onready var new_game_btn: Button = $CenterCard/Margin/VBox/Buttons/NewGameBtn
@onready var map_btn: Button = $CenterCard/Margin/VBox/Buttons/WorldMapBtn
@onready var status_label: Label = $CenterCard/Margin/VBox/StatusLabel


func _ready() -> void:
	continue_btn.pressed.connect(_on_continue_pressed)
	new_game_btn.pressed.connect(_on_new_game_pressed)
	map_btn.pressed.connect(_on_map_pressed)
	_refresh_boot_state()


func _refresh_boot_state() -> void:
	var has_save := SaveLoadManager.has_saved_profile()
	if has_save:
		var area_cfg := DataRepository.get_area(GameStateManager.current_area_id)
		var area_name := str(area_cfg.get("name_vi", GameStateManager.current_area_id))
		status_label.text = "Chào mừng trở lại, %s! (Khu vực: %s)" % [GameStateManager.nickname, area_name]
		continue_btn.visible = true
		map_btn.visible = true
		new_game_btn.text = "Chơi lại từ đầu"
	else:
		status_label.text = "Chào mừng tới Thế giới Phép Thuật Ngôn Ngữ!"
		continue_btn.visible = false
		map_btn.visible = false
		new_game_btn.text = "Bắt đầu Phiêu lưu mới!"


func _on_continue_pressed() -> void:
	if not GameStateManager.world_intro_seen:
		SceneRouter.go_to_world_introduction()
	else:
		SceneRouter.enter_area(GameStateManager.current_area_id)


func _on_map_pressed() -> void:
	SceneRouter.go_to_world_map()


func _on_new_game_pressed() -> void:
	SaveLoadManager.delete_save()
	GameStateManager.reset_new_game()
	SceneRouter.go_to_character_selection()
