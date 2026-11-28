extends Node3D
class_name AlphabetIsland3DMap
## Interactive 3D Multi-Biome Archipelago Map of Alphabet Island.
## Renders 5 visually distinct, functional regions (Harbor Village, Letter Meadow,
## Granite Cavern Mountain, Waterfall Crystal Lagoon, and Obsidian Shadow Citadel)
## connected by bridges, winding golden paths, drifting clouds, and animated ocean.

const AREA_COORDS := {
	"welcome_village": Vector3(-7.0, 0.45, 3.6),
	"alphabet_meadow": Vector3(-4.0, 0.72, -2.6),
	"letter_cave": Vector3(0.4, 1.15, -4.6),
	"crystal_lake": Vector3(3.4, 0.50, 2.8),
	"shadow_gate": Vector3(7.5, 1.10, -2.4)
}

const LABEL_OFFSETS := {
	"welcome_village": Vector3(0.0, -0.1, 2.55),
	"alphabet_meadow": Vector3(-0.3, 0.1, 2.25),
	"letter_cave": Vector3(0.0, 0.2, 2.15),
	"crystal_lake": Vector3(0.2, -0.1, 2.55),
	"shadow_gate": Vector3(0.0, 0.2, 2.25)
}

var _camera: Camera3D
var _focus_target: Vector3 = Vector3(0.2, 0.5, 0.2)
var _cam_base_offset: Vector3 = Vector3(0.0, 15.6, 13.6)
var _time: float = 0.0
var _landmark_nodes: Dictionary = {}
var _shadow_rings: Dictionary = {}
var _boat_node: Node3D = null
var _cloud_nodes: Array[Node3D] = []
var _portal_ring: Node3D = null
var _crystal_spire: Node3D = null
var _mat_cache: Dictionary = {}


func _ready() -> void:
	_build_environment()
	_build_ocean_and_backdrop()
	_build_biome_islands()
	_build_bridges_and_paths()
	_build_landmarks()
	_build_clouds_and_islets()
	refresh_states()


func _build_environment() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var psky := ProceduralSkyMaterial.new()
	psky.sky_top_color = Color("#1864BD")
	psky.sky_horizon_color = Color("#8FD6F8")
	psky.ground_bottom_color = Color("#164E78")
	psky.ground_horizon_color = Color("#58B2DC")
	sky.sky_material = psky
	env.sky = sky
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 0.92
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_sky_contribution = 0.55
	env.ambient_light_energy = 0.72
	env.glow_enabled = SettingsManager.graphics_quality != "low"
	env.glow_intensity = 0.42
	env.fog_enabled = true
	env.fog_light_color = Color("#8FD4F5")
	env.fog_density = 0.0042
	we.environment = env
	add_child(we)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 32, 0)
	sun.light_color = Color("#FFE7BE")
	sun.light_energy = 1.10
	sun.shadow_enabled = SettingsManager.graphics_quality != "low"
	sun.shadow_blur = 1.4
	add_child(sun)

	_camera = Camera3D.new()
	_camera.fov = 39.0
	_camera.position = _focus_target + _cam_base_offset
	_camera.current = true
	add_child(_camera)
	_camera.look_at(_focus_target, Vector3.UP)


func _mat(albedo: Color, rough: float = 0.74, emission: Color = Color.BLACK, e_energy: float = 0.0, metallic: float = 0.0) -> StandardMaterial3D:
	var key := "%s|%.2f|%s|%.2f|%.2f" % [albedo.to_html(true), rough, emission.to_html(true), e_energy, metallic]
	if _mat_cache.has(key):
		return _mat_cache[key] as StandardMaterial3D
	var m := StandardMaterial3D.new()
	m.albedo_color = albedo
	m.roughness = rough
	m.metallic = metallic
	if e_energy > 0.0:
		m.emission_enabled = true
		m.emission = emission
		m.emission_energy_multiplier = e_energy
	_mat_cache[key] = m
	return m


func _mesh(parent: Node3D, mesh: Mesh, mat: Material, pos: Vector3, rot_deg: Vector3 = Vector3.ZERO, scale_v: Vector3 = Vector3.ONE, shadows: bool = true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot_deg
	mi.scale = scale_v
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadows else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi


func _cyl(rt: float, rb: float, h: float, segs: int = 18) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = rt
	c.bottom_radius = rb
	c.height = h
	c.radial_segments = segs
	return c


func _box(sz: Vector3) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = sz
	return b


func _sph(r: float, h: float = -1.0, rings: int = 8, segs: int = 12) -> SphereMesh:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0 if h < 0.0 else h
	s.rings = rings
	s.radial_segments = segs
	return s


func _build_ocean_and_backdrop() -> void:
	var ocean := PlaneMesh.new()
	ocean.size = Vector2(72, 56)
	_mesh(self, ocean, PropFactory3D.create_stylized_water_material(Color(0.11, 0.58, 0.88, 0.96)), Vector3(0, -0.35, 0), Vector3.ZERO, Vector3.ONE, false)


func _build_island_plateau(
	parent: Node3D,
	center: Vector3,
	rx: float,
	rz: float,
	height: float,
	top_color: Color,
	cliff_color: Color,
	with_sand_rim: bool = true
) -> void:
	var foam_mat := _mat(Color(0.84, 0.96, 1.0, 0.65), 0.35)
	foam_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mesh(parent, _cyl(1.0, 1.06, 0.06, 22), foam_mat, Vector3(center.x, -0.30, center.z), Vector3.ZERO, Vector3(rx + 0.65, 1.0, rz + 0.65), false)

	if with_sand_rim:
		_mesh(parent, _cyl(0.98, 1.05, 0.32, 20), _mat(Color("#EAD08F"), 0.82), Vector3(center.x, -0.14, center.z), Vector3.ZERO, Vector3(rx + 0.35, 1.0, rz + 0.35), false)

	_mesh(parent, _cyl(0.94, 1.02, height, 16), _mat(cliff_color, 0.86), Vector3(center.x, height * 0.5 - 0.12, center.z), Vector3.ZERO, Vector3(rx, 1.0, rz), true)
	_mesh(parent, _cyl(0.95, 0.96, 0.24, 18), _mat(top_color, 0.78), Vector3(center.x, height - 0.04, center.z), Vector3.ZERO, Vector3(rx * 0.98, 1.0, rz * 0.98), false)


func _build_biome_islands() -> void:
	var base := Node3D.new()
	base.name = "BiomeIslands"
	add_child(base)

	# 1. Welcome Village Peninsula (Sunlit chartreuse-lime grass + slate-earth cliff + sandy harbor bay)
	_build_island_plateau(base, Vector3(-7.0, 0.0, 3.6), 3.3, 2.55, 0.56, Color("#669E2D"), Color("#7C5A3E"), true)
	_build_island_plateau(base, Vector3(-5.2, 0.0, 1.6), 1.85, 1.45, 0.50, Color("#6BA431"), Color("#7C5A3E"), true)

	# 2. Alphabet Meadow Terrace (Vibrant sunlit lime-green pasture)
	_build_island_plateau(base, Vector3(-4.0, 0.0, -2.6), 3.1, 2.35, 0.82, Color("#73AC36"), Color("#826040"), true)
	_build_island_plateau(base, Vector3(-2.0, 0.0, -3.5), 1.75, 1.40, 0.86, Color("#6DA532"), Color("#826040"), false)

	# 3. Letter Cave Granite Mountain Massif (Multi-tiered slate crag peak)
	_build_island_plateau(base, Vector3(0.4, 0.0, -4.6), 3.25, 2.55, 1.25, Color("#566278"), Color("#3E4659"), true)
	_mesh(base, _cyl(0.20, 2.35, 2.50, 7), _mat(Color("#475166"), 0.86), Vector3(0.2, 2.30, -5.8), Vector3(0, 18, 0))
	_mesh(base, _cyl(0.12, 1.65, 2.10, 7), _mat(Color("#606C82"), 0.82), Vector3(1.6, 2.05, -5.6), Vector3(0, 42, 0))
	_mesh(base, _cyl(0.14, 1.50, 1.85, 7), _mat(Color("#545F74"), 0.84), Vector3(-1.2, 1.90, -5.5), Vector3(0, -24, 0))

	# 4. Crystal Lake Jade Lagoon Basin (Cool jade shore + crescent sand beach + sparkling water)
	_build_island_plateau(base, Vector3(3.4, 0.0, 2.8), 3.45, 2.65, 0.60, Color("#2E8668"), Color("#4B645C"), true)
	_mesh(base, _cyl(2.15, 2.30, 0.14, 24), _mat(Color("#E2CA8C"), 0.82), Vector3(3.3, 0.54, 2.9), Vector3.ZERO, Vector3(1.15, 1.0, 0.88), false)
	var lake_water := PropFactory3D.create_stylized_water_material(Color(0.18, 0.82, 0.98, 0.90), true)
	_mesh(base, _cyl(1.75, 1.75, 0.12, 24), lake_water, Vector3(3.3, 0.60, 2.9), Vector3.ZERO, Vector3(1.12, 1.0, 0.84), false)

	# 5. Shadow Gate Obsidian Fortress Crag (Dark amethyst-slate volcanic cliff)
	_build_island_plateau(base, Vector3(7.5, 0.0, -2.4), 2.85, 2.30, 1.20, Color("#2E244E"), Color("#1E1736"), false)
	var rock_dark := _mat(Color("#251D42"), 0.82)
	for sp_pos in [Vector3(5.6, 1.45, -3.5), Vector3(9.4, 1.55, -3.2), Vector3(9.2, 1.25, -1.0)]:
		_mesh(base, _cyl(0.08, 0.65, 1.65, 6), rock_dark, sp_pos, Vector3(8, 22, -6))


func _build_bridge(parent: Node3D, from_p: Vector3, to_p: Vector3, width: float, plank_col: Color, rail_col: Color, glow_col: Color = Color.BLACK) -> void:
	var mid := (from_p + to_p) * 0.5
	var diff := to_p - from_p
	var len_f := Vector2(diff.x, diff.z).length()
	var yaw := rad_to_deg(atan2(diff.x, diff.z))
	var bridge := Node3D.new()
	bridge.position = mid
	bridge.rotation_degrees.y = yaw
	parent.add_child(bridge)

	var p_mat := _mat(plank_col, 0.72)
	var r_mat := _mat(rail_col, 0.76, glow_col, 0.85 if glow_col != Color.BLACK else 0.0)
	var steps := maxi(4, int(floor(len_f / 0.42)))
	for i in range(steps):
		var t := (float(i) + 0.5) / float(steps) - 0.5
		var arc_y := cos(t * PI) * 0.24
		_mesh(bridge, _box(Vector3(width, 0.12, 0.34)), p_mat, Vector3(0, arc_y, t * len_f))
	for sx in [-width * 0.48, width * 0.48]:
		_mesh(bridge, _box(Vector3(0.09, 0.10, len_f)), r_mat, Vector3(sx, 0.36, 0))
		for pz in [-len_f * 0.42, 0.0, len_f * 0.42]:
			_mesh(bridge, _cyl(0.07, 0.08, 0.46, 6), r_mat, Vector3(sx, 0.20, pz))


func _build_curved_trail(parent: Node3D, p0: Vector3, ctrl: Vector3, p1: Vector3, steps: int, stone_mat: Material) -> void:
	for i in range(1, steps):
		var t := float(i) / float(steps)
		var omt := 1.0 - t
		var pos := p0 * (omt * omt) + ctrl * (2.0 * omt * t) + p1 * (t * t)
		var disc := _cyl(0.24, 0.28, 0.10, 7)
		_mesh(parent, disc, stone_mat, pos + Vector3(0, 0.05, 0), Vector3(0, float(i * 28), 0), Vector3(1.15, 1.0, 0.85), false)


func _build_bridges_and_paths() -> void:
	var paths := Node3D.new()
	paths.name = "BridgesAndPaths"
	add_child(paths)

	var gold_stone := _mat(Color("#EBC35B"), 0.55, Color("#E8B43A"), 0.28)
	var cliff_stone := _mat(Color("#9EA7B8"), 0.72)
	var shadow_stone := _mat(Color("#8E5EEB"), 0.42, Color("#8E5EEB"), 0.75)

	# 1. Welcome Village -> Alphabet Meadow (Timber Bridge + golden dirt curve)
	_build_bridge(paths, Vector3(-5.2, 0.58, 1.1), Vector3(-4.5, 0.74, -0.8), 0.78, Color("#8E5A32"), Color("#5E381C"))
	_build_curved_trail(paths, Vector3(-6.8, 0.52, 3.3), Vector3(-5.6, 0.58, 2.2), Vector3(-5.2, 0.54, 1.2), 5, gold_stone)

	# 2. Alphabet Meadow -> Letter Cave (Stone Arch Bridge + mountain steps)
	_build_bridge(paths, Vector3(-2.1, 0.86, -3.5), Vector3(-0.9, 1.10, -4.1), 0.80, Color("#8E95A4"), Color("#687080"))
	_build_curved_trail(paths, Vector3(-4.2, 0.80, -2.5), Vector3(-3.0, 0.86, -3.3), Vector3(-2.1, 0.86, -3.5), 5, gold_stone)

	# 3. Letter Cave -> Crystal Lake (Waterfall Cliff Cascade + East Stone Steps)
	var wf_mat := ShaderMaterial.new()
	wf_mat.shader = load("res://shaders/stylized_water_jet.gdshader") as Shader
	wf_mat.set_shader_parameter("scroll_speed", 1.85)
	_mesh(paths, _box(Vector3(0.76, 1.25, 0.16)), wf_mat, Vector3(2.15, 0.92, -2.25), Vector3(38, 22, 0), Vector3.ONE, false)
	var foam_ring := TorusMesh.new()
	foam_ring.inner_radius = 0.28
	foam_ring.outer_radius = 0.52
	_mesh(paths, foam_ring, _mat(Color("#DAF6FF"), 0.30, Color("#88E8FF"), 0.45), Vector3(2.45, 0.62, 1.15), Vector3.ZERO, Vector3.ONE, false)
	_build_curved_trail(paths, Vector3(1.2, 1.18, -3.5), Vector3(3.1, 0.92, -1.6), Vector3(3.4, 0.58, 0.8), 7, cliff_stone)

	# 4. Crystal Lake -> Shadow Gate (Violet-Rune Causeway Bridge)
	_build_bridge(paths, Vector3(5.3, 0.64, 0.7), Vector3(6.4, 1.05, -0.8), 0.78, Color("#413569"), Color("#784EE0"), Color("#9462FF"))
	_build_curved_trail(paths, Vector3(4.2, 0.56, 2.2), Vector3(4.9, 0.62, 1.4), Vector3(5.3, 0.64, 0.7), 4, shadow_stone)


func _build_landmarks() -> void:
	# === 1. WELCOME VILLAGE (Tudor Violet-Indigo Cottages + Clocktower + Sandy Path + Haystacks + Sailboat) ===
	var wv := Node3D.new()
	wv.position = AREA_COORDS["welcome_village"]
	add_child(wv)
	_mesh(wv, _cyl(1.38, 1.44, 0.08, 20), _mat(Color("#C4966E"), 0.84), Vector3(0, 0.10, 0.1), Vector3.ZERO, Vector3.ONE, false)
	_mesh(wv, _box(Vector3(0.70, 0.06, 2.15)), _mat(Color("#BE9068"), 0.84), Vector3(0.25, 0.09, -0.45), Vector3(0, -18, 0), Vector3.ONE, false)

	var owl_cottage := PropFactory3D.build_village_cottage(Color("#4A3586"), Color("#E3DFD7"), true, "academy")
	owl_cottage.position = Vector3(0.0, 0.08, -1.15)
	owl_cottage.scale = Vector3.ONE * 0.30
	wv.add_child(owl_cottage)

	var lily_cottage := PropFactory3D.build_village_cottage(Color("#4E398C"), Color("#E3DFD7"), false, "garden_cottage")
	lily_cottage.position = Vector3(1.42, 0.08, -0.42)
	lily_cottage.rotation_degrees.y = -28.0
	lily_cottage.scale = Vector3.ONE * 0.25
	wv.add_child(lily_cottage)

	var supply_cottage := PropFactory3D.build_village_cottage(Color("#4A3586"), Color("#E1DDD4"), false, "supply_post")
	supply_cottage.position = Vector3(-1.38, 0.08, -0.52)
	supply_cottage.rotation_degrees.y = 28.0
	supply_cottage.scale = Vector3.ONE * 0.25
	wv.add_child(supply_cottage)

	# Mini Haystacks & Wooden Lantern Post
	for hp in [Vector3(0.95, 0.08, -1.05), Vector3(1.18, 0.08, -0.82)]:
		var hs := PropFactory3D.build_haystack()
		hs.position = hp
		hs.scale = Vector3.ONE * 0.28
		wv.add_child(hs)
	var wv_lamp := PropFactory3D.build_lamppost()
	wv_lamp.position = Vector3(0.55, 0.08, 0.45)
	wv_lamp.scale = Vector3.ONE * 0.32
	wv.add_child(wv_lamp)

	# Mini Fountain on Village Plaza
	_mesh(wv, _cyl(0.46, 0.50, 0.16, 14), _mat(Color("#7C8696"), 0.74), Vector3(-0.42, 0.18, 0.25))
	_mesh(wv, _cyl(0.36, 0.36, 0.12, 14), _mat(Color("#3BD4FA"), 0.22, Color("#3BD4FA"), 0.45), Vector3(-0.42, 0.24, 0.25), Vector3.ZERO, Vector3.ONE, false)
	_mesh(wv, _cyl(0.08, 0.14, 0.36, 10), _mat(Color("#99A3B3"), 0.72), Vector3(-0.42, 0.34, 0.25))
	_mesh(wv, _sph(0.11), _mat(Color("#BDF2FF"), 0.15, Color("#8CE8FF"), 0.85), Vector3(-0.42, 0.56, 0.25), Vector3.ZERO, Vector3.ONE, false)

	var wv_t1 := PropFactory3D.build_stylized_tree(0.36, Color("#2E5C27"), "pine")
	wv_t1.position = Vector3(-2.15, 0.08, 0.45)
	wv.add_child(wv_t1)
	var wv_t2 := PropFactory3D.build_stylized_tree(0.34, Color("#3E772A"), "oak")
	wv_t2.position = Vector3(1.95, 0.08, 0.65)
	wv.add_child(wv_t2)

	# Wooden Harbor Pier & Bobbing Sailboat in Southern Cove
	_mesh(wv, _box(Vector3(0.55, 0.10, 1.55)), _mat(Color("#7C4E2B"), 0.76), Vector3(-0.8, -0.45, 2.35))
	var boat := Node3D.new()
	boat.position = Vector3(AREA_COORDS["welcome_village"].x + 0.65, -0.22, AREA_COORDS["welcome_village"].z + 2.85)
	boat.rotation_degrees.y = -24.0
	add_child(boat)
	_mesh(boat, _box(Vector3(0.46, 0.22, 0.96)), _mat(Color("#8B532A"), 0.72), Vector3.ZERO)
	_mesh(boat, _cyl(0.03, 0.04, 0.95, 6), _mat(Color("#5C371C"), 0.78), Vector3(0, 0.50, 0))
	_mesh(boat, _box(Vector3(0.05, 0.66, 0.52)), _mat(Color("#FFF8E8"), 0.52), Vector3(0.04, 0.56, 0.08), Vector3(0, 12, 0))
	_boat_node = boat
	_landmark_nodes["welcome_village"] = wv

	# === 2. ALPHABET MEADOW (Rolling Pasture + Colorful A-B-C Letter Blocks + Flowers + Chest) ===
	var am := Node3D.new()
	am.position = AREA_COORDS["alphabet_meadow"]
	add_child(am)
	# Winding sandy-terracotta pasture path
	_mesh(am, _box(Vector3(3.6, 0.06, 0.56)), _mat(Color("#BE9068"), 0.84), Vector3(0.0, 0.08, 0.35), Vector3(0, 12, 0), Vector3.ONE, false)
	# 3 Colorful Alphabet Letter Blocks on Stone Pedestals ("A", "B", "C")
	var letter_specs := [
		{ "pos": Vector3(-1.35, 0.10, 0.15), "col": Color("#F25C69"), "rot": 18.0 },
		{ "pos": Vector3(-0.10, 0.10, -0.42), "col": Color("#38A8F5"), "rot": -12.0 },
		{ "pos": Vector3(1.15, 0.10, 0.10), "col": Color("#F8C038"), "rot": 24.0 },
	]
	for ls in letter_specs:
		var lp: Vector3 = ls["pos"]
		_mesh(am, _cyl(0.28, 0.34, 0.16, 8), _mat(Color("#8D95A3"), 0.80), lp + Vector3(0, 0.08, 0))
		_mesh(am, _box(Vector3(0.46, 0.46, 0.22)), _mat(ls["col"], 0.42, ls["col"], 0.25), lp + Vector3(0, 0.38, 0), Vector3(0, float(ls["rot"]), 0))
		_mesh(am, _box(Vector3(0.20, 0.20, 0.26)), _mat(Color("#FFF9EB"), 0.35, Color("#FFF9EB"), 0.20), lp + Vector3(0, 0.40, 0), Vector3(0, float(ls["rot"]), 45), Vector3.ONE, false)

	var am_t1 := PropFactory3D.build_stylized_tree(0.42, Color("#3E782B"), "oak")
	am_t1.position = Vector3(-1.95, 0.08, -0.95)
	am.add_child(am_t1)
	var am_t2 := PropFactory3D.build_stylized_tree(0.40, Color("#2E5C27"), "pine")
	am_t2.position = Vector3(1.45, 0.08, -1.05)
	am.add_child(am_t2)
	var am_t3 := PropFactory3D.build_stylized_tree(0.32, Color("#46822E"), "berry_tree")
	am_t3.position = Vector3(-0.65, 0.08, 1.05)
	am.add_child(am_t3)
	for fpos in [Vector3(-1.75, 0.12, 0.95), Vector3(0.45, 0.12, 0.95), Vector3(1.85, 0.12, -0.25)]:
		var sh := PropFactory3D.build_shrub_variant(2, 0.55, Color("#48822E"))
		sh.position = fpos
		am.add_child(sh)
	_landmark_nodes["alphabet_meadow"] = am

	# === 3. LETTER CAVE (Granite Cavern Mouth + Torches + Cyan Crystals + Tablet) ===
	var lc := Node3D.new()
	lc.position = AREA_COORDS["letter_cave"]
	add_child(lc)
	var rock_m := _mat(Color("#5C667A"), 0.84)
	var cave_dark := _mat(Color("#121728"), 0.95)
	var torch_glow := _mat(Color("#FFBE4A"), 0.15, Color("#FFA828"), 1.65)
	var cyan_cryst := _mat(Color("#46DCFF"), 0.15, Color("#46DCFF"), 1.35)
	var violet_cryst := _mat(Color("#A866FF"), 0.18, Color("#9C54FF"), 1.10)

	# Carved Cave Archway + Dark Cavern Interior
	_mesh(lc, _box(Vector3(1.95, 1.45, 1.35)), rock_m, Vector3(0, 0.65, -0.35))
	var cave_arch := TorusMesh.new()
	cave_arch.inner_radius = 0.62
	cave_arch.outer_radius = 0.98
	_mesh(lc, cave_arch, _mat(Color("#6F7A90"), 0.80), Vector3(0, 0.45, 0.30), Vector3(90, 0, 0))
	_mesh(lc, _cyl(0.58, 0.62, 0.35, 14), cave_dark, Vector3(0, 0.45, 0.24), Vector3(90, 0, 0), Vector3.ONE, false)
	# Glowing entrance torches & cyan crystal clusters
	for tx in [-0.88, 0.88]:
		_mesh(lc, _cyl(0.05, 0.07, 0.52, 6), _mat(Color("#5C3A20"), 0.8), Vector3(tx, 0.30, 0.72))
		_mesh(lc, _sph(0.11), torch_glow, Vector3(tx, 0.60, 0.72), Vector3.ZERO, Vector3.ONE, false)
	_mesh(lc, _cyl(0.02, 0.20, 0.75, 6), cyan_cryst, Vector3(-1.35, 0.42, 0.15), Vector3(8, 0, 18), Vector3.ONE, false)
	_mesh(lc, _cyl(0.02, 0.16, 0.55, 6), violet_cryst, Vector3(-1.12, 0.34, 0.42), Vector3(-10, 0, -16), Vector3.ONE, false)
	_mesh(lc, _cyl(0.02, 0.22, 0.82, 6), cyan_cryst, Vector3(1.25, 0.46, 0.10), Vector3(-6, 0, -15), Vector3.ONE, false)
	var lc_pine := PropFactory3D.build_stylized_tree(0.36, Color("#24583A"), "pine")
	lc_pine.position = Vector3(-1.85, 0.08, -0.65)
	lc.add_child(lc_pine)
	_landmark_nodes["letter_cave"] = lc

	# === 4. CRYSTAL LAKE (Lagoon Pier + Giant Glowing Crystal Spire + Lakeside Trees) ===
	var cl := Node3D.new()
	cl.position = AREA_COORDS["crystal_lake"]
	add_child(cl)
	# Pier reaching onto lake
	_mesh(cl, _box(Vector3(0.45, 0.08, 0.95)), _mat(Color("#7C4E2B"), 0.76), Vector3(-1.35, 0.14, -0.35), Vector3(0, -35, 0))
	# Glowing Central Crystal Sanctuary on Lake Islet
	var spire_pivot := Node3D.new()
	spire_pivot.position = Vector3(0.0, 0.22, 0.0)
	cl.add_child(spire_pivot)
	_mesh(spire_pivot, _cyl(0.32, 0.45, 0.22, 8), _mat(Color("#546175"), 0.82), Vector3(0, 0.05, 0))
	_mesh(spire_pivot, _cyl(0.03, 0.24, 1.05, 6), cyan_cryst, Vector3(0, 0.60, 0), Vector3.ZERO, Vector3.ONE, false)
	_mesh(spire_pivot, _cyl(0.02, 0.14, 0.62, 6), violet_cryst, Vector3(-0.22, 0.36, 0.12), Vector3(12, 0, 22), Vector3.ONE, false)
	_mesh(spire_pivot, _cyl(0.02, 0.14, 0.58, 6), violet_cryst, Vector3(0.22, 0.34, -0.10), Vector3(-10, 0, -24), Vector3.ONE, false)
	_crystal_spire = spire_pivot

	var cl_t1 := PropFactory3D.build_stylized_tree(0.38, Color("#206B50"), "pine")
	cl_t1.position = Vector3(1.85, 0.10, -0.85)
	cl.add_child(cl_t1)
	var cl_t2 := PropFactory3D.build_stylized_tree(0.34, Color("#E47698"), "blossom")
	cl_t2.position = Vector3(-1.95, 0.10, 0.95)
	cl.add_child(cl_t2)
	_landmark_nodes["crystal_lake"] = cl

	# === 5. THE SHADOW GATE (Obsidian Twin-Tower Gatehouse + Violet Portal Vortex) ===
	var sg := Node3D.new()
	sg.position = AREA_COORDS["shadow_gate"]
	add_child(sg)
	var obs_mat := _mat(Color("#271F44"), 0.52, Color.BLACK, 0.0, 0.25)
	var tower_cap := _mat(Color("#4B2878"), 0.45)
	var rune_violet := _mat(Color("#AC66FF"), 0.18, Color("#9F52FF"), 1.65)
	# Twin Citadel Towers
	for sx in [-1.12, 1.12]:
		_mesh(sg, _cyl(0.34, 0.42, 1.35, 8), obs_mat, Vector3(sx, 0.72, -0.15))
		_mesh(sg, _cyl(0.06, 0.48, 0.65, 8), tower_cap, Vector3(sx, 1.68, -0.15))
	# Central Archway + Glowing Violet Vortex Ring
	var sg_arch := TorusMesh.new()
	sg_arch.inner_radius = 0.68
	sg_arch.outer_radius = 0.98
	_mesh(sg, sg_arch, obs_mat, Vector3(0, 0.88, 0.05), Vector3(90, 0, 0))
	var sg_core := TorusMesh.new()
	sg_core.inner_radius = 0.50
	sg_core.outer_radius = 0.64
	_portal_ring = _mesh(sg, sg_core, rune_violet, Vector3(0, 0.88, 0.05), Vector3(90, 0, 0), Vector3.ONE, false)
	var veil_mat := StandardMaterial3D.new()
	veil_mat.albedo_color = Color(0.56, 0.28, 0.96, 0.52)
	veil_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	veil_mat.emission_enabled = true
	veil_mat.emission = Color(0.62, 0.34, 1.0)
	veil_mat.emission_energy_multiplier = 1.25
	_mesh(sg, _cyl(0.50, 0.50, 0.04, 16), veil_mat, Vector3(0, 0.88, 0.05), Vector3(90, 0, 0), Vector3.ONE, false)
	_landmark_nodes["shadow_gate"] = sg

	# Silent Shadow Seal Rings for Locked Regions
	var mist_mat := _mat(Color(0.36, 0.22, 0.58), 0.55, Color(0.54, 0.26, 0.82), 1.05)
	for aid_var in AREA_COORDS.keys():
		var aid := str(aid_var)
		var ring_m := TorusMesh.new()
		ring_m.inner_radius = 1.65
		ring_m.outer_radius = 1.88
		var r_node := _mesh(_landmark_nodes[aid], ring_m, mist_mat, Vector3(0, 0.22, 0), Vector3.ZERO, Vector3.ONE, false)
		_shadow_rings[aid] = r_node


func _build_clouds_and_islets() -> void:
	# Decorative Floating Mini-Islets (echoing fantasy archipelago reference)
	var islet_spots := [
		{ "pos": Vector3(-9.8, 0.9, -4.6), "r": 0.95 },
		{ "pos": Vector3(9.4, 1.2, 3.6), "r": 0.85 },
	]
	for isp in islet_spots:
		var isl := Node3D.new()
		isl.position = isp["pos"]
		add_child(isl)
		var rr: float = float(isp["r"])
		_mesh(isl, _cyl(rr * 0.95, 0.15, 1.15, 7), _mat(Color("#7D5B3E"), 0.85), Vector3(0, -0.58, 0))
		_mesh(isl, _cyl(rr, rr * 0.96, 0.20, 10), _mat(Color("#54A848"), 0.78), Vector3(0, 0.06, 0))
		var mini_t := PropFactory3D.build_stylized_tree(0.28, Color("#32783C"), "oak")
		mini_t.position = Vector3(0, 0.12, 0)
		isl.add_child(mini_t)

	# Drifting Fluffy Low-Poly Clouds
	var cloud_mat := _mat(Color(0.98, 0.99, 1.0, 0.90), 0.88)
	cloud_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for cp in [Vector3(-9.5, 4.6, -5.5), Vector3(4.5, 5.1, -6.2), Vector3(8.5, 4.3, 4.8)]:
		var cld := Node3D.new()
		cld.position = cp
		add_child(cld)
		_mesh(cld, _sph(0.75, 0.9, 6, 8), cloud_mat, Vector3.ZERO, Vector3.ZERO, Vector3(1.3, 0.75, 0.9), false)
		_mesh(cld, _sph(0.55, 0.7, 6, 8), cloud_mat, Vector3(-0.68, -0.08, 0.08), Vector3.ZERO, Vector3(1.1, 0.75, 0.85), false)
		_mesh(cld, _sph(0.52, 0.65, 6, 8), cloud_mat, Vector3(0.66, -0.10, -0.05), Vector3.ZERO, Vector3(1.1, 0.75, 0.85), false)
		_cloud_nodes.append(cld)


func refresh_states() -> void:
	for aid_var in _shadow_rings.keys():
		var aid := str(aid_var)
		var ring: MeshInstance3D = _shadow_rings[aid]
		ring.visible = not GameStateManager.is_area_unlocked(aid)


func focus_area(area_id: String) -> void:
	if AREA_COORDS.has(area_id):
		var c: Vector3 = AREA_COORDS[area_id]
		_focus_target = Vector3(c.x * 0.20, 0.45, c.z * 0.20)


func get_area_screen_position(area_id: String) -> Vector2:
	if _camera == null or not AREA_COORDS.has(area_id):
		return Vector2.ZERO
	var off: Vector3 = LABEL_OFFSETS.get(area_id, Vector3(0, 0.0, 2.2))
	var world_p: Vector3 = AREA_COORDS[area_id] + off
	return _camera.unproject_position(world_p)


func _process(delta: float) -> void:
	_time += delta
	if _camera != null and _camera.is_inside_tree():
		var desired := _focus_target + _cam_base_offset + Vector3(sin(_time * 0.30) * 0.35, 0.0, cos(_time * 0.26) * 0.25)
		_camera.position = _camera.position.lerp(desired, minf(1.0, delta * 3.5))
		_camera.look_at(_focus_target, Vector3.UP)
	if _boat_node != null:
		_boat_node.position.y = -0.22 + sin(_time * 1.9) * 0.045
		_boat_node.rotation_degrees.z = sin(_time * 1.4) * 4.5
	if _crystal_spire != null:
		_crystal_spire.rotation.y += delta * 0.55
	if _portal_ring != null:
		_portal_ring.rotation.z += delta * 0.9
	for i in range(_cloud_nodes.size()):
		var cld := _cloud_nodes[i]
		cld.position.x += delta * (0.22 + float(i) * 0.05)
		if cld.position.x > 13.5:
			cld.position.x = -13.5
	for aid_var in _shadow_rings.keys():
		var ring: MeshInstance3D = _shadow_rings[aid_var]
		if ring.visible:
			ring.rotation.y += delta * 1.15
