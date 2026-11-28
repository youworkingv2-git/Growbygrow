extends Node
## Autoload Facade for the AudioVoiceSystem (Prompt 07).
## Preserves backwards compatibility with Prompt 01-06 callers while providing
## modular access to Asset, Music, SFX, Voice, TTS, Playback, Recorder, STT,
## Pronunciation Assessment, Feedback, Profiles, Settings, and Event Handler.

const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"
const BUS_VOICE := "Voice"
const BUS_LEARNING := "Learning"

var has_bundled_audio_assets: bool = false
var missing_audio_notice: String = "Âm thanh UI/SFX/Nhạc nền đã sẵn sàng; phát âm từ vựng & NPC sử dụng giọng đọc TTS hệ thống khi chưa có file .ogg thu sẵn."

var asset_manager: AudioAssetManager
var voice_profiles: VoiceProfileManager
var settings_manager: AudioSettingsManager
var music_manager: MusicManager
var sfx_manager: SoundEffectManager
var tts_manager: TextToSpeechManager
var playback_manager: AudioPlaybackManager
var voice_manager: VoiceManager
var speech_recorder: SpeechRecorder
var speech_recognition: SpeechRecognitionManager
var pronunciation_assessment: PronunciationAssessmentManager
var pronunciation_feedback: PronunciationFeedbackManager
var event_handler: AudioEventHandler


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	settings_manager = AudioSettingsManager.new()
	settings_manager.ensure_buses()
	settings_manager.apply_from_settings()

	asset_manager = AudioAssetManager.new()
	voice_profiles = VoiceProfileManager.new()

	music_manager = MusicManager.new()
	music_manager.name = "MusicManager"
	add_child(music_manager)
	music_manager.setup(asset_manager, settings_manager)

	sfx_manager = SoundEffectManager.new()
	sfx_manager.name = "SoundEffectManager"
	add_child(sfx_manager)
	sfx_manager.setup(asset_manager)

	tts_manager = TextToSpeechManager.new()
	tts_manager.name = "TextToSpeechManager"
	add_child(tts_manager)

	playback_manager = AudioPlaybackManager.new()
	playback_manager.name = "AudioPlaybackManager"
	add_child(playback_manager)
	playback_manager.setup(asset_manager, music_manager, tts_manager, settings_manager)

	voice_manager = VoiceManager.new(voice_profiles, playback_manager)

	speech_recorder = SpeechRecorder.new()
	speech_recorder.name = "SpeechRecorder"
	add_child(speech_recorder)
	speech_recorder.setup(playback_manager, sfx_manager)

	speech_recognition = SpeechRecognitionManager.new()
	speech_recognition.name = "SpeechRecognitionManager"
	add_child(speech_recognition)

	pronunciation_assessment = PronunciationAssessmentManager.new()
	pronunciation_assessment.name = "PronunciationAssessmentManager"
	add_child(pronunciation_assessment)

	pronunciation_feedback = PronunciationFeedbackManager.new()

	event_handler = AudioEventHandler.new(music_manager, sfx_manager, playback_manager)
	event_handler.connect_events()

	var audit := asset_manager.get_audit_summary()
	has_bundled_audio_assets = int(audit.get("bundled_verified", 0)) > 0

	EventBus.settings_changed.connect(_apply_volumes_from_settings)
	AppLogger.info(
		"AudioManager",
		"AudioVoiceSystem initialized: %d bundled WAV assets, TTS=%s" % [
			int(audit.get("bundled_verified", 0)),
			str(tts_manager.is_available())
		]
	)


func _apply_volumes_from_settings() -> void:
	if settings_manager != null:
		settings_manager.apply_from_settings()
	if music_manager != null:
		music_manager.pop_duck("_refresh_noop")


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_on_app_backgrounded()
	elif what == NOTIFICATION_APPLICATION_RESUMED or what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		_on_app_foregrounded()


func _on_app_backgrounded() -> void:
	if playback_manager != null:
		playback_manager.stop_all_speech()
	if speech_recorder != null and speech_recorder.is_recording():
		speech_recorder.clear_recording(false)
	if music_manager != null:
		music_manager.set_paused(true)


func _on_app_foregrounded() -> void:
	if music_manager != null:
		music_manager.set_paused(false)


func set_bus_linear_volume(bus_idx: int, linear: float) -> void:
	if settings_manager != null:
		settings_manager.set_bus_linear_volume(bus_idx, linear)


func register_sfx_stream(event_key: String, stream: AudioStream) -> void:
	if sfx_manager != null:
		sfx_manager.register_stream(event_key, stream)
		has_bundled_audio_assets = true


func play_sfx(event_key: String) -> void:
	if sfx_manager != null:
		sfx_manager.play_sfx(event_key)


func play_learning_audio(audio_path: String, accent: String = "") -> Dictionary:
	var acc := accent if not accent.is_empty() else SettingsManager.preferred_accent
	if not audio_path.is_empty() and asset_manager != null:
		var stream := asset_manager.load_stream_by_path(audio_path, true)
		if stream != null:
			var pb := playback_manager.play_speech_or_asset({
				"audio_path": audio_path,
				"accent": acc,
				"channel": "learning",
				"allow_tts_fallback": false
			})
			pb["played_bundled"] = bool(pb.get("played", false))
			return pb
	return {
		"played_bundled": false,
		"status": "missing_asset",
		"message_vi": "Chưa có file âm thanh thu sẵn (dùng giọng đọc TTS hệ thống nếu thiết bị hỗ trợ)."
	}


func can_use_browser_tts() -> bool:
	# Kept for backwards compatibility with Prompt 04-06 callers; true whenever OS TTS or Web TTS works!
	if tts_manager != null:
		return tts_manager.is_available()
	return OS.has_feature("web")


func speak_browser_tts_fallback(text: String, accent: String = "en-US", rate: float = 0.86) -> bool:
	if voice_manager != null:
		var res := voice_manager.speak_learning_text(text, "", accent, rate < 0.76)
		return bool(res.get("played", false))
	return false
