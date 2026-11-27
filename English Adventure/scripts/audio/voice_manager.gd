class_name VoiceManager
extends RefCounted
## High-level Voice API for NPC dialogues, Vocabulary (normal, slow, example sentence),
## Phonics (distinct Letter Name vs Letter Sound), Sentences, and Mini-Game prompts.
## Decouples NPCs, Dialogue UI, Learning Hub, and MiniGames from underlying TTS/Audio providers.

var _profiles: VoiceProfileManager
var _playback: AudioPlaybackManager


func _init(profiles: VoiceProfileManager, playback: AudioPlaybackManager) -> void:
	_profiles = profiles
	_playback = playback


func speak_npc_line(speaker_id: String, text_en: String, audio_path: String = "", accent: String = "") -> Dictionary:
	if text_en.strip_edges().is_empty() and audio_path.is_empty():
		return { "played": false, "source": "empty" }
	var prof := _profiles.get_profile(speaker_id)
	var acc := accent if not accent.is_empty() else _profiles.get_active_accent()
	var base_rate := clampf(SettingsManager.speech_rate, 0.65, 1.15)
	var npc_rate := clampf(float(prof.get("rate_scale", 0.85)) * (base_rate / 0.85), 0.62, 1.25)
	return _playback.play_speech_or_asset({
		"audio_path": audio_path,
		"text_en": text_en,
		"accent": acc,
		"rate": npc_rate,
		"pitch": float(prof.get("pitch_scale", 1.0)),
		"speaker_id": speaker_id if not speaker_id.is_empty() else "professor_owl",
		"channel": "npc",
		"allow_tts_fallback": true
	})


func speak_learning_text(text_en: String, audio_path: String = "", accent: String = "", slow: bool = false, audio_id: String = "") -> Dictionary:
	var acc := accent if not accent.is_empty() else _profiles.get_active_accent()
	var rate := clampf(SettingsManager.speech_rate * (0.72 if slow else 1.0), 0.55, 1.15)
	return _playback.play_speech_or_asset({
		"audio_path": audio_path,
		"audio_id": audio_id,
		"text_en": text_en,
		"accent": acc,
		"rate": rate,
		"pitch": 1.0,
		"speaker_id": "learning_narrator",
		"channel": "learning",
		"allow_tts_fallback": true
	})


func speak_vocab_word(word_dict: Dictionary, slow: bool = false, accent: String = "") -> Dictionary:
	var acc := accent if not accent.is_empty() else _profiles.get_active_accent()
	var path := ""
	if slow:
		path = str(word_dict.get("audio_slow_uk_path" if acc == "en-GB" else "audio_slow_us_path", ""))
	if path.is_empty():
		path = str(word_dict.get("audio_uk_path" if acc == "en-GB" else "audio_us_path", ""))
	return speak_learning_text(str(word_dict.get("word", "")), path, acc, slow, str(word_dict.get("id", "")))


func speak_vocab_example(word_dict: Dictionary, accent: String = "") -> Dictionary:
	var acc := accent if not accent.is_empty() else _profiles.get_active_accent()
	var path := str(word_dict.get("example_audio_uk_path" if acc == "en-GB" else "example_audio_us_path", ""))
	return speak_learning_text(str(word_dict.get("example_sentence", "")), path, acc, false, str(word_dict.get("id", "")) + "_ex")


func speak_letter_name(letter_dict: Dictionary, accent: String = "") -> Dictionary:
	var acc := accent if not accent.is_empty() else _profiles.get_active_accent()
	var name_audio: Dictionary = letter_dict.get("audio_name", {})
	var path := str(name_audio.get(acc, name_audio.get("en-US", "")))
	var sym := str(letter_dict.get("letter_upper", ""))
	return speak_learning_text(sym, path, acc, false, str(letter_dict.get("id", "")) + "_name")


func speak_letter_sound_example(letter_dict: Dictionary, anchor_word: String, accent: String = "") -> Dictionary:
	var acc := accent if not accent.is_empty() else _profiles.get_active_accent()
	var sound_audio: Dictionary = letter_dict.get("audio_sound", {})
	var path := str(sound_audio.get(acc, sound_audio.get("en-US", "")))
	# Only speak verified bundled phoneme audio OR verified anchor word; never invent distorted syllable TTS
	var text_to_speak := anchor_word.strip_edges()
	return speak_learning_text(text_to_speak, path, acc, true, str(letter_dict.get("id", "")) + "_sound")


func pause() -> void:
	_playback.pause_speech()


func resume() -> void:
	_playback.resume_speech()


func replay() -> Dictionary:
	return _playback.replay_last()


func stop() -> void:
	_playback.stop_all_speech()
