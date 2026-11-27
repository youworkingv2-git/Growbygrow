class_name TextToSpeechManager
extends Node
## Cross-platform Text-to-Speech adapter using Godot 4.3 DisplayServer.tts_*
## (Windows SAPI/OneCore, Android TTS, iOS AVSpeechSynthesizer) with Web SpeechSynthesis
## fallback. Strictly separated from STT and AI Pronunciation Assessment.

signal speech_started(utterance_id: int, text: String, metadata: Dictionary)
signal speech_finished(utterance_id: int, metadata: Dictionary)

var _next_utterance_id: int = 1
var _active_utterance_id: int = 0
var _active_metadata: Dictionary = {}
var _is_speaking_flag: bool = false
var _is_paused_flag: bool = false
var _web_fallback_end_msec: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func is_available() -> bool:
	if OS.has_feature("web"):
		var ok: Variant = JavaScriptBridge.eval("('speechSynthesis' in window)")
		if bool(ok):
			return true
	var voices := _get_native_en_voices("en")
	return not voices.is_empty()


func get_capability_summary() -> Dictionary:
	var native_us := _get_native_en_voices("en-US")
	var native_gb := _get_native_en_voices("en-GB")
	var web_ok := false
	if OS.has_feature("web"):
		web_ok = bool(JavaScriptBridge.eval("('speechSynthesis' in window)"))
	return {
		"native_tts_available": (native_us.size() + native_gb.size()) > 0,
		"native_us_voices": native_us.size(),
		"native_gb_voices": native_gb.size(),
		"web_tts_available": web_ok
	}


func speak(
	text: String,
	accent: String = "en-US",
	rate: float = 0.85,
	pitch: float = 1.0,
	volume_pct: int = 85,
	metadata: Dictionary = {}
) -> Dictionary:
	var clean := _normalize_spoken_text(text, accent)
	if clean.is_empty():
		return { "played": false, "source": "empty_text" }

	stop()

	_next_utterance_id += 1
	_active_utterance_id = _next_utterance_id
	_active_metadata = metadata.duplicate(true)
	_is_paused_flag = false

	var r := clampf(rate, 0.50, 1.40)
	var p := clampf(pitch, 0.65, 1.45)
	var v := clampi(volume_pct, 0, 100)

	# Prefer Web SpeechSynthesis on Web builds for consistent browser voice selection
	if OS.has_feature("web") and _speak_web(clean, accent, r, p, float(v) / 100.0):
		_is_speaking_flag = true
		speech_started.emit(_active_utterance_id, clean, _active_metadata)
		return {
			"played": true,
			"source": "web_speech_synthesis",
			"utterance_id": _active_utterance_id,
			"accent": accent
		}

	var voice_id := _pick_native_voice(accent)
	if not voice_id.is_empty():
		DisplayServer.tts_speak(clean, voice_id, v, p, r, _active_utterance_id, true)
		_is_speaking_flag = true
		speech_started.emit(_active_utterance_id, clean, _active_metadata)
		return {
			"played": true,
			"source": "native_os_tts",
			"utterance_id": _active_utterance_id,
			"accent": accent
		}

	_active_utterance_id = 0
	_active_metadata = {}
	return {
		"played": false,
		"source": "tts_unavailable",
		"message_vi": "Thiết bị chưa có gói giọng đọc tiếng Anh offline hoặc trình duyệt không hỗ trợ TTS."
	}


func pause() -> void:
	if not _is_speaking_flag or _is_paused_flag:
		return
	_is_paused_flag = true
	if OS.has_feature("web"):
		JavaScriptBridge.eval("(function(){ if ('speechSynthesis' in window) window.speechSynthesis.pause(); })();")
	elif DisplayServer.tts_is_speaking():
		DisplayServer.tts_pause()


func resume() -> void:
	if not _is_speaking_flag or not _is_paused_flag:
		return
	_is_paused_flag = false
	if OS.has_feature("web"):
		JavaScriptBridge.eval("(function(){ if ('speechSynthesis' in window) window.speechSynthesis.resume(); })();")
	else:
		DisplayServer.tts_resume()


func stop() -> void:
	var was_speaking := _is_speaking_flag
	var prev_id := _active_utterance_id
	var prev_meta := _active_metadata.duplicate(true)
	_is_speaking_flag = false
	_is_paused_flag = false
	_active_utterance_id = 0
	_active_metadata = {}
	_web_fallback_end_msec = 0

	if OS.has_feature("web"):
		JavaScriptBridge.eval("(function(){ if ('speechSynthesis' in window) window.speechSynthesis.cancel(); window.__eaTtsSpeaking = false; })();")
	elif DisplayServer.tts_is_speaking() or DisplayServer.tts_is_paused():
		DisplayServer.tts_stop()

	if was_speaking:
		speech_finished.emit(prev_id, prev_meta)


func is_speaking() -> bool:
	return _is_speaking_flag


func is_paused() -> bool:
	return _is_paused_flag


func _process(_delta: float) -> void:
	if not _is_speaking_flag or _is_paused_flag:
		return
	if OS.has_feature("web"):
		var still_speaking := bool(JavaScriptBridge.eval("Boolean(window.__eaTtsSpeaking || ('speechSynthesis' in window && window.speechSynthesis.speaking))"))
		if not still_speaking and Time.get_ticks_msec() >= _web_fallback_end_msec:
			_finish_current()
	else:
		if not DisplayServer.tts_is_speaking() and not DisplayServer.tts_is_paused():
			_finish_current()


func _finish_current() -> void:
	if not _is_speaking_flag:
		return
	var prev_id := _active_utterance_id
	var prev_meta := _active_metadata.duplicate(true)
	_is_speaking_flag = false
	_is_paused_flag = false
	_active_utterance_id = 0
	_active_metadata = {}
	speech_finished.emit(prev_id, prev_meta)


func _normalize_spoken_text(text: String, accent: String) -> String:
	var clean := text.strip_edges()
	# Strip inline IPA/phonetic slash blocks like " - /æ/ - " or "/æ/" so TTS never reads "slash"
	if clean.contains("/"):
		var re := RegEx.new()
		if re.compile("(?:\\s*-\\s*)?/[^/\\s]+/(?:\\s*-\\s*)?") == OK:
			clean = re.sub(clean, ", ", true).strip_edges()
			while clean.begins_with(",") or clean.begins_with("-"):
				clean = clean.substr(1).strip_edges()
			while clean.ends_with(",") or clean.ends_with("-"):
				clean = clean.substr(0, clean.length() - 1).strip_edges()
	if clean == "Z" and accent == "en-GB":
		return "Zed"
	return clean


func _get_native_en_voices(lang_prefix: String) -> PackedStringArray:
	if OS.has_feature("web"):
		return PackedStringArray()
	return DisplayServer.tts_get_voices_for_language(lang_prefix)


func _pick_native_voice(accent: String) -> String:
	var exact := _get_native_en_voices(accent)
	if not exact.is_empty():
		return exact[0]
	var lang_only := _get_native_en_voices("en")
	if not lang_only.is_empty():
		return lang_only[0]
	return ""


func _speak_web(text: String, accent: String, rate: float, pitch: float, volume: float) -> bool:
	var lang := "en-GB" if accent == "en-GB" else "en-US"
	var lang_lc := lang.to_lower()
	var safe_text := JSON.stringify(text)
	# Estimate fallback timeout in case browser suppresses onend on headless/restricted audio contexts
	var est_ms := clampi(int((float(maxi(4, text.length())) / 11.0 / maxf(0.5, rate)) * 1000.0) + 600, 1200, 15000)
	_web_fallback_end_msec = Time.get_ticks_msec() + mini(est_ms, 2200)
	var js := "(function(){ if (!('speechSynthesis' in window)) return false; try { window.speechSynthesis.cancel(); var u = new SpeechSynthesisUtterance(" + safe_text + "); u.lang = '" + lang + "'; u.rate = " + str(rate) + "; u.pitch = " + str(pitch) + "; u.volume = " + str(clampf(volume, 0.0, 1.0)) + "; var voices = window.speechSynthesis.getVoices() || []; var v = voices.find(function(x){ return x.lang && x.lang.toLowerCase().replace('_','-') === '" + lang_lc + "'; }) || voices.find(function(x){ return x.lang && x.lang.toLowerCase().startsWith('en'); }); if (v) u.voice = v; window.__eaTtsSpeaking = true; u.onend = function(){ window.__eaTtsSpeaking = false; }; u.onerror = function(){ window.__eaTtsSpeaking = false; }; window.speechSynthesis.speak(u); return true; } catch(e){ window.__eaTtsSpeaking = false; return false; } })();"
	var ok: Variant = JavaScriptBridge.eval(js)
	return bool(ok)
