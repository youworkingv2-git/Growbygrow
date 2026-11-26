class_name MiniGameAudioManager
extends RefCounted
## Dedicated Mini-Game Audio Controller wrapping shared AudioManager.
## Prevents overlapping pronunciation playback, preserves independent BGM/SFX control,
## and cleanly reports audio asset status without pretending missing audio files exist.

var _bgm_ducked: bool = false
var _saved_music_vol: float = 0.75


func play_word_or_sentence(audio_path: String, text_en: String, accent: String = "") -> Dictionary:
	var acc := accent if not accent.is_empty() else SettingsManager.preferred_accent
	var res := AudioManager.play_learning_audio(audio_path, acc)
	if bool(res.get("played_bundled", false)):
		return {
			"source": "bundled_audio",
			"played": true,
			"message_vi": "Đang phát âm thanh mẫu chuẩn."
		}
	if AudioManager.can_use_browser_tts() and not text_en.strip_edges().is_empty():
		var ok := AudioManager.speak_browser_tts_fallback(text_en, acc)
		return {
			"source": "browser_tts_fallback",
			"played": ok,
			"message_vi": "Đang phát bằng giọng đọc trình duyệt (%s) — file thu âm .ogg đang chờ bổ sung." % acc
		}
	return {
		"source": "missing_asset",
		"played": false,
		"message_vi": "Chưa có file âm thanh thu sẵn (.ogg); hãy xem từ & phiên âm IPA hiển thị trên màn hình."
	}


func play_sfx(event_key: String) -> void:
	# event_key: "correct", "wrong", "click", "reward"
	AudioManager.play_sfx("minigame_" + event_key)


func duck_bgm_for_speech(duck: bool) -> void:
	if duck == _bgm_ducked:
		return
	_bgm_ducked = duck
	var music_idx := AudioServer.get_bus_index(AudioManager.BUS_MUSIC)
	if music_idx < 0:
		return
	if duck:
		_saved_music_vol = SettingsManager.music_volume
		AudioManager.set_bus_linear_volume(music_idx, _saved_music_vol * 0.35)
	else:
		AudioManager.set_bus_linear_volume(music_idx, SettingsManager.music_volume)
