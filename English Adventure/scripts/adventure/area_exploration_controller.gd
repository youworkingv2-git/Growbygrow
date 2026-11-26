extends Node3D
## Orchestrates the active 3D Alphabet Island Area Exploration scene:
## instantiates the specific 3D area layout, configures lighting/quality via WorldEnvironment3DController,
## spawns 3D Player + Buddy + NPCs + Interactables + Portals using Coord3D compatibility,
## and wires InteractionManager, DialogueManager, QuestManager, and HUD.

const PLAYER_SCENE := preload("res://scenes/characters/player/player.tscn")
const BUDDY_SCENE := preload("res://scenes/characters/buddy/buddy.tscn")
const NPC_SCENE := preload("res://scenes/characters/npcs/npc.tscn")
const INTERACTABLE_SCENE := preload("res://scenes/interactions/interactable_object.tscn")

var _area_id: String = "welcome_village"
var _area_data: Dictionary = {}
var _player: PlayerController = null
var _buddy: BuddyController = null
var _pending_quest_offer_id: String = ""
var _pending_learning_lesson_id: String = ""
var _pending_minigame_id: String = ""
var _pending_minigame_ctx: Dictionary = {}
var _autosave_timer: float = 0.0

@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var sun_light: DirectionalLight3D = $DirectionalLight3D
@onready var env_controller: WorldEnvironment3DController = $Env3DController
@onready var area_container: Node3D = $AreaContainer
@onready var entities_3d: Node3D = $Entities3D
@onready var interaction_manager: InteractionManager = $InteractionManager
@onready var dialogue_manager: DialogueManager = $DialogueManager
@onready var hud: CanvasLayer = $AdventureHUD


func _ready() -> void:
	_area_id = GameStateManager.current_area_id
	if not GameStateManager.is_area_unlocked(_area_id):
		_area_id = "welcome_village"
		GameStateManager.current_area_id = _area_id

	_area_data = DataRepository.get_area(_area_id)
	hud.set_area_header(_area_data)

	env_controller.setup_for_area(_area_id, world_env, sun_light)
	_load_area_environment()
	_spawn_player_and_buddy()
	_spawn_npcs()
	_spawn_objects()
	_spawn_portals()
	_connect_systems()

	EventBus.area_entered.emit(_area_id)
	_play_buddy_area_greeting()
	_check_auto_quest_offer_on_area_enter()


func _check_auto_quest_offer_on_area_enter() -> void:
	for q in DataRepository.quests_ordered:
		var qid := str(q.get("id", ""))
		if str(q.get("area_id", "")) == _area_id and QuestManager.get_quest_status(qid) == "available":
			var giver_id := str(q.get("giver_npc_id", ""))
			var giver_cfg: Dictionary = DataRepository.npcs_by_id.get(giver_id, {})
			if str(giver_cfg.get("area_id", "")) != _area_id:
				hud.show_quest_intro(qid)
				break


func _load_area_environment() -> void:
	for c in area_container.get_children():
		c.queue_free()
	var scene_path := str(_area_data.get("scene_path", "res://scenes/world/areas/welcome_village.tscn"))
	if ResourceLoader.exists(scene_path):
		var packed := load(scene_path) as PackedScene
		if packed != null:
			area_container.add_child(packed.instantiate())


func _spawn_player_and_buddy() -> void:
	var def_spawn_dict: Dictionary = _area_data.get("default_spawn", { "x": 640, "y": 500 })
	var fallback_2d := Vector2(float(def_spawn_dict.get("x", 640)), float(def_spawn_dict.get("y", 500)))
	var spawn_2d := GameStateManager.get_saved_position(_area_id, fallback_2d)

	_player = PLAYER_SCENE.instantiate() as PlayerController
	_player.position = Coord3D.to_3d(spawn_2d, 0.05)
	_player.set_world_bounds(Coord3D.WORLD_HALF_X, Coord3D.WORLD_HALF_Z)
	entities_3d.add_child(_player)

	_buddy = BUDDY_SCENE.instantiate() as BuddyController
	entities_3d.add_child(_buddy)
	_buddy.attach_to_player(_player)

	var detector := _player.get_node("InteractionDetector") as Area3D
	interaction_manager.bind_detector(_player, detector)


func _spawn_npcs() -> void:
	var npcs := DataRepository.get_npcs_for_area(_area_id)
	var snapshot := GameStateManager.to_state_dict()
	for npc_cfg in npcs:
		var cond: Dictionary = npc_cfg.get("appear_condition", {})
		if not UnlockEvaluator.is_condition_met(cond, snapshot):
			continue
		var npc := NPC_SCENE.instantiate() as NpcController
		var sp: Dictionary = npc_cfg.get("spawn_pos", { "x": 500, "y": 350 })
		var pos_2d := Vector2(float(sp.get("x", 500)), float(sp.get("y", 350)))
		npc.position = Coord3D.to_3d(pos_2d, 0.0)
		npc.setup(npc_cfg)
		entities_3d.add_child(npc)


func _spawn_objects() -> void:
	var objects := DataRepository.get_objects_for_area(_area_id)
	var pos_map := _get_object_positions_from_area_scene()
	for obj_cfg in objects:
		var oid := str(obj_cfg.get("id", ""))
		var obj := INTERACTABLE_SCENE.instantiate() as InteractableObject
		var fallback_3d := Coord3D.to_3d(Vector2(640, 420), 0.0)
		var pos_val: Variant = pos_map.get(oid, fallback_3d)
		if pos_val is Vector3:
			obj.position = pos_val
		elif pos_val is Vector2:
			obj.position = Coord3D.to_3d(pos_val, 0.0)
		else:
			obj.position = fallback_3d
		obj.setup_from_data(obj_cfg)
		entities_3d.add_child(obj)


func _spawn_portals() -> void:
	var portal_markers := _get_portal_markers_from_area_scene()
	for pm in portal_markers:
		var dest_area := str(pm.get("dest_area_id", ""))
		if dest_area.is_empty():
			continue
		var portal := INTERACTABLE_SCENE.instantiate() as InteractableObject
		var p_pos: Variant = pm.get("position", Vector3.ZERO)
		portal.position = p_pos if p_pos is Vector3 else Vector3.ZERO
		portal.setup_portal("portal_to_" + dest_area, dest_area, pm.get("dest_spawn", Vector2(640, 500)))
		entities_3d.add_child(portal)


func _get_object_positions_from_area_scene() -> Dictionary:
	var map: Dictionary = {}
	if area_container.get_child_count() == 0:
		return map
	var env_root := area_container.get_child(0)
	var markers := env_root.get_node_or_null("ObjectSpawns")
	if markers != null:
		for child in markers.get_children():
			if child is Node3D:
				map[child.name] = (child as Node3D).position
			elif child is Node2D:
				map[child.name] = Coord3D.to_3d((child as Node2D).position, 0.0)
	return map


func _get_portal_markers_from_area_scene() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	if area_container.get_child_count() == 0:
		return list
	var env_root := area_container.get_child(0)
	var portals := env_root.get_node_or_null("PortalSpawns")
	if portals != null:
		for child in portals.get_children():
			if child.has_meta("dest_area_id"):
				var spawn_vec := Vector2(-1, -1)
				if child.has_meta("dest_spawn"):
					spawn_vec = child.get_meta("dest_spawn")
				var pos_3d := Vector3.ZERO
				if child is Node3D:
					pos_3d = (child as Node3D).position
				elif child is Node2D:
					pos_3d = Coord3D.to_3d((child as Node2D).position, 0.0)
				list.append({
					"position": pos_3d,
					"dest_area_id": str(child.get_meta("dest_area_id")),
					"dest_spawn": spawn_vec
				})
	return list


func _connect_systems() -> void:
	interaction_manager.target_changed.connect(func(meta: Dictionary) -> void: hud.set_focused_target(meta))
	interaction_manager.npc_interaction_requested.connect(_on_npc_interacted)
	interaction_manager.object_message_requested.connect(_on_object_message)

	dialogue_manager.line_changed.connect(func(line: Dictionary, idx: int, total: int) -> void:
		hud.dialogue_box.show_line(line, idx, total, true)
	)
	dialogue_manager.sequence_finished.connect(_on_dialogue_finished)
	hud.dialogue_box.next_requested.connect(func() -> void: dialogue_manager.next_line())
	hud.dialogue_box.close_requested.connect(func() -> void: dialogue_manager.close_dialogue())

	hud.interact_pressed.connect(func() -> void: interaction_manager.trigger_current_interaction())
	hud.jump_pressed.connect(func() -> void: _player.trigger_jump())
	hud.buddy_help_pressed.connect(func() -> void: _buddy.offer_contextual_help())
	hud.joystick_changed.connect(func(vec: Vector2) -> void: _player.set_virtual_joystick(vec))
	hud.camera_look_delta.connect(func(delta_px: Vector2) -> void: _player.apply_look_delta(delta_px))
	hud.overlay_blocking_changed.connect(func(blocked: bool) -> void: interaction_manager.set_ui_blocked(blocked))
	hud.quest_accepted.connect(func(qid: String) -> void:
		QuestManager.start_quest(qid)
	)


func _on_npc_interacted(npc_data: Dictionary) -> void:
	var npc_id := str(npc_data.get("id", ""))
	GameStateManager.mark_npc_met(npc_id)
	if npc_data.has("on_talk_set_flag") and not str(npc_data["on_talk_set_flag"]).is_empty():
		GameStateManager.set_flag(str(npc_data["on_talk_set_flag"]), true)

	var dlg_id := str(npc_data.get("default_dialogue_id", ""))
	if npc_id == "professor_owl" and GameStateManager.completed_quests.has("quest_01_new_adventure"):
		dlg_id = "dlg_owl_quest_done"
	elif npc_id == "lily" and GameStateManager.completed_quests.has("quest_01_new_adventure"):
		dlg_id = "dlg_lily_after_q1"

	var started_dlg := dialogue_manager.start_dialogue(dlg_id)
	QuestManager.report_npc_talk(npc_id)
	_pending_quest_offer_id = QuestManager.has_available_quest_for_npc(npc_id)

	# Connect NPCs to contextual Mini-Games after their quest intro / dialogue
	_pending_minigame_id = ""
	_pending_minigame_ctx = {}
	if _pending_quest_offer_id.is_empty():
		if npc_id == "professor_owl" and GameStateManager.completed_quests.has("quest_01_new_adventure"):
			_pending_minigame_id = "listen_and_find"
			_pending_minigame_ctx = { "source_type": "npc", "source_id": npc_id, "bypass_unlock": true }
		elif npc_id == "lily" and GameStateManager.completed_quests.has("quest_01_new_adventure"):
			_pending_minigame_id = "dialogue_adventure"
			_pending_minigame_ctx = { "source_type": "npc", "source_id": npc_id, "bypass_unlock": true }
		elif npc_id == "rocky":
			_pending_minigame_id = "speaking_hero"
			_pending_minigame_ctx = { "source_type": "npc", "source_id": npc_id, "bypass_unlock": true }
		elif npc_id == "crystal_guardian":
			_pending_minigame_id = "sentence_builder"
			_pending_minigame_ctx = { "source_type": "npc", "source_id": npc_id, "bypass_unlock": true }

	if not started_dlg:
		if not _pending_quest_offer_id.is_empty():
			hud.show_quest_intro(_pending_quest_offer_id)
			_pending_quest_offer_id = ""
		elif not _pending_minigame_id.is_empty():
			var mg_id := _pending_minigame_id
			var mg_ctx := _pending_minigame_ctx.duplicate(true)
			_pending_minigame_id = ""
			_pending_minigame_ctx = {}
			MiniGameManager.start_minigame(mg_id, mg_ctx)


func _on_object_message(title: String, message: String, obj_data: Dictionary) -> void:
	var oid := str(obj_data.get("id", ""))
	_pending_minigame_id = ""
	_pending_minigame_ctx = {}
	if oid == "obj_shadow_gate_seal":
		_pending_minigame_id = "sentence_builder"
		_pending_minigame_ctx = { "source_type": "object", "source_id": oid, "bypass_unlock": true }
	elif oid == "obj_meadow_chest":
		_pending_minigame_id = "word_builder"
		_pending_minigame_ctx = { "source_type": "object", "source_id": oid, "bypass_unlock": true }
	elif oid == "obj_village_chest":
		_pending_minigame_id = "word_matching"
		_pending_minigame_ctx = { "source_type": "object", "source_id": oid, "bypass_unlock": true }
	elif oid == "obj_cave_sign":
		_pending_minigame_id = "sound_detective"
		_pending_minigame_ctx = { "source_type": "object", "source_id": oid, "bypass_unlock": true }
	elif oid == "obj_lake_chest":
		_pending_minigame_id = "memory_quest"
		_pending_minigame_ctx = { "source_type": "object", "source_id": oid, "bypass_unlock": true }
	elif oid == "obj_letter_e":
		_pending_minigame_id = "listen_and_find"
		_pending_minigame_ctx = { "source_type": "object", "source_id": oid, "bypass_unlock": true }
	elif oid in ["obj_letter_a", "obj_letter_b", "obj_letter_c"]:
		_pending_learning_lesson_id = "lesson_01_01_abc"
	dialogue_manager.start_custom_message(title, message, "buddy")


func _on_dialogue_finished(_dialogue_id: String) -> void:
	hud.dialogue_box.visible = false
	if _player != null:
		_player.clear_dialogue_focus()
	if not _pending_quest_offer_id.is_empty():
		var qid := _pending_quest_offer_id
		_pending_quest_offer_id = ""
		_pending_minigame_id = ""
		hud.show_quest_intro(qid)
	elif not _pending_minigame_id.is_empty():
		var mg_id := _pending_minigame_id
		var mg_ctx := _pending_minigame_ctx.duplicate(true)
		_pending_minigame_id = ""
		_pending_minigame_ctx = {}
		MiniGameManager.start_minigame(mg_id, mg_ctx)
	elif not _pending_learning_lesson_id.is_empty():
		var lid := _pending_learning_lesson_id
		_pending_learning_lesson_id = ""
		hud.open_learning_hub(lid)


func _play_buddy_area_greeting() -> void:
	var greeting: Dictionary = DataRepository.buddy_config.get("area_greetings", {}).get(_area_id, {})
	if not greeting.is_empty():
		_buddy.speak_tip(LocalizationManager.pick_text(greeting, "text"), str(greeting.get("state", "happy")), 5.5)


func _process(delta: float) -> void:
	if GameStateManager.current_area_id != _area_id:
		return
	if _player != null:
		GameStateManager.set_player_position(_area_id, Coord3D.to_2d(_player.position))
	_autosave_timer += delta
	if _autosave_timer >= 8.0:
		_autosave_timer = 0.0
		GameStateManager.save_now("autosave")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_H:
		if _buddy != null:
			_buddy.offer_contextual_help()


func _exit_tree() -> void:
	if GameStateManager.current_area_id != _area_id:
		return
	if _player != null:
		GameStateManager.set_player_position(_area_id, Coord3D.to_2d(_player.position))
	GameStateManager.save_now("exit_area")
