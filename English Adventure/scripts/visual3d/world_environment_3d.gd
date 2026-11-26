class_name WorldEnvironment3DController
extends Node
## Configures stylized 3D Environment, Sky, Directional Sunlight, Shadows, Fog,
## Glow/Bloom, and Low/Medium/High Graphics Quality scaling across Desktop, Web, and Mobile.

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
	var sky := Sky.new()
	sky.sky_material = sky_mat
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 0.86
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_sky_contribution = 0.65

	match _area_id:
		"welcome_village":
			sky_mat.sky_top_color = Color("#2474CC")
			sky_mat.sky_horizon_color = Color("#8FD4FA")
			sky_mat.ground_bottom_color = Color("#2B6A3B")
			sky_mat.ground_horizon_color = Color("#6CB470")
			_sun.light_color = Color("#FFEECF")
			_sun.light_energy = 0.82
			_sun.rotation_degrees = Vector3(-52.0, -32.0, 0.0)
			env.ambient_light_energy = 0.42
			env.fog_enabled = true
			env.fog_light_color = Color("#A8DFFF")
			env.fog_density = 0.004
		"alphabet_meadow":
			sky_mat.sky_top_color = Color("#2C84E6")
			sky_mat.sky_horizon_color = Color("#A8E6FA")
			sky_mat.ground_bottom_color = Color("#267336")
			sky_mat.ground_horizon_color = Color("#72C86A")
			_sun.light_color = Color("#FFF4D4")
			_sun.light_energy = 0.86
			_sun.rotation_degrees = Vector3(-48.0, 28.0, 0.0)
			env.ambient_light_energy = 0.44
			env.fog_enabled = true
			env.fog_light_color = Color("#B5EBFF")
			env.fog_density = 0.0038
		"letter_cave":
			sky_mat.sky_top_color = Color("#121A33")
			sky_mat.sky_horizon_color = Color("#1F3058")
			sky_mat.ground_bottom_color = Color("#0D1322")
			sky_mat.ground_horizon_color = Color("#1A2644")
			_sun.light_color = Color("#7CC4FF")
			_sun.light_energy = 0.62
			_sun.rotation_degrees = Vector3(-68.0, -20.0, 0.0)
			env.ambient_light_energy = 0.42
			env.fog_enabled = true
			env.fog_light_color = Color("#1A2B4C")
			env.fog_density = 0.007
		"crystal_lake":
			sky_mat.sky_top_color = Color("#186CC4")
			sky_mat.sky_horizon_color = Color("#8CDCF5")
			sky_mat.ground_bottom_color = Color("#164E75")
			sky_mat.ground_horizon_color = Color("#5AB8DC")
			_sun.light_color = Color("#E4F8FF")
			_sun.light_energy = 0.84
			_sun.rotation_degrees = Vector3(-46.0, -40.0, 0.0)
			env.ambient_light_energy = 0.44
			env.fog_enabled = true
			env.fog_light_color = Color("#92E0FA")
			env.fog_density = 0.005
		"shadow_gate":
			sky_mat.sky_top_color = Color("#1A1033")
			sky_mat.sky_horizon_color = Color("#3F246E")
			sky_mat.ground_bottom_color = Color("#161124")
			sky_mat.ground_horizon_color = Color("#2D1D4D")
			_sun.light_color = Color("#C9A8FF")
			_sun.light_energy = 0.72
			_sun.rotation_degrees = Vector3(-56.0, 35.0, 0.0)
			env.ambient_light_energy = 0.40
			env.fog_enabled = true
			env.fog_light_color = Color("#352159")
			env.fog_density = 0.006


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
				env.glow_intensity = 0.36
				env.glow_bloom = 0.06
				env.glow_hdr_threshold = 1.22
				env.fog_enabled = true
				env.ssao_enabled = not OS.has_feature("web") and not OS.has_feature("mobile")
			if vp != null:
				vp.msaa_3d = Viewport.MSAA_DISABLED if OS.has_feature("web") else Viewport.MSAA_4X
				vp.scaling_3d_scale = 1.0
		"medium", _:
			_sun.shadow_enabled = true
			_sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
			_sun.directional_shadow_max_distance = 60.0
			if env != null:
				env.glow_enabled = true
				env.glow_intensity = 0.24
				env.glow_bloom = 0.03
				env.glow_hdr_threshold = 1.28
				env.fog_enabled = true
				env.ssao_enabled = false
			if vp != null:
				vp.msaa_3d = Viewport.MSAA_DISABLED if OS.has_feature("web") else Viewport.MSAA_2X
				vp.scaling_3d_scale = 1.0
