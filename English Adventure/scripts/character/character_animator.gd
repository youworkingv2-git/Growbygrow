class_name CharacterAnimator
extends Node3D
## Unified 3D articulated procedural animation controller supporting:
## idle, walk, run, jump, interact, celebrate, hurt.

enum AnimState { IDLE, WALK, RUN, JUMP, INTERACT, CELEBRATE, HURT }

var current_state: AnimState = AnimState.IDLE
var _time: float = 0.0
var _jump_timer: float = 0.0
var _burst_timer: float = 0.0
var _rig: CharacterRig3D = null
var _target_yaw: float = 0.0


func bind_rig(rig: CharacterRig3D) -> void:
	_rig = rig


func set_facing_vector(dir_xz: Vector2) -> void:
	if dir_xz.length_squared() < 0.004:
		return
	# In Godot 3D, forward is +Z for our rig face (face built on +Z), so yaw = atan2(dir.x, dir.y)
	_target_yaw = atan2(dir_xz.x, dir_xz.y)


func set_facing_dir(dir_x: float) -> void:
	if absf(dir_x) < 0.05:
		return
	_target_yaw = PI * 0.5 if dir_x > 0.0 else -PI * 0.5


func play_state(state: AnimState) -> void:
	if current_state == state and state != AnimState.JUMP and state != AnimState.INTERACT and state != AnimState.CELEBRATE:
		return
	current_state = state
	if state == AnimState.JUMP:
		_jump_timer = 0.45
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
	if _rig == null or not is_instance_valid(_rig):
		return
	_time += delta

	# Smoothly rotate rig toward movement direction
	_rig.rotation.y = lerp_angle(_rig.rotation.y, _target_yaw, minf(1.0, delta * 12.0))

	if _jump_timer > 0.0:
		_jump_timer = maxf(0.0, _jump_timer - delta)
		_apply_pose(0.0, 0.25, -0.8, 0.8, 0.0)
		if _jump_timer == 0.0:
			current_state = AnimState.IDLE
		return

	if _burst_timer > 0.0:
		_burst_timer = maxf(0.0, _burst_timer - delta)
		match current_state:
			AnimState.CELEBRATE:
				var hop := absf(sin(_time * 14.0)) * 0.22
				_apply_pose(hop, 0.0, -2.2 + sin(_time * 14.0) * 0.35, -2.2 - sin(_time * 14.0) * 0.35, sin(_time * 10.0) * 0.14)
			AnimState.INTERACT:
				_apply_pose(0.0, 0.0, -0.3, -1.2 + sin(_time * 16.0) * 0.3, 0.12)
			AnimState.HURT:
				_apply_pose(0.0, 0.0, 0.4, 0.4, -0.18)
		if _burst_timer == 0.0:
			current_state = AnimState.IDLE
		return

	match current_state:
		AnimState.IDLE:
			var breath := sin(_time * 2.8) * 0.025
			_apply_pose(breath, 0.0, sin(_time * 2.2) * 0.05, -sin(_time * 2.2) * 0.05, 0.0)
		AnimState.WALK:
			var s := sin(_time * 9.5)
			var bob := absf(s) * 0.06
			_apply_pose(bob, s * 0.65, -s * 0.55, s * 0.55, 0.05)
		AnimState.RUN:
			var s := sin(_time * 14.5)
			var bob := absf(s) * 0.10
			_apply_pose(bob, s * 0.95, -s * 0.90, s * 0.90, 0.14)


func _apply_pose(body_y: float, leg_swing: float, arm_l: float, arm_r: float, lean_x: float) -> void:
	if _rig.body_pivot != null:
		_rig.body_pivot.position.y = body_y
		_rig.body_pivot.rotation.x = lerpf(_rig.body_pivot.rotation.x, lean_x, 0.25)
	if _rig.left_leg_pivot != null:
		_rig.left_leg_pivot.rotation.x = leg_swing
	if _rig.right_leg_pivot != null:
		_rig.right_leg_pivot.rotation.x = -leg_swing
	if _rig.left_arm_pivot != null:
		_rig.left_arm_pivot.rotation.x = arm_l
	if _rig.right_arm_pivot != null:
		_rig.right_arm_pivot.rotation.x = arm_r
	if _rig.head_pivot != null:
		_rig.head_pivot.rotation.y = sin(_time * 1.6) * 0.06
