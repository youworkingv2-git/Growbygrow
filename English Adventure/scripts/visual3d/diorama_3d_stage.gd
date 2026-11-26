extends Node3D
class_name Diorama3DStage
## Reusable 3D Showcase Stage for Character Selection turntables and Main Menu Welcome Village diorama.

@export_enum("boy", "girl", "buddy", "professor_owl", "welcome_diorama") var stage_mode: String = "boy"

var _turntable: Node3D
var _buddy: CharacterRig3D
var _hero: CharacterRig3D
var _time: float = 0.0
var _manual_spin_pause: float = 0.0


func _ready() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var psky := ProceduralSkyMaterial.new()
	psky.sky_top_color = Color(0.18, 0.48, 0.86)
	psky.sky_horizon_color = Color(0.62, 0.86, 0.98)
	sky.sky_material = psky
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.82
	env.glow_enabled = SettingsManager.graphics_quality != "low"
	we.environment = env
	add_child(we)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-36, 28, 0)
	sun.light_energy = 1.2
	sun.shadow_enabled = SettingsManager.graphics_quality != "low"
	add_child(sun)

	var cam := Camera3D.new()
	cam.fov = 38.0
	cam.current = true
	add_child(cam)

	_turntable = Node3D.new()
	add_child(_turntable)

	if stage_mode == "welcome_diorama":
		_build_welcome_diorama()
		cam.position = Vector3(0.0, 2.7, 6.2)
		cam.look_at(Vector3(0.0, 1.0, 0.0), Vector3.UP)
	else:
		_build_character_turntable(stage_mode)
		cam.position = Vector3(0.0, 1.35, 3.15)
		cam.look_at(Vector3(0.0, 0.82, 0.0), Vector3.UP)


func _build_character_turntable(char_id: String) -> void:
	var ped_mat := StandardMaterial3D.new()
	ped_mat.albedo_color = Color(0.32, 0.56, 0.84)
	ped_mat.roughness = 0.45
	var ped := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.68
	cyl.bottom_radius = 0.78
	cyl.height = 0.22
	ped.mesh = cyl
	ped.material_override = ped_mat
	ped.position = Vector3(0, -0.11, 0)
	_turntable.add_child(ped)

	_hero = CharacterRig3D.build_character(char_id)
	_hero.set_expression("happy")
	_turntable.add_child(_hero)


func set_character(char_id: String) -> void:
	stage_mode = char_id
	if _hero != null and is_instance_valid(_hero):
		_hero.queue_free()
	_hero = CharacterRig3D.build_character(char_id)
	_hero.set_expression("happy")
	if _turntable != null:
		_turntable.add_child(_hero)


func _build_welcome_diorama() -> void:
	var disc := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 3.2
	cyl.bottom_radius = 3.4
	cyl.height = 0.35
	disc.mesh = cyl
	var g_mat := StandardMaterial3D.new()
	g_mat.albedo_color = Color(0.36, 0.76, 0.40)
	g_mat.roughness = 0.8
	disc.material_override = g_mat
	disc.position = Vector3(0, -0.18, 0)
	_turntable.add_child(disc)

	var cottage := PropFactory3D.build_village_cottage(Color(0.24, 0.46, 0.80), Color(0.98, 0.94, 0.84), true)
	cottage.scale = Vector3.ONE * 0.52
	cottage.position = Vector3(0.95, 0, -0.85)
	cottage.rotation_degrees.y = -18.0
	_turntable.add_child(cottage)

	var tree := PropFactory3D.build_stylized_tree(0.62)
	tree.position = Vector3(-1.55, 0, -0.75)
	_turntable.add_child(tree)

	var crystal := PropFactory3D.build_interactable_prop("crystal")
	crystal.scale = Vector3.ONE * 0.72
	crystal.position = Vector3(1.85, 0, 0.85)
	_turntable.add_child(crystal)

	_hero = CharacterRig3D.build_character("boy")
	_hero.position = Vector3(-0.65, 0, 0.75)
	_hero.rotation_degrees.y = 18.0
	_hero.set_expression("happy")
	_turntable.add_child(_hero)

	_buddy = CharacterRig3D.build_character("buddy")
	_buddy.position = Vector3(-0.05, 1.15, 0.95)
	_buddy.rotation_degrees.y = -15.0
	_buddy.set_expression("excited")
	_turntable.add_child(_buddy)


func rotate_turntable(delta_yaw: float) -> void:
	if _turntable != null:
		_turntable.rotation.y += delta_yaw
		_manual_spin_pause = 1.6


func _process(delta: float) -> void:
	_time += delta
	if _manual_spin_pause > 0.0:
		_manual_spin_pause = maxf(0.0, _manual_spin_pause - delta)
	if stage_mode == "welcome_diorama":
		_turntable.rotation.y = sin(_time * 0.45) * 0.22
		if _buddy != null:
			_buddy.position.y = 1.15 + sin(_time * 3.4) * 0.14
			if _buddy.left_wing_pivot != null:
				_buddy.left_wing_pivot.rotation.z = sin(_time * 9.0) * 0.35
			if _buddy.right_wing_pivot != null:
				_buddy.right_wing_pivot.rotation.z = -sin(_time * 9.0) * 0.35
	else:
		if _manual_spin_pause <= 0.0:
			_turntable.rotation.y += delta * 0.75
		if _hero != null and _hero.body_pivot != null:
			_hero.body_pivot.position.y = sin(_time * 2.8) * 0.025
