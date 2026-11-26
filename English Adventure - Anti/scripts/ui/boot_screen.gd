extends Control
## Boot screen: checks saved profile and routes to Character Select or World Map.

func _ready() -> void:
	await get_tree().create_timer(0.6).timeout
	if SaveManager.has_selected_character():
		GameManager.go_to_world_map()
	else:
		GameManager.go_to_character_select()
