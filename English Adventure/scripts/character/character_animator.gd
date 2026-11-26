class_name CharacterAnimator
extends Node2D
## Unified procedural + sprite-ready animation controller supporting:
## idle, walk, run, jump, interact, celebrate, hurt.

enum AnimState { IDLE, WALK, RUN, JUMP, INTERACT, CELEBRATE, HURT }

@export var sprite_node_path: NodePath = ^"Sprite2D"

var current_state: AnimState = AnimState.IDLE
var _time: float = 0.0
var _jump_timer: float = 0.0
var _burst_timer: float = 0.0
var _base_scale: Vector2 = Vector2.ONE
var _base_pos: Vector2 = Vector2.ZERO
var _sprite: Sprite2D = null


func _ready() -> void:
	_sprite = get_node_or_null(sprite_node_path) as Sprite2D
	if _sprite != null:
		_base_scale = _sprite.scale
		_base_pos = _sprite.position


func set_facing_dir(dir_x: float) -> void:
	if _sprite == null or absf(dir_x) < 0.05:
		return
	_sprite.flip_h = dir_x < 0.0


func play_state(state: AnimState) -> void:
	if current_state == state and state != AnimState.JUMP and state != AnimState.INTERACT and state != AnimState.CELEBRATE:
		return
	current_state = state
	if state == AnimState.JUMP:
		_jump_timer = 0.42
	elif state == AnimState.INTERACT or state == AnimState.CELEBRATE or state == AnimState.HURT:
		_burst_timer = 0.55


func play_state_by_name(state_name: String) -> void:
	match state_name.to_lower():
		"walk": play_state(AnimState.WALK)
		"run": play_state(AnimState.RUN)
		"jump": play_state(AnimState.JUMP)
		"interact": play_state(AnimState.INTERACT)
		"celebrate": play_state(AnimState.CELEBRATE)
		"hurt": play_state(AnimState.HURT)
		_: play_state(AnimState.IDLE)


func _process(delta: float) -> void:
	if _sprite == null:
		return
	_time += delta

	if _jump_timer > 0.0:
		_jump_timer = maxf(0.0, _jump_timer - delta)
		var t := 1.0 - (_jump_timer / 0.42)
		var arc := sin(t * PI) * 26.0
		_sprite.position = _base_pos + Vector2(0.0, -arc)
		_sprite.scale = _base_scale * Vector2(1.0 - 0.08 * sin(t * PI), 1.0 + 0.1 * sin(t * PI))
		_sprite.rotation = 0.0
		if _jump_timer == 0.0:
			current_state = AnimState.IDLE
		return

	if _burst_timer > 0.0:
		_burst_timer = maxf(0.0, _burst_timer - delta)
		match current_state:
			AnimState.CELEBRATE:
				var bounce := absf(sin(_time * 16.0)) * 14.0
				_sprite.position = _base_pos + Vector2(0.0, -bounce)
				_sprite.rotation = sin(_time * 14.0) * 0.1
			AnimState.INTERACT:
				_sprite.scale = _base_scale * Vector2(1.0 + 0.08 * sin(_time * 18.0), 1.0 - 0.05 * sin(_time * 18.0))
			AnimState.HURT:
				_sprite.position = _base_pos + Vector2(sin(_time * 40.0) * 6.0, 0.0)
				_sprite.modulate = Color(1.0, 0.55, 0.55, 1.0)
		if _burst_timer == 0.0:
			_sprite.modulate = Color.WHITE
			_sprite.rotation = 0.0
			current_state = AnimState.IDLE
		return

	_sprite.modulate = Color.WHITE
	match current_state:
		AnimState.IDLE:
			var breath := sin(_time * 3.0) * 0.025
			_sprite.position = _base_pos
			_sprite.scale = _base_scale * Vector2(1.0 - breath * 0.5, 1.0 + breath)
			_sprite.rotation = 0.0
		AnimState.WALK:
			var step_bob := absf(sin(_time * 10.0)) * 6.0
			_sprite.position = _base_pos + Vector2(0.0, -step_bob)
			_sprite.rotation = sin(_time * 10.0) * 0.06
			_sprite.scale = _base_scale
		AnimState.RUN:
			var run_bob := absf(sin(_time * 16.0)) * 9.0
			_sprite.position = _base_pos + Vector2(0.0, -run_bob)
			_sprite.rotation = sin(_time * 16.0) * 0.1
			_sprite.scale = _base_scale * Vector2(1.03, 0.97)
