extends Node3D
class_name AreaEnvironment3D
## Procedural 3D Stylized Fantasy Environment Builder for Alphabet Island's 5 Areas.
## Builds terrain, multi-tier hills, stone plazas, curving trails, cottages, trees,
## lampposts, animated water, cave arches, crystals, firefly particles, and colliders.

@export_enum("welcome_village", "alphabet_meadow", "letter_cave", "crystal_lake", "shadow_gate") var area_id: String = "welcome_village"


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


func _mat(albedo: Color, roughness: float = 0.72, metallic: float = 0.0, emission: Color = Color.BLACK, emission_energy: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = albedo
	m.roughness = roughness
	m.metallic = metallic
	if emission_energy > 0.0:
		m.emission_enabled = true
		m.emission = emission
		m.emission_energy_multiplier = emission_energy
	return m


func _mesh(parent: Node3D, node_name: String, mesh: Mesh, mat: Material, pos: Vector3, rot_deg: Vector3 = Vector3.ZERO, shadows: bool = true, lod_end: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot_deg
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadows else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if lod_end > 0.0:
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
	_mesh(self, "GroundMesh", plane, _mat(color, 0.85), Vector3.ZERO, Vector3.ZERO, false)


func _add_trail_segment(parent: Node3D, from_p: Vector3, to_p: Vector3, width: float, mat: Material) -> void:
	var diff := to_p - from_p
	var length := Vector2(diff.x, diff.z).length()
	if length < 0.05:
		return
	var mid := (from_p + to_p) * 0.5
	var box := BoxMesh.new()
	box.size = Vector3(width, 0.04, length + width * 0.5)
	var yaw := rad_to_deg(atan2(diff.x, diff.z))
	_mesh(parent, "Trail", box, mat, Vector3(mid.x, 0.02, mid.z), Vector3(0, yaw, 0), false)


func _add_fireflies(color: Color, count: int = 24, spread: Vector3 = Vector3(16.0, 2.2, 9.0)) -> void:
	if SettingsManager.graphics_quality == "low":
		return
	var p := CPUParticles3D.new()
	p.name = "AmbientParticles"
	p.position = Vector3(0, 1.5, 0)
	p.amount = count if SettingsManager.graphics_quality == "high" else maxi(8, count / 2)
	p.lifetime = 3.2
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = spread
	p.gravity = Vector3(0, 0.12, 0)
	p.initial_velocity_min = 0.15
	p.initial_velocity_max = 0.45
	p.scale_amount_min = 0.04
	p.scale_amount_max = 0.10
	var sm := SphereMesh.new()
	sm.radius = 0.5
	sm.height = 1.0
	sm.material = _mat(color, 0.1, 0.0, color, 2.0)
	p.mesh = sm
	add_child(p)


func _add_flower_cluster(parent: Node3D, pos: Vector3, petal_color: Color) -> void:
	var leaf_m := _mat(Color(0.24, 0.68, 0.32), 0.7)
	var pet_m := _mat(petal_color, 0.45, 0.0, petal_color, 0.15)
	var bush := SphereMesh.new()
	bush.radius = 0.35
	bush.height = 0.4
	_mesh(parent, "Bush", bush, leaf_m, pos + Vector3(0, 0.14, 0), Vector3.ZERO, false, 34.0)
	for i in range(3):
		var fl := SphereMesh.new()
		fl.radius = 0.09
		fl.height = 0.14
		var ang := float(i) * 2.1
		_mesh(parent, "Flower%d" % i, fl, pet_m, pos + Vector3(cos(ang) * 0.22, 0.32, sin(ang) * 0.22), Vector3.ZERO, false, 28.0)


func _add_fence_row(parent: Node3D, start_p: Vector3, end_p: Vector3, posts: int) -> void:
	var wood := _mat(Color(0.62, 0.40, 0.22), 0.72)
	for i in range(posts):
		var t := float(i) / maxf(1.0, float(posts - 1))
		var p := start_p.lerp(end_p, t)
		var post_m := CylinderMesh.new()
		post_m.top_radius = 0.07
		post_m.bottom_radius = 0.09
		post_m.height = 0.75
		_mesh(parent, "Post_%d" % i, post_m, wood, p + Vector3(0, 0.37, 0), Vector3.ZERO, true, 36.0)
	var diff := end_p - start_p
	var len_f := Vector2(diff.x, diff.z).length()
	var mid := (start_p + end_p) * 0.5
	var yaw := rad_to_deg(atan2(diff.x, diff.z))
	var rail := BoxMesh.new()
	rail.size = Vector3(0.06, 0.08, len_f)
	_mesh(parent, "RailTop", rail, wood, Vector3(mid.x, 0.56, mid.z), Vector3(0, yaw, 0), false, 36.0)
	_mesh(parent, "RailLow", rail, wood, Vector3(mid.x, 0.28, mid.z), Vector3(0, yaw, 0), false, 36.0)


func _add_rock(pos: Vector3, radius: float, color: Color = Color(0.46, 0.49, 0.55), has_collider: bool = true) -> void:
	var rm := SphereMesh.new()
	rm.radius = radius
	rm.height = radius * 1.45
	rm.rings = 6
	rm.radial_segments = 8
	_mesh(self, "Rock3D", rm, _mat(color, 0.88), pos + Vector3(0, radius * 0.45, 0), Vector3(8, 22, -6))
	if has_collider:
		var body := StaticBody3D.new()
		body.collision_layer = 2
		var col := CollisionShape3D.new()
		var sp := SphereShape3D.new()
		sp.radius = radius * 0.9
		col.shape = sp
		col.position = pos + Vector3(0, radius * 0.5, 0)
		body.add_child(col)
		add_child(body)


func _add_hills_backdrop(hill_color: Color) -> void:
	var h_mat := _mat(hill_color, 0.82)
	var positions := [
		Vector3(-24, -1.0, -16), Vector3(-10, -0.5, -18), Vector3(6, -0.8, -19), Vector3(22, -1.0, -16),
		Vector3(-25, -1.2, 6), Vector3(25, -1.2, 6), Vector3(-18, -1.5, 17), Vector3(18, -1.5, 17)
	]
	for i in range(positions.size()):
		var sm := SphereMesh.new()
		sm.radius = 8.0 + float(i % 3) * 2.5
		sm.height = 7.0 + float(i % 2) * 2.5
		_mesh(self, "Hill_%d" % i, sm, h_mat, positions[i], Vector3.ZERO, false)


func _build_welcome_village() -> void:
	_add_ground_plane(74.0, 52.0, Color(0.36, 0.72, 0.36))
	_add_hills_backdrop(Color(0.28, 0.62, 0.32))

	# Raised lush village lawn
	var lawn := CylinderMesh.new()
	lawn.top_radius = 18.0
	lawn.bottom_radius = 19.2
	lawn.height = 0.14
	lawn.radial_segments = 32
	_mesh(self, "VillageLawn", lawn, _mat(Color(0.46, 0.80, 0.42), 0.82), Vector3(0, 0.01, 0), Vector3.ZERO, false)

	# Cobblestone central plaza
	var plaza_rim := CylinderMesh.new()
	plaza_rim.top_radius = 6.2
	plaza_rim.bottom_radius = 6.4
	plaza_rim.height = 0.08
	plaza_rim.radial_segments = 28
	_mesh(self, "PlazaBorder", plaza_rim, _mat(Color(0.76, 0.64, 0.42), 0.75), Vector3(0, 0.03, 1.5), Vector3.ZERO, false)

	var plaza_inner := CylinderMesh.new()
	plaza_inner.top_radius = 5.6
	plaza_inner.bottom_radius = 5.7
	plaza_inner.height = 0.09
	plaza_inner.radial_segments = 28
	_mesh(self, "PlazaSurface", plaza_inner, _mat(Color(0.92, 0.85, 0.66), 0.68), Vector3(0, 0.04, 1.5), Vector3.ZERO, false)

	# Pathways connecting landmarks
	var path_mat := _mat(Color(0.88, 0.79, 0.56), 0.76)
	var trails_root := Node3D.new()
	trails_root.name = "VillageTrails"
	add_child(trails_root)
	_add_trail_segment(trails_root, Vector3(0, 0, 1.5), Vector3(0, 0, -4.5), 2.1, path_mat) # To Owl House
	_add_trail_segment(trails_root, Vector3(-3.5, 0, 1.5), Vector3(-10.0, 0, 0.6), 1.8, path_mat) # To Chest
	_add_trail_segment(trails_root, Vector3(4.2, 0, 1.8), Vector3(16.5, 0, 1.25), 2.1, path_mat) # To Meadow Portal
	_add_trail_segment(trails_root, Vector3(6.0, 0, 2.5), Vector3(10.0, 0, 3.3), 1.7, path_mat) # To Lily

	# Professor Owl's Academy Cottage (North center)
	var owl_house := PropFactory3D.build_village_cottage(Color(0.24, 0.44, 0.78), Color(0.98, 0.94, 0.84), true)
	owl_house.position = Vector3(0, 0, -6.5)
	add_child(owl_house)

	# Lily's Garden Cottage (Northeast)
	var lily_house := PropFactory3D.build_village_cottage(Color(0.86, 0.36, 0.34), Color(0.98, 0.92, 0.82), false)
	lily_house.position = Vector3(11.6, 0, -4.6)
	lily_house.rotation_degrees.y = -24.0
	add_child(lily_house)

	# Cozy Explorer Bakery/Inn Cottage (Northwest)
	var west_house := PropFactory3D.build_village_cottage(Color(0.88, 0.58, 0.22), Color(0.96, 0.92, 0.84), false)
	west_house.position = Vector3(-11.8, 0, -4.8)
	west_house.rotation_degrees.y = 26.0
	add_child(west_house)

	# Central Village Fountain (offset left of center walkway so Owl & Player spawns remain clear)
	var fountain := PropFactory3D.build_fountain()
	fountain.position = Vector3(-5.0, 0, -0.8)
	fountain.scale = Vector3.ONE * 0.72
	add_child(fountain)

	# Stylized Trees framing the village
	var tree_spots := [
		Vector3(-15.5, 0, -7.2), Vector3(-15.2, 0, 5.8), Vector3(-8.0, 0, 8.2),
		Vector3(7.2, 0, -8.5), Vector3(15.0, 0, -7.8), Vector3(14.5, 0, 7.6),
		Vector3(-4.2, 0, -9.2), Vector3(4.5, 0, -9.2)
	]
	for i in range(tree_spots.size()):
		var leaf_c := Color(0.24, 0.68, 0.34) if i % 2 == 0 else Color(0.32, 0.74, 0.36)
		var tree := PropFactory3D.build_stylized_tree(0.95 + float(i % 3) * 0.14, leaf_c)
		tree.position = tree_spots[i]
		add_child(tree)

	# Warm Glowing Lampposts
	var lamp_spots := [Vector3(-2.6, 0, -3.4), Vector3(2.6, 0, -3.4), Vector3(7.8, 0, 0.2), Vector3(-8.2, 0, 2.2)]
	for lp in lamp_spots:
		var lamp := PropFactory3D.build_lamppost()
		lamp.position = lp
		add_child(lamp)

	# Wooden Fences & Flowerbeds
	var decor := Node3D.new()
	decor.name = "VillageDecor"
	add_child(decor)
	_add_fence_row(decor, Vector3(-14.5, 0, 8.8), Vector3(-6.0, 0, 8.8), 6)
	_add_fence_row(decor, Vector3(6.0, 0, 8.8), Vector3(14.5, 0, 8.8), 6)
	_add_flower_cluster(decor, Vector3(9.4, 0, -1.6), Color(1.0, 0.45, 0.65))
	_add_flower_cluster(decor, Vector3(11.6, 0, 1.4), Color(1.0, 0.82, 0.25))
	_add_flower_cluster(decor, Vector3(-3.2, 0, 5.8), Color(0.55, 0.78, 1.0))
	_add_flower_cluster(decor, Vector3(3.4, 0, 5.8), Color(1.0, 0.55, 0.72))

	_add_fireflies(Color(1.0, 0.92, 0.48), 22)


func _build_alphabet_meadow() -> void:
	_add_ground_plane(74.0, 52.0, Color(0.34, 0.74, 0.42))
	_add_hills_backdrop(Color(0.28, 0.64, 0.34))

	var path_mat := _mat(Color(0.88, 0.80, 0.54), 0.76)
	var trails := Node3D.new()
	add_child(trails)
	_add_trail_segment(trails, Vector3(-16.8, 0, 2.2), Vector3(16.5, 0, 2.2), 2.0, path_mat)
	_add_trail_segment(trails, Vector3(-8.8, 0, 2.2), Vector3(-8.8, 0, -3.2), 1.6, path_mat)
	_add_trail_segment(trails, Vector3(0.8, 0, 2.2), Vector3(0.8, 0, -4.6), 1.6, path_mat)
	_add_trail_segment(trails, Vector3(7.5, 0, 2.2), Vector3(7.5, 0, 5.6), 1.6, path_mat)
	_add_trail_segment(trails, Vector3(10.0, 0, 2.2), Vector3(10.0, 0, -3.2), 1.6, path_mat)

	# Stylized Meadow Trees & Flowers
	var trees := [Vector3(-13.5, 0, -6.5), Vector3(-4.0, 0, -7.2), Vector3(5.5, 0, -7.5), Vector3(13.8, 0, -6.0), Vector3(12.5, 0, 6.8), Vector3(-12.5, 0, 6.8)]
	for i in range(trees.size()):
		var t := PropFactory3D.build_stylized_tree(1.05, Color(0.26, 0.74, 0.38) if i % 2 == 0 else Color(0.36, 0.78, 0.40))
		t.position = trees[i]
		add_child(t)

	_add_rock(Vector3(0.0, 0, 6.2), 1.05)
	_add_flower_cluster(self, Vector3(-6.0, 0, -1.5), Color(1.0, 0.50, 0.72))
	_add_flower_cluster(self, Vector3(4.2, 0, -2.2), Color(1.0, 0.85, 0.25))
	_add_flower_cluster(self, Vector3(-2.5, 0, 4.5), Color(0.45, 0.82, 1.0))
	_add_fireflies(Color(0.95, 1.0, 0.58), 24)


func _build_letter_cave() -> void:
	_add_ground_plane(70.0, 50.0, Color(0.18, 0.21, 0.30))
	var floor_m := CylinderMesh.new()
	floor_m.top_radius = 17.5
	floor_m.bottom_radius = 18.5
	floor_m.height = 0.12
	_mesh(self, "CaveFloor", floor_m, _mat(Color(0.30, 0.34, 0.44), 0.85), Vector3(0, 0.02, 0), Vector3.ZERO, false)

	# Giant Stone Cave Arches
	var stone := _mat(Color(0.36, 0.39, 0.48), 0.86)
	var arch_m := TorusMesh.new()
	arch_m.inner_radius = 4.2
	arch_m.outer_radius = 5.6
	_mesh(self, "CaveArchNorth", arch_m, stone, Vector3(0.5, 0.5, -6.5), Vector3(90, 0, 0))
	_mesh(self, "CaveArchBack", arch_m, stone, Vector3(0.5, 0.8, -9.8), Vector3(90, 0, 0))

	# Glowing Cave Crystals
	var crystal_spots := [Vector3(-11.0, 0, -5.5), Vector3(11.0, 0, -5.0), Vector3(-6.0, 0, -7.8), Vector3(6.5, 0, -7.8)]
	for cp in crystal_spots:
		var c := PropFactory3D.build_interactable_prop("crystal")
		c.position = cp
		c.scale = Vector3.ONE * 1.4
		add_child(c)

	_add_rock(Vector3(-7.5, 0, -3.1), 1.15, Color(0.36, 0.40, 0.50))
	_add_rock(Vector3(8.75, 0, 5.0), 1.15, Color(0.36, 0.40, 0.50))
	_add_fireflies(Color(0.45, 0.90, 1.0), 26)


func _build_crystal_lake() -> void:
	_add_ground_plane(74.0, 52.0, Color(0.28, 0.68, 0.54))
	_add_hills_backdrop(Color(0.22, 0.56, 0.48))

	# Sandy shoreline around lake
	var sand := CylinderMesh.new()
	sand.top_radius = 9.2
	sand.bottom_radius = 9.8
	sand.height = 0.08
	_mesh(self, "ShoreSand", sand, _mat(Color(0.92, 0.86, 0.66), 0.78), Vector3(-0.3, 0.02, 3.8), Vector3.ZERO, false)

	# Shimmering 3D Lake Water + Collider
	var water_mesh := CylinderMesh.new()
	water_mesh.top_radius = 6.2
	water_mesh.bottom_radius = 6.2
	water_mesh.height = 0.14
	water_mesh.radial_segments = 28
	_mesh(self, "LakeWaterSurface", water_mesh, PropFactory3D.create_stylized_water_material(Color(0.18, 0.74, 0.96, 0.88)), Vector3(-0.3, 0.05, 4.2), Vector3.ZERO, false)

	var lake_body := StaticBody3D.new()
	lake_body.collision_layer = 2
	var lake_col := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 5.8
	cyl.height = 1.6
	lake_col.shape = cyl
	lake_col.position = Vector3(-0.3, 0.7, 4.2)
	lake_body.add_child(lake_col)
	add_child(lake_body)

	# Giant Glowing Crystals & Trees
	for cp in [Vector3(-12.0, 0, -6.0), Vector3(11.0, 0, -6.5), Vector3(13.0, 0, 5.0)]:
		var cr := PropFactory3D.build_interactable_prop("crystal")
		cr.position = cp
		cr.scale = Vector3.ONE * 1.5
		add_child(cr)

	for tp in [Vector3(-13.5, 0, -5.0), Vector3(13.5, 0, 6.2), Vector3(-5.0, 0, -8.5)]:
		var t := PropFactory3D.build_stylized_tree(1.0, Color(0.22, 0.72, 0.56))
		t.position = tp
		add_child(t)

	_add_fireflies(Color(0.42, 0.96, 1.0), 28)


func _build_shadow_gate() -> void:
	_add_ground_plane(74.0, 52.0, Color(0.15, 0.14, 0.28))

	# Obsidian Sanctuary Platform & Ancient Path
	var path_m := BoxMesh.new()
	path_m.size = Vector3(5.6, 0.10, 14.0)
	_mesh(self, "AncientPath", path_m, _mat(Color(0.28, 0.25, 0.42), 0.72), Vector3(0, 0.03, 3.0), Vector3.ZERO, false)

	var sanct := CylinderMesh.new()
	sanct.top_radius = 6.8
	sanct.bottom_radius = 7.4
	sanct.height = 0.18
	_mesh(self, "SanctuaryPlatform", sanct, _mat(Color(0.24, 0.20, 0.38), 0.65), Vector3(0, 0.06, -4.0), Vector3.ZERO, false)

	# Monumental Shadow Gate Arch behind obj_shadow_gate_seal
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
	_add_fireflies(Color(0.76, 0.48, 1.0), 28)
