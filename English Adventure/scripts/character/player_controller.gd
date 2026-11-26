class_name PlayerController
extends CharacterBody3D
## Third-person 3D Adventurer Controller with:
## - Camera-relative movement (WASD / Arrows / VirtualJoystick)
## - SpringArm3D collision-safe third-person camera with mouse/touch/key orbit
## - Smooth 3D jump & gravity
## - Dialogue framing support

@export var walk_speed: float = 6.2
@export var run_speed: float = 9.2
@export var jump_velocity: float = 7.4
@export var gravity: float = 20.0
@export var world_half_extent_x: float = 20.0
@export var world_half_extent_z: float = 11.5

@export_group("Third-person Camera Manager")
@export_range(4.0, 10.5, 0.2) var camera_distance: float = 6.8
@export_range(0.9, 2.5, 0.05) var camera_height: float = 1.55
@export_range(0.4, 2.0, 0.1) var camera_sensitivity: float = 1.0
@export_range(3.0, 16.0, 0.5) var camera_smoothing: float = 8.5
@export_range(0.8, 3.5, 0.1) var camera_rotation_speed: float = 1.9
@export var camera_collision: bool = true

var virtual_move_vector: Vector2 = Vector2.ZERO
var movement_locked: bool = false
var _last_facing: Vector3 = Vector3.BACK

@onready var visual_slot: Asset3DSlot = $VisualSlot
@onready var animator: CharacterAnimator = $CharacterAnimator
@onready var camera_pivot: Node3D = $CameraPivot
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D

var _rig: CharacterRig3D = null
var _dialogue_locked: bool = false
var _pause_locked: bool = false
var _cam_yaw: float = 0.0
var _cam_pitch: float = -0.44
var _orbit_dragging: bool = false
var _dialogue_focus_active: bool = false
var _dialogue_focus_pos: Vector3 = Vector3.ZERO


func _ready() -> void:
	add_to_group("player")
	apply_character_visual(GameStateManager.selected_character)
	_sync_camera_settings()
	EventBus.dialogue_started.connect(_on_dialogue_started)
	EventBus.dialogue_ended.connect(_on_dialogue_ended)
	EventBus.pause_toggled.connect(_on_pause_toggled)
	EventBus.settings_changed.connect(_sync_camera_settings)


func _sync_camera_settings() -> void:
	camera_sensitivity = SettingsManager.camera_sensitivity
	if spring_arm != null:
		spring_arm.collision_mask = 2 if camera_collision else 0
		if not _dialogue_focus_active:
			spring_arm.spring_length = clampf(camera_distance, 4.0, 10.5)


func apply_look_delta(delta_px: Vector2) -> void:
	if _dialogue_locked or _pause_locked or UIManager.is_modal_open():
		return
	var yaw_step := clampf(delta_px.x * 0.0055 * camera_sensitivity, -0.14, 0.14)
	var pitch_step := clampf(delta_px.y * 0.0042 * camera_sensitivity, -0.10, 0.10)
	_cam_yaw -= yaw_step
	_cam_pitch = clampf(_cam_pitch - pitch_step, -0.92, -0.18)


func apply_character_visual(gender_id: String) -> void:
	var char_id := "girl" if gender_id == "girl" else "boy"
	var cfg := DataRepository.get_character_config(char_id)
	var override_glb := str(cfg.get("model_3d_path", ""))
	if not override_glb.is_empty():
		visual_slot.override_model_path = override_glb
	_rig = CharacterRig3D.build_character(char_id)
	var loaded: Node3D = visual_slot.attach_or_placeholder(_rig)
	if loaded is CharacterRig3D:
		animator.bind_rig(loaded as CharacterRig3D)
	else:
		animator.bind_rig(null)


func set_camera_limits(_bounds: Rect2i) -> void:
	# Kept for Prompt 02/03 API compatibility; 3D uses SpringArm3D collision & world bounds.
	pass


func set_world_bounds(half_x: float, half_z: float) -> void:
	world_half_extent_x = half_x
	world_half_extent_z = half_z


func set_virtual_joystick(vec: Vector2) -> void:
	virtual_move_vector = vec


func trigger_jump() -> void:
	if movement_locked or not is_on_floor():
		return
	velocity.y = jump_velocity
	animator.play_state(CharacterAnimator.AnimState.JUMP)


func trigger_interact_anim() -> void:
	animator.play_state(CharacterAnimator.AnimState.INTERACT)


func trigger_celebrate_anim() -> void:
	animator.play_state(CharacterAnimator.AnimState.CELEBRATE)
	if _rig != null:
		_rig.set_expression("excited")


func set_dialogue_focus(target_pos: Vector3) -> void:
	_dialogue_focus_active = true
	_dialogue_focus_pos = target_pos
	if _rig != null:
		var dir := Vector2(target_pos.x - global_position.x, target_pos.z - global_position.z)
		animator.set_facing_vector(dir)
		_rig.set_expression("happy")


func clear_dialogue_focus() -> void:
	_dialogue_focus_active = false
	if _rig != null:
		_rig.set_expression("neutral")


func _unhandled_input(event: InputEvent) -> void:
	if UIManager.is_modal_open() or _pause_locked:
		_orbit_dragging = false
		return

	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT or mb.button_index == MOUSE_BUTTON_MIDDLE:
			_orbit_dragging = mb.pressed
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			camera_distance = clampf(camera_distance - 0.55, 4.0, 10.5)
			spring_arm.spring_length = camera_distance
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			camera_distance = clampf(camera_distance + 0.55, 4.0, 10.5)
			spring_arm.spring_length = camera_distance
	elif event is InputEventMouseMotion and _orbit_dragging:
		var mm := event as InputEventMouseMotion
		apply_look_delta(mm.relative)


func _physics_process(delta: float) -> void:
	_update_camera(delta)

	movement_locked = _dialogue_locked or _pause_locked or UIManager.is_modal_open()
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif velocity.y < 0.0:
		velocity.y = 0.0

	if movement_locked:
		velocity.x = move_toward(velocity.x, 0.0, 28.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 28.0 * delta)
		move_and_slide()
		animator.play_state(CharacterAnimator.AnimState.IDLE)
		return

	# Optional Q / C keyboard camera rotation for laptop trackpads
	if Input.is_key_pressed(KEY_Q):
		_cam_yaw += camera_rotation_speed * camera_sensitivity * delta
	if Input.is_key_pressed(KEY_C):
		_cam_yaw -= camera_rotation_speed * camera_sensitivity * delta

	var input_vec := _read_keyboard_vector()
	if virtual_move_vector.length() > 0.1:
		input_vec = virtual_move_vector

	if input_vec.length() > 1.0:
		input_vec = input_vec.normalized()

	var is_running := Input.is_key_pressed(KEY_SHIFT) or input_vec.length() > 0.85
	var speed := run_speed if is_running else walk_speed

	# Camera-relative movement on XZ plane
	var cam_basis := Basis(Vector3.UP, _cam_yaw)
	var move_dir := (cam_basis * Vector3(input_vec.x, 0.0, input_vec.y))
	move_dir.y = 0.0
	if move_dir.length_squared() > 0.001:
		move_dir = move_dir.normalized() * minf(1.0, input_vec.length())

	velocity.x = move_dir.x * speed
	velocity.z = move_dir.z * speed
	move_and_slide()

	# Keep inside walkable island bounds smoothly
	global_position.x = clampf(global_position.x, -world_half_extent_x, world_half_extent_x)
	global_position.z = clampf(global_position.z, -world_half_extent_z, world_half_extent_z)

	if move_dir.length() > 0.08:
		_last_facing = move_dir.normalized()
		animator.set_facing_vector(Vector2(move_dir.x, move_dir.z))
		if is_on_floor() and animator.current_state != CharacterAnimator.AnimState.JUMP:
			animator.play_state(CharacterAnimator.AnimState.RUN if is_running else CharacterAnimator.AnimState.WALK)
	else:
		if is_on_floor() and animator.current_state != CharacterAnimator.AnimState.JUMP and animator.current_state != CharacterAnimator.AnimState.CELEBRATE and animator.current_state != CharacterAnimator.AnimState.INTERACT:
			animator.play_state(CharacterAnimator.AnimState.IDLE)

	if (Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_SPACE)) and is_on_floor():
		trigger_jump()


func _update_camera(delta: float) -> void:
	if camera_pivot == null:
		return
	var target_pivot_pos := Vector3(0.0, camera_height, 0.0)
	var target_pitch := _cam_pitch
	var target_len := clampf(camera_distance, 4.0, 10.5)

	if _dialogue_focus_active:
		var mid := (_dialogue_focus_pos - global_position) * 0.45
		target_pivot_pos = Vector3(mid.x, camera_height + 0.1, mid.z)
		target_pitch = -0.32
		target_len = 5.2

	var pos_alpha := minf(1.0, delta * maxf(2.0, camera_smoothing * 0.78))
	var rot_alpha := minf(1.0, delta * maxf(2.5, camera_smoothing))
	camera_pivot.position = camera_pivot.position.lerp(target_pivot_pos, pos_alpha)
	camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y, _cam_yaw, rot_alpha)
	camera_pivot.rotation.x = lerpf(camera_pivot.rotation.x, target_pitch, rot_alpha)
	spring_arm.spring_length = lerpf(spring_arm.spring_length, target_len, minf(1.0, delta * 6.0))

	# Never let player's own head/cap mesh block the camera if SpringArm3D compresses near a wall
	if camera != null and visual_slot != null:
		var head_world := global_position + Vector3(0.0, 1.25, 0.0)
		var head_dist := camera.global_position.distance_to(head_world)
		if visual_slot.visible and head_dist < 2.35:
			visual_slot.visible = false
		elif (not visual_slot.visible) and head_dist > 2.60:
			visual_slot.visible = true


func _read_keyboard_vector() -> Vector2:
	var x := 0.0
	var y := 0.0
	if Input.is_action_pressed("move_left") or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		x -= 1.0
	if Input.is_action_pressed("move_right") or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		x += 1.0
	if Input.is_action_pressed("move_up") or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		y -= 1.0
	if Input.is_action_pressed("move_down") or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		y += 1.0
	return Vector2(x, y)


func _on_dialogue_started(_dialogue_id: String) -> void:
	_dialogue_locked = true
	movement_locked = true


func _on_dialogue_ended(_dialogue_id: String) -> void:
	_dialogue_locked = false
	movement_locked = _pause_locked or UIManager.is_modal_open()
	clear_dialogue_focus()


func _on_pause_toggled(is_paused: bool) -> void:
	_pause_locked = is_paused
	movement_locked = _dialogue_locked or _pause_locked or UIManager.is_modal_open()
