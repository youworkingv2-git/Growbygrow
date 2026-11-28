extends Node3D
class_name FountainController
## Controls the Real Water System on the Village Fountain:
## - Scales water shader quality_level (Low / Medium / High) without ever hiding water
## - Scales splash / mist CPUParticles3D cleanly per graphics tier
## - Animates central crystal finial & plays spatial 3D water audio

var water_materials: Array[ShaderMaterial] = []
var jet_nodes: Array[Node3D] = []
var crystal_node: Node3D = null
var plume_particles: CPUParticles3D = null
var splash_particles: CPUParticles3D = null
var mist_particles: CPUParticles3D = null
var audio_player: AudioStreamPlayer3D = null
var _t: float = 0.0


func _ready() -> void:
	_setup_spatial_audio()
	_apply_quality()
	if not EventBus.settings_changed.is_connected(_apply_quality):
		EventBus.settings_changed.connect(_apply_quality)


func _setup_spatial_audio() -> void:
	var wav_path := "res://assets/audio/sfx/sfx_fountain_loop.wav"
	if not ResourceLoader.exists(wav_path):
		return
	var stream := load(wav_path) as AudioStream
	if stream == null:
		return
	if stream is AudioStreamWAV:
		var wav := (stream as AudioStreamWAV).duplicate() as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = int(wav.get_length() * float(wav.mix_rate))
		stream = wav
	audio_player = AudioStreamPlayer3D.new()
	audio_player.name = "FountainWaterAudio"
	audio_player.stream = stream
	audio_player.bus = "SFX"
	audio_player.unit_size = 4.2
	audio_player.max_distance = 17.5
	audio_player.volume_db = -9.0
	audio_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	add_child(audio_player)
	audio_player.play()


func _apply_quality() -> void:
	var q := SettingsManager.graphics_quality
	var q_num := 2.0 if q == "high" else (1.0 if q == "medium" else 0.0)
	for wm in water_materials:
		if wm != null:
			wm.set_shader_parameter("quality_level", q_num)

	# Keep water jets visible across ALL tiers (Low shows 4 main jets, Med/High all jets)
	for i in range(jet_nodes.size()):
		var jn := jet_nodes[i]
		if is_instance_valid(jn):
			jn.visible = true if q != "low" else (i % 2 == 0)

	# Particles: Low keeps subtle droplet splash so fountain never looks frozen/dry
	if plume_particles != null:
		plume_particles.amount = 28 if q == "high" else (16 if q == "medium" else 6)
		plume_particles.visible = true
		plume_particles.emitting = true
	if splash_particles != null:
		splash_particles.amount = 34 if q == "high" else (18 if q == "medium" else 8)
		splash_particles.visible = true
		splash_particles.emitting = true
	if mist_particles != null:
		mist_particles.amount = 14 if q == "high" else 8
		mist_particles.visible = (q != "low")
		mist_particles.emitting = (q != "low")


func _process(delta: float) -> void:
	_t += delta
	if crystal_node != null and is_instance_valid(crystal_node):
		crystal_node.rotation.y += delta * 0.85
		crystal_node.position.y = 2.26 + sin(_t * 2.4) * 0.045
