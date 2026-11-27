class_name AudioPlaybackManager
extends Node
## Unified Audio Playback controller coordinating bundled/cached AudioStreams and TTS,
## enforcing non-overlapping voice playback, BGM ducking, pause/resume/replay,
## and speaker animation signals.

signal playback_started(playback_info: Dictionary)
signal playback_finished(playback_info: Dictionary)

var _stream_player: AudioStreamPlayer = null
var _assets: AudioAssetManager = null
var _music: MusicManager = null
var _tts: TextToSpeechManager = null
var _settings: AudioSettingsManager = null

var _active_mode: String = "" # "stream" | "tts" | ""
var _active_info: Dictionary = {}
var _last_request: Dictionary = {}
var _is_paused: bool = false


func setup(
	assets: AudioAssetManager,
	music: MusicManager,
	tts: TextToSpeechManager,
	settings: AudioSettingsManager
) -> void:
	_assets = assets
	_music = music
	_tts = tts
	_settings = settings
	if _stream_player == null:
		_stream_player = AudioStreamPlayer.new()
		_stream_player.bus = AudioSettingsManager.BUS_LEARNING
		_stream_player.process_mode = Node.PROCESS_MODE_ALWAYS
		_stream_player.finished.connect(_on_stream_finished)
		add_child(_stream_player)
	if _tts != null and not _tts.speech_finished.is_connected(_on_tts_finished):
		_tts.speech_finished.connect(_on_tts_finished)


func play_speech_or_asset(request: Dictionary) -> Dictionary:
	# request: { audio_path, audio_id, text_en, accent, rate, pitch, bus, speaker_id, channel, allow_tts_fallback }
	stop_all_speech()
	_last_request = request.duplicate(true)
	_is_paused = false

	var audio_path := str(request.get("audio_path", ""))
	var audio_id := str(request.get("audio_id", ""))
	var text_en := str(request.get("text_en", "")).strip_edges()
	var accent := str(request.get("accent", SettingsManager.preferred_accent))
	var rate := float(request.get("rate", SettingsManager.speech_rate))
	var pitch := float(request.get("pitch", 1.0))
	var speaker_id := str(request.get("speaker_id", "learning_narrator"))
	var channel := str(request.get("channel", "learning"))
	var allow_tts := bool(request.get("allow_tts_fallback", true))

	var stream: AudioStream = null
	if _assets != null:
		if not audio_path.is_empty():
			stream = _assets.load_stream_by_path(audio_path, true)
		elif not audio_id.is_empty():
			var cache_path := _assets.get_offline_cache_path(audio_id, accent, "ogg")
			if FileAccess.file_exists(cache_path):
				stream = _assets.load_stream_by_path(cache_path, true)
			else:
				stream = _assets.load_stream_by_id(audio_id, true)

	if stream != null and _stream_player != null:
		_stream_player.bus = AudioSettingsManager.BUS_VOICE if channel == "npc" else AudioSettingsManager.BUS_LEARNING
		_stream_player.pitch_scale = clampf(rate / 0.85, 0.72, 1.25) if absf(rate - 0.85) > 0.12 else 1.0
		_stream_player.stream = stream
		_stream_player.play()
		_active_mode = "stream"
		_active_info = {
			"source": "bundled_audio",
			"played": true,
			"speaker_id": speaker_id,
			"text_en": text_en,
			"accent": accent,
			"duration_sec": stream.get_length(),
			"message_vi": "Đang phát âm thanh thu sẵn."
		}
		if _music != null:
			_music.push_duck("speech", 0.30)
		playback_started.emit(_active_info)
		EventBus.voice_playback_started.emit(speaker_id, text_en, _active_info)
		return _active_info

	if allow_tts and _tts != null and not text_en.is_empty():
		var vol_pct := _settings.get_effective_tts_volume_percent(channel) if _settings != null else 85
		var tts_res := _tts.speak(text_en, accent, rate, pitch, vol_pct, {
			"speaker_id": speaker_id,
			"text_en": text_en,
			"accent": accent
		})
		if bool(tts_res.get("played", false)):
			_active_mode = "tts"
			_active_info = {
				"source": str(tts_res.get("source", "tts")),
				"played": true,
				"speaker_id": speaker_id,
				"text_en": text_en,
				"accent": accent,
				"message_vi": "Đang phát bằng giọng đọc hệ thống (%s)." % accent
			}
			if _music != null:
				_music.push_duck("speech", 0.30)
			playback_started.emit(_active_info)
			EventBus.voice_playback_started.emit(speaker_id, text_en, _active_info)
			return _active_info

	return {
		"source": "missing_asset",
		"played": false,
		"speaker_id": speaker_id,
		"text_en": text_en,
		"accent": accent,
		"message_vi": "Chưa có file âm thanh thu sẵn (.ogg) và giọng đọc TTS chưa khả dụng; hãy xem chữ & phiên âm IPA."
	}


func play_recorded_stream(wav: AudioStreamWAV) -> bool:
	if wav == null or _stream_player == null:
		return false
	stop_all_speech()
	_is_paused = false
	_stream_player.bus = AudioSettingsManager.BUS_LEARNING
	_stream_player.pitch_scale = 1.0
	_stream_player.stream = wav
	_stream_player.play()
	_active_mode = "stream"
	_active_info = {
		"source": "player_recording",
		"played": true,
		"speaker_id": "player",
		"text_en": "",
		"duration_sec": wav.get_length()
	}
	if _music != null:
		_music.push_duck("speech", 0.30)
	playback_started.emit(_active_info)
	return true


func replay_last() -> Dictionary:
	if _last_request.is_empty():
		return { "played": false, "source": "none" }
	return play_speech_or_asset(_last_request)


func pause_speech() -> void:
	if _is_paused or _active_mode.is_empty():
		return
	_is_paused = true
	if _active_mode == "stream" and _stream_player != null:
		_stream_player.stream_paused = true
	elif _active_mode == "tts" and _tts != null:
		_tts.pause()


func resume_speech() -> void:
	if not _is_paused or _active_mode.is_empty():
		return
	_is_paused = false
	if _active_mode == "stream" and _stream_player != null:
		_stream_player.stream_paused = false
	elif _active_mode == "tts" and _tts != null:
		_tts.resume()


func stop_all_speech() -> void:
	var was_active := not _active_mode.is_empty()
	var prev_info := _active_info.duplicate(true)
	_active_mode = ""
	_active_info = {}
	_is_paused = false
	if _stream_player != null and _stream_player.playing:
		_stream_player.stop()
	if _tts != null and (_tts.is_speaking() or _tts.is_paused()):
		_tts.stop()
	if _music != null:
		_music.pop_duck("speech")
	if was_active:
		playback_finished.emit(prev_info)
		EventBus.voice_playback_finished.emit(str(prev_info.get("speaker_id", "")), prev_info)


func is_playing() -> bool:
	return not _active_mode.is_empty() and not _is_paused


func is_paused() -> bool:
	return _is_paused


func get_playback_position_sec() -> float:
	if _active_mode == "stream" and _stream_player != null and _stream_player.playing:
		return _stream_player.get_playback_position()
	return 0.0


func _on_stream_finished() -> void:
	if _active_mode != "stream":
		return
	var prev_info := _active_info.duplicate(true)
	_active_mode = ""
	_active_info = {}
	_is_paused = false
	if _music != null:
		_music.pop_duck("speech")
	playback_finished.emit(prev_info)
	EventBus.voice_playback_finished.emit(str(prev_info.get("speaker_id", "")), prev_info)


func _on_tts_finished(_uid: int, _meta: Dictionary) -> void:
	if _active_mode != "tts":
		return
	var prev_info := _active_info.duplicate(true)
	_active_mode = ""
	_active_info = {}
	_is_paused = false
	if _music != null:
		_music.pop_duck("speech")
	playback_finished.emit(prev_info)
	EventBus.voice_playback_finished.emit(str(prev_info.get("speaker_id", "")), prev_info)
