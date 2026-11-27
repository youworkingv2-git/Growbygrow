class_name MiniGameAudioManager
extends RefCounted
## Dedicated Mini-Game Audio Controller wrapping shared AudioManager / VoiceManager.
## Prevents overlapping pronunciation playback, preserves independent BGM/SFX control,
## and cleanly reports audio asset status without pretending missing audio files exist.

var _bgm_ducked: bool = false


func play_word_or_sentence(audio_path: String, text_en: String, accent: String = "", slow: bool = false, speaker_id: String = "") -> Dictionary:
	var acc := accent if not accent.is_empty() else SettingsManager.preferred_accent
	if not speaker_id.is_empty() and AudioManager.voice_manager != null:
		return AudioManager.voice_manager.speak_npc_line(speaker_id, text_en, audio_path, acc)
	if AudioManager.voice_manager != null:
		var res := AudioManager.voice_manager.speak_learning_text(text_en, audio_path, acc, slow)
		var src := str(res.get("source", "missing_asset"))
		return {
			"source": src,
			"played": bool(res.get("played", false)),
			"message_vi": str(res.get("message_vi", ""))
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
	if AudioManager.music_manager == null:
		return
	if duck:
		AudioManager.music_manager.push_duck("minigame_speech", 0.35)
	else:
		AudioManager.music_manager.pop_duck("minigame_speech")
