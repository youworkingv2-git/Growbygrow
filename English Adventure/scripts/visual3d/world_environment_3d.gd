class_name WorldEnvironment3DController
extends Node
## Configures stylized 3D Environment, Sky, Directional Sunlight, Soft Shadows,
## Atmospheric Fog, Glow/Bloom, and Low/Medium/High Graphics Quality scaling
## across Windows, WebGL2, Android, and iOS.

var _world_env: WorldEnvironment = null
var _sun: DirectionalLight3D = null
var _area_id: String = "welcome_village"


func setup_for_area(area_id: String, world_env: WorldEnvironment, sun: DirectionalLight3D) -> void:
	_area_id = area_id
	_world_env = world_env
	_sun = sun
	if not EventBus.settings_changed.is_connected(_apply_quality):
		EventBus.settings_changed.connect(_apply_quality)
	_apply_area_palette()
	_apply_quality()


func _apply_area_palette() -> void:
	if _world_env == null or _sun == null:
		return
	var env := _world_env.environment
	if env == null:
		env = Environment.new()
		_world_env.environment = env

	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_curve = 0.14
	sky_mat.ground_curve = 0.06
	sky_mat.sun_angle_max = 26.0
	sky_mat.sun_curve = 0.18
	var sky := Sky.new()
	sky.sky_material = sky_mat
	env.background_mode = Environment.BG_SKY
	env.sky = sky

	# Calibrated Filmic Tonemapping to eliminate blown-out highlights & chalky whites
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 0.88
	env.tonemap_white = 5.5
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_sky_contribution = 0.48
	env.ambient_light_color = Color("#8BB6E0")

	_sun.shadow_bias = 0.04
	_sun.shadow_normal_bias = 1.2
	_sun.shadow_blur = 1.6
	_sun.directional_shadow_blend_splits = true

	match _area_id:
		"welcome_village":
			sky_mat.sky_top_color = Color("#1B62B8")
			sky_mat.sky_horizon_color = Color("#8BCCEE")
			sky_mat.ground_bottom_color = Color("#1F4929")
			sky_mat.ground_horizon_color = Color("#4D7E45")
			_sun.light_color = Color("#FFE2B2")
			_sun.light_energy = 1.04
			_sun.rotation_degrees = Vector3(-38.0, -36.0, 0.0)
			env.ambient_light_energy = 0.34
			env.fog_enabled = true
			env.fog_light_color = Color("#9ED2EE")
			env.fog_density = 0.0062
		"alphabet_meadow":
			sky_mat.sky_top_color = Color("#2172CC")
			sky_mat.sky_horizon_color = Color("#9BDDF7")
			sky_mat.ground_bottom_color = Color("#20522A")
			sky_mat.ground_horizon_color = Color("#58924C")
			_sun.light_color = Color("#FFEAC2")
			_sun.light_energy = 1.06
			_sun.rotation_degrees = Vector3(-40.0, 26.0, 0.0)
			env.ambient_light_energy = 0.36
			env.fog_enabled = true
			env.fog_light_color = Color("#A8E0F7")
			env.fog_density = 0.0055
		"letter_cave":
			sky_mat.sky_top_color = Color("#10172E")
			sky_mat.sky_horizon_color = Color("#1E2E54")
			sky_mat.ground_bottom_color = Color("#0B101F")
			sky_mat.ground_horizon_color = Color("#182442")
			_sun.light_color = Color("#7EC4FF")
			_sun.light_energy = 0.68
			_sun.rotation_degrees = Vector3(-62.0, -22.0, 0.0)
			env.ambient_light_energy = 0.38
			env.fog_enabled = true
			env.fog_light_color = Color("#1A2A4B")
			env.fog_density = 0.0078
		"crystal_lake":
			sky_mat.sky_top_color = Color("#1561B4")
			sky_mat.sky_horizon_color = Color("#82D2EE")
			sky_mat.ground_bottom_color = Color("#154566")
			sky_mat.ground_horizon_color = Color("#4CA5CC")
			_sun.light_color = Color("#E8F6FF")
			_sun.light_energy = 0.98
			_sun.rotation_degrees = Vector3(-42.0, -38.0, 0.0)
			env.ambient_light_energy = 0.38
			env.fog_enabled = true
			env.fog_light_color = Color("#8AD7F2")
			env.fog_density = 0.0058
		"shadow_gate":
			sky_mat.sky_top_color = Color("#170E2E")
			sky_mat.sky_horizon_color = Color("#3A2166")
			sky_mat.ground_bottom_color = Color("#120E20")
			sky_mat.ground_horizon_color = Color("#281A46")
			_sun.light_color = Color("#C8A6FF")
			_sun.light_energy = 0.78
			_sun.rotation_degrees = Vector3(-50.0, 34.0, 0.0)
			env.ambient_light_energy = 0.36
			env.fog_enabled = true
			env.fog_light_color = Color("#321F54")
			env.fog_density = 0.0068


func _apply_quality() -> void:
	if _world_env == null or _sun == null:
		return
	var env := _world_env.environment
	var q := SettingsManager.graphics_quality
	var vp := get_viewport()

	match q:
		"low":
			_sun.shadow_enabled = false
			if env != null:
				env.glow_enabled = false
				env.ssao_enabled = false
				env.fog_enabled = false
			if vp != null:
				vp.msaa_3d = Viewport.MSAA_DISABLED
				vp.scaling_3d_scale = 0.85
		"high":
			_sun.shadow_enabled = true
			_sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
			_sun.directional_shadow_max_distance = 75.0
			if env != null:
				env.glow_enabled = true
				env.glow_intensity = 0.32
				env.glow_bloom = 0.05
				env.glow_hdr_threshold = 1.18
				env.fog_enabled = true
				env.ssao_enabled = not OS.has_feature("web") and not OS.has_feature("mobile")
			if vp != null:
				vp.msaa_3d = Viewport.MSAA_DISABLED if OS.has_feature("web") else Viewport.MSAA_4X
				vp.scaling_3d_scale = 1.0
		"medium", _:
			_sun.shadow_enabled = true
			_sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
			_sun.directional_shadow_max_distance = 58.0
			if env != null:
				env.glow_enabled = true
				env.glow_intensity = 0.22
				env.glow_bloom = 0.03
				env.glow_hdr_threshold = 1.24
				env.fog_enabled = true
				env.ssao_enabled = false
			if vp != null:
				vp.msaa_3d = Viewport.MSAA_DISABLED if OS.has_feature("web") else Viewport.MSAA_2X
				vp.scaling_3d_scale = 1.0

	var tree := get_tree()
	if tree != null:
		for p_node in tree.get_nodes_in_group("quality_particles"):
			if p_node is CPUParticles3D:
				var cp := p_node as CPUParticles3D
				var base_amt := int(cp.get_meta("base_amount", 18))
				if q == "low":
					cp.emitting = false
					cp.visible = false
				elif q == "high":
					cp.visible = true
					cp.amount = base_amt
					cp.emitting = true
				else:
					cp.visible = true
					cp.amount = maxi(6, base_amt / 2)
					cp.emitting = true
		for l_node in tree.get_nodes_in_group("quality_lights"):
			if l_node is Light3D:
				(l_node as Light3D).visible = (q == "high")
