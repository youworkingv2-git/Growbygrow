extends Node
## Centralized Scene Router with area unlock guard, transition fade, and responsive breakpoint tracking.

enum Breakpoint { MOBILE_PORTRAIT, MOBILE_LANDSCAPE, TABLET, DESKTOP }

const SCENE_BOOT := "res://scenes/boot/main_entry.tscn"
const SCENE_CHAR_SELECT := "res://scenes/authentication/character_selection.tscn"
const SCENE_WORLD_INTRO := "res://scenes/world/world_introduction.tscn"
const SCENE_WORLD_MAP := "res://scenes/world/world_map/world_map.tscn"
const SCENE_EXPLORATION := "res://scenes/world/alphabet_island/area_exploration.tscn"

var current_breakpoint: Breakpoint = Breakpoint.DESKTOP
var _is_transitioning: bool = false
var _transition_layer: CanvasLayer = null
var _fade_rect: ColorRect = null


func _ready() -> void:
	get_tree().root.size_changed.connect(_update_breakpoint)
	_update_breakpoint()
	_build_transition_overlay()


func _build_transition_overlay() -> void:
	_transition_layer = CanvasLayer.new()
	_transition_layer.layer = 100
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0.06, 0.09, 0.16, 0.0)
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_layer.add_child(_fade_rect)
	add_child(_transition_layer)


func _update_breakpoint() -> void:
	var vp_size := get_viewport().get_visible_rect().size
	var win_size := Vector2(DisplayServer.window_get_size())
	var ref_w := minf(vp_size.x, win_size.x) if win_size.x > 0.0 else vp_size.x
	var ref_h := minf(vp_size.y, win_size.y) if win_size.y > 0.0 else vp_size.y
	var next_bp: Breakpoint = Breakpoint.DESKTOP
	if vp_size.y > vp_size.x or (ref_w < 768.0 and ref_h > ref_w):
		next_bp = Breakpoint.MOBILE_PORTRAIT
	elif ref_h < 540.0 and ref_w >= ref_h:
		next_bp = Breakpoint.MOBILE_LANDSCAPE
	elif ref_w < 1150.0:
		next_bp = Breakpoint.TABLET
	else:
		next_bp = Breakpoint.DESKTOP

	if next_bp != current_breakpoint:
		current_breakpoint = next_bp
	EventBus.viewport_breakpoint_changed.emit(get_breakpoint_name(), vp_size)


func get_breakpoint_name() -> String:
	return Breakpoint.keys()[current_breakpoint]


func is_mobile_or_compact() -> bool:
	return (
		current_breakpoint == Breakpoint.MOBILE_PORTRAIT
		or current_breakpoint == Breakpoint.MOBILE_LANDSCAPE
		or OS.has_feature("mobile")
		or OS.has_feature("web_android")
		or OS.has_feature("web_ios")
	)


func go_to_scene(scene_path: String) -> void:
	if _is_transitioning:
		return
	_transition_to(scene_path)


func go_to_character_selection() -> void:
	go_to_scene(SCENE_CHAR_SELECT)


func go_to_world_introduction() -> void:
	go_to_scene(SCENE_WORLD_INTRO)


func go_to_world_map() -> void:
	GameStateManager.save_now("enter_world_map")
	go_to_scene(SCENE_WORLD_MAP)


func enter_area(area_id: String, custom_spawn: Vector2 = Vector2(-1, -1)) -> bool:
	# Security / Unlock Guard: prevent entering locked areas directly
	if not GameStateManager.is_area_unlocked(area_id):
		var area_cfg := DataRepository.get_area(area_id)
		var cond: Dictionary = area_cfg.get("unlock_condition", {})
		var reason := str(cond.get("description_vi", "Khu vực này chưa được mở khóa!"))
		AppLogger.warn("SceneRouter", "Blocked entry to locked area: " + area_id)
		EventBus.area_locked_attempted.emit(area_id, reason)
		return false

	var area_data := DataRepository.get_area(area_id)
	if area_data.is_empty():
		AppLogger.error("SceneRouter", "Unknown area_id: " + area_id)
		return false

	GameStateManager.current_area_id = area_id
	if custom_spawn.x >= 0 and custom_spawn.y >= 0:
		GameStateManager.set_player_position(area_id, custom_spawn)
	GameStateManager.save_now("enter_area_" + area_id)
	go_to_scene(SCENE_EXPLORATION)
	return true


func _transition_to(scene_path: String) -> void:
	_is_transitioning = true
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tw := create_tween()
	tw.tween_property(_fade_rect, "color:a", 1.0, 0.2)
	await tw.finished
	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		AppLogger.error("SceneRouter", "Failed to load scene %s (err=%d)" % [scene_path, err])
	var tw_in := create_tween()
	tw_in.tween_property(_fade_rect, "color:a", 0.0, 0.25)
	await tw_in.finished
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_is_transitioning = false
