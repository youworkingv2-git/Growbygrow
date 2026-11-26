extends Node
## Shared Audio Manager for UI SFX, BGM, and Quest/Reward sound events.
## Dynamically configures AudioServer buses without referencing missing audio files.

const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"
const BUS_VOICE := "Voice"

var has_bundled_audio_assets: bool = false
var missing_audio_notice: String = "Chưa có file âm thanh trong assets/audio/ (AudioManager đã cấu hình AudioServer buses sẵn sàng)."

var _music_bus_idx: int = -1
var _sfx_bus_idx: int = -1
var _voice_bus_idx: int = -1
var _players_by_key: Dictionary = {}
var _voice_player: AudioStreamPlayer = null


func _ready() -> void:
	_ensure_audio_buses()
	_voice_player = AudioStreamPlayer.new()
	_voice_player.bus = BUS_SFX
	add_child(_voice_player)
	_apply_volumes_from_settings()
	EventBus.settings_changed.connect(_apply_volumes_from_settings)
	EventBus.quest_completed.connect(func(_qid: String, _rw: Dictionary) -> void: play_sfx("quest_complete"))
	EventBus.area_unlocked.connect(func(_aid: String) -> void: play_sfx("area_unlocked"))
	EventBus.item_collected.connect(func(_iid: String, _qty: int) -> void: play_sfx("reward_received"))


func _ensure_audio_buses() -> void:
	_music_bus_idx = AudioServer.get_bus_index(BUS_MUSIC)
	if _music_bus_idx == -1:
		AudioServer.add_bus()
		_music_bus_idx = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(_music_bus_idx, BUS_MUSIC)

	_sfx_bus_idx = AudioServer.get_bus_index(BUS_SFX)
	if _sfx_bus_idx == -1:
		AudioServer.add_bus()
		_sfx_bus_idx = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(_sfx_bus_idx, BUS_SFX)

	_voice_bus_idx = AudioServer.get_bus_index(BUS_VOICE)
	if _voice_bus_idx == -1:
		AudioServer.add_bus()
		_voice_bus_idx = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(_voice_bus_idx, BUS_VOICE)


func _apply_volumes_from_settings() -> void:
	set_bus_linear_volume(_music_bus_idx, SettingsManager.music_volume)
	set_bus_linear_volume(_sfx_bus_idx, SettingsManager.sfx_volume)
	set_bus_linear_volume(_voice_bus_idx, 1.0)


func set_bus_linear_volume(bus_idx: int, linear: float) -> void:
	if bus_idx < 0:
		return
	var clamped := clampf(linear, 0.0, 1.0)
	AudioServer.set_bus_mute(bus_idx, clamped <= 0.001)
	if clamped > 0.001:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(clamped))


func register_sfx_stream(event_key: String, stream: AudioStream) -> void:
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.bus = BUS_SFX
	player.stream = stream
	add_child(player)
	_players_by_key[event_key] = player
	has_bundled_audio_assets = true


func play_sfx(event_key: String) -> void:
	if SettingsManager.sfx_volume <= 0.001:
		return
	if _players_by_key.has(event_key):
		var p: AudioStreamPlayer = _players_by_key[event_key]
		if p != null:
			p.play()
	else:
		# No bundled audio asset yet — cleanly log at debug level only for major gameplay cues
		if event_key in ["quest_complete", "reward_received", "area_unlocked"]:
			AppLogger.debug("AudioManager", "SFX hook triggered (asset pending): " + event_key)


func play_learning_audio(audio_path: String, _accent: String = "") -> Dictionary:
	if not audio_path.is_empty() and ResourceLoader.exists(audio_path):
		var stream := load(audio_path) as AudioStream
		if stream != null and _voice_player != null:
			_voice_player.stream = stream
			_voice_player.play()
			return { "played_bundled": true, "status": "ok", "message_vi": "Đang phát âm thanh mẫu." }
	return {
		"played_bundled": false,
		"status": "missing_asset",
		"message_vi": "Chưa có file âm thanh thu sẵn (asset âm thanh đang chờ bổ sung)."
	}


func can_use_browser_tts() -> bool:
	return OS.has_feature("web")


func speak_browser_tts_fallback(text: String, accent: String = "en-US", rate: float = 0.86) -> bool:
	if not OS.has_feature("web") or text.strip_edges().is_empty():
		return false
	var lang := "en-GB" if accent == "en-GB" else "en-US"
	var clean_text := text.strip_edges()
	if clean_text == "Z" and lang == "en-GB":
		clean_text = "Zed"
	var safe_text := JSON.stringify(clean_text)
	var r := clampf(rate, 0.55, 1.2)
	var lang_lc := lang.to_lower()
	var js := "(function(){ if ('speechSynthesis' in window) { window.speechSynthesis.cancel(); var u = new SpeechSynthesisUtterance(" + safe_text + "); u.lang = '" + lang + "'; u.rate = " + str(r) + "; var voices = window.speechSynthesis.getVoices() || []; var v = voices.find(function(x){ return x.lang && x.lang.toLowerCase().replace('_', '-') === '" + lang_lc + "'; }) || voices.find(function(x){ return x.lang && x.lang.toLowerCase().startsWith('en'); }); if (v) u.voice = v; window.speechSynthesis.speak(u); return true; } return false; })();"
	var ok: Variant = JavaScriptBridge.eval(js)
	return bool(ok)
