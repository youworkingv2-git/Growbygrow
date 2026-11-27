class_name SpeechRecorder
extends Node
## Cross-platform Speech Recorder with child-privacy guards:
## - Never auto-records or records in background.
## - Requires explicit user press and microphone permission.
## - Supports Windows/Android/iOS native AudioEffectRecord AND Web MediaRecorder (when user grants browser mic permission).
## - Computes basic signal quality (RMS, peak, too-quiet / clipping hints) and cleans up temporary buffers on cancel/close.

signal recording_started()
signal recording_stopped(summary: Dictionary)
signal recording_cancelled()
signal permission_status_changed(status: String, message_vi: String)
signal level_updated(rms_linear: float, elapsed_sec: float)

const MAX_DURATION_SEC := 15.0
const MIN_DURATION_SEC := 0.35

var _record_bus_idx: int = -1
var _record_effect: AudioEffectRecord = null
var _mic_player: AudioStreamPlayer = null
var _playback: AudioPlaybackManager = null
var _sfx: SoundEffectManager = null

var _is_recording: bool = false
var _is_paused: bool = false
var _elapsed_sec: float = 0.0
var _recorded_wav: AudioStreamWAV = null
var _web_has_recording: bool = false
var _web_recording_duration: float = 0.0
var _permission_state: String = "unknown" # unknown | granted | denied | unavailable
var _last_quality: Dictionary = {}
var _session_id: String = ""


func setup(playback: AudioPlaybackManager, sfx: SoundEffectManager) -> void:
	_playback = playback
	_sfx = sfx


func get_capability_report() -> Dictionary:
	var is_web := OS.has_feature("web")
	if is_web:
		var web_media_ok := bool(JavaScriptBridge.eval("Boolean(navigator && navigator.mediaDevices && navigator.mediaDevices.getUserMedia && window.MediaRecorder)"))
		return {
			"platform": "web",
			"mic_hardware_detected": web_media_ok,
			"mic_recording_available": web_media_ok,
			"permission_state": _permission_state,
			"supports_pause": true,
			"supports_signal_analysis": false,
			"privacy_notice_vi": "Chỉ ghi âm khi bé bấm nút Micro và cho phép quyền Micro trên trình duyệt."
		}

	var devices := AudioServer.get_input_device_list()
	var has_hw := devices.size() > 0
	return {
		"platform": OS.get_name().to_lower(),
		"mic_hardware_detected": has_hw,
		"mic_recording_available": has_hw,
		"permission_state": _permission_state if has_hw else "unavailable",
		"supports_pause": true,
		"supports_signal_analysis": has_hw,
		"input_devices": devices,
		"privacy_notice_vi": "Chỉ ghi âm khi bé bấm nút Micro. Bản ghi chỉ lưu tạm để bé nghe lại và không tự gửi lên máy chủ."
	}


func request_microphone_permission() -> Dictionary:
	SettingsManager.mic_consent_acknowledged = true
	if OS.has_feature("web"):
		var has_api := bool(JavaScriptBridge.eval("Boolean(navigator && navigator.mediaDevices && navigator.mediaDevices.getUserMedia && window.MediaRecorder)"))
		if not has_api:
			_permission_state = "unavailable"
			permission_status_changed.emit(_permission_state, "Trình duyệt chưa hỗ trợ ghi âm MediaRecorder; bé vẫn có thể học nghe & chọn đáp án bình thường.")
			return { "granted": false, "state": _permission_state }
		# Trigger explicit browser permission check via helper
		_ensure_web_recorder_bridge()
		JavaScriptBridge.eval("window.__eaRecorder && window.__eaRecorder.requestPermission();")
		_permission_state = "prompting"
		return { "granted": true, "state": "prompting", "message_vi": "Hãy chọn 'Cho phép' (Allow) nếu trình duyệt hỏi quyền Micro." }

	if OS.has_feature("android") or OS.has_feature("ios"):
		var granted := OS.request_permissions()
		_permission_state = "granted" if granted else "denied"
		var msg := "Microphone đã sẵn sàng!" if granted else "Chưa cấp quyền Microphone. Bé vẫn có thể nghe mẫu và học các bài khác bình thường."
		permission_status_changed.emit(_permission_state, msg)
		return { "granted": granted, "state": _permission_state, "message_vi": msg }

	var devs := AudioServer.get_input_device_list()
	if devs.is_empty():
		_permission_state = "unavailable"
		var msg_no_hw := "Không tìm thấy Microphone trên máy. Bé vẫn có thể nghe mẫu và hoàn thành bài học."
		permission_status_changed.emit(_permission_state, msg_no_hw)
		return { "granted": false, "state": _permission_state, "message_vi": msg_no_hw }

	_permission_state = "granted"
	permission_status_changed.emit(_permission_state, "Microphone trên Windows đã sẵn sàng!")
	return { "granted": true, "state": "granted", "message_vi": "Microphone trên Windows đã sẵn sàng!" }


func start_recording() -> Dictionary:
	if _is_recording:
		return { "started": true, "session_id": _session_id }

	clear_recording(false)
	if _playback != null:
		_playback.stop_all_speech()

	_session_id = "rec_%d_%d" % [Time.get_unix_time_from_system(), randi() % 10000]
	_elapsed_sec = 0.0
	_is_paused = false

	if OS.has_feature("web"):
		_ensure_web_recorder_bridge()
		var ok := bool(JavaScriptBridge.eval("window.__eaRecorder ? window.__eaRecorder.start() : false"))
		if not ok:
			_permission_state = "unavailable"
			return {
				"started": false,
				"error": "web_recorder_unavailable",
				"message_vi": "Trình duyệt chưa hỗ trợ hoặc chưa cấp quyền Micro. Bé vẫn có thể học bằng cách nghe và chọn đáp án."
			}
		_is_recording = true
		if _sfx != null:
			_sfx.play_sfx("mic_start")
		recording_started.emit()
		EventBus.speech_recording_started.emit({ "session_id": _session_id })
		return { "started": true, "session_id": _session_id, "platform": "web" }

	var devs := AudioServer.get_input_device_list()
	if devs.is_empty():
		_permission_state = "unavailable"
		return {
			"started": false,
			"error": "no_input_device",
			"message_vi": "Không phát hiện Microphone trên thiết bị. Bé vẫn có thể nghe mẫu và luyện nói không cần thu âm."
		}

	if OS.has_feature("android") or OS.has_feature("ios"):
		if not OS.request_permissions():
			_permission_state = "denied"
			return {
				"started": false,
				"error": "permission_denied",
				"message_vi": "Chưa được cấp quyền Microphone. Bé có thể bật quyền trong Cài đặt thiết bị hoặc tiếp tục học nghe."
			}

	_ensure_record_bus()
	if _record_effect == null:
		return { "started": false, "error": "record_effect_failed", "message_vi": "Không khởi tạo được bộ ghi âm." }

	if _mic_player == null:
		_mic_player = AudioStreamPlayer.new()
		_mic_player.stream = AudioStreamMicrophone.new()
		_mic_player.bus = "Record"
		add_child(_mic_player)

	_mic_player.play()
	_record_effect.set_recording_active(true)
	_is_recording = true
	_permission_state = "granted"
	if _sfx != null:
		_sfx.play_sfx("mic_start")
	recording_started.emit()
	EventBus.speech_recording_started.emit({ "session_id": _session_id })
	return { "started": true, "session_id": _session_id, "platform": "native" }


func pause_recording() -> void:
	if not _is_recording or _is_paused:
		return
	_is_paused = true
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.__eaRecorder && window.__eaRecorder.pause();")
	elif _record_effect != null:
		_record_effect.set_recording_active(false)


func resume_recording() -> void:
	if not _is_recording or not _is_paused:
		return
	_is_paused = false
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.__eaRecorder && window.__eaRecorder.resume();")
	elif _record_effect != null:
		_record_effect.set_recording_active(true)


func stop_recording() -> Dictionary:
	if not _is_recording:
		return get_recording_summary()

	_is_recording = false
	_is_paused = false
	if _sfx != null:
		_sfx.play_sfx("mic_stop")

	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.__eaRecorder && window.__eaRecorder.stop();")
		_web_has_recording = _elapsed_sec >= MIN_DURATION_SEC
		_web_recording_duration = _elapsed_sec
		var web_sum := get_recording_summary()
		recording_stopped.emit(web_sum)
		EventBus.speech_recording_stopped.emit(_elapsed_sec, _web_has_recording)
		return web_sum

	if _record_effect != null and _record_effect.is_recording_active():
		_record_effect.set_recording_active(false)
	if _record_effect != null:
		_recorded_wav = _record_effect.get_recording()
	if _mic_player != null and _mic_player.playing:
		_mic_player.stop()

	_last_quality = _analyze_wav_quality(_recorded_wav)
	var summary := get_recording_summary()
	recording_stopped.emit(summary)
	EventBus.speech_recording_stopped.emit(float(summary.get("duration_sec", 0.0)), bool(summary.get("has_recording", false)))
	return summary


func replay_recording() -> bool:
	if _is_recording:
		stop_recording()
	if OS.has_feature("web"):
		if _playback != null:
			_playback.stop_all_speech()
		var ok := bool(JavaScriptBridge.eval("window.__eaRecorder ? window.__eaRecorder.replay() : false"))
		return ok
	if _recorded_wav == null or _playback == null:
		return false
	return _playback.play_recorded_stream(_recorded_wav)


func clear_recording(emit_cancel: bool = true) -> void:
	if _is_recording:
		_is_recording = false
		_is_paused = false
		if OS.has_feature("web"):
			JavaScriptBridge.eval("window.__eaRecorder && window.__eaRecorder.cancel();")
		else:
			if _record_effect != null and _record_effect.is_recording_active():
				_record_effect.set_recording_active(false)
			if _mic_player != null and _mic_player.playing:
				_mic_player.stop()
	elif OS.has_feature("web"):
		JavaScriptBridge.eval("window.__eaRecorder && window.__eaRecorder.cancel();")

	_recorded_wav = null
	_web_has_recording = false
	_web_recording_duration = 0.0
	_elapsed_sec = 0.0
	_last_quality = {}
	if emit_cancel:
		recording_cancelled.emit()


func has_recording() -> bool:
	if OS.has_feature("web"):
		var ready_flag := bool(JavaScriptBridge.eval("Boolean(window.__eaRecorder && window.__eaRecorder.hasAudio())"))
		return _web_has_recording or ready_flag
	return _recorded_wav != null and _recorded_wav.get_length() >= MIN_DURATION_SEC


func is_recording() -> bool:
	return _is_recording


func is_paused() -> bool:
	return _is_paused


func get_session_id() -> String:
	return _session_id


func get_recording_summary() -> Dictionary:
	if OS.has_feature("web"):
		var st_str := str(JavaScriptBridge.eval("window.__eaRecorder ? window.__eaRecorder.getStatus() : 'idle'"))
		if st_str == "denied":
			_permission_state = "denied"
			permission_status_changed.emit("denied", "Quyền Micro trên trình duyệt bị từ chối. Bé vẫn có thể nghe mẫu và học các phần khác.")
		var has_aud := has_recording()
		return {
			"session_id": _session_id,
			"has_recording": has_aud,
			"duration_sec": snappedf(_web_recording_duration, 0.01),
			"quality_ok": has_aud,
			"quality_hint_vi": "Đã lưu bản ghi tạm trên trình duyệt." if has_aud else "Chưa thu được âm thanh hoặc bản ghi quá ngắn.",
			"permission_state": _permission_state
		}

	var dur := _recorded_wav.get_length() if _recorded_wav != null else 0.0
	var has_wav := _recorded_wav != null and dur >= MIN_DURATION_SEC
	var q_ok := has_wav and not bool(_last_quality.get("too_quiet", false))
	var q_hint := "Chất lượng bản ghi rõ ràng!"
	if not has_wav:
		q_hint = "Bản ghi quá ngắn, bé hãy bấm Micro và nói lại rõ ràng nhé."
	elif bool(_last_quality.get("too_quiet", false)):
		q_hint = "Âm lượng hơi nhỏ, bé thử nói gần Micro hơn một chút nhé."
	elif bool(_last_quality.get("clipped", false)):
		q_hint = "Âm thanh hơi to sát Micro, bé nói vừa đủ nghe sẽ rõ hơn."

	return {
		"session_id": _session_id,
		"has_recording": has_wav,
		"duration_sec": snappedf(dur, 0.01),
		"quality_ok": q_ok,
		"rms_db": float(_last_quality.get("rms_db", -60.0)),
		"peak_db": float(_last_quality.get("peak_db", -60.0)),
		"quality_hint_vi": q_hint,
		"permission_state": _permission_state
	}


func get_recorded_audio_base64() -> Dictionary:
	# Called ONLY after explicit user Submit action!
	if OS.has_feature("web"):
		var b64 := str(JavaScriptBridge.eval("window.__eaRecorder ? window.__eaRecorder.getBase64() : ''"))
		if b64.is_empty():
			return {}
		return { "mime_type": "audio/webm", "base64": b64, "duration_sec": _web_recording_duration }
	if _recorded_wav == null:
		return {}
	var pcm_bytes := _build_wav_file_bytes(_recorded_wav)
	return {
		"mime_type": "audio/wav",
		"base64": Marshalls.raw_to_base64(pcm_bytes),
		"duration_sec": _recorded_wav.get_length()
	}


func _process(delta: float) -> void:
	if not _is_recording or _is_paused:
		return
	_elapsed_sec += delta
	if _elapsed_sec >= MAX_DURATION_SEC:
		stop_recording()
		return

	var rms_lin := 0.0
	if not OS.has_feature("web") and _record_bus_idx >= 0:
		var db_l := AudioServer.get_bus_peak_volume_left_db(_record_bus_idx, 0)
		rms_lin = clampf(db_to_linear(db_l), 0.0, 1.0)
	elif OS.has_feature("web"):
		var st := str(JavaScriptBridge.eval("window.__eaRecorder ? window.__eaRecorder.getStatus() : 'idle'"))
		if st == "denied":
			_is_recording = false
			_permission_state = "denied"
			permission_status_changed.emit("denied", "Trình duyệt chưa cấp quyền Micro. Bé vẫn có thể học bằng cách nghe mẫu!")
			return
	level_updated.emit(rms_lin, _elapsed_sec)


func _ensure_record_bus() -> void:
	_record_bus_idx = AudioServer.get_bus_index("Record")
	if _record_bus_idx == -1:
		AudioServer.add_bus()
		_record_bus_idx = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(_record_bus_idx, "Record")
		AudioServer.set_bus_mute(_record_bus_idx, true)
	var has_eff := false
	for i in range(AudioServer.get_bus_effect_count(_record_bus_idx)):
		var eff := AudioServer.get_bus_effect(_record_bus_idx, i)
		if eff is AudioEffectRecord:
			_record_effect = eff as AudioEffectRecord
			has_eff = true
			break
	if not has_eff:
		_record_effect = AudioEffectRecord.new()
		AudioServer.add_bus_effect(_record_bus_idx, _record_effect)


func _analyze_wav_quality(wav: AudioStreamWAV) -> Dictionary:
	if wav == null or wav.data.is_empty():
		return { "too_quiet": true, "clipped": false, "rms_db": -60.0, "peak_db": -60.0 }
	var data := wav.data
	var sample_count := data.size() / 2
	if sample_count <= 0:
		return { "too_quiet": true, "clipped": false, "rms_db": -60.0, "peak_db": -60.0 }
	var step := maxi(1, sample_count / 2000)
	var sum_sq := 0.0
	var peak := 0.0
	var n := 0
	for i in range(0, sample_count, step):
		var s_int := data.decode_s16(i * 2)
		var f := absf(float(s_int) / 32768.0)
		sum_sq += f * f
		if f > peak:
			peak = f
		n += 1
	var rms := sqrt(sum_sq / maxf(1.0, float(n)))
	var rms_db := linear_to_db(maxf(0.0001, rms))
	var peak_db := linear_to_db(maxf(0.0001, peak))
	return {
		"too_quiet": peak < 0.015 or rms_db < -44.0,
		"clipped": peak > 0.98,
		"rms_db": snappedf(rms_db, 0.1),
		"peak_db": snappedf(peak_db, 0.1)
	}


func _build_wav_file_bytes(wav: AudioStreamWAV) -> PackedByteArray:
	var pcm := wav.data
	var channels := 2 if wav.stereo else 1
	var sample_rate := wav.mix_rate
	var bits := 16 if wav.format == AudioStreamWAV.FORMAT_16_BITS else 8
	var byte_rate := sample_rate * channels * (bits / 8)
	var block_align := channels * (bits / 8)
	var out := PackedByteArray()
	out.resize(44 + pcm.size())
	out.encode_u32(0, 0x46464952) # "RIFF"
	out.encode_u32(4, 36 + pcm.size())
	out.encode_u32(8, 0x45564157) # "WAVE"
	out.encode_u32(12, 0x20746d66) # "fmt "
	out.encode_u32(16, 16)
	out.encode_u16(20, 1)
	out.encode_u16(22, channels)
	out.encode_u32(24, sample_rate)
	out.encode_u32(28, byte_rate)
	out.encode_u16(32, block_align)
	out.encode_u16(34, bits)
	out.encode_u32(36, 0x61746164) # "data"
	out.encode_u32(40, pcm.size())
	for i in range(pcm.size()):
		out[44 + i] = pcm[i]
	return out


func _ensure_web_recorder_bridge() -> void:
	var js := """
	(function(){
	  if (window.__eaRecorder) return true;
	  var state = { stream: null, mr: null, chunks: [], blobUrl: '', b64: '', status: 'idle', audioEl: null };
	  function cleanupUrl(){ if (state.blobUrl) { try{ URL.revokeObjectURL(state.blobUrl); }catch(e){} state.blobUrl=''; } }
	  window.__eaRecorder = {
	    requestPermission: function(){
	      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) { state.status='unavailable'; return; }
	      navigator.mediaDevices.getUserMedia({ audio: true }).then(function(s){
	        s.getTracks().forEach(function(t){ t.stop(); });
	        state.status = 'granted';
	      }).catch(function(){ state.status = 'denied'; });
	    },
	    start: function(){
	      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia || !window.MediaRecorder) { state.status='unavailable'; return false; }
	      cleanupUrl(); state.chunks = []; state.b64 = ''; state.status = 'starting';
	      navigator.mediaDevices.getUserMedia({ audio: true }).then(function(s){
	        state.stream = s;
	        state.mr = new MediaRecorder(s);
	        state.mr.ondataavailable = function(ev){ if (ev.data && ev.data.size > 0) state.chunks.push(ev.data); };
	        state.mr.onstop = function(){
	          var blob = new Blob(state.chunks, { type: state.mr.mimeType || 'audio/webm' });
	          state.blobUrl = URL.createObjectURL(blob);
	          var reader = new FileReader();
	          reader.onloadend = function(){
	            var res = String(reader.result || '');
	            var idx = res.indexOf(',');
	            state.b64 = idx >= 0 ? res.slice(idx + 1) : '';
	          };
	          reader.readAsDataURL(blob);
	          if (state.stream) { state.stream.getTracks().forEach(function(t){ t.stop(); }); state.stream = null; }
	          state.status = 'stopped';
	        };
	        state.mr.start();
	        state.status = 'recording';
	      }).catch(function(){ state.status = 'denied'; });
	      return true;
	    },
	    pause: function(){ if (state.mr && state.mr.state === 'recording' && state.mr.pause) state.mr.pause(); },
	    resume: function(){ if (state.mr && state.mr.state === 'paused' && state.mr.resume) state.mr.resume(); },
	    stop: function(){ if (state.mr && state.mr.state !== 'inactive') state.mr.stop(); },
	    replay: function(){
	      if (!state.blobUrl) return false;
	      if (state.audioEl) { try { state.audioEl.pause(); } catch(e){} }
	      state.audioEl = new Audio(state.blobUrl);
	      state.audioEl.play().catch(function(){});
	      return true;
	    },
	    cancel: function(){
	      if (state.mr && state.mr.state !== 'inactive') { try{ state.mr.stop(); }catch(e){} }
	      if (state.stream) { state.stream.getTracks().forEach(function(t){ t.stop(); }); state.stream = null; }
	      cleanupUrl(); state.chunks = []; state.b64 = ''; state.status = 'idle';
	    },
	    hasAudio: function(){ return Boolean(state.blobUrl); },
	    getStatus: function(){ return state.status; },
	    getBase64: function(){ return state.b64 || ''; }
	  };
	  return true;
	})();
	"""
	JavaScriptBridge.eval(js)
