extends CharacterBody2D
class_name PlayerController
## 2.5D Player Controller supporting Boy/Girl avatar, keyboard (WASD/Arrows + E),
## and mobile virtual joystick input.

const MOVE_SPEED := 240.0
const RUN_SPEED := 330.0
const BOY_TEXTURE := "res://assets/characters/player_boy/player_boy.svg"
const GIRL_TEXTURE := "res://assets/characters/player_girl/player_girl.svg"

enum AnimState { IDLE, WALK, RUN, JUMP, INTERACT, CELEBRATE, HURT }

var current_state: AnimState = AnimState.IDLE
var mobile_move_vector: Vector2 = Vector2.ZERO
var _bob_time: float = 0.0
var _save_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_apply_avatar_appearance()
	var saved_pos: Dictionary = SaveManager.player_data.get("last_position", {})
	if saved_pos.has("x") and saved_pos.has("y"):
		global_position = Vector2(saved_pos["x"], saved_pos["y"])

func _apply_avatar_appearance() -> void:
	if sprite == null:
		return
	var avatar: String = SaveManager.player_data.get("avatar_type", "boy")
	var tex_path := GIRL_TEXTURE if avatar == "girl" else BOY_TEXTURE
	if ResourceLoader.exists(tex_path):
		sprite.texture = load(tex_path)

func set_mobile_input(vec: Vector2) -> void:
	mobile_move_vector = vec

func _physics_process(delta: float) -> void:
	if DialogueManager.is_active:
		velocity = Vector2.ZERO
		_set_state(AnimState.IDLE)
		return

	var input_vec := _get_movement_vector()
	var is_running := Input.is_key_pressed(KEY_SHIFT)
	var speed := RUN_SPEED if is_running else MOVE_SPEED

	velocity = input_vec * speed
	move_and_slide()

	if input_vec.length() > 0.1:
		_set_state(AnimState.RUN if is_running else AnimState.WALK)
		if sprite != null and abs(input_vec.x) > 0.05:
			sprite.flip_h = input_vec.x < 0
		EventBus.player_moved.emit(global_position)
		_save_timer += delta
		if _save_timer >= 1.5:
			_save_timer = 0.0
			SaveManager.update_player_position(global_position)
	else:
		_set_state(AnimState.IDLE)

	_animate_procedural_bob(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			_set_state(AnimState.INTERACT)
			InteractionManager.trigger_current()
		elif event.keycode == KEY_SPACE and not DialogueManager.is_active:
			_set_state(AnimState.JUMP)

func _get_movement_vector() -> Vector2:
	if mobile_move_vector.length() > 0.05:
		return mobile_move_vector.limit_length(1.0)
	var vec := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		vec.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		vec.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		vec.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		vec.y += 1.0
	return vec.normalized()

func _set_state(new_state: AnimState) -> void:
	current_state = new_state

func _animate_procedural_bob(delta: float) -> void:
	if sprite == null:
		return
	if current_state == AnimState.WALK or current_state == AnimState.RUN:
		_bob_time += delta * (14.0 if current_state == AnimState.RUN else 9.0)
		sprite.position.y = -abs(sin(_bob_time)) * 6.0
	else:
		_bob_time = 0.0
		sprite.position.y = lerpf(sprite.position.y, 0.0, delta * 10.0)
