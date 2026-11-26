extends RefCounted
class_name PropFactory3D
## Stylized 3D Fantasy Cartoon Prop & Landmark Builder.
## Provides articulated/detailed 3D placeholder models for Welcome Village,
## Alphabet Meadow, Letter Cave, Crystal Lake, and The Shadow Gate,
## plus interactive objects (Signpost, Chest, Lost Letter, Crystal, Portal).


static func build_interactable_prop(visual_type: String) -> Node3D:
	var root := Node3D.new()
	root.name = "Prop_%s" % visual_type
	match visual_type:
		"chest":
			_build_chest(root)
		"letter":
			_build_lost_letter(root)
		"crystal":
			_build_crystal(root)
		"portal":
			_build_portal(root)
		_:
			_build_signpost(root)
	return root


static func _mat(albedo: Color, roughness: float = 0.55, metallic: float = 0.0, emission: Color = Color.BLACK, emission_energy: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = albedo
	m.roughness = roughness
	m.metallic = metallic
	if emission_energy > 0.0:
		m.emission_enabled = true
		m.emission = emission
		m.emission_energy_multiplier = emission_energy
	return m


static func _mesh_part(parent: Node3D, node_name: String, mesh: Mesh, mat: Material, pos: Vector3 = Vector3.ZERO, rot_deg: Vector3 = Vector3.ZERO, scl: Vector3 = Vector3.ONE, lod_end: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot_deg
	mi.scale = scl
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	# Keep all village/area meshes continuously visible (no mid-range LOD popping)
	if lod_end > 90.0:
		mi.visibility_range_end = lod_end
		mi.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	parent.add_child(mi)
	return mi


static func _box(sz: Vector3) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = sz
	return b


static func _cyl(rt: float, rb: float, h: float, seg: int = 16) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = rt
	c.bottom_radius = rb
	c.height = h
	c.radial_segments = seg
	return c


static func _sph(r: float, h: float = -1.0) -> SphereMesh:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0 if h < 0.0 else h
	s.rings = 10
	s.radial_segments = 16
	return s


static func _torus(ir: float, orad: float) -> TorusMesh:
	var t := TorusMesh.new()
	t.inner_radius = ir
	t.outer_radius = orad
	t.rings = 18
	t.ring_segments = 12
	return t


static func _build_signpost(root: Node3D) -> void:
	var wood := _mat(Color(0.56, 0.34, 0.18), 0.72)
	var board := _mat(Color(0.84, 0.65, 0.38), 0.62)
	var trim := _mat(Color(0.96, 0.80, 0.28), 0.35, 0.45)
	var glow := _mat(Color(0.45, 0.88, 1.0), 0.2, 0.0, Color(0.45, 0.88, 1.0), 1.1)

	_mesh_part(root, "BaseStone", _cyl(0.32, 0.38, 0.16), _mat(Color(0.52, 0.56, 0.62), 0.8), Vector3(0, 0.08, 0))
	_mesh_part(root, "Post", _cyl(0.10, 0.12, 1.35), wood, Vector3(0, 0.75, 0))
	_mesh_part(root, "Board", _box(Vector3(1.05, 0.52, 0.12)), board, Vector3(0, 1.18, 0.04))
	_mesh_part(root, "BoardFrameTop", _box(Vector3(1.10, 0.06, 0.16)), trim, Vector3(0, 1.44, 0.04))
	_mesh_part(root, "LanternGem", _sph(0.09), glow, Vector3(0.48, 1.46, 0.04), Vector3.ZERO, Vector3.ONE, 28.0)


static func _build_chest(root: Node3D) -> void:
	var wood := _mat(Color(0.58, 0.33, 0.16), 0.65)
	var gold := _mat(Color(0.98, 0.78, 0.22), 0.28, 0.8)
	var gem := _mat(Color(0.30, 0.92, 0.96), 0.15, 0.0, Color(0.30, 0.92, 0.96), 1.4)

	_mesh_part(root, "ChestBase", _box(Vector3(0.95, 0.48, 0.68)), wood, Vector3(0, 0.24, 0))
	_mesh_part(root, "GoldBandL", _box(Vector3(0.10, 0.50, 0.72)), gold, Vector3(-0.34, 0.25, 0))
	_mesh_part(root, "GoldBandR", _box(Vector3(0.10, 0.50, 0.72)), gold, Vector3(0.34, 0.25, 0))

	var lid_pivot := Node3D.new()
	lid_pivot.name = "LidPivot"
	lid_pivot.position = Vector3(0, 0.48, -0.34)
	root.add_child(lid_pivot)
	_mesh_part(lid_pivot, "ChestLid", _cyl(0.34, 0.34, 0.96), wood, Vector3(0, 0.04, 0.34), Vector3(0, 0, 90))
	_mesh_part(lid_pivot, "LidLock", _box(Vector3(0.18, 0.20, 0.08)), gold, Vector3(0, 0.02, 0.68))
	_mesh_part(lid_pivot, "LidGem", _sph(0.065), gem, Vector3(0, 0.02, 0.72))


static func _build_lost_letter(root: Node3D) -> void:
	var stone := _mat(Color(0.75, 0.78, 0.84), 0.65)
	var gold := _mat(Color(1.0, 0.82, 0.25), 0.25, 0.6, Color(1.0, 0.78, 0.20), 0.75)
	var rune := _mat(Color(0.40, 0.92, 1.0), 0.2, 0.0, Color(0.40, 0.92, 1.0), 1.3)

	_mesh_part(root, "Pedestal", _cyl(0.32, 0.42, 0.45), stone, Vector3(0, 0.22, 0))
	_mesh_part(root, "HaloRing", _torus(0.34, 0.40), rune, Vector3(0, 0.48, 0))

	var float_node := Node3D.new()
	float_node.name = "FloatToken"
	float_node.position = Vector3(0, 1.05, 0)
	root.add_child(float_node)
	_mesh_part(float_node, "TokenDisc", _cyl(0.36, 0.36, 0.12), gold, Vector3.ZERO, Vector3(90, 0, 0))
	_mesh_part(float_node, "InnerStar", _box(Vector3(0.26, 0.26, 0.18)), rune, Vector3.ZERO, Vector3(0, 0, 45))


static func _build_crystal(root: Node3D) -> void:
	var rock := _mat(Color(0.34, 0.38, 0.46), 0.85)
	var cyan := _mat(Color(0.34, 0.90, 1.0), 0.15, 0.1, Color(0.32, 0.88, 1.0), 1.45)
	var violet := _mat(Color(0.72, 0.48, 1.0), 0.18, 0.1, Color(0.70, 0.45, 1.0), 1.1)

	_mesh_part(root, "RockBase", _cyl(0.45, 0.58, 0.24, 8), rock, Vector3(0, 0.12, 0))
	var float_node := Node3D.new()
	float_node.name = "FloatToken"
	float_node.position = Vector3(0, 0.82, 0)
	root.add_child(float_node)
	_mesh_part(float_node, "MainSpire", _cyl(0.02, 0.26, 1.05, 6), cyan, Vector3(0, 0.12, 0))
	_mesh_part(float_node, "SideSpireL", _cyl(0.02, 0.16, 0.66, 6), violet, Vector3(-0.22, -0.05, 0.08), Vector3(12, 0, 22))
	_mesh_part(float_node, "SideSpireR", _cyl(0.02, 0.15, 0.62, 6), violet, Vector3(0.22, -0.06, -0.06), Vector3(-10, 0, -24))


static func _build_portal(root: Node3D) -> void:
	var stone := _mat(Color(0.44, 0.48, 0.58), 0.72)
	var rune := _mat(Color(0.36, 0.86, 1.0), 0.2, 0.1, Color(0.36, 0.86, 1.0), 1.6)
	var core_mat := StandardMaterial3D.new()
	core_mat.albedo_color = Color(0.45, 0.88, 1.0, 0.45)
	core_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	core_mat.emission_enabled = true
	core_mat.emission = Color(0.38, 0.86, 1.0)
	core_mat.emission_energy_multiplier = 1.5

	_mesh_part(root, "PadBase", _cyl(1.10, 1.25, 0.20, 20), stone, Vector3(0, 0.10, 0))
	_mesh_part(root, "ArchRing", _torus(0.92, 1.12), stone, Vector3(0, 1.25, 0), Vector3(90, 0, 0))
	_mesh_part(root, "RuneRing", _torus(0.78, 0.86), rune, Vector3(0, 1.25, 0), Vector3(90, 0, 0))
	var veil := _mesh_part(root, "PortalVeil", _cyl(0.76, 0.76, 0.05, 20), core_mat, Vector3(0, 1.25, 0), Vector3(90, 0, 0))
	veil.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var particles := CPUParticles3D.new()
	particles.name = "PortalParticles"
	particles.position = Vector3(0, 1.1, 0)
	particles.amount = 18
	particles.lifetime = 1.6
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 0.85
	particles.gravity = Vector3(0, 0.65, 0)
	particles.initial_velocity_min = 0.2
	particles.initial_velocity_max = 0.6
	particles.scale_amount_min = 0.05
	particles.scale_amount_max = 0.12
	var p_mesh := SphereMesh.new()
	p_mesh.radius = 0.5
	p_mesh.height = 1.0
	p_mesh.material = rune
	particles.mesh = p_mesh
	root.add_child(particles)


static func build_stylized_tree(scale_factor: float = 1.0, leaf_color: Color = Color(0.24, 0.68, 0.34)) -> Node3D:
	var tree := Node3D.new()
	tree.name = "StylizedTree3D"
	var trunk_mat := _mat(Color(0.50, 0.31, 0.18), 0.78)
	var leaf_mat := _mat(leaf_color, 0.62)
	var leaf_hi := _mat(leaf_color.lightened(0.14), 0.58)

	_mesh_part(tree, "Trunk", _cyl(0.24, 0.38, 2.2, 10), trunk_mat, Vector3(0, 1.1, 0))
	_mesh_part(tree, "CanopyMain", _sph(1.35, 2.2), leaf_mat, Vector3(0, 2.75, 0))
	_mesh_part(tree, "CanopyTop", _sph(0.95, 1.6), leaf_hi, Vector3(0.25, 3.65, -0.15), Vector3.ZERO, Vector3.ONE, 42.0)
	_mesh_part(tree, "CanopySide", _sph(0.90, 1.5), leaf_hi, Vector3(-0.65, 2.55, 0.35), Vector3.ZERO, Vector3.ONE, 42.0)

	var body := StaticBody3D.new()
	body.collision_layer = 32
	body.collision_mask = 0
	var col := CollisionShape3D.new()
	var cyl_shape := CylinderShape3D.new()
	cyl_shape.radius = 0.42
	cyl_shape.height = 2.2
	col.shape = cyl_shape
	col.position = Vector3(0, 1.1, 0)
	body.add_child(col)
	tree.add_child(body)

	# Camera-fade occluder (layer 16) so tree softly turns translucent if between Camera3D and Player
	var cam_occ_body := StaticBody3D.new()
	cam_occ_body.collision_layer = 16
	cam_occ_body.collision_mask = 0
	cam_occ_body.set_meta("occluder_root", tree)
	var trunk_occ := CollisionShape3D.new()
	var trunk_sph := CylinderShape3D.new()
	trunk_sph.radius = 0.45
	trunk_sph.height = 2.2
	trunk_occ.shape = trunk_sph
	trunk_occ.position = Vector3(0, 1.1, 0)
	cam_occ_body.add_child(trunk_occ)
	var canopy_col := CollisionShape3D.new()
	var canopy_sph := SphereShape3D.new()
	canopy_sph.radius = 1.45
	canopy_col.shape = canopy_sph
	canopy_col.position = Vector3(0, 2.75, 0)
	cam_occ_body.add_child(canopy_col)
	tree.add_child(cam_occ_body)

	tree.scale = Vector3.ONE * scale_factor
	return tree


static func build_village_cottage(roof_color: Color = Color(0.84, 0.34, 0.28), wall_color: Color = Color(0.97, 0.93, 0.84), with_owl_sign: bool = false) -> Node3D:
	var house := Node3D.new()
	house.name = "Cottage3D"
	var wall_m := _mat(wall_color, 0.72)
	var roof_m := _mat(roof_color, 0.55)
	var wood_m := _mat(Color(0.46, 0.28, 0.16), 0.70)
	var stone_m := _mat(Color(0.58, 0.60, 0.66), 0.82)
	var window_glow := _mat(Color(1.0, 0.86, 0.45), 0.2, 0.0, Color(1.0, 0.84, 0.38), 1.1)

	_mesh_part(house, "StoneFoundation", _box(Vector3(4.6, 0.5, 4.0)), stone_m, Vector3(0, 0.25, 0))
	_mesh_part(house, "Walls", _box(Vector3(4.2, 2.6, 3.6)), wall_m, Vector3(0, 1.8, 0))
	_mesh_part(house, "RoofPyramid", _cyl(0.25, 3.55, 2.2, 4), roof_m, Vector3(0, 4.1, 0), Vector3(0, 45, 0))
	_mesh_part(house, "Chimney", _box(Vector3(0.55, 1.5, 0.55)), stone_m, Vector3(1.2, 4.1, -0.7), Vector3.ZERO, Vector3.ONE, 48.0)
	_mesh_part(house, "Door", _box(Vector3(0.95, 1.65, 0.14)), wood_m, Vector3(0, 1.32, 1.82))
	_mesh_part(house, "PorchStep", _box(Vector3(1.5, 0.22, 0.75)), stone_m, Vector3(0, 0.11, 2.15))
	_mesh_part(house, "WindowL", _box(Vector3(0.75, 0.75, 0.14)), window_glow, Vector3(-1.25, 1.9, 1.82))
	_mesh_part(house, "WindowR", _box(Vector3(0.75, 0.75, 0.14)), window_glow, Vector3(1.25, 1.9, 1.82))
	_mesh_part(house, "WindowSideL", _box(Vector3(0.14, 0.75, 0.75)), window_glow, Vector3(-2.12, 1.9, 0), Vector3.ZERO, Vector3.ONE, 42.0)
	_mesh_part(house, "WindowSideR", _box(Vector3(0.14, 0.75, 0.75)), window_glow, Vector3(2.12, 1.9, 0), Vector3.ZERO, Vector3.ONE, 42.0)

	if with_owl_sign:
		_mesh_part(house, "AcademySign", _cyl(0.45, 0.45, 0.12), _mat(Color(0.96, 0.78, 0.24), 0.3, 0.6), Vector3(0, 2.65, 1.88), Vector3(90, 0, 0))

	var body := StaticBody3D.new()
	body.collision_layer = 32
	body.collision_mask = 0
	var col := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(4.5, 3.2, 3.9)
	col.shape = box_shape
	col.position = Vector3(0, 1.6, 0)
	body.add_child(col)
	house.add_child(body)

	# Camera-fade occluder (layer 16) so cottage softly turns translucent when Leo walks behind it
	var house_occ_body := StaticBody3D.new()
	house_occ_body.collision_layer = 16
	house_occ_body.collision_mask = 0
	house_occ_body.set_meta("occluder_root", house)
	var house_occ_col := CollisionShape3D.new()
	var house_occ_box := BoxShape3D.new()
	house_occ_box.size = Vector3(5.3, 5.2, 5.2)
	house_occ_col.shape = house_occ_box
	house_occ_col.position = Vector3(0, 2.6, 0)
	house_occ_body.add_child(house_occ_col)
	house.add_child(house_occ_body)
	return house


static func build_fountain() -> Node3D:
	var f := Node3D.new()
	f.name = "VillageFountain3D"
	var stone := _mat(Color(0.76, 0.78, 0.84), 0.68)
	var rim := _mat(Color(0.86, 0.88, 0.92), 0.55)
	var water_mat := create_stylized_water_material(Color(0.20, 0.74, 0.96, 0.85))

	_mesh_part(f, "BasinOuter", _cyl(2.2, 2.4, 0.55, 20), stone, Vector3(0, 0.28, 0))
	_mesh_part(f, "RimTorus", _torus(1.95, 2.25), rim, Vector3(0, 0.58, 0))
	_mesh_part(f, "CenterPillar", _cyl(0.36, 0.52, 1.7, 14), stone, Vector3(0, 0.85, 0))
	_mesh_part(f, "TopBowl", _cyl(0.85, 0.32, 0.35, 16), rim, Vector3(0, 1.65, 0))
	_mesh_part(f, "CrystalFinial", _cyl(0.02, 0.18, 0.55, 6), _mat(Color(0.45, 0.92, 1.0), 0.15, 0.1, Color(0.45, 0.92, 1.0), 1.3), Vector3(0, 2.08, 0))

	var water_disc := _mesh_part(f, "WaterSurface", _cyl(1.92, 1.92, 0.06, 20), water_mat, Vector3(0, 0.46, 0))
	water_disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var body := StaticBody3D.new()
	body.collision_layer = 32
	body.collision_mask = 0
	var col := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 2.25
	cyl.height = 1.6
	col.shape = cyl
	col.position = Vector3(0, 0.8, 0)
	body.add_child(col)
	f.add_child(body)
	return f


static func build_lamppost() -> Node3D:
	var lamp := Node3D.new()
	lamp.name = "LampPost3D"
	var iron := _mat(Color(0.22, 0.25, 0.32), 0.45, 0.6)
	var glow := _mat(Color(1.0, 0.88, 0.50), 0.1, 0.0, Color(1.0, 0.84, 0.42), 1.8)
	_mesh_part(lamp, "Base", _cyl(0.14, 0.22, 0.35, 10), iron, Vector3(0, 0.18, 0))
	_mesh_part(lamp, "Pole", _cyl(0.06, 0.08, 2.6, 10), iron, Vector3(0, 1.5, 0))
	_mesh_part(lamp, "Arm", _box(Vector3(0.48, 0.08, 0.08)), iron, Vector3(0.20, 2.75, 0))
	_mesh_part(lamp, "Lantern", _sph(0.20), glow, Vector3(0.40, 2.58, 0))

	var body := StaticBody3D.new()
	body.collision_layer = 32
	body.collision_mask = 0
	var col := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 0.22
	cyl.height = 2.6
	col.shape = cyl
	col.position = Vector3(0, 1.3, 0)
	body.add_child(col)
	lamp.add_child(body)

	var occ_body := StaticBody3D.new()
	occ_body.collision_layer = 16
	occ_body.collision_mask = 0
	occ_body.set_meta("occluder_root", lamp)
	var occ_col := CollisionShape3D.new()
	var occ_cyl := CylinderShape3D.new()
	occ_cyl.radius = 0.42
	occ_cyl.height = 2.9
	occ_col.shape = occ_cyl
	occ_col.position = Vector3(0.15, 1.45, 0)
	occ_body.add_child(occ_col)
	lamp.add_child(occ_body)
	return lamp


static func create_stylized_water_material(base_color: Color = Color(0.16, 0.68, 0.92, 0.86)) -> ShaderMaterial:
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, specular_schlick_ggx;

uniform vec4 shallow_color : source_color = vec4(0.22, 0.78, 0.96, 0.86);
uniform vec4 deep_color : source_color = vec4(0.08, 0.42, 0.76, 0.92);
uniform float wave_speed = 1.4;

void vertex() {
	float w = sin(VERTEX.x * 1.8 + TIME * wave_speed) * 0.04 + cos(VERTEX.z * 2.1 + TIME * (wave_speed * 0.85)) * 0.04;
	VERTEX.y += w;
}

void fragment() {
	float ripple = sin(UV.x * 26.0 + TIME * 1.8) * cos(UV.y * 26.0 - TIME * 1.4);
	vec3 col = mix(deep_color.rgb, shallow_color.rgb, 0.55 + ripple * 0.22);
	float sparkle = smoothstep(0.68, 0.96, ripple);
	ALBEDO = col + vec3(sparkle * 0.28);
	ROUGHNESS = 0.14;
	METALLIC = 0.15;
	ALPHA = shallow_color.a;
}
"""
	var sm := ShaderMaterial.new()
	sm.shader = sh
	sm.set_shader_parameter("shallow_color", base_color)
	sm.set_shader_parameter("deep_color", base_color.darkened(0.32))
	return sm
