extends Node
## Autoload MiniGameManager: orchestrates Registry, Session, DataProvider, Audio,
## World-to-MiniGame transitions (pausing 3D movement & restoring exact position),
## Quest integration, and EventBus notifications.

signal launch_modal_requested(session: MiniGameSession)
signal close_modal_requested()
signal launch_arcade_requested()

var registry: MiniGameRegistry
var audio: MiniGameAudioManager
var active_session: MiniGameSession = null
var _ui_host: MiniGameUI = null
var _saved_world_position: Vector3 = Vector3.ZERO
var _has_saved_world_pos: bool = false
var _last_result: MiniGameResult = null


func _ready() -> void:
	registry = MiniGameRegistry.new()
	registry.reload()
	audio = MiniGameAudioManager.new()
	var host_scene := load("res://scenes/minigames/minigame_host_modal.tscn")
	if host_scene is PackedScene:
		var inst := (host_scene as PackedScene).instantiate()
		if inst is MiniGameUI:
			_ui_host = inst as MiniGameUI
			add_child(_ui_host)
	EventBus.learning_hook_requested.connect(_on_learning_hook_requested)
	AppLogger.info("MiniGameManager", "Initialized with %d registered mini-games (%d playable)." % [
		registry.get_all_entries().size(),
		registry.get_playable_entries().size()
	])


func get_all_minigames() -> Array[Dictionary]:
	return registry.get_all_entries()


func get_playable_minigames() -> Array[Dictionary]:
	return registry.get_playable_entries()


func is_minigame_active() -> bool:
	return active_session != null


func open_arcade_launcher() -> void:
	launch_arcade_requested.emit()


func start_minigame(minigame_id: String, context: Dictionary = {}, requested_tier: String = "auto") -> bool:
	if active_session != null:
		AppLogger.warn("MiniGameManager", "Already inside active session: " + active_session.minigame_id)
		return false

	var entry := registry.get_entry(minigame_id)
	if entry.is_empty():
		EventBus.toast_requested.emit("Không tìm thấy mini-game: " + minigame_id, "warning")
		return false

	var status := str(entry.get("availability_status", ""))
	if status == "planned_template":
		EventBus.toast_requested.emit("Mini-game '%s' thuộc lộ trình mở rộng (Prompt 06+)." % str(entry.get("name_vi", minigame_id)), "info")
		return false

	if not registry.is_unlocked(minigame_id) and not bool(context.get("bypass_unlock", false)):
		EventBus.toast_requested.emit("Hãy hoàn thành thử thách mở đầu trước để mở khóa mini-game này!", "info")
		return false

	var tier := MiniGameDifficulty.resolve_adaptive_tier(minigame_id, requested_tier)
	var diff_cfg := MiniGameDifficulty.get_config_for(minigame_id, tier)
	if context.has("mode"):
		diff_cfg["mode"] = str(context.get("mode"))

	var items := MiniGameDataProvider.build_items_for(minigame_id, diff_cfg, context)
	if items.is_empty():
		EventBus.toast_requested.emit("Chưa đủ dữ liệu từ Learning Engine cho mini-game này.", "warning")
		return false

	var sess := MiniGameSession.new(entry, context, tier, diff_cfg)
	sess.set_items(items)
	active_session = sess

	# Capture exact 3D player position if present in current scene
	_capture_player_position()
	get_tree().paused = true
	audio.duck_bgm_for_speech(true)

	EventBus.minigame_started.emit(minigame_id, context)
	launch_modal_requested.emit(sess)
	AppLogger.info("MiniGameManager", "Started '%s' (tier=%s, items=%d, source=%s)" % [
		minigame_id, tier, items.size(), str(context.get("source_type", "arcade"))
	])
	return true


func complete_active_session() -> MiniGameResult:
	if active_session == null:
		return null
	var result := active_session.finalize_session()
	_last_result = result
	EventBus.minigame_completed.emit(result.minigame_id, result.to_dict())
	EventBus.progress_updated.emit()
	return result


func close_active_session() -> void:
	if active_session == null:
		return
	active_session.current_stage = MiniGameSession.Stage.RETURNED
	var finished_id := active_session.minigame_id
	active_session = null
	audio.duck_bgm_for_speech(false)
	get_tree().paused = false
	_restore_player_position()
	close_modal_requested.emit()
	AppLogger.info("MiniGameManager", "Returned cleanly to 3D world from mini-game: " + finished_id)


func get_last_result() -> MiniGameResult:
	return _last_result


func _capture_player_position() -> void:
	_has_saved_world_pos = false
	var player := get_tree().get_first_node_in_group("player")
	if player is Node3D:
		_saved_world_position = (player as Node3D).global_position
		_has_saved_world_pos = true


func _restore_player_position() -> void:
	if not _has_saved_world_pos:
		return
	var player := get_tree().get_first_node_in_group("player")
	if player is Node3D:
		(player as Node3D).global_position = _saved_world_position
	_has_saved_world_pos = false


func _on_learning_hook_requested(hook_payload: Dictionary) -> void:
	var mg_id := str(hook_payload.get("minigame_id", ""))
	if not mg_id.is_empty():
		var ctx := {
			"source_type": str(hook_payload.get("source_type", "quest")),
			"source_id": str(hook_payload.get("source_id", "")),
			"quest_id": str(hook_payload.get("quest_id", "")),
			"topic": str(hook_payload.get("topic", "")),
			"mode": str(hook_payload.get("mode", "")),
			"scenario_id": str(hook_payload.get("scenario_id", ""))
		}
		start_minigame(mg_id, ctx)
