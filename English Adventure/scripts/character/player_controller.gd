class_name PlayerController
extends CharacterBody2D
## 2.5D top-down player movement supporting Desktop (WASD/Arrows, Shift run, Space jump, E interact)
## and Mobile Touch Virtual Joystick + action buttons.

@export var walk_speed: float = 235.0
@export var run_speed: float = 340.0

var virtual_move_vector: Vector2 = Vector2.ZERO
var movement_locked: bool = false
var _last_facing: Vector2 = Vector2.DOWN

@onready var sprite: Sprite2D = $Sprite2D
@onready var animator: CharacterAnimator = $CharacterAnimator
@onready var camera: Camera2D = $Camera2D


var _dialogue_locked: bool = false
var _pause_locked: bool = false


func _ready() -> void:
	apply_character_visual(GameStateManager.selected_character)
	EventBus.dialogue_started.connect(_on_dialogue_started)
	EventBus.dialogue_ended.connect(_on_dialogue_ended)
	EventBus.pause_toggled.connect(_on_pause_toggled)


func apply_character_visual(gender_id: String) -> void:
	var cfg := DataRepository.get_character_config(gender_id)
	var path := str(cfg.get("sprite_path", "res://assets/characters/player/boy/boy_adventurer.svg"))
	if ResourceLoader.exists(path):
		sprite.texture = load(path)


func set_camera_limits(bounds: Rect2i) -> void:
	if camera == null:
		return
	camera.limit_left = bounds.position.x
	camera.limit_top = bounds.position.y
	camera.limit_right = bounds.position.x + bounds.size.x
	camera.limit_bottom = bounds.position.y + bounds.size.y


func set_virtual_joystick(vec: Vector2) -> void:
	virtual_move_vector = vec


func trigger_jump() -> void:
	if movement_locked:
		return
	animator.play_state(CharacterAnimator.AnimState.JUMP)


func trigger_interact_anim() -> void:
	animator.play_state(CharacterAnimator.AnimState.INTERACT)


func trigger_celebrate_anim() -> void:
	animator.play_state(CharacterAnimator.AnimState.CELEBRATE)


func _physics_process(_delta: float) -> void:
	movement_locked = _dialogue_locked or _pause_locked or UIManager.is_modal_open()
	if movement_locked:
		velocity = Vector2.ZERO
		animator.play_state(CharacterAnimator.AnimState.IDLE)
		return

	var input_vec := _read_keyboard_vector()
	if virtual_move_vector.length() > 0.1:
		input_vec = virtual_move_vector

	if input_vec.length() > 1.0:
		input_vec = input_vec.normalized()

	var is_running := Input.is_key_pressed(KEY_SHIFT) or input_vec.length() > 0.85
	var speed := run_speed if is_running else walk_speed
	velocity = input_vec * speed
	move_and_slide()

	if input_vec.length() > 0.08:
		_last_facing = input_vec.normalized()
		animator.set_facing_dir(input_vec.x)
		if animator.current_state != CharacterAnimator.AnimState.JUMP:
			animator.play_state(CharacterAnimator.AnimState.RUN if is_running else CharacterAnimator.AnimState.WALK)
	else:
		if animator.current_state != CharacterAnimator.AnimState.JUMP and animator.current_state != CharacterAnimator.AnimState.CELEBRATE and animator.current_state != CharacterAnimator.AnimState.INTERACT:
			animator.play_state(CharacterAnimator.AnimState.IDLE)

	if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_SPACE):
		if animator.current_state != CharacterAnimator.AnimState.JUMP:
			trigger_jump()


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


func _on_pause_toggled(is_paused: bool) -> void:
	_pause_locked = is_paused
	movement_locked = _dialogue_locked or _pause_locked or UIManager.is_modal_open()
