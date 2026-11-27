class_name MusicManager
extends Node
## Manages background music playback, seamless looping, smooth ducking during
## English speech/pronunciation, and pause/resume without loading giant tracks needlessly.

var _player: AudioStreamPlayer = null
var _assets: AudioAssetManager = null
var _settings: AudioSettingsManager = null
var _current_track_id: String = ""
var _duck_reasons: Dictionary = {}
var _duck_factor: float = 1.0


func setup(assets: AudioAssetManager, settings: AudioSettingsManager) -> void:
	_assets = assets
	_settings = settings
	if _player == null:
		_player = AudioStreamPlayer.new()
		_player.bus = AudioSettingsManager.BUS_MUSIC
		_player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(_player)


func play_track(track_id: String, force_restart: bool = false) -> bool:
	if _player == null or _assets == null:
		return false
	if _current_track_id == track_id and _player.playing and not force_restart:
		return true
	var stream := _assets.load_stream_by_id(track_id, false)
	if stream == null:
		return false
	if stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	_current_track_id = track_id
	_player.stream = stream
	_player.play()
	_apply_effective_music_volume()
	return true


func stop_music() -> void:
	if _player != null and _player.playing:
		_player.stop()
	_current_track_id = ""


func set_paused(paused: bool) -> void:
	if _player != null:
		_player.stream_paused = paused


func is_playing() -> bool:
	return _player != null and _player.playing and not _player.stream_paused


func get_current_track_id() -> String:
	return _current_track_id


func push_duck(reason: String, factor: float = 0.30) -> void:
	_duck_reasons[reason] = clampf(factor, 0.10, 1.0)
	_recompute_duck()


func pop_duck(reason: String) -> void:
	_duck_reasons.erase(reason)
	_recompute_duck()


func _recompute_duck() -> void:
	_duck_factor = 1.0
	for k in _duck_reasons.keys():
		_duck_factor = minf(_duck_factor, float(_duck_reasons[k]))
	_apply_effective_music_volume()


func _apply_effective_music_volume() -> void:
	if _settings == null:
		return
	var target := clampf(SettingsManager.music_volume * _duck_factor, 0.0, 1.0)
	_settings.set_bus_linear_volume(_settings.music_bus_idx, target)
