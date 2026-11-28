extends Node3D
class_name AreaEnvironment3D
## Procedural 3D Stylized Fantasy Environment Builder for Alphabet Island's 5 Areas.
## Builds multi-tier terrain, sculpted grass mounds, stone plazas, cobblestone paths,
## half-timbered cottages, varied trees (oak/pine/blossom), benches, lecterns, archways,
## animated water, distant mountain ridges, firefly particles, and colliders.

@export_enum("welcome_village", "alphabet_meadow", "letter_cave", "crystal_lake", "shadow_gate") var area_id: String = "welcome_village"

static var _mat_cache: Dictionary = {}
static var _mesh_cache: Dictionary = {}


func _ready() -> void:
	match area_id:
		"welcome_village":
			_build_welcome_village()
		"alphabet_meadow":
			_build_alphabet_meadow()
		"letter_cave":
			_build_letter_cave()
		"crystal_lake":
			_build_crystal_lake()
		"shadow_gate":
			_build_shadow_gate()


func _mat(albedo: Color, roughness: float = 0.78, metallic: float = 0.0, emission: Color = Color.BLACK, emission_energy: float = 0.0) -> StandardMaterial3D:
	var key := "%s|%.2f|%.2f|%s|%.2f" % [albedo.to_html(true), roughness, metallic, emission.to_html(true), emission_energy]
	if _mat_cache.has(key):
		return _mat_cache[key] as StandardMaterial3D
	var m := StandardMaterial3D.new()
	m.albedo_color = albedo
	m.roughness = roughness
	m.metallic = metallic
	if emission_energy > 0.0:
		m.emission_enabled = true
		m.emission = emission
		m.emission_energy_multiplier = emission_energy
	_mat_cache[key] = m
	return m


func _cached_sphere(radius: float, height: float, rings: int = 8, segs: int = 12) -> SphereMesh:
	var key := "sph|%.2f|%.2f|%d|%d" % [radius, height, rings, segs]
	if _mesh_cache.has(key):
		return _mesh_cache[key] as SphereMesh
	var sm := SphereMesh.new()
	sm.radius = radius
	sm.height = height
	sm.rings = rings
	sm.radial_segments = segs
	_mesh_cache[key] = sm
	return sm


func _cached_cylinder(rt: float, rb: float, h: float, segs: int = 12) -> CylinderMesh:
	var key := "cyl|%.2f|%.2f|%.2f|%d" % [rt, rb, h, segs]
	if _mesh_cache.has(key):
		return _mesh_cache[key] as CylinderMesh
	var cm := CylinderMesh.new()
	cm.top_radius = rt
	cm.bottom_radius = rb
	cm.height = h
	cm.radial_segments = segs
	_mesh_cache[key] = cm
	return cm


func _cached_box(sz: Vector3) -> BoxMesh:
	var key := "box|%.2f|%.2f|%.2f" % [sz.x, sz.y, sz.z]
	if _mesh_cache.has(key):
		return _mesh_cache[key] as BoxMesh
	var bm := BoxMesh.new()
	bm.size = sz
	_mesh_cache[key] = bm
	return bm


func _mesh(parent: Node3D, node_name: String, mesh: Mesh, mat: Material, pos: Vector3, rot_deg: Vector3 = Vector3.ZERO, shadows: bool = true, lod_end: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot_deg
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadows else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if lod_end > 90.0:
		mi.visibility_range_end = lod_end
		mi.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	parent.add_child(mi)
	return mi


func _add_ground_plane(size_x: float, size_z: float, color: Color) -> void:
	var body := StaticBody3D.new()
	body.name = "GroundCollider"
	body.collision_layer = 2
	body.collision_mask = 0
	add_child(body)

	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(size_x, 1.0, size_z)
	col.shape = box
	col.position = Vector3(0, -0.5, 0)
	body.add_child(col)

	var plane := PlaneMesh.new()
	plane.size = Vector2(size_x, size_z)
	_mesh(self, "GroundMesh", plane, _mat(color, 0.88), Vector3.ZERO, Vector3.ZERO, false)


func _add_grass_mound(parent: Node3D, pos: Vector3, radius_x: float, height: float, radius_z: float, color: Color) -> void:
	var sm := _cached_sphere(1.0, 1.0, 8, 14)
	var mi := _mesh(parent, "GrassMound", sm, _mat(color, 0.86), pos, Vector3.ZERO, false)
	mi.scale = Vector3(radius_x, height, radius_z)


func _add_trail_segment(parent: Node3D, from_p: Vector3, to_p: Vector3, width: float, earth_mat: Material, stone_mat: Material) -> void:
	var diff := to_p - from_p
	var length := Vector2(diff.x, diff.z).length()
	if length < 0.05:
		return
	var mid := (from_p + to_p) * 0.5
	var box := BoxMesh.new()
	box.size = Vector3(width, 0.04, length + width * 0.45)
	var yaw := rad_to_deg(atan2(diff.x, diff.z))
	_mesh(parent, "Trail", box, earth_mat, Vector3(mid.x, 0.02, mid.z), Vector3(0, yaw, 0), false)

	# Stepping flagstones along trail for tactile fantasy depth
	var steps := maxi(2, int(floor(length / 1.45)))
	var dir_n := Vector2(diff.x, diff.z).normalized()
	var perp := Vector2(-dir_n.y, dir_n.x)
	var stone_slab := _cached_cylinder(0.36, 0.42, 0.045, 7)
	for i in range(steps):
		var t := (float(i) + 0.5) / float(steps)
		var lateral := (0.28 if (i % 2 == 0) else -0.28) * minf(1.0, width * 0.45)
		var sp := from_p.lerp(to_p, t) + Vector3(perp.x * lateral, 0.032, perp.y * lateral)
		var smi := _mesh(parent, "SteppingStone", stone_slab, stone_mat, sp, Vector3(0, float(i * 37), 0), false)
		smi.scale = Vector3(1.15, 1.0, 0.85)


func _add_fireflies(color: Color, count: int = 20, spread: Vector3 = Vector3(15.0, 2.0, 8.5)) -> void:
	var p := CPUParticles3D.new()
	p.name = "AmbientParticles"
	p.add_to_group("quality_particles")
	p.set_meta("base_amount", count)
	p.position = Vector3(0, 1.5, 0)
	var q := SettingsManager.graphics_quality
	p.amount = count if q == "high" else maxi(6, count / 2)
	p.visible = q != "low"
	p.emitting = q != "low"
	p.lifetime = 3.2
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = spread
	p.gravity = Vector3(0, 0.12, 0)
	p.initial_velocity_min = 0.12
	p.initial_velocity_max = 0.40
	p.scale_amount_min = 0.035
	p.scale_amount_max = 0.085
	var sm := _cached_sphere(0.5, 1.0, 6, 8)
	p.material_override = _mat(color, 0.1, 0.0, color, 1.8)
	p.mesh = sm
	add_child(p)


func _add_flower_cluster(parent: Node3D, pos: Vector3, petal_color: Color) -> void:
	var leaf_m := PropFactory3D.create_foliage_wind_material(Color("#24592B"), Color("#438C3F"), 0.045, 0.5)
	var pet_m := PropFactory3D.create_foliage_wind_material(petal_color.darkened(0.12), petal_color.lightened(0.22), 0.055, 0.55)
	var center_m := _mat(Color("#F6C945"), 0.42, 0.0, Color("#F6C945"), 0.14)
	var bush := StylizedMeshKit.build_leaf_clump_mesh(pos.x + pos.z, 0.34, 0.24, 5, 8, 0.18)
	_mesh(parent, "Bush", bush, leaf_m, pos + Vector3(0, 0.14, 0), Vector3.ZERO, false)
	var bush_side := StylizedMeshKit.build_leaf_clump_mesh(pos.x * 1.7, 0.22, 0.17, 5, 7, 0.18)
	_mesh(parent, "BushSide", bush_side, leaf_m, pos + Vector3(0.24, 0.11, 0.12), Vector3.ZERO, false)
	var fl := _cached_sphere(0.085, 0.12, 6, 8)
	for i in range(5):
		var ang := float(i) * (TAU / 5.0) + 0.3
		var fpos := pos + Vector3(cos(ang) * 0.23, 0.32 + float(i % 2) * 0.05, sin(ang) * 0.23)
		_mesh(parent, "Flower%d" % i, fl, pet_m if i % 2 == 0 else center_m, fpos, Vector3.ZERO, false)


func _add_shrub(parent: Node3D, pos: Vector3, scale_s: float = 1.0, color: Color = Color("#2A6334"), variant: int = 0) -> void:
	var sh := PropFactory3D.build_shrub_variant(variant, scale_s, color)
	sh.position = pos
	parent.add_child(sh)


func _add_mushroom_patch(parent: Node3D, pos: Vector3) -> void:
	var stem_m := _mat(Color("#F2E8D5"), 0.72)
	var cap_m := _mat(Color("#D94A4A"), 0.52)
	var dot_m := _mat(Color("#FFF7E8"), 0.50)
	var stem := _cached_cylinder(0.032, 0.045, 0.14, 6)
	var cap := _cached_sphere(0.11, 0.10, 5, 8)
	var dot := _cached_sphere(0.025, 0.035, 4, 6)
	for i in range(3):
		var sc := 1.0 - float(i) * 0.22
		var off := Vector3(float(i - 1) * 0.14, 0.0, float(i % 2) * 0.10)
		_mesh(parent, "MushStem_%d" % i, stem, stem_m, pos + off + Vector3(0, 0.07 * sc, 0), Vector3.ZERO, false).scale = Vector3.ONE * sc
		_mesh(parent, "MushCap_%d" % i, cap, cap_m, pos + off + Vector3(0, 0.15 * sc, 0), Vector3.ZERO, false).scale = Vector3.ONE * sc
		_mesh(parent, "MushDot_%d" % i, dot, dot_m, pos + off + Vector3(0.03 * sc, 0.19 * sc, 0.03 * sc), Vector3.ZERO, false).scale = Vector3.ONE * sc


func _add_stump_and_leaves(parent: Node3D, pos: Vector3, leaf_col: Color) -> void:
	var bark := _mat(Color("#694426"), 0.85)
	var cut := _mat(Color("#C9A576"), 0.76)
	var fallen_m := _mat(leaf_col, 0.76)
	_mesh(parent, "Stump", _cached_cylinder(0.28, 0.38, 0.36, 8), bark, pos + Vector3(0, 0.18, 0), Vector3.ZERO, true)
	_mesh(parent, "StumpTop", _cached_cylinder(0.26, 0.26, 0.03, 8), cut, pos + Vector3(0, 0.36, 0), Vector3.ZERO, false)
	var leaf_disc := _cached_cylinder(0.08, 0.09, 0.014, 5)
	for i in range(5):
		var a := float(i) * 1.25
		_mesh(parent, "FallenLeaf_%d" % i, leaf_disc, fallen_m, pos + Vector3(cos(a) * 0.55, 0.02, sin(a) * 0.55), Vector3(0, float(i * 42), 0), false)


func _add_pebble_cluster(parent: Node3D, pos: Vector3) -> void:
	var st1 := _mat(Color("#6A7382"), 0.88)
	var st2 := _mat(Color("#88909E"), 0.84)
	var p_mesh := _cached_sphere(0.14, 0.10, 5, 7)
	for i in range(4):
		var off := Vector3(cos(float(i) * 1.6) * 0.22, 0.035, sin(float(i) * 1.6) * 0.22)
		var p := _mesh(parent, "Pebble_%d" % i, p_mesh, st1 if i % 2 == 0 else st2, pos + off, Vector3(0, float(i * 35), 0), false)
		p.scale = Vector3(1.1 - float(i) * 0.15, 0.65, 0.9)


func _add_grass_field(
	parent: Node3D,
	avoid_circles: Array[Dictionary],
	avoid_rects: Array[Rect2],
	bounds: Rect2,
	seed_val: int = 202611
) -> void:
	var max_count := 1150
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = StylizedMeshKit.build_grass_tuft_mesh()
	mm.instance_count = max_count

	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val
	var placed := 0
	var attempts := 0

	while placed < max_count and attempts < max_count * 6:
		attempts += 1
		var gx := rng.randf_range(bounds.position.x, bounds.position.x + bounds.size.x)
		var gz := rng.randf_range(bounds.position.y, bounds.position.y + bounds.size.y)
		var pt2 := Vector2(gx, gz)

		var skip := false
		for ac in avoid_circles:
			var center_v: Vector2 = ac["center"]
			var rad: float = float(ac["radius"])
			if pt2.distance_squared_to(center_v) < rad * rad:
				skip = true
				break
		if skip:
			continue
		for ar in avoid_rects:
			if ar.has_point(pt2):
				skip = true
				break
		if skip:
			continue

		var sc_xz := rng.randf_range(0.75, 1.35)
		var sc_y := rng.randf_range(0.68, 1.38)
		var rot_y := rng.randf_range(0.0, TAU)
		var basis := Basis(Vector3.UP, rot_y).scaled(Vector3(sc_xz, sc_y, sc_xz))
		mm.set_instance_transform(placed, Transform3D(basis, Vector3(gx, 0.075, gz)))
		mm.set_instance_custom_data(placed, Color(rng.randf(), sc_y, rng.randf(), 1.0))
		placed += 1

	mm.instance_count = placed
	var mmi := MultiMeshInstance3D.new()
	mmi.name = "MeadowGrassField"
	mmi.multimesh = mm
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var gmat := ShaderMaterial.new()
	gmat.shader = load("res://shaders/stylized_grass_wind.gdshader") as Shader
	mmi.material_override = gmat
	parent.add_child(mmi)

	var apply_density := func() -> void:
		if not is_instance_valid(mmi) or mmi.multimesh == null:
			return
		var q := SettingsManager.graphics_quality
		var target := placed if q == "high" else (mini(placed, 640) if q == "medium" else mini(placed, 260))
		mmi.multimesh.visible_instance_count = target
	apply_density.call()
	if not EventBus.settings_changed.is_connected(apply_density):
		EventBus.settings_changed.connect(apply_density)


func _add_fence_row(parent: Node3D, start_p: Vector3, end_p: Vector3, posts: int) -> void:
	var wood := _mat(Color("#6E4627"), 0.76)
	var cap := _mat(Color("#54331A"), 0.80)
	var post_m := _cached_cylinder(0.075, 0.095, 0.78, 8)
	var cap_m := _cached_sphere(0.09, 0.10, 5, 7)
	for i in range(posts):
		var t := float(i) / maxf(1.0, float(posts - 1))
		var p := start_p.lerp(end_p, t)
		_mesh(parent, "Post_%d" % i, post_m, wood, p + Vector3(0, 0.39, 0), Vector3.ZERO, true)
		_mesh(parent, "PostCap_%d" % i, cap_m, cap, p + Vector3(0, 0.79, 0), Vector3.ZERO, false)
	var diff := end_p - start_p
	var len_f := Vector2(diff.x, diff.z).length()
	var mid := (start_p + end_p) * 0.5
	var yaw := rad_to_deg(atan2(diff.x, diff.z))
	var rail := _cached_box(Vector3(0.06, 0.08, len_f))
	_mesh(parent, "RailTop", rail, wood, Vector3(mid.x, 0.58, mid.z), Vector3(0, yaw, 0), false)
	_mesh(parent, "RailLow", rail, wood, Vector3(mid.x, 0.30, mid.z), Vector3(0, yaw, 0), false)


func _add_rock(pos: Vector3, radius: float, color: Color = Color("#58616E"), has_collider: bool = true) -> void:
	var rm := _cached_sphere(radius, radius * 1.35, 6, 8)
	_mesh(self, "Rock3D", rm, _mat(color, 0.88), pos + Vector3(0, radius * 0.42, 0), Vector3(8, 22, -6))
	var moss := _cached_sphere(radius * 0.58, radius * 0.45, 5, 7)
	_mesh(self, "RockAccent", moss, _mat(color.lightened(0.12), 0.85), pos + Vector3(radius * 0.38, radius * 0.25, radius * 0.22), Vector3(0, 15, 12), false)
	if has_collider:
		var body := StaticBody3D.new()
		body.collision_layer = 32 | 64
		body.collision_mask = 0
		var col := CollisionShape3D.new()
		var sp := SphereShape3D.new()
		sp.radius = radius * 0.9
		col.shape = sp
		col.position = pos + Vector3(0, radius * 0.5, 0)
		body.add_child(col)
		add_child(body)


func _add_mountain_backdrop(hill_color: Color, mountain_color: Color) -> void:
	var h_mat := _mat(hill_color, 0.86)
	var m_mat := _mat(mountain_color, 0.88)
	var peak_mat := _mat(mountain_color.lightened(0.22), 0.80)

	# Midground rolling forest hills safely outside camera orbit radius
	var hill_positions := [
		Vector3(-27, -0.8, -22), Vector3(-12, -0.4, -25), Vector3(8, -0.6, -26), Vector3(26, -0.8, -22),
		Vector3(-32, -1.0, 2), Vector3(32, -1.0, 2), Vector3(-25, -1.1, 24), Vector3(25, -1.1, 24)
	]
	for i in range(hill_positions.size()):
		var sm := SphereMesh.new()
		sm.radius = 8.2 + float(i % 3) * 1.6
		sm.height = 7.0 + float(i % 2) * 2.2
		_mesh(self, "Hill_%d" % i, sm, h_mat, hill_positions[i], Vector3.ZERO, false)

	# Distant layered fantasy mountain silhouettes for strong foreground/mid/background separation
	var peaks := [
		{ "pos": Vector3(-34, 4.5, -42), "r": 12.5, "h": 19.0 },
		{ "pos": Vector3(-14, 6.2, -46), "r": 14.0, "h": 24.0 },
		{ "pos": Vector3(11, 5.5, -45), "r": 13.0, "h": 22.0 },
		{ "pos": Vector3(34, 4.8, -40), "r": 12.0, "h": 18.5 },
		{ "pos": Vector3(44, 3.8, -16), "r": 11.0, "h": 16.0 },
		{ "pos": Vector3(-44, 3.8, -16), "r": 11.0, "h": 16.0 },
	]
	for idx in range(peaks.size()):
		var pk: Dictionary = peaks[idx]
		var r: float = float(pk["r"])
		var h: float = float(pk["h"])
		var pos: Vector3 = pk["pos"]
		var cone := _cached_cylinder(0.6, r, h, 7)
		_mesh(self, "Mountain_%d" % idx, cone, m_mat, pos, Vector3(0, float(idx * 23), 0), false)
		var cap := _cached_cylinder(0.25, r * 0.34, h * 0.32, 7)
		_mesh(self, "MountainCap_%d" % idx, cap, peak_mat, pos + Vector3(0, h * 0.35, 0), Vector3(0, float(idx * 23), 0), false)


func _add_distant_forest_ring(ring_parent: Node3D) -> void:
	# Lightweight silhouette trees around outer valley perimeter (no colliders)
	var bark := _mat(Color("#4D331E"), 0.86)
	var pine1 := _mat(Color("#1F4F2D"), 0.78)
	var pine2 := _mat(Color("#275E35"), 0.76)
	var spots := [
		Vector3(-21.5, 0, -14.5), Vector3(-17.5, 0, -16.8), Vector3(-9.5, 0, -17.5),
		Vector3(9.0, 0, -17.5), Vector3(17.5, 0, -16.5), Vector3(22.0, 0, -13.5),
		Vector3(-23.0, 0, -5.0), Vector3(-23.0, 0, 7.5), Vector3(23.5, 0, -6.5), Vector3(23.5, 0, 8.5),
		Vector3(-18.5, 0, 15.5), Vector3(0.0, 0, 16.5), Vector3(18.5, 0, 15.5)
	]
	for i in range(spots.size()):
		var sc := 1.15 + float(i % 3) * 0.25
		var p: Vector3 = spots[i]
		_mesh(ring_parent, "BgTrunk_%d" % i, _cached_cylinder(0.20 * sc, 0.32 * sc, 1.8 * sc, 6), bark, p + Vector3(0, 0.9 * sc, 0), Vector3.ZERO, false)
		_mesh(ring_parent, "BgCrownA_%d" % i, _cached_cylinder(0.18 * sc, 1.45 * sc, 2.2 * sc, 7), pine1 if i % 2 == 0 else pine2, p + Vector3(0, 2.4 * sc, 0), Vector3.ZERO, false)
		_mesh(ring_parent, "BgCrownB_%d" % i, _cached_cylinder(0.08 * sc, 1.05 * sc, 1.7 * sc, 7), pine2, p + Vector3(0, 3.6 * sc, 0), Vector3.ZERO, false)

	# Distant Mystical Lighthouse / Watchtower in Northeast to spark exploration curiosity
	var tower_pos := Vector3(24.5, 0, -20.5)
	_mesh(ring_parent, "DistantTowerBase", _cached_cylinder(1.1, 1.45, 5.2, 8), _mat(Color("#697385"), 0.84), tower_pos + Vector3(0, 2.6, 0), Vector3.ZERO, false)
	_mesh(ring_parent, "DistantTowerBeacon", _cached_sphere(0.65, 1.30, 8, 12), _mat(Color("#7CE4FF"), 0.15, 0.0, Color("#5CCFFF"), 1.6), tower_pos + Vector3(0, 5.7, 0), Vector3.ZERO, false)
	_mesh(ring_parent, "DistantTowerRoof", _cached_cylinder(0.1, 1.35, 1.6, 8), _mat(Color("#2D4F8A"), 0.65), tower_pos + Vector3(0, 6.7, 0), Vector3.ZERO, false)


func _build_welcome_village() -> void:
	# Rich multi-layered natural green ground (never pastel mint!)
	_add_ground_plane(130.0, 110.0, Color("#2C5D33"))
	_add_mountain_backdrop(Color("#275632"), Color("#3C556E"))

	var bg_forest := Node3D.new()
	bg_forest.name = "DistantForestRing"
	add_child(bg_forest)
	_add_distant_forest_ring(bg_forest)

	# Gentle sculpted grass terraces / elevation mounds around village edges
	var terrain_decor := Node3D.new()
	terrain_decor.name = "TerrainRelief"
	add_child(terrain_decor)
	_add_grass_mound(terrain_decor, Vector3(-16.5, -0.15, -9.5), 6.5, 1.35, 5.2, Color("#356C38"))
	_add_grass_mound(terrain_decor, Vector3(16.5, -0.15, -9.5), 6.5, 1.45, 5.2, Color("#387039"))
	_add_grass_mound(terrain_decor, Vector3(-16.2, -0.20, 9.2), 6.0, 1.15, 4.6, Color("#3B733C"))
	_add_grass_mound(terrain_decor, Vector3(16.2, -0.20, 9.2), 6.0, 1.15, 4.6, Color("#376E3A"))
	_add_grass_mound(terrain_decor, Vector3(0.0, -0.18, -13.2), 11.5, 1.55, 4.8, Color("#326636"))

	# Natural Village Meadow Terrace
	var lawn := CylinderMesh.new()
	lawn.top_radius = 18.6
	lawn.bottom_radius = 19.8
	lawn.height = 0.14
	lawn.radial_segments = 32
	_mesh(self, "VillageLawn", lawn, _mat(Color("#3F763B"), 0.88), Vector3(0, 0.01, 0), Vector3.ZERO, false)

	# Stepped Cobblestone Central Plaza (warm earth & stone tones)
	var plaza_rim := CylinderMesh.new()
	plaza_rim.top_radius = 6.3
	plaza_rim.bottom_radius = 6.6
	plaza_rim.height = 0.10
	plaza_rim.radial_segments = 24
	_mesh(self, "PlazaBorder", plaza_rim, _mat(Color("#696E78"), 0.84), Vector3(0, 0.035, 1.5), Vector3.ZERO, false)

	var plaza_inner := CylinderMesh.new()
	plaza_inner.top_radius = 5.65
	plaza_inner.bottom_radius = 5.8
	plaza_inner.height = 0.11
	plaza_inner.radial_segments = 24
	_mesh(self, "PlazaSurface", plaza_inner, _mat(Color("#B69C6E"), 0.82), Vector3(0, 0.045, 1.5), Vector3.ZERO, false)

	# Decorative center compass emblem ring on plaza floor
	var plaza_ring := TorusMesh.new()
	plaza_ring.inner_radius = 2.65
	plaza_ring.outer_radius = 2.85
	_mesh(self, "PlazaEmblemRing", plaza_ring, _mat(Color("#8E7854"), 0.84), Vector3(0, 0.08, 1.5), Vector3.ZERO, false)

	# Earth & Flagstone Pathways connecting all landmarks
	var path_mat := _mat(Color("#8E6C47"), 0.84)
	var stone_mat := _mat(Color("#838995"), 0.82)
	var trails_root := Node3D.new()
	trails_root.name = "VillageTrails"
	add_child(trails_root)
	_add_trail_segment(trails_root, Vector3(0, 0, 1.5), Vector3(0, 0, -5.6), 2.3, path_mat, stone_mat)      # To Owl Academy
	_add_trail_segment(trails_root, Vector3(-3.5, 0, 1.5), Vector3(-10.0, 0, 0.6), 1.85, path_mat, stone_mat) # To Chest Camp
	_add_trail_segment(trails_root, Vector3(4.2, 0, 1.6), Vector3(16.5, 0, 1.25), 2.2, path_mat, stone_mat)  # To Meadow Arch & Portal
	_add_trail_segment(trails_root, Vector3(6.2, 0, 2.2), Vector3(10.0, 0, 3.3), 1.75, path_mat, stone_mat)  # To Lily

	# 1. Professor Owl's Academy Cottage (North center — Scholar Tower + Balcony)
	var owl_house := PropFactory3D.build_village_cottage(Color("#2D4F8A"), Color("#EFE5D2"), true, "academy")
	owl_house.position = Vector3(0, 0, -7.8)
	add_child(owl_house)

	var lectern := PropFactory3D.build_academy_lectern()
	lectern.position = Vector3(-2.15, 0, -4.35)
	lectern.rotation_degrees.y = 22.0
	add_child(lectern)

	# 2. Lily's Garden Cottage (Northeast — Pergola Trellis + Mailbox + Vines)
	var lily_house := PropFactory3D.build_village_cottage(Color("#C94B43"), Color("#EFE4CE"), false, "garden_cottage")
	lily_house.position = Vector3(11.6, 0, -4.6)
	lily_house.rotation_degrees.y = -24.0
	add_child(lily_house)

	# 3. Explorer's Supply Cottage (Northwest — Timber Canopy + Chest Camp Crates)
	var west_house := PropFactory3D.build_village_cottage(Color("#CF862E"), Color("#EDE2CC"), false, "supply_post")
	west_house.position = Vector3(-11.8, 0, -4.8)
	west_house.rotation_degrees.y = 26.0
	add_child(west_house)

	var crates := PropFactory3D.build_supply_crates()
	crates.position = Vector3(-11.6, 0, 1.85)
	crates.rotation_degrees.y = 18.0
	add_child(crates)

	# 4. Real Water Fountain Square + Wooden Benches
	var fountain := PropFactory3D.build_fountain()
	fountain.position = Vector3(-5.0, 0, -1.0)
	fountain.scale = Vector3.ONE * 0.78
	add_child(fountain)

	var bench1 := PropFactory3D.build_wooden_bench()
	bench1.position = Vector3(-4.8, 0, 3.6)
	bench1.rotation_degrees.y = 152.0
	add_child(bench1)

	var bench2 := PropFactory3D.build_wooden_bench()
	bench2.position = Vector3(2.3, 0, -4.3)
	bench2.rotation_degrees.y = -18.0
	add_child(bench2)

	# 5. Eastern Meadow Welcome Gateway Arch framing ToAlphabetMeadow portal
	var gateway := PropFactory3D.build_gateway_arch()
	gateway.position = Vector3(13.6, 0, 1.3)
	gateway.rotation_degrees.y = 90.0
	add_child(gateway)

	# 6. Varied Big Trees (3 styles) + Small Trees / Saplings (3 styles) with Wind-Animated Foliage
	var tree_specs := [
		{ "pos": Vector3(-15.5, 0, -7.2), "scale": 1.08, "color": Color("#265B33"), "style": "oak", "rot": 18.0 },
		{ "pos": Vector3(-15.2, 0, 5.8),  "scale": 1.04, "color": Color("#1E4D2D"), "style": "pine", "rot": 40.0 },
		{ "pos": Vector3(-8.2, 0, 8.4),   "scale": 0.98, "color": Color("#2F6D39"), "style": "oak", "rot": -35.0 },
		{ "pos": Vector3(7.4, 0, -8.6),   "scale": 1.12, "color": Color("#215330"), "style": "pine", "rot": 12.0 },
		{ "pos": Vector3(15.2, 0, -7.6),  "scale": 1.05, "color": Color("#2A6436"), "style": "oak", "rot": 65.0 },
		{ "pos": Vector3(14.5, 0, 7.4),   "scale": 0.98, "color": Color("#DF6B88"), "style": "blossom", "rot": -20.0 },
		{ "pos": Vector3(-4.4, 0, -9.4),  "scale": 1.06, "color": Color("#1F4F2E"), "style": "pine", "rot": 80.0 },
		{ "pos": Vector3(4.6, 0, -9.4),   "scale": 1.02, "color": Color("#2B6637"), "style": "oak", "rot": -55.0 },
		# Small Trees / Saplings (3 distinct small variants)
		{ "pos": Vector3(-6.2, 0, 7.6),   "scale": 0.92, "color": Color("#387B3E"), "style": "sapling_oak", "rot": 25.0 },
		{ "pos": Vector3(7.6, 0, 7.4),    "scale": 0.95, "color": Color("#2E6D37"), "style": "berry_tree", "rot": -15.0 },
		{ "pos": Vector3(5.2, 0, -3.6),   "scale": 0.88, "color": Color("#235D34"), "style": "cypress_small", "rot": 0.0 },
		{ "pos": Vector3(-13.6, 0, -1.8), "scale": 0.90, "color": Color("#35743B"), "style": "berry_tree", "rot": 48.0 },
	]
	for ts in tree_specs:
		var tree := PropFactory3D.build_stylized_tree(float(ts["scale"]), ts["color"], str(ts["style"]))
		tree.position = ts["pos"]
		tree.rotation_degrees.y = float(ts["rot"])
		add_child(tree)

	# 7. Warm Glowing Lampposts
	var lamp_spots := [
		Vector3(-2.6, 0, -3.2),
		Vector3(2.6, 0, -3.2),
		Vector3(8.2, 0, 0.2),
		Vector3(-8.0, 0, 2.2)
	]
	for lp in lamp_spots:
		var lamp := PropFactory3D.build_lamppost()
		lamp.position = lp
		add_child(lamp)

	# 8. Wooden Fences, 3 Shrub Variants, Flowerbeds, Mushrooms, Pebbles & Stump
	var decor := Node3D.new()
	decor.name = "VillageDecor"
	add_child(decor)
	_add_fence_row(decor, Vector3(-14.5, 0, 8.8), Vector3(-5.8, 0, 8.8), 6)
	_add_fence_row(decor, Vector3(5.8, 0, 8.8), Vector3(14.5, 0, 8.8), 6)

	var flower_spots: Array[Vector3] = [
		Vector3(9.4, 0, -1.6),
		Vector3(11.8, 0, 5.2),
		Vector3(-3.0, 0, 5.8),
		Vector3(3.2, 0, 5.8),
		Vector3(-7.4, 0, -0.4),
	]
	var flower_cols := [Color("#E85878"), Color("#F0B836"), Color("#589BE8"), Color("#EB6884"), Color("#B974F0")]
	for fi in range(flower_spots.size()):
		_add_flower_cluster(decor, flower_spots[fi], flower_cols[fi])

	_add_shrub(decor, Vector3(-7.6, 0, -4.8), 1.15, Color("#275E32"), 0)
	_add_shrub(decor, Vector3(6.8, 0, -4.4), 1.05, Color("#2D6B37"), 1)
	_add_shrub(decor, Vector3(13.2, 0, 4.4), 0.95, Color("#2A6234"), 2)
	_add_shrub(decor, Vector3(-1.8, 0, 7.4), 0.92, Color("#32723B"), 1)
	_add_shrub(decor, Vector3(4.8, 0, 7.5), 1.00, Color("#2A6334"), 2)
	_add_shrub(decor, Vector3(-9.8, 0, 5.2), 1.05, Color("#285F32"), 0)

	_add_mushroom_patch(decor, Vector3(-13.8, 0, 5.2))
	_add_mushroom_patch(decor, Vector3(13.8, 0, -6.8))
	_add_stump_and_leaves(decor, Vector3(-9.4, 0, 7.2), Color("#427E38"))
	_add_pebble_cluster(decor, Vector3(4.5, 0, 3.0))
	_add_pebble_cluster(decor, Vector3(-5.8, 0, 2.2))
	_add_pebble_cluster(decor, Vector3(8.5, 0, 2.6))
	_add_rock(Vector3(-13.8, 0, 3.8), 0.65, Color("#5A6270"), false)
	_add_rock(Vector3(12.8, 0, -0.8), 0.58, Color("#5C6573"), false)

	# 9. Real MultiMesh Wind-Animated Grass System across meadow (avoiding plaza, trails, houses, fountain)
	var avoid_circles: Array[Dictionary] = [
		{ "center": Vector2(0.0, 1.5), "radius": 6.55 },     # Central Cobblestone Plaza
		{ "center": Vector2(-5.0, -1.0), "radius": 2.45 },   # Fountain footprint
		{ "center": Vector2(-10.0, 0.6), "radius": 1.65 },   # Chest camp
		{ "center": Vector2(16.5, 1.25), "radius": 2.0 },    # Meadow portal
	]
	var avoid_rects: Array[Rect2] = [
		Rect2(Vector2(-3.6, -10.8), Vector2(7.2, 6.2)),      # Owl Academy + front porch
		Rect2(Vector2(8.0, -7.8), Vector2(7.2, 6.4)),        # Lily Cottage
		Rect2(Vector2(-15.2, -8.0), Vector2(7.0, 6.4)),      # Supply Cottage
		Rect2(Vector2(-1.4, -5.8), Vector2(2.8, 7.5)),       # Path Plaza <-> Owl Academy
		Rect2(Vector2(-10.5, -0.5), Vector2(7.5, 2.5)),      # Path Plaza <-> Chest
		Rect2(Vector2(4.0, 0.2), Vector2(13.0, 2.6)),        # Path Plaza <-> Gateway Portal
	]
	_add_grass_field(decor, avoid_circles, avoid_rects, Rect2(Vector2(-17.2, -10.2), Vector2(34.4, 20.2)), 202611)

	# 10. Dynamic Ambient Life (Butterflies + Soaring Birds) & Sunlit Pollen Particles
	var life := AmbientLife3D.new()
	life.name = "AmbientLife3D"
	add_child(life)
	life.setup_village_life(flower_spots, Vector3(0, 0, 0))

	_add_fireflies(Color("#FFE478"), 24)


func _build_alphabet_meadow() -> void:
	_add_ground_plane(120.0, 100.0, Color("#306B37"))
	_add_mountain_backdrop(Color("#295E32"), Color("#3D5872"))

	var meadow_disc := CylinderMesh.new()
	meadow_disc.top_radius = 19.5
	meadow_disc.bottom_radius = 20.5
	meadow_disc.height = 0.12
	meadow_disc.radial_segments = 28
	_mesh(self, "MeadowTerrace", meadow_disc, _mat(Color("#44803E"), 0.86), Vector3(0, 0.01, 0), Vector3.ZERO, false)

	var path_mat := _mat(Color("#9A784E"), 0.82)
	var stone_mat := _mat(Color("#868C98"), 0.82)
	var trails := Node3D.new()
	add_child(trails)
	_add_trail_segment(trails, Vector3(-16.8, 0, 2.2), Vector3(16.5, 0, 2.2), 2.1, path_mat, stone_mat)
	_add_trail_segment(trails, Vector3(-8.8, 0, 2.2), Vector3(-8.8, 0, -3.2), 1.65, path_mat, stone_mat)
	_add_trail_segment(trails, Vector3(0.8, 0, 2.2), Vector3(0.8, 0, -4.6), 1.65, path_mat, stone_mat)
	_add_trail_segment(trails, Vector3(7.5, 0, 2.2), Vector3(7.5, 0, 5.6), 1.65, path_mat, stone_mat)
	_add_trail_segment(trails, Vector3(10.0, 0, 2.2), Vector3(10.0, 0, -3.2), 1.65, path_mat, stone_mat)

	var trees := [
		{ "pos": Vector3(-13.5, 0, -6.5), "style": "oak", "col": Color("#2A6838") },
		{ "pos": Vector3(-4.0, 0, -7.2),  "style": "pine", "col": Color("#205430") },
		{ "pos": Vector3(5.5, 0, -7.5),   "style": "oak", "col": Color("#34753D") },
		{ "pos": Vector3(13.8, 0, -6.0),  "style": "pine", "col": Color("#245B33") },
		{ "pos": Vector3(12.5, 0, 6.8),   "style": "blossom", "col": Color("#E4728E") },
		{ "pos": Vector3(-12.5, 0, 6.8),  "style": "oak", "col": Color("#2D6B39") },
	]
	for t_info in trees:
		var t := PropFactory3D.build_stylized_tree(1.05, t_info["col"], str(t_info["style"]))
		t.position = t_info["pos"]
		add_child(t)

	_add_rock(Vector3(0.0, 0, 6.2), 1.05)
	_add_flower_cluster(self, Vector3(-6.0, 0, -1.5), Color("#ED5A7C"))
	_add_flower_cluster(self, Vector3(4.2, 0, -2.2), Color("#F2C236"))
	_add_flower_cluster(self, Vector3(-2.5, 0, 4.5), Color("#509CEB"))
	_add_fireflies(Color("#EBFF80"), 22)


func _build_letter_cave() -> void:
	_add_ground_plane(74.0, 54.0, Color(0.16, 0.19, 0.28))
	var floor_m := CylinderMesh.new()
	floor_m.top_radius = 17.5
	floor_m.bottom_radius = 18.5
	floor_m.height = 0.12
	_mesh(self, "CaveFloor", floor_m, _mat(Color(0.27, 0.31, 0.41), 0.85), Vector3(0, 0.02, 0), Vector3.ZERO, false)

	var stone := _mat(Color(0.34, 0.38, 0.48), 0.86)
	var arch_m := TorusMesh.new()
	arch_m.inner_radius = 4.2
	arch_m.outer_radius = 5.6
	_mesh(self, "CaveArchNorth", arch_m, stone, Vector3(0.5, 0.5, -6.5), Vector3(90, 0, 0))
	_mesh(self, "CaveArchBack", arch_m, stone, Vector3(0.5, 0.8, -9.8), Vector3(90, 0, 0))

	var crystal_spots := [Vector3(-11.0, 0, -5.5), Vector3(11.0, 0, -5.0), Vector3(-6.0, 0, -7.8), Vector3(6.5, 0, -7.8)]
	for cp in crystal_spots:
		var c := PropFactory3D.build_interactable_prop("crystal")
		c.position = cp
		c.scale = Vector3.ONE * 1.4
		add_child(c)

	_add_rock(Vector3(-7.5, 0, -3.1), 1.15, Color(0.36, 0.40, 0.50))
	_add_rock(Vector3(8.75, 0, 5.0), 1.15, Color(0.36, 0.40, 0.50))
	_add_fireflies(Color(0.45, 0.90, 1.0), 24)


func _build_crystal_lake() -> void:
	_add_ground_plane(116.0, 96.0, Color("#265F4A"))
	_add_mountain_backdrop(Color("#1F5243"), Color("#2E536E"))

	var sand := CylinderMesh.new()
	sand.top_radius = 9.2
	sand.bottom_radius = 9.8
	sand.height = 0.08
	_mesh(self, "ShoreSand", sand, _mat(Color("#D4C294"), 0.82), Vector3(-0.3, 0.02, 3.8), Vector3.ZERO, false)

	var water_mesh := CylinderMesh.new()
	water_mesh.top_radius = 6.2
	water_mesh.bottom_radius = 6.2
	water_mesh.height = 0.14
	water_mesh.radial_segments = 28
	_mesh(self, "LakeWaterSurface", water_mesh, PropFactory3D.create_stylized_water_material(Color(0.15, 0.68, 0.92, 0.88)), Vector3(-0.3, 0.05, 4.2), Vector3.ZERO, false)

	var lake_body := StaticBody3D.new()
	lake_body.collision_layer = 32 | 64
	lake_body.collision_mask = 0
	var lake_col := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 5.8
	cyl.height = 1.6
	lake_col.shape = cyl
	lake_col.position = Vector3(-0.3, 0.7, 4.2)
	lake_body.add_child(lake_col)
	add_child(lake_body)

	for cp in [Vector3(-12.0, 0, -6.0), Vector3(11.0, 0, -6.5), Vector3(13.0, 0, 5.0)]:
		var cr := PropFactory3D.build_interactable_prop("crystal")
		cr.position = cp
		cr.scale = Vector3.ONE * 1.5
		add_child(cr)

	for tp in [Vector3(-13.5, 0, -5.0), Vector3(13.5, 0, 6.2), Vector3(-5.0, 0, -8.5)]:
		var t := PropFactory3D.build_stylized_tree(1.0, Color("#20634A"), "pine")
		t.position = tp
		add_child(t)

	_add_fireflies(Color(0.42, 0.96, 1.0), 26)


func _build_shadow_gate() -> void:
	_add_ground_plane(76.0, 54.0, Color(0.14, 0.13, 0.26))

	var path_m := BoxMesh.new()
	path_m.size = Vector3(5.6, 0.10, 14.0)
	_mesh(self, "AncientPath", path_m, _mat(Color(0.26, 0.23, 0.39), 0.72), Vector3(0, 0.03, 3.0), Vector3.ZERO, false)

	var sanct := CylinderMesh.new()
	sanct.top_radius = 6.8
	sanct.bottom_radius = 7.4
	sanct.height = 0.18
	_mesh(self, "SanctuaryPlatform", sanct, _mat(Color(0.22, 0.19, 0.36), 0.65), Vector3(0, 0.06, -4.0), Vector3.ZERO, false)

	var obsidian := _mat(Color(0.18, 0.16, 0.30), 0.45, 0.3)
	var rune_violet := _mat(Color(0.68, 0.38, 1.0), 0.2, 0.0, Color(0.66, 0.36, 1.0), 1.6)
	var arch := TorusMesh.new()
	arch.inner_radius = 3.1
	arch.outer_radius = 3.9
	_mesh(self, "ShadowArch", arch, obsidian, Vector3(0, 2.6, -5.6), Vector3(90, 0, 0))
	var inner_rune := TorusMesh.new()
	inner_rune.inner_radius = 2.65
	inner_rune.outer_radius = 2.85
	_mesh(self, "ShadowRuneRing", inner_rune, rune_violet, Vector3(0, 2.6, -5.6), Vector3(90, 0, 0))

	_add_rock(Vector3(-6.25, 0, 0.6), 1.15, Color(0.28, 0.26, 0.42))
	_add_rock(Vector3(6.25, 0, 0.6), 1.15, Color(0.28, 0.26, 0.42))
	_add_fireflies(Color(0.76, 0.48, 1.0), 26)
