extends Node3D
class_name AlphabetIsland3DMap
## Interactive 3D Overhead / Isometric World Map of Alphabet Island.
## Renders the sculpted 3D island, animated ocean, 5 distinct area landmarks,
## glowing connecting paths, and Silent Shadow mist on locked areas.

const AREA_COORDS := {
	"welcome_village": Vector3(-7.0, 0.55, 3.2),
	"alphabet_meadow": Vector3(-3.0, 0.70, 0.2),
	"letter_cave": Vector3(1.2, 0.90, -2.4),
	"crystal_lake": Vector3(5.2, 0.70, 1.2),
	"shadow_gate": Vector3(7.4, 1.15, -3.8)
}

var _camera: Camera3D
var _focus_target: Vector3 = Vector3(0.0, 0.5, 0.0)
var _cam_base_offset: Vector3 = Vector3(0.0, 14.5, 11.5)
var _time: float = 0.0
var _landmark_nodes: Dictionary = {}
var _shadow_rings: Dictionary = {}


func _ready() -> void:
	_build_environment()
	_build_ocean_and_island()
	_build_landmarks_and_paths()
	refresh_states()


func _build_environment() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var psky := ProceduralSkyMaterial.new()
	psky.sky_top_color = Color(0.18, 0.52, 0.88)
	psky.sky_horizon_color = Color(0.62, 0.86, 0.98)
	sky.sky_material = psky
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.78
	env.glow_enabled = SettingsManager.graphics_quality != "low"
	env.glow_intensity = 0.55
	we.environment = env
	add_child(we)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, 34, 0)
	sun.light_energy = 1.15
	sun.shadow_enabled = SettingsManager.graphics_quality != "low"
	add_child(sun)

	_camera = Camera3D.new()
	_camera.fov = 42.0
	_camera.position = _cam_base_offset
	_camera.current = true
	add_child(_camera)
	_camera.look_at(Vector3.ZERO, Vector3.UP)


func _mat(albedo: Color, rough: float = 0.7, emission: Color = Color.BLACK, e_energy: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = albedo
	m.roughness = rough
	if e_energy > 0.0:
		m.emission_enabled = true
		m.emission = emission
		m.emission_energy_multiplier = e_energy
	return m


func _mesh(parent: Node3D, mesh: Mesh, mat: Material, pos: Vector3, rot_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot_deg
	parent.add_child(mi)
	return mi


func _build_ocean_and_island() -> void:
	var ocean := PlaneMesh.new()
	ocean.size = Vector2(56, 44)
	_mesh(self, ocean, PropFactory3D.create_stylized_water_material(Color(0.12, 0.56, 0.84, 0.96)), Vector3(0, -0.35, 0))

	# Sandy beach base
	var beach := CylinderMesh.new()
	beach.top_radius = 10.6
	beach.bottom_radius = 11.4
	beach.height = 0.7
	beach.radial_segments = 32
	var beach_mi := _mesh(self, beach, _mat(Color(0.94, 0.86, 0.62), 0.82), Vector3(0, -0.1, 0))
	beach_mi.scale = Vector3(1.15, 1.0, 0.76)

	# Lush green Alphabet Island plateau
	var grass := CylinderMesh.new()
	grass.top_radius = 9.6
	grass.bottom_radius = 10.2
	grass.height = 0.8
	grass.radial_segments = 32
	var grass_mi := _mesh(self, grass, _mat(Color("#3C733B"), 0.82), Vector3(0, 0.2, 0))
	grass_mi.scale = Vector3(1.12, 1.0, 0.72)

	# Northern misty mountain ridge
	var ridge_mat := _mat(Color(0.34, 0.42, 0.52), 0.85)
	for i in range(4):
		var cone := CylinderMesh.new()
		cone.top_radius = 0.15
		cone.bottom_radius = 2.0 + float(i % 2) * 0.6
		cone.height = 2.6 + float(i % 2) * 0.8
		cone.radial_segments = 7
		_mesh(self, cone, ridge_mat, Vector3(-4.5 + float(i) * 3.4, 1.4, -4.6))


func _build_landmarks_and_paths() -> void:
	# Paths between connected areas
	var pairs := [
		["welcome_village", "alphabet_meadow"],
		["alphabet_meadow", "letter_cave"],
		["letter_cave", "crystal_lake"],
		["crystal_lake", "shadow_gate"]
	]
	var path_mat := _mat(Color(0.96, 0.82, 0.38), 0.4, Color(0.96, 0.78, 0.25), 0.35)
	for pair in pairs:
		var p1: Vector3 = AREA_COORDS[pair[0]]
		var p2: Vector3 = AREA_COORDS[pair[1]]
		for step in range(1, 5):
			var t := float(step) / 5.0
			var pos := p1.lerp(p2, t)
			var dot := SphereMesh.new()
			dot.radius = 0.22
			dot.height = 0.18
			_mesh(self, dot, path_mat, Vector3(pos.x, 0.65, pos.z))

	# 1. Welcome Village
	var wv := Node3D.new()
	wv.position = AREA_COORDS["welcome_village"]
	add_child(wv)
	var cottage := PropFactory3D.build_village_cottage(Color("#2D4F8A"), Color("#EFE5D2"), true)
	cottage.scale = Vector3.ONE * 0.42
	wv.add_child(cottage)
	var t1 := PropFactory3D.build_stylized_tree(0.45)
	t1.position = Vector3(-1.3, 0, 0.6)
	wv.add_child(t1)
	_landmark_nodes["welcome_village"] = wv

	# 2. Alphabet Meadow
	var am := Node3D.new()
	am.position = AREA_COORDS["alphabet_meadow"]
	add_child(am)
	var letter := PropFactory3D.build_interactable_prop("letter")
	letter.scale = Vector3.ONE * 1.15
	am.add_child(letter)
	var t2 := PropFactory3D.build_stylized_tree(0.48, Color(0.32, 0.78, 0.38))
	t2.position = Vector3(1.1, 0, -0.7)
	am.add_child(t2)
	_landmark_nodes["alphabet_meadow"] = am

	# 3. Letter Cave
	var lc := Node3D.new()
	lc.position = AREA_COORDS["letter_cave"]
	add_child(lc)
	var arch := TorusMesh.new()
	arch.inner_radius = 0.75
	arch.outer_radius = 1.15
	_mesh(lc, arch, _mat(Color(0.42, 0.45, 0.54), 0.85), Vector3(0, 0.6, 0), Vector3(90, 0, 0))
	var c_glow := PropFactory3D.build_interactable_prop("crystal")
	c_glow.position = Vector3(0.9, 0, 0.5)
	c_glow.scale = Vector3.ONE * 0.75
	lc.add_child(c_glow)
	_landmark_nodes["letter_cave"] = lc

	# 4. Crystal Lake
	var cl := Node3D.new()
	cl.position = AREA_COORDS["crystal_lake"]
	add_child(cl)
	var pool := CylinderMesh.new()
	pool.top_radius = 1.35
	pool.bottom_radius = 1.4
	pool.height = 0.14
	_mesh(cl, pool, PropFactory3D.create_stylized_water_material(Color(0.20, 0.80, 0.98, 0.9)), Vector3(0, 0.05, 0))
	var cr := PropFactory3D.build_interactable_prop("crystal")
	cr.position = Vector3(0, 0.1, -0.3)
	cr.scale = Vector3.ONE * 1.1
	cl.add_child(cr)
	_landmark_nodes["crystal_lake"] = cl

	# 5. Shadow Gate
	var sg := Node3D.new()
	sg.position = AREA_COORDS["shadow_gate"]
	add_child(sg)
	var sg_arch := TorusMesh.new()
	sg_arch.inner_radius = 0.85
	sg_arch.outer_radius = 1.18
	_mesh(sg, sg_arch, _mat(Color(0.20, 0.16, 0.34), 0.5), Vector3(0, 0.9, 0), Vector3(90, 0, 0))
	var sg_core := TorusMesh.new()
	sg_core.inner_radius = 0.68
	sg_core.outer_radius = 0.80
	_mesh(sg, sg_core, _mat(Color(0.68, 0.38, 1.0), 0.2, Color(0.68, 0.38, 1.0), 1.5), Vector3(0, 0.9, 0), Vector3(90, 0, 0))
	_landmark_nodes["shadow_gate"] = sg

	# Silent Shadow mist rings for locked areas
	var mist_mat := _mat(Color(0.32, 0.22, 0.54), 0.6, Color(0.42, 0.24, 0.68), 0.8)
	for aid_var in AREA_COORDS.keys():
		var aid := str(aid_var)
		var ring_m := TorusMesh.new()
		ring_m.inner_radius = 1.35
		ring_m.outer_radius = 1.60
		var r_node := _mesh(_landmark_nodes[aid], ring_m, mist_mat, Vector3(0, 0.25, 0))
		_shadow_rings[aid] = r_node


func refresh_states() -> void:
	for aid_var in _shadow_rings.keys():
		var aid := str(aid_var)
		var ring: MeshInstance3D = _shadow_rings[aid]
		ring.visible = not GameStateManager.is_area_unlocked(aid)


func focus_area(area_id: String) -> void:
	if AREA_COORDS.has(area_id):
		var c: Vector3 = AREA_COORDS[area_id]
		_focus_target = Vector3(c.x * 0.35, 0.4, c.z * 0.35)


func get_area_screen_position(area_id: String) -> Vector2:
	if _camera == null or not AREA_COORDS.has(area_id):
		return Vector2.ZERO
	var world_p: Vector3 = AREA_COORDS[area_id] + Vector3(0, 1.3, 0)
	return _camera.unproject_position(world_p)


func _process(delta: float) -> void:
	_time += delta
	if _camera != null and _camera.is_inside_tree():
		var desired := _focus_target + _cam_base_offset + Vector3(sin(_time * 0.35) * 0.4, 0.0, cos(_time * 0.3) * 0.3)
		_camera.position = _camera.position.lerp(desired, minf(1.0, delta * 3.5))
		_camera.look_at(_focus_target, Vector3.UP)
	for aid_var in _shadow_rings.keys():
		var ring: MeshInstance3D = _shadow_rings[aid_var]
		if ring.visible:
			ring.rotation.y += delta * 1.1
