extends RefCounted
class_name PropFactory3D
## Stylized 3D Fantasy Cartoon Prop & Landmark Builder.
## Builds multi-part stylized fantasy architecture, varied trees (oak/pine/blossom),
## fountains, warm lantern posts, archways, lecterns, benches, and interactable props
## with shared material/mesh caching and mobile-safe contact shadows.

static var _mesh_cache: Dictionary = {}
static var _mat_cache: Dictionary = {}


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


static func _mat(albedo: Color, roughness: float = 0.62, metallic: float = 0.0, emission: Color = Color.BLACK, emission_energy: float = 0.0) -> StandardMaterial3D:
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


static func _mesh_part(
	parent: Node3D,
	node_name: String,
	mesh: Mesh,
	mat: Material,
	pos: Vector3 = Vector3.ZERO,
	rot_deg: Vector3 = Vector3.ZERO,
	scl: Vector3 = Vector3.ONE,
	lod_end: float = 0.0,
	cast_shadows: bool = true
) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot_deg
	mi.scale = scl
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if cast_shadows else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if lod_end > 90.0:
		mi.visibility_range_end = lod_end
		mi.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	parent.add_child(mi)
	return mi


static func _add_contact_shadow(parent: Node3D, radius: float, opacity: float = 0.28) -> void:
	var key := "cshad|%.2f" % opacity
	var sm: StandardMaterial3D
	if _mat_cache.has(key):
		sm = _mat_cache[key] as StandardMaterial3D
	else:
		sm = StandardMaterial3D.new()
		sm.albedo_color = Color(0.05, 0.09, 0.14, opacity)
		sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_mat_cache[key] = sm
	var disc := _mesh_part(parent, "ContactShadow", _cyl(radius, radius, 0.012, 16), sm, Vector3(0, 0.014, 0), Vector3.ZERO, Vector3.ONE, 0.0, false)
	disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


static func _box(sz: Vector3) -> BoxMesh:
	var key := "box|%.2f|%.2f|%.2f" % [sz.x, sz.y, sz.z]
	if _mesh_cache.has(key):
		return _mesh_cache[key] as BoxMesh
	var b := BoxMesh.new()
	b.size = sz
	_mesh_cache[key] = b
	return b


static func _cyl(rt: float, rb: float, h: float, seg: int = 16) -> CylinderMesh:
	var key := "cyl|%.2f|%.2f|%.2f|%d" % [rt, rb, h, seg]
	if _mesh_cache.has(key):
		return _mesh_cache[key] as CylinderMesh
	var c := CylinderMesh.new()
	c.top_radius = rt
	c.bottom_radius = rb
	c.height = h
	c.radial_segments = seg
	_mesh_cache[key] = c
	return c


static func _sph(r: float, h: float = -1.0, rings: int = 10, segs: int = 16) -> SphereMesh:
	var hh := r * 2.0 if h < 0.0 else h
	var key := "sph|%.2f|%.2f|%d|%d" % [r, hh, rings, segs]
	if _mesh_cache.has(key):
		return _mesh_cache[key] as SphereMesh
	var s := SphereMesh.new()
	s.radius = r
	s.height = hh
	s.rings = rings
	s.radial_segments = segs
	_mesh_cache[key] = s
	return s


static func _torus(ir: float, orad: float) -> TorusMesh:
	var key := "tor|%.2f|%.2f" % [ir, orad]
	if _mesh_cache.has(key):
		return _mesh_cache[key] as TorusMesh
	var t := TorusMesh.new()
	t.inner_radius = ir
	t.outer_radius = orad
	t.rings = 18
	t.ring_segments = 12
	_mesh_cache[key] = t
	return t


static func _build_signpost(root: Node3D) -> void:
	var wood := _mat(Color("#6E4728"), 0.74)
	var dark_wood := _mat(Color("#4E301B"), 0.78)
	var board := _mat(Color("#C9995A"), 0.65)
	var trim := _mat(Color("#E8B83A"), 0.35, 0.45)
	var stone := _mat(Color("#697380"), 0.85)
	var glow := _mat(Color("#5ED8FF"), 0.15, 0.0, Color("#4AC8FF"), 1.05)

	_add_contact_shadow(root, 0.48, 0.26)
	_mesh_part(root, "BaseStone", _cyl(0.32, 0.42, 0.18, 8), stone, Vector3(0, 0.09, 0))
	_mesh_part(root, "Post", _cyl(0.10, 0.13, 1.48, 10), wood, Vector3(0, 0.82, 0))
	_mesh_part(root, "PostCap", _cyl(0.04, 0.15, 0.16, 6), dark_wood, Vector3(0, 1.62, 0))
	_mesh_part(root, "CrossBeam", _box(Vector3(1.16, 0.10, 0.12)), dark_wood, Vector3(0, 1.24, 0.02))
	_mesh_part(root, "Board", _box(Vector3(1.08, 0.50, 0.09)), board, Vector3(0, 1.20, 0.06))
	_mesh_part(root, "BoardFrameTop", _box(Vector3(1.14, 0.06, 0.12)), trim, Vector3(0, 1.46, 0.06))
	_mesh_part(root, "ArrowTip", _cyl(0.02, 0.16, 0.24, 4), trim, Vector3(0.58, 1.20, 0.06), Vector3(0, 0, -90))
	_mesh_part(root, "LanternHook", _box(Vector3(0.24, 0.05, 0.05)), dark_wood, Vector3(-0.46, 1.48, 0.05))
	_mesh_part(root, "LanternGem", _sph(0.09), glow, Vector3(-0.56, 1.38, 0.05), Vector3.ZERO, Vector3.ONE, 0.0, false)


static func _build_chest(root: Node3D) -> void:
	var wood := _mat(Color("#734120"), 0.66)
	var dark_wood := _mat(Color("#4E2A14"), 0.72)
	var gold := _mat(Color("#F2B830"), 0.28, 0.78)
	var gem := _mat(Color("#3FE0EB"), 0.15, 0.0, Color("#3FE0EB"), 1.3)

	_add_contact_shadow(root, 0.62, 0.30)
	_mesh_part(root, "ChestBase", _box(Vector3(1.00, 0.50, 0.70)), wood, Vector3(0, 0.25, 0))
	_mesh_part(root, "BasePlinth", _box(Vector3(1.06, 0.10, 0.76)), dark_wood, Vector3(0, 0.05, 0))
	_mesh_part(root, "GoldBandL", _box(Vector3(0.10, 0.52, 0.74)), gold, Vector3(-0.35, 0.26, 0))
	_mesh_part(root, "GoldBandR", _box(Vector3(0.10, 0.52, 0.74)), gold, Vector3(0.35, 0.26, 0))

	var lid_pivot := Node3D.new()
	lid_pivot.name = "LidPivot"
	lid_pivot.position = Vector3(0, 0.50, -0.35)
	root.add_child(lid_pivot)
	_mesh_part(lid_pivot, "ChestLid", _cyl(0.35, 0.35, 1.00, 12), wood, Vector3(0, 0.04, 0.35), Vector3(0, 0, 90))
	_mesh_part(lid_pivot, "LidBandL", _cyl(0.365, 0.365, 0.10, 12), gold, Vector3(-0.35, 0.04, 0.35), Vector3(0, 0, 90))
	_mesh_part(lid_pivot, "LidBandR", _cyl(0.365, 0.365, 0.10, 12), gold, Vector3(0.35, 0.04, 0.35), Vector3(0, 0, 90))
	_mesh_part(lid_pivot, "LidLock", _box(Vector3(0.20, 0.22, 0.08)), gold, Vector3(0, 0.02, 0.69))
	_mesh_part(lid_pivot, "LidGem", _sph(0.068), gem, Vector3(0, 0.02, 0.73), Vector3.ZERO, Vector3.ONE, 0.0, false)


static func _build_lost_letter(root: Node3D) -> void:
	var stone := _mat(Color("#7C8492"), 0.74)
	var gold := _mat(Color("#F8C438"), 0.24, 0.62, Color("#F5B828"), 0.7)
	var rune := _mat(Color("#4CCEFF"), 0.18, 0.0, Color("#4CCEFF"), 1.25)

	_add_contact_shadow(root, 0.50, 0.28)
	_mesh_part(root, "PedestalBase", _cyl(0.42, 0.50, 0.14, 8), stone, Vector3(0, 0.07, 0))
	_mesh_part(root, "Pedestal", _cyl(0.30, 0.38, 0.42, 8), stone, Vector3(0, 0.32, 0))
	_mesh_part(root, "HaloRing", _torus(0.34, 0.40), rune, Vector3(0, 0.56, 0), Vector3.ZERO, Vector3.ONE, 0.0, false)

	var float_node := Node3D.new()
	float_node.name = "FloatToken"
	float_node.position = Vector3(0, 1.08, 0)
	root.add_child(float_node)
	_mesh_part(float_node, "TokenDisc", _cyl(0.36, 0.36, 0.12), gold, Vector3.ZERO, Vector3(90, 0, 0))
	_mesh_part(float_node, "InnerStar", _box(Vector3(0.26, 0.26, 0.18)), rune, Vector3.ZERO, Vector3(0, 0, 45), Vector3.ONE, 0.0, false)


static func _build_crystal(root: Node3D) -> void:
	var rock := _mat(Color("#4A5161"), 0.86)
	var cyan := _mat(Color("#46D8FA"), 0.15, 0.1, Color("#3ECDF5"), 1.35)
	var violet := _mat(Color("#945CEB"), 0.18, 0.1, Color("#884CE6"), 1.05)

	_add_contact_shadow(root, 0.62, 0.30)
	_mesh_part(root, "RockBase", _cyl(0.45, 0.60, 0.26, 8), rock, Vector3(0, 0.13, 0))
	var float_node := Node3D.new()
	float_node.name = "FloatToken"
	float_node.position = Vector3(0, 0.84, 0)
	root.add_child(float_node)
	_mesh_part(float_node, "MainSpire", _cyl(0.02, 0.26, 1.08, 6), cyan, Vector3(0, 0.12, 0))
	_mesh_part(float_node, "SideSpireL", _cyl(0.02, 0.16, 0.66, 6), violet, Vector3(-0.22, -0.05, 0.08), Vector3(12, 0, 22))
	_mesh_part(float_node, "SideSpireR", _cyl(0.02, 0.15, 0.62, 6), violet, Vector3(0.22, -0.06, -0.06), Vector3(-10, 0, -24))


static func _build_portal(root: Node3D) -> void:
	var stone := _mat(Color("#5B6374"), 0.78)
	var trim := _mat(Color("#808A9E"), 0.68)
	var rune := _mat(Color("#46C8FA"), 0.2, 0.1, Color("#3DBDF5"), 1.45)
	var gold := _mat(Color("#EEBA3A"), 0.3, 0.65)
	var core_mat := StandardMaterial3D.new()
	core_mat.albedo_color = Color(0.32, 0.82, 0.98, 0.44)
	core_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	core_mat.emission_enabled = true
	core_mat.emission = Color(0.34, 0.84, 1.0)
	core_mat.emission_energy_multiplier = 1.4

	_add_contact_shadow(root, 1.35, 0.30)
	_mesh_part(root, "PadBase", _cyl(1.16, 1.34, 0.22, 16), stone, Vector3(0, 0.11, 0))
	_mesh_part(root, "PadStep", _cyl(0.95, 1.02, 0.10, 16), trim, Vector3(0, 0.24, 0))
	_mesh_part(root, "ArchPillarL", _cyl(0.18, 0.24, 1.25, 8), stone, Vector3(-1.02, 0.82, 0))
	_mesh_part(root, "ArchPillarR", _cyl(0.18, 0.24, 1.25, 8), stone, Vector3(1.02, 0.82, 0))
	_mesh_part(root, "ArchRing", _torus(0.92, 1.14), stone, Vector3(0, 1.35, 0), Vector3(90, 0, 0))
	_mesh_part(root, "Keystone", _box(Vector3(0.36, 0.34, 0.32)), gold, Vector3(0, 2.40, 0))
	_mesh_part(root, "RuneRing", _torus(0.78, 0.86), rune, Vector3(0, 1.35, 0), Vector3(90, 0, 0), Vector3.ONE, 0.0, false)
	_mesh_part(root, "PortalVeil", _cyl(0.76, 0.76, 0.05, 18), core_mat, Vector3(0, 1.35, 0), Vector3(90, 0, 0), Vector3.ONE, 0.0, false)

	var particles := CPUParticles3D.new()
	particles.name = "PortalParticles"
	particles.add_to_group("quality_particles")
	particles.set_meta("base_amount", 16)
	particles.position = Vector3(0, 1.2, 0)
	var gq := SettingsManager.graphics_quality
	particles.amount = 16 if gq == "high" else 8
	particles.visible = gq != "low"
	particles.emitting = gq != "low"
	particles.lifetime = 1.6
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 0.85
	particles.gravity = Vector3(0, 0.6, 0)
	particles.initial_velocity_min = 0.18
	particles.initial_velocity_max = 0.55
	particles.scale_amount_min = 0.045
	particles.scale_amount_max = 0.10
	var p_mesh := SphereMesh.new()
	p_mesh.radius = 0.5
	p_mesh.height = 1.0
	p_mesh.material = rune
	particles.mesh = p_mesh
	root.add_child(particles)


static func create_foliage_wind_material(
	base_color: Color,
	tip_color: Color,
	wind_strength: float = 0.085,
	cluster_height: float = 1.4
) -> ShaderMaterial:
	var key := "fwind|%s|%s|%.3f|%.2f" % [base_color.to_html(false), tip_color.to_html(false), wind_strength, cluster_height]
	if _mat_cache.has(key):
		return _mat_cache[key] as ShaderMaterial
	var sm := ShaderMaterial.new()
	sm.shader = load("res://shaders/stylized_foliage_wind.gdshader") as Shader
	sm.set_shader_parameter("base_color", base_color)
	sm.set_shader_parameter("tip_color", tip_color)
	sm.set_shader_parameter("wind_strength", wind_strength)
	sm.set_shader_parameter("cluster_height", cluster_height)
	_mat_cache[key] = sm
	return sm


static func build_stylized_tree(
	scale_factor: float = 1.0,
	leaf_color: Color = Color("#2B6638"),
	style: String = "oak"
) -> Node3D:
	var tree := Node3D.new()
	tree.name = "StylizedTree3D"
	var trunk_mat := _mat(Color("#6A4326"), 0.84)
	var bark_dark := _mat(Color("#4D301C"), 0.88)

	var leaf_dark := create_foliage_wind_material(leaf_color.darkened(0.24), leaf_color.lightened(0.10), 0.075, 1.5)
	var leaf_mid := create_foliage_wind_material(leaf_color.darkened(0.10), leaf_color.lightened(0.20), 0.088, 1.4)
	var leaf_hi := create_foliage_wind_material(leaf_color, leaf_color.lightened(0.28), 0.10, 1.25)

	var is_small := style in ["sapling_oak", "berry_tree", "cypress_small"]
	_add_contact_shadow(tree, 0.85 if is_small else 1.45, 0.26 if is_small else 0.30)

	match style:
		"pine":
			# Layered evergreen with natural curved trunk, exposed lower boughs & scalloped needle skirts
			_mesh_part(tree, "Trunk", StylizedMeshKit.build_curved_trunk_mesh(0.32, 0.14, 2.7, 0.12, -0.06, 9), bark_dark, Vector3(0, 0, 0))
			_mesh_part(tree, "BoughL", StylizedMeshKit.build_curved_trunk_mesh(0.12, 0.06, 0.95, 0.14, 0.0, 7), bark_dark, Vector3(-0.1, 1.35, 0.08), Vector3(0, 0, 48))
			_mesh_part(tree, "BoughR", StylizedMeshKit.build_curved_trunk_mesh(0.12, 0.06, 0.90, -0.14, 0.0, 7), bark_dark, Vector3(0.1, 1.55, -0.08), Vector3(0, 0, -45))
			_mesh_part(tree, "PineSkirt1", StylizedMeshKit.build_pine_bough_tier_mesh(1.52, 1.15, 7, 0.2), leaf_dark, Vector3(0, 1.95, 0))
			_mesh_part(tree, "PineSkirt2", StylizedMeshKit.build_pine_bough_tier_mesh(1.22, 1.02, 7, 1.4), leaf_mid, Vector3(0.05, 2.72, -0.04), Vector3(0, 26, 0))
			_mesh_part(tree, "PineSkirt3", StylizedMeshKit.build_pine_bough_tier_mesh(0.88, 0.90, 6, 2.7), leaf_hi, Vector3(0.06, 3.44, -0.03), Vector3(0, 52, 0))
			_mesh_part(tree, "PineTopTuft", StylizedMeshKit.build_leaf_clump_mesh(3.1, 0.44, 0.56, 6, 10, 0.22), leaf_hi, Vector3(0.06, 4.02, -0.03))
		"blossom":
			var warm_trunk := _mat(Color("#7C563B"), 0.80)
			var bl_deep := create_foliage_wind_material(leaf_color.darkened(0.16), Color("#FFACC4"), 0.09, 1.3)
			var bl_hi := create_foliage_wind_material(Color("#EF7FA0"), Color("#FFD2DF"), 0.105, 1.2)
			_mesh_part(tree, "Trunk", StylizedMeshKit.build_curved_trunk_mesh(0.30, 0.16, 2.05, 0.22, 0.09, 9), warm_trunk, Vector3.ZERO)
			_mesh_part(tree, "BranchL", StylizedMeshKit.build_curved_trunk_mesh(0.14, 0.07, 1.05, 0.18, 0.05, 7), warm_trunk, Vector3(-0.08, 1.55, 0.04), Vector3(0, 0, 42))
			_mesh_part(tree, "BranchR", StylizedMeshKit.build_curved_trunk_mesh(0.13, 0.07, 1.00, -0.14, -0.06, 7), warm_trunk, Vector3(0.14, 1.65, -0.04), Vector3(0, 0, -38))
			_mesh_part(tree, "CanopyCore", StylizedMeshKit.build_leaf_clump_mesh(2.2, 1.18, 0.94, 7, 12, 0.20), bl_deep, Vector3(0.10, 2.78, 0.04))
			_mesh_part(tree, "CanopyTop", StylizedMeshKit.build_leaf_clump_mesh(4.8, 0.86, 0.72, 7, 11, 0.22), bl_hi, Vector3(0.36, 3.45, -0.14))
			_mesh_part(tree, "CanopyWest", StylizedMeshKit.build_leaf_clump_mesh(6.1, 0.82, 0.68, 6, 10, 0.20), bl_hi, Vector3(-0.76, 2.48, 0.24))
			_mesh_part(tree, "CanopyEast", StylizedMeshKit.build_leaf_clump_mesh(7.3, 0.74, 0.64, 6, 10, 0.20), bl_deep, Vector3(0.80, 2.42, 0.28))
		"sapling_oak":
			# Small tree variant 1: young slender forked oak
			_mesh_part(tree, "Trunk", StylizedMeshKit.build_curved_trunk_mesh(0.16, 0.08, 1.45, 0.12, 0.05, 7), trunk_mat, Vector3.ZERO)
			_mesh_part(tree, "BranchL", StylizedMeshKit.build_curved_trunk_mesh(0.07, 0.035, 0.62, 0.08, 0.0, 6), trunk_mat, Vector3(0.04, 1.05, 0.02), Vector3(0, 0, 34))
			_mesh_part(tree, "LeafCrown", StylizedMeshKit.build_leaf_clump_mesh(8.4, 0.72, 0.62, 6, 10, 0.22), leaf_hi, Vector3(0.08, 1.72, 0.02))
			_mesh_part(tree, "LeafSide", StylizedMeshKit.build_leaf_clump_mesh(9.1, 0.52, 0.45, 6, 9, 0.20), leaf_mid, Vector3(-0.38, 1.48, 0.14))
		"berry_tree":
			# Small tree variant 2: low orchard berry tree with visible fruit clusters
			_mesh_part(tree, "Trunk", StylizedMeshKit.build_curved_trunk_mesh(0.18, 0.10, 1.25, -0.10, 0.06, 7), bark_dark, Vector3.ZERO)
			_mesh_part(tree, "CrownA", StylizedMeshKit.build_leaf_clump_mesh(3.7, 0.82, 0.68, 6, 10, 0.21), leaf_mid, Vector3(-0.06, 1.56, 0.02))
			_mesh_part(tree, "CrownB", StylizedMeshKit.build_leaf_clump_mesh(5.9, 0.58, 0.50, 6, 9, 0.19), leaf_hi, Vector3(0.36, 1.45, -0.14))
			var berry_m := _mat(Color("#F05252"), 0.42, 0.0, Color("#D93B3B"), 0.15)
			for bp in [Vector3(-0.42, 1.42, 0.56), Vector3(0.28, 1.62, 0.48), Vector3(-0.18, 1.80, -0.45), Vector3(0.55, 1.38, 0.16)]:
				_mesh_part(tree, "Berry", _sph(0.08, 0.15, 5, 7), berry_m, bp, Vector3.ZERO, Vector3.ONE, 0.0, false)
		"cypress_small":
			# Small tree variant 3: stylized multi-tiered garden cypress / topiary tree
			_mesh_part(tree, "Trunk", StylizedMeshKit.build_curved_trunk_mesh(0.15, 0.08, 1.30, 0.04, 0.03, 7), bark_dark, Vector3.ZERO)
			_mesh_part(tree, "PuffLow", StylizedMeshKit.build_leaf_clump_mesh(1.5, 0.62, 0.55, 6, 10, 0.16), leaf_dark, Vector3(0, 1.22, 0))
			_mesh_part(tree, "PuffMid", StylizedMeshKit.build_leaf_clump_mesh(2.9, 0.50, 0.48, 6, 10, 0.16), leaf_mid, Vector3(0, 1.75, 0))
			_mesh_part(tree, "PuffTop", StylizedMeshKit.build_leaf_clump_mesh(4.3, 0.36, 0.40, 6, 9, 0.18), leaf_hi, Vector3(0, 2.22, 0))
		_:
			# Big Tree Variant 1 ("oak"): Broad storybook oak with curved buttressed trunk, 3 boughs & 6 layered wind-swaying leaf clusters
			_mesh_part(tree, "Trunk", StylizedMeshKit.build_curved_trunk_mesh(0.42, 0.22, 2.35, 0.18, 0.06, 9), trunk_mat, Vector3.ZERO)
			_mesh_part(tree, "BranchL", StylizedMeshKit.build_curved_trunk_mesh(0.16, 0.08, 1.15, 0.14, 0.04, 7), trunk_mat, Vector3(0.02, 1.75, 0.02), Vector3(8, 0, 42))
			_mesh_part(tree, "BranchR", StylizedMeshKit.build_curved_trunk_mesh(0.15, 0.075, 1.10, -0.12, -0.04, 7), trunk_mat, Vector3(0.12, 1.82, 0.02), Vector3(-10, 0, -38))
			_mesh_part(tree, "BranchBack", StylizedMeshKit.build_curved_trunk_mesh(0.13, 0.07, 0.95, 0.05, -0.10, 7), trunk_mat, Vector3(0.06, 1.90, -0.05), Vector3(-34, 0, 6))
			_mesh_part(tree, "CanopyCore", StylizedMeshKit.build_leaf_clump_mesh(1.1, 1.32, 1.05, 7, 12, 0.20), leaf_dark, Vector3(0.06, 2.95, 0.0))
			_mesh_part(tree, "CanopyCrown", StylizedMeshKit.build_leaf_clump_mesh(2.7, 0.98, 0.84, 7, 11, 0.22), leaf_hi, Vector3(0.24, 3.76, -0.10))
			_mesh_part(tree, "CanopyWest", StylizedMeshKit.build_leaf_clump_mesh(3.9, 0.96, 0.82, 6, 11, 0.20), leaf_mid, Vector3(-0.88, 2.70, 0.34))
			_mesh_part(tree, "CanopyEast", StylizedMeshKit.build_leaf_clump_mesh(5.2, 0.92, 0.78, 6, 11, 0.20), leaf_mid, Vector3(0.88, 2.66, 0.26))
			_mesh_part(tree, "CanopyBack", StylizedMeshKit.build_leaf_clump_mesh(6.4, 0.88, 0.76, 6, 10, 0.19), leaf_dark, Vector3(-0.18, 2.98, -0.78))
			_mesh_part(tree, "CanopyAccent", StylizedMeshKit.build_leaf_clump_mesh(7.8, 0.64, 0.56, 6, 10, 0.22), leaf_hi, Vector3(-0.42, 3.55, 0.42))

	var body := StaticBody3D.new()
	body.collision_layer = 32
	body.collision_mask = 0
	var col := CollisionShape3D.new()
	var cyl_shape := CylinderShape3D.new()
	cyl_shape.radius = 0.26 if is_small else 0.44
	cyl_shape.height = 1.6 if is_small else 2.2
	col.shape = cyl_shape
	col.position = Vector3(0, 0.8 if is_small else 1.1, 0)
	body.add_child(col)
	tree.add_child(body)

	# Camera-fade occluder (layer 16)
	var cam_occ_body := StaticBody3D.new()
	cam_occ_body.collision_layer = 16
	cam_occ_body.collision_mask = 0
	cam_occ_body.set_meta("occluder_root", tree)
	var trunk_occ := CollisionShape3D.new()
	var trunk_sph := CylinderShape3D.new()
	trunk_sph.radius = 0.28 if is_small else 0.46
	trunk_sph.height = 1.6 if is_small else 2.2
	trunk_occ.shape = trunk_sph
	trunk_occ.position = Vector3(0, 0.8 if is_small else 1.1, 0)
	cam_occ_body.add_child(trunk_occ)
	var canopy_col := CollisionShape3D.new()
	var canopy_sph := SphereShape3D.new()
	canopy_sph.radius = 1.05 if is_small else 1.78
	canopy_col.shape = canopy_sph
	canopy_col.position = Vector3(0, 1.75 if is_small else 2.90, 0)
	cam_occ_body.add_child(canopy_col)
	tree.add_child(cam_occ_body)

	tree.scale = Vector3.ONE * scale_factor
	return tree


static func build_shrub_variant(variant_idx: int = 0, scale_s: float = 1.0, color: Color = Color("#2D6B37")) -> Node3D:
	var shrub := Node3D.new()
	shrub.name = "Shrub3D_%d" % variant_idx
	var m_dark := create_foliage_wind_material(color.darkened(0.22), color.lightened(0.12), 0.055, 0.7)
	var m_hi := create_foliage_wind_material(color, color.lightened(0.24), 0.068, 0.65)
	_add_contact_shadow(shrub, 0.48 * scale_s, 0.22)

	match variant_idx % 3:
		1:
			# Fern / woodland rosette
			for i in range(5):
				var ang := float(i) * (TAU / 5.0)
				var frond := _mesh_part(shrub, "Frond_%d" % i, StylizedMeshKit.build_leaf_clump_mesh(float(i) + 0.5, 0.34, 0.16, 5, 8, 0.16), m_hi if i % 2 == 0 else m_dark, Vector3(cos(ang) * 0.22, 0.20, sin(ang) * 0.22), Vector3(-16, rad_to_deg(-ang), 0), Vector3(1.2, 0.75, 0.7))
				frond.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		2:
			# Flowering garden shrub
			_mesh_part(shrub, "BushBase", StylizedMeshKit.build_leaf_clump_mesh(3.3, 0.44, 0.36, 6, 9, 0.20), m_dark, Vector3(0, 0.24, 0))
			_mesh_part(shrub, "BushTop", StylizedMeshKit.build_leaf_clump_mesh(4.9, 0.32, 0.28, 6, 8, 0.20), m_hi, Vector3(0.14, 0.38, -0.10))
			var fl_m := _mat(Color("#FF78A0"), 0.45, 0.0, Color("#FF78A0"), 0.15)
			for fp in [Vector3(-0.20, 0.42, 0.24), Vector3(0.24, 0.46, 0.18), Vector3(0.05, 0.52, -0.16), Vector3(-0.18, 0.32, -0.22)]:
				_mesh_part(shrub, "Blossom", _sph(0.065, 0.11, 5, 7), fl_m, fp, Vector3.ZERO, Vector3.ONE, 0.0, false)
		_:
			# Berry woodland bush
			_mesh_part(shrub, "BushMain", StylizedMeshKit.build_leaf_clump_mesh(1.8, 0.46, 0.38, 6, 10, 0.22), m_dark, Vector3(0, 0.26, 0))
			_mesh_part(shrub, "BushSide", StylizedMeshKit.build_leaf_clump_mesh(2.4, 0.30, 0.26, 5, 8, 0.20), m_hi, Vector3(0.26, 0.20, 0.14))
			var ber := _mat(Color("#F2A62E"), 0.42)
			for bp in [Vector3(-0.22, 0.38, 0.28), Vector3(0.18, 0.44, 0.24), Vector3(0.32, 0.26, 0.26)]:
				_mesh_part(shrub, "Berry", _sph(0.055, 0.10, 4, 6), ber, bp, Vector3.ZERO, Vector3.ONE, 0.0, false)

	shrub.scale = Vector3.ONE * scale_s
	return shrub


static func build_village_cottage(
	roof_color: Color = Color("#4A3586"),
	wall_color: Color = Color("#E3DFD7"),
	with_owl_sign: bool = false,
	style: String = ""
) -> Node3D:
	var cottage_style := style if not style.is_empty() else ("academy" if with_owl_sign else "garden_cottage")
	var house := Node3D.new()
	house.name = "Cottage3D_%s" % cottage_style
	var wall_m := _mat(wall_color, 0.80)
	var roof_m := _mat(roof_color, 0.62)
	var roof_shingle_m := _mat(roof_color.darkened(0.18), 0.66)
	var timber_m := _mat(Color("#7A4D2A"), 0.74)
	var dark_timber_m := _mat(Color("#5C371C"), 0.78)
	var wood_door_m := _mat(Color("#8E5B32"), 0.68)
	var stone_step_m := _mat(Color("#4E5A6D"), 0.84)
	var stone_light_m := _mat(Color("#697589"), 0.78)
	var brass_m := _mat(Color("#E8B63E"), 0.30, 0.75)
	var glass_dark_m := _mat(Color("#2D4058"), 0.25, 0.1)
	var window_glow := _mat(Color("#FFE088"), 0.22, 0.0, Color("#FFCE5C"), 0.65)
	var vine_m := create_foliage_wind_material(Color("#2B6127"), Color("#569632"), 0.035, 1.2)
	var barrel_m := _mat(Color("#84532E"), 0.74)
	var iron_m := _mat(Color("#343C48"), 0.50, 0.60)

	_add_contact_shadow(house, 3.45, 0.28)

	# Slate-Blue Stone Foundation & Front Steps (matching reference Tudor cottage)
	_mesh_part(house, "FoundationBase", _box(Vector3(4.65, 0.28, 4.35)), stone_step_m, Vector3(0, 0.14, 0))
	_mesh_part(house, "FoundationLedge", _box(Vector3(4.45, 0.14, 4.15)), stone_light_m, Vector3(0, 0.34, 0))

	# Main Cream Stucco Body + Steep Triangular Plaster Gable Front/Back
	_mesh_part(house, "Walls", _box(Vector3(4.18, 2.32, 3.92)), wall_m, Vector3(0, 1.54, 0))
	_mesh_part(house, "GableWall", StylizedMeshKit.build_gable_prism_mesh(4.18, 2.25, 3.92), wall_m, Vector3(0, 2.70, 0))

	# Crisp Tudor Half-Timber Frame: Corner Posts, Middle Studs, Horizontal & Eave Beams
	for cx in [-2.06, 0.0, 2.06]:
		for cz in [-1.94, 1.94]:
			if cx != 0.0:
				_mesh_part(house, "CornerPost", _box(Vector3(0.20, 2.40, 0.20)), timber_m, Vector3(cx, 1.56, cz))
	for sx in [-1.25, 1.25]:
		_mesh_part(house, "FrontStud", _box(Vector3(0.14, 2.34, 0.14)), timber_m, Vector3(sx, 1.54, 1.96))
		_mesh_part(house, "BackStud", _box(Vector3(0.14, 2.34, 0.14)), timber_m, Vector3(sx, 1.54, -1.96))
	for sz in [-0.95, 0.0, 0.95]:
		_mesh_part(house, "SideStudL", _box(Vector3(0.14, 2.34, 0.14)), timber_m, Vector3(-2.08, 1.54, sz))
		_mesh_part(house, "SideStudR", _box(Vector3(0.14, 2.34, 0.14)), timber_m, Vector3(2.08, 1.54, sz))
	_mesh_part(house, "MidBeamF", _box(Vector3(4.30, 0.15, 0.16)), timber_m, Vector3(0, 2.18, 1.96))
	_mesh_part(house, "MidBeamB", _box(Vector3(4.30, 0.15, 0.16)), timber_m, Vector3(0, 2.18, -1.96))
	_mesh_part(house, "MidBeamL", _box(Vector3(0.16, 0.15, 4.08)), timber_m, Vector3(-2.08, 2.18, 0))
	_mesh_part(house, "MidBeamR", _box(Vector3(0.16, 0.15, 4.08)), timber_m, Vector3(2.08, 2.18, 0))
	_mesh_part(house, "EaveBeamF", _box(Vector3(4.36, 0.18, 0.18)), timber_m, Vector3(0, 2.70, 1.96))
	_mesh_part(house, "EaveBeamB", _box(Vector3(4.36, 0.18, 0.18)), timber_m, Vector3(0, 2.70, -1.96))

	# Gable Half-Timber Braces (Vertical King Post + Diagonal A-Braces)
	for gz in [1.96, -1.96]:
		_mesh_part(house, "GableKingPost", _box(Vector3(0.14, 2.15, 0.14)), timber_m, Vector3(0, 3.75, gz))
		_mesh_part(house, "GableBraceL", _box(Vector3(0.13, 1.72, 0.13)), timber_m, Vector3(-0.62, 3.35, gz), Vector3(0, 0, -40))
		_mesh_part(house, "GableBraceR", _box(Vector3(0.13, 1.72, 0.13)), timber_m, Vector3(0.62, 3.35, gz), Vector3(0, 0, 40))

	# Steep Royal Violet-Indigo Shingled Gable Roof + Timber Bargeboards
	_mesh_part(house, "MainRoof", StylizedMeshKit.build_gable_prism_mesh(4.86, 2.52, 4.58), roof_m, Vector3(0, 2.66, 0))
	_mesh_part(house, "RoofRidgeBeam", _box(Vector3(0.22, 0.22, 4.66)), roof_shingle_m, Vector3(0, 5.16, 0))
	# Shingle step ridges along slopes for tactile tile look
	for ri in range(3):
		var ry := 3.12 + float(ri) * 0.62
		var rx := 2.00 - float(ri) * 0.58
		_mesh_part(house, "ShingleStripL_%d" % ri, _box(Vector3(0.10, 0.08, 4.54)), roof_shingle_m, Vector3(-rx, ry, 0), Vector3(0, 0, 46))
		_mesh_part(house, "ShingleStripR_%d" % ri, _box(Vector3(0.10, 0.08, 4.54)), roof_shingle_m, Vector3(rx, ry, 0), Vector3(0, 0, -46))
	# Heavy Warm Wood Roof Bargeboards (Front & Back)
	for bz in [2.24, -2.24]:
		_mesh_part(house, "BargeboardL", _box(Vector3(0.18, 3.55, 0.22)), timber_m, Vector3(-1.24, 3.92, bz), Vector3(0, 0, -44))
		_mesh_part(house, "BargeboardR", _box(Vector3(0.18, 3.55, 0.22)), timber_m, Vector3(1.24, 3.92, bz), Vector3(0, 0, 44))

	# Round Leaded Attic Gable Window
	_mesh_part(house, "AtticRim", _cyl(0.42, 0.42, 0.16, 14), timber_m, Vector3(0, 3.92, 1.98), Vector3(90, 0, 0))
	_mesh_part(house, "AtticGlass", _cyl(0.32, 0.32, 0.18, 14), glass_dark_m, Vector3(0, 3.92, 1.99), Vector3(90, 0, 0))
	_mesh_part(house, "AtticMullionH", _box(Vector3(0.60, 0.05, 0.20)), dark_timber_m, Vector3(0, 3.92, 2.00))
	_mesh_part(house, "AtticMullionV", _box(Vector3(0.05, 0.60, 0.20)), dark_timber_m, Vector3(0, 3.92, 2.00))

	# Slate-Blue Stone Entry Stairs + Arched Oak Door Frame & Recessed Door
	_mesh_part(house, "StepLow", _box(Vector3(1.66, 0.16, 0.88)), stone_step_m, Vector3(0, 0.08, 2.36))
	_mesh_part(house, "StepMid", _box(Vector3(1.42, 0.16, 0.62)), stone_light_m, Vector3(0, 0.24, 2.22))
	_mesh_part(house, "DoorJambL", _box(Vector3(0.16, 1.62, 0.22)), timber_m, Vector3(-0.56, 1.18, 1.98))
	_mesh_part(house, "DoorJambR", _box(Vector3(0.16, 1.62, 0.22)), timber_m, Vector3(0.56, 1.18, 1.98))
	_mesh_part(house, "DoorArch", _torus(0.46, 0.62), timber_m, Vector3(0, 1.88, 1.98), Vector3(90, 0, 0))
	_mesh_part(house, "DoorPanel", _box(Vector3(0.94, 1.56, 0.14)), wood_door_m, Vector3(0, 1.16, 1.92))
	_mesh_part(house, "DoorBrace", _box(Vector3(0.84, 0.10, 0.16)), dark_timber_m, Vector3(0, 1.46, 1.94))
	_mesh_part(house, "DoorRing", _sph(0.06), iron_m, Vector3(0.28, 1.14, 2.02))

	# Side Arched Windows with Warm Glow
	for sx in [-2.12, 2.12]:
		for sz in [-0.72, 0.72]:
			_mesh_part(house, "SideWinFrame", _box(Vector3(0.16, 0.82, 0.62)), timber_m, Vector3(sx, 1.48, sz))
			_mesh_part(house, "SideWinGlass", _box(Vector3(0.18, 0.64, 0.44)), window_glow, Vector3(sx, 1.48, sz))

	# Front Flanking Wooden Barrel Planters with Lush Shrubs
	for bx in [-1.25, 1.25]:
		_mesh_part(house, "PorchBarrel", _cyl(0.24, 0.22, 0.56, 10), barrel_m, Vector3(bx, 0.28, 2.34))
		_mesh_part(house, "BarrelHoopT", _torus(0.22, 0.25), iron_m, Vector3(bx, 0.44, 2.34))
		_mesh_part(house, "BarrelHoopB", _torus(0.22, 0.25), iron_m, Vector3(bx, 0.14, 2.34))
		_mesh_part(house, "BarrelPlant", StylizedMeshKit.build_leaf_clump_mesh(bx * 2.0, 0.34, 0.28, 5, 8, 0.20), vine_m, Vector3(bx, 0.68, 2.34))

	# Distinct Architectural Silhouettes per Building Role (matching village skyline in reference)
	match cottage_style:
		"academy":
			# Tall Half-Timbered Clocktower / Belltower + Purple Spire + Golden Clock Face
			_mesh_part(house, "ClockTowerBase", _box(Vector3(1.65, 5.20, 1.65)), wall_m, Vector3(-2.35, 2.60, -0.85))
			for tx in [-3.16, -1.54]:
				for tz in [-1.66, -0.04]:
					_mesh_part(house, "TowerPost", _box(Vector3(0.16, 5.25, 0.16)), timber_m, Vector3(tx, 2.62, tz))
			_mesh_part(house, "TowerBandMid", _box(Vector3(1.74, 0.14, 1.74)), timber_m, Vector3(-2.35, 3.25, -0.85))
			_mesh_part(house, "TowerBandTop", _box(Vector3(1.78, 0.16, 1.78)), timber_m, Vector3(-2.35, 5.15, -0.85))
			_mesh_part(house, "ClockTowerSpire", _cyl(0.06, 1.32, 2.15, 4), roof_m, Vector3(-2.35, 6.22, -0.85), Vector3(0, 45, 0))
			_mesh_part(house, "ClockFace", _cyl(0.38, 0.38, 0.12, 14), brass_m, Vector3(-2.35, 4.48, -0.01), Vector3(90, 0, 0))
			_mesh_part(house, "ClockInner", _cyl(0.28, 0.28, 0.14, 14), wall_m, Vector3(-2.35, 4.48, 0.00), Vector3(90, 0, 0))
			_mesh_part(house, "AcademySign", _cyl(0.42, 0.42, 0.14, 14), brass_m, Vector3(0, 2.44, 2.02), Vector3(90, 0, 0))
			_mesh_part(house, "AcademyCrest", _sph(0.13), _mat(Color("#5ED6FF"), 0.15, 0.1, Color("#4AC8FF"), 1.1), Vector3(0, 2.44, 2.08), Vector3.ZERO, Vector3.ONE, 0.0, false)
		"garden_cottage":
			# Side Burnt-Terracotta Wing Gable + Garden Mailbox (echoing orange annex roof in reference)
			var terra_m := _mat(Color("#A34F2C"), 0.64)
			_mesh_part(house, "AnnexWalls", _box(Vector3(1.85, 1.95, 2.45)), wall_m, Vector3(-2.65, 1.25, -0.35))
			_mesh_part(house, "AnnexRoof", StylizedMeshKit.build_gable_prism_mesh(2.15, 1.35, 2.72), terra_m, Vector3(-2.65, 2.20, -0.35))
			_mesh_part(house, "AnnexBeam", _box(Vector3(1.94, 0.14, 2.54)), timber_m, Vector3(-2.65, 2.22, -0.35))
			_mesh_part(house, "MailboxPost", _cyl(0.055, 0.065, 0.85, 6), timber_m, Vector3(1.85, 0.42, 2.45))
			_mesh_part(house, "MailboxBody", _box(Vector3(0.28, 0.24, 0.42)), _mat(Color("#4D7ED9"), 0.55), Vector3(1.85, 0.92, 2.45))
		"supply_post":
			# Explorer Supply Veranda + Hanging Wood Sign + Stacked Logs
			var terra_m := _mat(Color("#A34F2C"), 0.64)
			_mesh_part(house, "SupplyCanopy", _box(Vector3(3.40, 0.14, 1.25)), terra_m, Vector3(0, 2.18, 2.45), Vector3(14, 0, 0))
			for px in [-1.52, 1.52]:
				_mesh_part(house, "SupplyPost", _cyl(0.09, 0.11, 2.10, 8), timber_m, Vector3(px, 1.05, 2.94))
			_mesh_part(house, "SupplySignBoard", _box(Vector3(1.36, 0.42, 0.10)), _mat(Color("#C9995A"), 0.65), Vector3(0, 2.48, 2.02))
			for lz in [0.0, 0.22]:
				_mesh_part(house, "FirewoodLog", _cyl(0.11, 0.11, 0.72, 7), timber_m, Vector3(-2.35, 0.14 + lz, 0.85), Vector3(90, 0, 0))

	# Solid architecture collider on layers 32 (player) + 64 (camera collision)
	var body := StaticBody3D.new()
	body.collision_layer = 32 | 64
	body.collision_mask = 0
	var col := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(4.8, 3.6, 4.4)
	col.shape = box_shape
	col.position = Vector3(0, 1.8, 0)
	body.add_child(col)
	house.add_child(body)

	# Camera-fade occluder (layer 16)
	var house_occ_body := StaticBody3D.new()
	house_occ_body.collision_layer = 16
	house_occ_body.collision_mask = 0
	house_occ_body.set_meta("occluder_root", house)
	var house_occ_col := CollisionShape3D.new()
	var house_occ_box := BoxShape3D.new()
	house_occ_box.size = Vector3(5.6, 5.4, 5.4)
	house_occ_col.shape = house_occ_box
	house_occ_col.position = Vector3(0, 2.6, 0)
	house_occ_body.add_child(house_occ_col)
	house.add_child(house_occ_body)
	return house


static func build_fountain() -> Node3D:
	var f := FountainController.new()
	f.name = "VillageFountain3D"
	var stone := _mat(Color("#767D8C"), 0.78)
	var rim := _mat(Color("#A4ACB9"), 0.64)
	var wet_floor := _mat(Color("#244864"), 0.42)
	var gold := _mat(Color("#EBBA3D"), 0.28, 0.72)

	var basin_water_mat := create_stylized_water_material(Color(0.18, 0.76, 0.94, 0.82), true)
	var top_water_mat := create_stylized_water_material(Color(0.28, 0.84, 0.98, 0.84), true)
	f.water_materials = [basin_water_mat, top_water_mat]

	var jet_mat := ShaderMaterial.new()
	jet_mat.shader = load("res://shaders/stylized_water_jet.gdshader") as Shader

	_add_contact_shadow(f, 2.72, 0.28)
	_mesh_part(f, "StepBase", _cyl(2.60, 2.76, 0.16, 20), stone, Vector3(0, 0.08, 0))

	# Real hollow octagonal/circular stone basin wall (built from 16 interlocking curved segments + deep wet floor)
	_mesh_part(f, "BasinWetFloor", _cyl(2.12, 2.18, 0.18, 20), wet_floor, Vector3(0, 0.24, 0))
	var wall_segs := 16
	for i in range(wall_segs):
		var ang := (float(i) / float(wall_segs)) * TAU
		var wall_r := 2.18
		var seg_pos := Vector3(cos(ang) * wall_r, 0.44, sin(ang) * wall_r)
		_mesh_part(f, "BasinWall_%d" % i, _box(Vector3(0.30, 0.48, 0.94)), stone, seg_pos, Vector3(0, rad_to_deg(-ang), 0))
	_mesh_part(f, "RimTorus", _torus(1.98, 2.34), rim, Vector3(0, 0.68, 0))

	# Center sculpted column, upper bowl & rotating crystal finial
	_mesh_part(f, "CenterPillar", _cyl(0.34, 0.56, 1.72, 14), stone, Vector3(0, 0.94, 0))
	_mesh_part(f, "GoldBand", _torus(0.37, 0.44), gold, Vector3(0, 1.25, 0))
	_mesh_part(f, "TopBowlRim", _torus(0.76, 0.94), rim, Vector3(0, 1.88, 0))
	_mesh_part(f, "TopBowl", _cyl(0.90, 0.34, 0.36, 16), stone, Vector3(0, 1.74, 0))

	var crystal_pivot := Node3D.new()
	crystal_pivot.name = "CrystalFinialPivot"
	crystal_pivot.position = Vector3(0, 2.26, 0)
	f.add_child(crystal_pivot)
	var cryst_mat := _mat(Color("#54DEFF"), 0.14, 0.1, Color("#4AC8FF"), 1.3)
	_mesh_part(crystal_pivot, "CrystalFinial", _cyl(0.03, 0.20, 0.56, 6), cryst_mat, Vector3(0, 0.0, 0))
	f.crystal_node = crystal_pivot

	# Animated water surfaces (subdivided plane disks for smooth vertex ripples)
	var lower_water_mesh := _cyl(2.04, 2.04, 0.04, 24)
	_mesh_part(f, "WaterSurface", lower_water_mesh, basin_water_mat, Vector3(0, 0.54, 0), Vector3.ZERO, Vector3.ONE, 0.0, false)
	_mesh_part(f, "TopBowlWater", _cyl(0.80, 0.80, 0.04, 18), top_water_mat, Vector3(0, 1.88, 0), Vector3.ZERO, Vector3.ONE, 0.0, false)

	# Real 3D arching water jets (top crystal spout -> upper bowl, and upper bowl -> main basin)
	var upper_jet_mesh := StylizedMeshKit.build_water_jet_arc_mesh(0.08, 0.64, 2.15, 2.48, 1.88, 0.048, 10)
	var lower_jet_mesh := StylizedMeshKit.build_water_jet_arc_mesh(0.78, 1.56, 1.88, 2.04, 0.54, 0.068, 12)
	for ji in range(6):
		var rot_y := float(ji) * 60.0
		var uj := _mesh_part(f, "UpperJet_%d" % ji, upper_jet_mesh, jet_mat, Vector3.ZERO, Vector3(0, rot_y, 0), Vector3.ONE, 0.0, false)
		var lj := _mesh_part(f, "LowerJet_%d" % ji, lower_jet_mesh, jet_mat, Vector3.ZERO, Vector3(0, rot_y + 30.0, 0), Vector3.ONE, 0.0, false)
		f.jet_nodes.append(uj)
		f.jet_nodes.append(lj)

	# 1. Upward Plume Spray at crystal spout
	var plume := CPUParticles3D.new()
	plume.name = "FountainPlume"
	plume.position = Vector3(0, 2.38, 0)
	plume.lifetime = 0.72
	plume.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	plume.emission_sphere_radius = 0.12
	plume.direction = Vector3(0, 1, 0)
	plume.spread = 28.0
	plume.gravity = Vector3(0, -6.2, 0)
	plume.initial_velocity_min = 1.4
	plume.initial_velocity_max = 2.3
	plume.scale_amount_min = 0.04
	plume.scale_amount_max = 0.075
	plume.mesh = _sph(0.5, 1.0, 5, 6)
	plume.material_override = _mat(Color("#D6F6FF"), 0.18, 0.0, Color("#8CE6FF"), 0.7)
	f.add_child(plume)
	f.plume_particles = plume

	# 2. Ring Splash Droplets where lower jets hit main basin surface
	var splash := CPUParticles3D.new()
	splash.name = "FountainBasinSplash"
	splash.position = Vector3(0, 0.58, 0)
	splash.lifetime = 0.58
	splash.emission_shape = CPUParticles3D.EMISSION_SHAPE_RING
	splash.emission_ring_radius = 1.56
	splash.emission_ring_inner_radius = 1.32
	splash.emission_ring_height = 0.04
	splash.direction = Vector3(0, 1, 0)
	splash.spread = 48.0
	splash.gravity = Vector3(0, -5.8, 0)
	splash.initial_velocity_min = 0.9
	splash.initial_velocity_max = 1.65
	splash.scale_amount_min = 0.035
	splash.scale_amount_max = 0.07
	splash.mesh = _sph(0.5, 1.0, 4, 6)
	splash.material_override = _mat(Color("#E6FAFF"), 0.15, 0.0, Color("#9AEBFF"), 0.65)
	f.add_child(splash)
	f.splash_particles = splash

	# 3. Soft Mist Shimmer floating over basin
	var mist := CPUParticles3D.new()
	mist.name = "FountainMist"
	mist.position = Vector3(0, 0.75, 0)
	mist.lifetime = 1.45
	mist.emission_shape = CPUParticles3D.EMISSION_SHAPE_RING
	mist.emission_ring_radius = 1.65
	mist.emission_ring_inner_radius = 0.45
	mist.emission_ring_height = 0.20
	mist.direction = Vector3(0, 1, 0)
	mist.gravity = Vector3(0, 0.25, 0)
	mist.initial_velocity_min = 0.15
	mist.initial_velocity_max = 0.40
	mist.scale_amount_min = 0.16
	mist.scale_amount_max = 0.30
	mist.mesh = _sph(0.5, 0.7, 5, 6)
	var mist_mat := StandardMaterial3D.new()
	mist_mat.albedo_color = Color(0.84, 0.96, 1.0, 0.22)
	mist_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mist_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mist.material_override = mist_mat
	f.add_child(mist)
	f.mist_particles = mist

	var body := StaticBody3D.new()
	body.collision_layer = 32
	body.collision_mask = 0
	var col := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 2.40
	cyl.height = 1.6
	col.shape = cyl
	col.position = Vector3(0, 0.8, 0)
	body.add_child(col)
	f.add_child(body)
	return f


static func build_lamppost() -> Node3D:
	var lamp := Node3D.new()
	lamp.name = "LampPost3D"
	var timber := _mat(Color("#6E4423"), 0.78)
	var dark_wood := _mat(Color("#4E2E16"), 0.82)
	var iron := _mat(Color("#2D3442"), 0.45, 0.60)
	var glow := _mat(Color("#FFE48F"), 0.1, 0.0, Color("#FFCF58"), 1.65)

	_add_contact_shadow(lamp, 0.36, 0.24)
	_mesh_part(lamp, "TimberPost", _box(Vector3(0.22, 2.48, 0.22)), timber, Vector3(0, 1.24, 0))
	_mesh_part(lamp, "PostBase", _box(Vector3(0.32, 0.26, 0.32)), dark_wood, Vector3(0, 0.13, 0))
	_mesh_part(lamp, "BracketArm", _box(Vector3(0.68, 0.14, 0.14)), timber, Vector3(0.28, 2.42, 0))
	_mesh_part(lamp, "BracketBrace", _box(Vector3(0.12, 0.56, 0.12)), dark_wood, Vector3(0.20, 2.18, 0), Vector3(0, 0, -45))
	_mesh_part(lamp, "LanternChain", _cyl(0.025, 0.025, 0.22, 6), iron, Vector3(0.54, 2.26, 0))
	_mesh_part(lamp, "LanternCap", _cyl(0.05, 0.24, 0.16, 4), iron, Vector3(0.54, 2.14, 0), Vector3(0, 45, 0))
	_mesh_part(lamp, "Lantern", _box(Vector3(0.24, 0.30, 0.24)), glow, Vector3(0.54, 1.94, 0), Vector3.ZERO, Vector3.ONE, 0.0, false)
	_mesh_part(lamp, "LanternBase", _box(Vector3(0.26, 0.06, 0.26)), iron, Vector3(0.54, 1.78, 0))

	var omni := OmniLight3D.new()
	omni.name = "LanternLight"
	omni.add_to_group("quality_lights")
	omni.position = Vector3(0.54, 1.94, 0)
	omni.light_color = Color("#FFD684")
	omni.light_energy = 0.72
	omni.omni_range = 6.0
	omni.shadow_enabled = false
	omni.visible = (SettingsManager.graphics_quality == "high")
	lamp.add_child(omni)

	var body := StaticBody3D.new()
	body.collision_layer = 32
	body.collision_mask = 0
	var col := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 0.24
	cyl.height = 2.5
	col.shape = cyl
	col.position = Vector3(0, 1.25, 0)
	body.add_child(col)
	lamp.add_child(body)

	var occ_body := StaticBody3D.new()
	occ_body.collision_layer = 16
	occ_body.collision_mask = 0
	occ_body.set_meta("occluder_root", lamp)
	var occ_col := CollisionShape3D.new()
	var occ_cyl := CylinderShape3D.new()
	occ_cyl.radius = 0.44
	occ_cyl.height = 2.7
	occ_col.shape = occ_cyl
	occ_col.position = Vector3(0.20, 1.35, 0)
	occ_body.add_child(occ_col)
	lamp.add_child(occ_body)
	return lamp


static func build_haystack() -> Node3D:
	var hs := Node3D.new()
	hs.name = "Haystack3D"
	var straw := _mat(Color("#C8A33E"), 0.86)
	var straw_hi := _mat(Color("#D9B64E"), 0.84)
	_add_contact_shadow(hs, 0.72, 0.22)
	_mesh_part(hs, "HayBase", _cyl(0.56, 0.72, 0.56, 10), straw, Vector3(0, 0.28, 0))
	_mesh_part(hs, "HayCone", _cyl(0.12, 0.58, 0.62, 10), straw_hi, Vector3(0, 0.82, 0))
	return hs


static func build_wooden_bench() -> Node3D:
	var b := Node3D.new()
	b.name = "WoodenBench3D"
	var wood := _mat(Color("#7C4F2C"), 0.74)
	var iron := _mat(Color("#2D3542"), 0.50, 0.55)
	_add_contact_shadow(b, 0.85, 0.24)
	_mesh_part(b, "LegL", _box(Vector3(0.10, 0.45, 0.54)), iron, Vector3(-0.62, 0.22, 0))
	_mesh_part(b, "LegR", _box(Vector3(0.10, 0.45, 0.54)), iron, Vector3(0.62, 0.22, 0))
	_mesh_part(b, "Seat", _box(Vector3(1.56, 0.08, 0.52)), wood, Vector3(0, 0.46, 0.02))
	_mesh_part(b, "BackRest", _box(Vector3(1.56, 0.36, 0.08)), wood, Vector3(0, 0.78, -0.22), Vector3(-12, 0, 0))
	var b_col_body := StaticBody3D.new()
	b_col_body.collision_layer = 32
	b_col_body.collision_mask = 0
	var b_col := CollisionShape3D.new()
	var b_box := BoxShape3D.new()
	b_box.size = Vector3(1.58, 0.95, 0.58)
	b_col.shape = b_box
	b_col.position = Vector3(0, 0.48, 0)
	b_col_body.add_child(b_col)
	b.add_child(b_col_body)
	return b


static func build_academy_lectern() -> Node3D:
	var lec := Node3D.new()
	lec.name = "AcademyLectern3D"
	var wood := _mat(Color("#6A4024"), 0.72)
	var gold := _mat(Color("#F0BE3D"), 0.30, 0.70)
	var page := _mat(Color("#F5EBD4"), 0.65)
	var rune := _mat(Color("#54D8FF"), 0.2, 0.0, Color("#4AC8FF"), 1.0)
	_add_contact_shadow(lec, 0.44, 0.25)
	_mesh_part(lec, "Pedestal", _cyl(0.14, 0.26, 0.92, 8), wood, Vector3(0, 0.46, 0))
	_mesh_part(lec, "StandTop", _box(Vector3(0.76, 0.08, 0.54)), wood, Vector3(0, 0.94, 0), Vector3(24, 0, 0))
	_mesh_part(lec, "BookCover", _box(Vector3(0.62, 0.06, 0.42)), _mat(Color("#2E4A8C"), 0.55), Vector3(0, 0.99, 0), Vector3(24, 0, 0))
	_mesh_part(lec, "PageL", _box(Vector3(0.27, 0.05, 0.36)), page, Vector3(-0.15, 1.03, 0.01), Vector3(24, 0, -6))
	_mesh_part(lec, "PageR", _box(Vector3(0.27, 0.05, 0.36)), page, Vector3(0.15, 1.03, 0.01), Vector3(24, 0, 6))
	_mesh_part(lec, "BookBookmark", _box(Vector3(0.06, 0.06, 0.44)), gold, Vector3(0, 1.03, 0.01), Vector3(24, 0, 0))
	_mesh_part(lec, "MagicSpark", _sph(0.06), rune, Vector3(0, 1.24, 0.05), Vector3.ZERO, Vector3.ONE, 0.0, false)
	return lec


static func build_supply_crates() -> Node3D:
	var grp := Node3D.new()
	grp.name = "SupplyCrates3D"
	var wood := _mat(Color("#7D522E"), 0.76)
	var trim := _mat(Color("#52341C"), 0.80)
	var barrel := _mat(Color("#8E5D34"), 0.70)
	var iron := _mat(Color("#3D4654"), 0.48, 0.65)
	_add_contact_shadow(grp, 0.95, 0.25)
	_mesh_part(grp, "CrateLarge", _box(Vector3(0.72, 0.64, 0.72)), wood, Vector3(-0.32, 0.32, 0.0))
	_mesh_part(grp, "CrateRim", _box(Vector3(0.76, 0.10, 0.76)), trim, Vector3(-0.32, 0.58, 0.0))
	_mesh_part(grp, "Barrel", _cyl(0.26, 0.28, 0.78, 12), barrel, Vector3(0.36, 0.39, 0.14))
	_mesh_part(grp, "BarrelBandTop", _torus(0.25, 0.28), iron, Vector3(0.36, 0.62, 0.14))
	_mesh_part(grp, "BarrelBandLow", _torus(0.26, 0.29), iron, Vector3(0.36, 0.18, 0.14))
	return grp


static func build_gateway_arch() -> Node3D:
	var arch := Node3D.new()
	arch.name = "VillageGatewayArch3D"
	var stone := _mat(Color("#6A7280"), 0.82)
	var wood := _mat(Color("#694224"), 0.74)
	var roof := _mat(Color("#C95042"), 0.60)
	var gold := _mat(Color("#EBB93A"), 0.30, 0.70)
	var glow := _mat(Color("#FFE07D"), 0.12, 0.0, Color("#FFCA4A"), 1.35)

	for sx in [-2.15, 2.15]:
		_add_contact_shadow(arch, 0.55, 0.26)
		_mesh_part(arch, "StonePlinth", _box(Vector3(0.78, 0.95, 0.78)), stone, Vector3(sx, 0.47, 0))
		_mesh_part(arch, "WoodPillar", _cyl(0.20, 0.24, 2.85, 8), wood, Vector3(sx, 2.25, 0))
	_mesh_part(arch, "CrossBeam", _box(Vector3(5.20, 0.28, 0.44)), wood, Vector3(0, 3.68, 0))
	_mesh_part(arch, "ArchRoof", _box(Vector3(5.65, 0.24, 1.05)), roof, Vector3(0, 3.98, 0))
	_mesh_part(arch, "CrestPlaque", _box(Vector3(1.85, 0.48, 0.24)), gold, Vector3(0, 3.68, 0.18))
	_mesh_part(arch, "HangingLanternL", _sph(0.14), glow, Vector3(-1.55, 3.35, 0.16), Vector3.ZERO, Vector3.ONE, 0.0, false)
	_mesh_part(arch, "HangingLanternR", _sph(0.14), glow, Vector3(1.55, 3.35, 0.16), Vector3.ZERO, Vector3.ONE, 0.0, false)

	var body := StaticBody3D.new()
	body.collision_layer = 32
	body.collision_mask = 0
	for sx in [-2.15, 2.15]:
		var col := CollisionShape3D.new()
		var b := BoxShape3D.new()
		b.size = Vector3(0.85, 3.6, 0.85)
		col.shape = b
		col.position = Vector3(sx, 1.8, 0)
		body.add_child(col)
	arch.add_child(body)
	return arch


static func create_stylized_water_material(base_color: Color = Color(0.18, 0.74, 0.94, 0.84), radial_mode: bool = false) -> ShaderMaterial:
	var sm := ShaderMaterial.new()
	sm.shader = load("res://shaders/stylized_water.gdshader") as Shader
	sm.set_shader_parameter("shallow_color", base_color)
	sm.set_shader_parameter("deep_color", base_color.darkened(0.40))
	sm.set_shader_parameter("radial_mode", 1.0 if radial_mode else 0.0)
	var q := SettingsManager.graphics_quality
	sm.set_shader_parameter("quality_level", 2.0 if q == "high" else (1.0 if q == "medium" else 0.0))
	return sm
