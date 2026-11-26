extends Node2D
## Orchestrates the active Alphabet Island Area Exploration scene:
## instantiates the specific area layout, spawns Player + Buddy + NPCs + Interactables + Portals,
## wires InteractionManager, DialogueManager, QuestManager, and HUD.

const PLAYER_SCENE := preload("res://scenes/characters/player/player.tscn")
const BUDDY_SCENE := preload("res://scenes/characters/buddy/buddy.tscn")
const NPC_SCENE := preload("res://scenes/characters/npcs/npc.tscn")
const INTERACTABLE_SCENE := preload("res://scenes/interactions/interactable_object.tscn")

var _area_id: String = "welcome_village"
var _area_data: Dictionary = {}
var _player: PlayerController = null
var _buddy: BuddyController = null
var _pending_quest_offer_id: String = ""
var _autosave_timer: float = 0.0

@onready var area_container: Node2D = $AreaContainer
@onready var entities_ysort: Node2D = $EntitiesYSort
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
	var fallback := Vector2(float(def_spawn_dict.get("x", 640)), float(def_spawn_dict.get("y", 500)))
	var spawn_pos := GameStateManager.get_saved_position(_area_id, fallback)

	_player = PLAYER_SCENE.instantiate() as PlayerController
	_player.position = spawn_pos
	entities_ysort.add_child(_player)
	_player.set_camera_limits(Rect2i(0, 0, 1280, 720))

	_buddy = BUDDY_SCENE.instantiate() as BuddyController
	entities_ysort.add_child(_buddy)
	_buddy.attach_to_player(_player)

	var detector := _player.get_node("InteractionDetector") as Area2D
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
		npc.position = Vector2(float(sp.get("x", 500)), float(sp.get("y", 350)))
		npc.setup(npc_cfg)
		entities_ysort.add_child(npc)


func _spawn_objects() -> void:
	var objects := DataRepository.get_objects_for_area(_area_id)
	var pos_map := _get_object_positions_from_area_scene()
	for obj_cfg in objects:
		var oid := str(obj_cfg.get("id", ""))
		var obj := INTERACTABLE_SCENE.instantiate() as InteractableObject
		obj.position = pos_map.get(oid, Vector2(640, 420))
		obj.setup_from_data(obj_cfg)
		entities_ysort.add_child(obj)


func _spawn_portals() -> void:
	var portal_markers := _get_portal_markers_from_area_scene()
	for pm in portal_markers:
		var dest_area := str(pm.get("dest_area_id", ""))
		if dest_area.is_empty():
			continue
		var portal := INTERACTABLE_SCENE.instantiate() as InteractableObject
		portal.position = pm.get("position", Vector2.ZERO)
		portal.setup_portal("portal_to_" + dest_area, dest_area, pm.get("dest_spawn", Vector2(640, 500)))
		entities_ysort.add_child(portal)


func _get_object_positions_from_area_scene() -> Dictionary:
	var map: Dictionary = {}
	if area_container.get_child_count() == 0:
		return map
	var env_root := area_container.get_child(0)
	var markers := env_root.get_node_or_null("ObjectSpawns")
	if markers != null:
		for child in markers.get_children():
			if child is Node2D:
				map[child.name] = child.position
	return map


func _get_portal_markers_from_area_scene() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	if area_container.get_child_count() == 0:
		return list
	var env_root := area_container.get_child(0)
	var portals := env_root.get_node_or_null("PortalSpawns")
	if portals != null:
		for child in portals.get_children():
			if child is Node2D and child.has_meta("dest_area_id"):
				var spawn_vec := Vector2(-1, -1)
				if child.has_meta("dest_spawn"):
					spawn_vec = child.get_meta("dest_spawn")
				list.append({
					"position": child.position,
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
	hud.quest_accepted.connect(func(qid: String) -> void:
		QuestManager.start_quest(qid)
		hud.show_toast("Đã nhận nhiệm vụ mới!")
	)


func _on_npc_interacted(npc_data: Dictionary) -> void:
	var npc_id := str(npc_data.get("id", ""))
	GameStateManager.mark_npc_met(npc_id)
	if npc_data.has("on_talk_set_flag") and not str(npc_data["on_talk_set_flag"]).is_empty():
		GameStateManager.set_flag(str(npc_data["on_talk_set_flag"]), true)
	QuestManager.report_npc_talk(npc_id)

	_pending_quest_offer_id = QuestManager.has_available_quest_for_npc(npc_id)

	var dlg_id := str(npc_data.get("default_dialogue_id", ""))
	if npc_id == "professor_owl" and GameStateManager.completed_quests.has("quest_01_new_adventure"):
		dlg_id = "dlg_owl_quest_done"
	elif npc_id == "lily" and GameStateManager.completed_quests.has("quest_01_new_adventure"):
		dlg_id = "dlg_lily_after_q1"

	if not dialogue_manager.start_dialogue(dlg_id):
		if not _pending_quest_offer_id.is_empty():
			hud.show_quest_intro(_pending_quest_offer_id)
			_pending_quest_offer_id = ""


func _on_object_message(title: String, message: String, _obj_data: Dictionary) -> void:
	dialogue_manager.start_custom_message(title, message, "buddy")


func _on_dialogue_finished(_dialogue_id: String) -> void:
	hud.dialogue_box.visible = false
	if not _pending_quest_offer_id.is_empty():
		var qid := _pending_quest_offer_id
		_pending_quest_offer_id = ""
		hud.show_quest_intro(qid)


func _play_buddy_area_greeting() -> void:
	var greeting: Dictionary = DataRepository.buddy_config.get("area_greetings", {}).get(_area_id, {})
	if not greeting.is_empty():
		_buddy.speak_tip(LocalizationManager.pick_text(greeting, "text"), str(greeting.get("state", "happy")), 5.5)


func _process(delta: float) -> void:
	if _player != null:
		GameStateManager.set_player_position(_area_id, _player.position)
	_autosave_timer += delta
	if _autosave_timer >= 8.0:
		_autosave_timer = 0.0
		GameStateManager.save_now("autosave")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_H:
		if _buddy != null:
			_buddy.offer_contextual_help()


func _exit_tree() -> void:
	if _player != null:
		GameStateManager.set_player_position(_area_id, _player.position)
	GameStateManager.save_now("exit_area")
