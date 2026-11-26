class_name InteractionManager
extends Node
## Shared Interaction Manager tracking nearby NPCs & objects, highlighting closest target,
## and routing interaction actions uniformly.

signal target_changed(target_meta: Dictionary)
signal object_message_requested(title: String, message: String, object_data: Dictionary)
signal npc_interaction_requested(npc_data: Dictionary)

var _candidates: Array[Area2D] = []
var _current_target: Area2D = null
var _player_node: Node2D = null
var _locked: bool = false


func bind_detector(player: Node2D, detector_area: Area2D) -> void:
	_player_node = player
	detector_area.area_entered.connect(_on_area_entered)
	detector_area.area_exited.connect(_on_area_exited)
	EventBus.dialogue_started.connect(func(_id: String) -> void: _locked = true)
	EventBus.dialogue_ended.connect(func(_id: String) -> void: _locked = false)


func _process(_delta: float) -> void:
	if _locked or _player_node == null:
		return
	_refresh_closest_target()
	if Input.is_action_just_pressed("interact"):
		trigger_current_interaction()


func _unhandled_input(event: InputEvent) -> void:
	if _locked:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E and not event.is_action("interact"):
		trigger_current_interaction()


func trigger_current_interaction() -> void:
	if _locked or _current_target == null or not is_instance_valid(_current_target):
		return
	if _player_node is PlayerController:
		(_player_node as PlayerController).trigger_interact_anim()

	if _current_target is NpcController:
		var npc := _current_target as NpcController
		EventBus.interaction_triggered.emit(npc.npc_id, "npc")
		npc_interaction_requested.emit(npc.npc_data)
	elif _current_target is InteractableObject:
		var obj := _current_target as InteractableObject
		EventBus.interaction_triggered.emit(obj.object_id, obj.object_type)
		_handle_object_interaction(obj)


func _handle_object_interaction(obj: InteractableObject) -> void:
	if obj.object_type == "portal":
		SceneRouter.enter_area(obj.target_area_id, obj.target_spawn_pos)
		return

	var data := obj.object_data
	var title := LocalizationManager.pick_text(data, "title")
	var msg := LocalizationManager.pick_text(data, "message")
	var tag := str(data.get("tag", ""))

	var already_collected := GameStateManager.is_object_collected(obj.object_id)
	if bool(data.get("one_time_reward", false)) and not already_collected:
		GameStateManager.mark_object_collected(obj.object_id)
		var gold_amt := int(data.get("reward_gold", 0))
		if gold_amt > 0:
			GameStateManager.add_exp_and_gold(10, gold_amt)
		if data.has("reward_item") and typeof(data["reward_item"]) == TYPE_DICTIONARY:
			GameStateManager.add_item(data["reward_item"])
	elif already_collected and obj.object_type == "chest":
		msg = "Chiếc rương này bạn đã mở rồi!"

	if data.has("set_flag") and not str(data["set_flag"]).is_empty():
		GameStateManager.set_flag(str(data["set_flag"]), true)

	QuestManager.report_object_interacted(obj.object_id, tag)
	obj._refresh_visuals()
	GameStateManager.save_now("interact_" + obj.object_id)
	object_message_requested.emit(title, msg, data)


func _on_area_entered(area: Area2D) -> void:
	if (area is NpcController or area is InteractableObject) and not _candidates.has(area):
		_candidates.append(area)
		if not _locked:
			_refresh_closest_target()


func _on_area_exited(area: Area2D) -> void:
	_candidates.erase(area)
	if _locked:
		if _current_target == area:
			_set_focus(area, false)
			_current_target = null
			target_changed.emit({})
			EventBus.interactable_unfocused.emit()
		return
	_refresh_closest_target()


func _refresh_closest_target() -> void:
	var best: Area2D = null
	var best_dist := INF
	for c in _candidates:
		if not is_instance_valid(c) or not c.visible:
			continue
		var d := _player_node.global_position.distance_squared_to(c.global_position)
		if d < best_dist:
			best_dist = d
			best = c

	if best != _current_target:
		if _current_target != null and is_instance_valid(_current_target):
			_set_focus(_current_target, false)
		_current_target = best
		if _current_target != null:
			_set_focus(_current_target, true)
			var meta: Dictionary = _current_target.call("get_interaction_metadata")
			target_changed.emit(meta)
			EventBus.interactable_focused.emit(meta)
		else:
			target_changed.emit({})
			EventBus.interactable_unfocused.emit()


func _set_focus(node: Area2D, focused: bool) -> void:
	if node.has_method("set_focused"):
		node.call("set_focused", focused)
