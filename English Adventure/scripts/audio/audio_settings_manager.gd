class_name AudioSettingsManager
extends RefCounted
## Coordinates AudioServer buses (Master, Music, SFX, Voice, Learning) with SettingsManager.
## Protects Learning Audio from accidental total silencing while preserving independent sliders.

const BUS_MASTER := "Master"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"
const BUS_VOICE := "Voice"
const BUS_LEARNING := "Learning"

var master_bus_idx: int = 0
var music_bus_idx: int = -1
var sfx_bus_idx: int = -1
var voice_bus_idx: int = -1
var learning_bus_idx: int = -1


func ensure_buses() -> void:
	master_bus_idx = AudioServer.get_bus_index(BUS_MASTER)
	music_bus_idx = _ensure_bus(BUS_MUSIC)
	sfx_bus_idx = _ensure_bus(BUS_SFX)
	voice_bus_idx = _ensure_bus(BUS_VOICE)
	learning_bus_idx = _ensure_bus(BUS_LEARNING)


func _ensure_bus(bus_name: String) -> int:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		AudioServer.add_bus()
		idx = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(idx, bus_name)
	return idx


func apply_from_settings() -> void:
	set_bus_linear_volume(master_bus_idx, SettingsManager.master_volume)
	set_bus_linear_volume(music_bus_idx, SettingsManager.music_volume)
	set_bus_linear_volume(sfx_bus_idx, SettingsManager.sfx_volume)
	set_bus_linear_volume(voice_bus_idx, SettingsManager.voice_volume)
	# Learning audio keeps a safe minimum floor (15%) unless Master is muted by OS/user
	var learn_vol := clampf(SettingsManager.learning_audio_volume, 0.15, 1.0)
	set_bus_linear_volume(learning_bus_idx, learn_vol)


func set_bus_linear_volume(bus_idx: int, linear: float) -> void:
	if bus_idx < 0:
		return
	var clamped := clampf(linear, 0.0, 1.0)
	AudioServer.set_bus_mute(bus_idx, clamped <= 0.001)
	if clamped > 0.001:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(clamped))


func get_effective_tts_volume_percent(channel: String = "learning") -> int:
	var master := clampf(SettingsManager.master_volume, 0.0, 1.0)
	var ch_vol := clampf(SettingsManager.learning_audio_volume, 0.15, 1.0) if channel == "learning" else clampf(SettingsManager.voice_volume, 0.0, 1.0)
	return clampi(int(round(master * ch_vol * 100.0)), 0, 100)


func reset_defaults() -> void:
	SettingsManager.reset_audio_defaults()
	apply_from_settings()
