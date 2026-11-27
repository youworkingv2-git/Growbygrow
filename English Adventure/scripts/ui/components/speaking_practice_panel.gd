class_name SpeakingPracticePanel
extends VBoxContainer
## Reusable Child-Friendly Speaking Practice UI (Prompt 07 Sections 7, 9, 11, 12, 18):
## - Model audio (normal + slow)
## - Explicit Microphone permission & privacy notice
## - Record / Pause / Stop / Replay / Re-record / Cancel
## - Duration & signal level meter
## - Explicit Submit for STT / AI Pronunciation Assessment (never auto-uploads)
## - Honest AI/Offline status + non-blocking self-practice completion

signal practice_completed(confidence_choice: String, extra_session_data: Dictionary)

var _target_text: String = ""
var _ipa_text: String = ""
var _audio_path: String = ""
var _learning_content_id: String = ""
var _mouth_hint_vi: String = ""
var _allow_completion_buttons: bool = true

var _listened_model: bool = false
var _replayed_own: bool = false
var _attempt_count: int = 0
var _last_rec_summary: Dictionary = {}
var _last_stt_result: Dictionary = {}
var _last_pron_result: Dictionary = {}

var _listen_btn: Button
var _slow_btn: Button
var _perm_btn: Button
var _rec_btn: Button
var _pause_btn: Button
var _stop_btn: Button
var _replay_btn: Button
var _rerecord_btn: Button
var _cancel_btn: Button
var _submit_ai_btn: Button
var _done_ok_btn: Button
var _done_retry_btn: Button

var _level_bar: ProgressBar
var _timer_lbl: Label
var _status_lbl: Label
var _feedback_box: PanelContainer
var _feedback_lbl: RichTextLabel


func _ready() -> void:
	add_theme_constant_override("separation", 8)
	_build_ui()
	_connect_audio_signals()
	_refresh_controls()


func _exit_tree() -> void:
	if AudioManager.speech_recorder != null and AudioManager.speech_recorder.is_recording():
		AudioManager.speech_recorder.clear_recording(false)


func setup_item(item: Dictionary, allow_completion_buttons: bool = true) -> void:
	_allow_completion_buttons = allow_completion_buttons
	_target_text = str(item.get("target_text_en", item.get("word", "")))
	_ipa_text = str(item.get("ipa", item.get("ipa_us", "")))
	_audio_path = str(item.get("audio_path", item.get("audio_us_path", "")))
	_learning_content_id = str(item.get("id", item.get("word_id", "")))
	_mouth_hint_vi = str(item.get("mouth_hint_vi", ""))

	_listened_model = false
	_replayed_own = false
	_attempt_count = 0
	_last_rec_summary = {}
	_last_stt_result = {}
	_last_pron_result = {}

	if AudioManager.speech_recorder != null:
		AudioManager.speech_recorder.clear_recording(false)
	_feedback_box.visible = false
	_timer_lbl.text = "0.0s / 15.0s"
	_level_bar.value = 0.0
	_refresh_controls()


func _build_ui() -> void:
	var model_row := HBoxContainer.new()
	model_row.alignment = BoxContainer.ALIGNMENT_CENTER
	model_row.add_theme_constant_override("separation", 10)
	add_child(model_row)

	_listen_btn = _make_btn("1. Nghe mẫu", Color(0.16, 0.52, 0.86, 1), Vector2(146, 44))
	_listen_btn.pressed.connect(func() -> void: _play_model(false))
	model_row.add_child(_listen_btn)

	_slow_btn = _make_btn("Nghe chậm", Color(0.24, 0.44, 0.74, 1), Vector2(126, 44))
	_slow_btn.pressed.connect(func() -> void: _play_model(true))
	model_row.add_child(_slow_btn)

	_perm_btn = _make_btn("Bật Micro", Color(0.45, 0.42, 0.70, 1), Vector2(120, 44))
	_perm_btn.pressed.connect(_on_request_permission)
	model_row.add_child(_perm_btn)

	var rec_row := HBoxContainer.new()
	rec_row.alignment = BoxContainer.ALIGNMENT_CENTER
	rec_row.add_theme_constant_override("separation", 8)
	add_child(rec_row)

	_rec_btn = _make_btn("2. Ghi âm", Color(0.80, 0.28, 0.24, 1), Vector2(138, 46))
	_rec_btn.pressed.connect(_on_start_rec)
	rec_row.add_child(_rec_btn)

	_pause_btn = _make_btn("Tạm dừng", Color(0.68, 0.48, 0.16, 1), Vector2(110, 46))
	_pause_btn.pressed.connect(_on_pause_resume_rec)
	rec_row.add_child(_pause_btn)

	_stop_btn = _make_btn("Dừng", Color(0.55, 0.22, 0.22, 1), Vector2(96, 46))
	_stop_btn.pressed.connect(_on_stop_rec)
	rec_row.add_child(_stop_btn)

	_replay_btn = _make_btn("3. Nghe lại", Color(0.42, 0.36, 0.74, 1), Vector2(130, 46))
	_replay_btn.pressed.connect(_on_replay_rec)
	rec_row.add_child(_replay_btn)

	_rerecord_btn = _make_btn("Ghi lại", Color(0.32, 0.46, 0.62, 1), Vector2(102, 46))
	_rerecord_btn.pressed.connect(_on_rerecord)
	rec_row.add_child(_rerecord_btn)

	_cancel_btn = _make_btn("Hủy bản ghi", Color(0.38, 0.38, 0.44, 1), Vector2(114, 46))
	_cancel_btn.pressed.connect(_on_cancel_rec)
	rec_row.add_child(_cancel_btn)

	# Duration + Live Audio Signal Meter
	var meter_row := HBoxContainer.new()
	meter_row.alignment = BoxContainer.ALIGNMENT_CENTER
	meter_row.add_theme_constant_override("separation", 10)
	add_child(meter_row)

	_timer_lbl = Label.new()
	_timer_lbl.text = "0.0s / 15.0s"
	_timer_lbl.add_theme_font_size_override("font_size", 14)
	_timer_lbl.add_theme_color_override("font_color", Color(0.18, 0.24, 0.36, 1))
	meter_row.add_child(_timer_lbl)

	_level_bar = ProgressBar.new()
	_level_bar.custom_minimum_size = Vector2(220, 16)
	_level_bar.min_value = 0.0
	_level_bar.max_value = 100.0
	_level_bar.show_percentage = false
	meter_row.add_child(_level_bar)

	_status_lbl = Label.new()
	_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_lbl.add_theme_font_size_override("font_size", 14)
	_status_lbl.add_theme_color_override("font_color", Color(0.24, 0.32, 0.44, 1))
	add_child(_status_lbl)

	# Explicit AI Submit + Completion Row
	var action_row := HBoxContainer.new()
	action_row.alignment = BoxContainer.ALIGNMENT_CENTER
	action_row.add_theme_constant_override("separation", 10)
	add_child(action_row)

	_submit_ai_btn = _make_btn("4. Gửi đánh giá phát âm", Color(0.18, 0.48, 0.72, 1), Vector2(210, 44))
	_submit_ai_btn.pressed.connect(_on_submit_for_assessment)
	action_row.add_child(_submit_ai_btn)

	_done_ok_btn = _make_btn("Mình đã nói to, rõ rồi!", Color(0.16, 0.64, 0.34, 1), Vector2(210, 44))
	_done_ok_btn.pressed.connect(func() -> void: _emit_complete("confident"))
	action_row.add_child(_done_ok_btn)

	_done_retry_btn = _make_btn("Cần luyện thêm câu này", Color(0.80, 0.52, 0.16, 1), Vector2(196, 44))
	_done_retry_btn.pressed.connect(func() -> void: _emit_complete("need_more_practice"))
	action_row.add_child(_done_retry_btn)

	_feedback_box = PanelContainer.new()
	_feedback_box.visible = false
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.95, 0.98, 1.0, 0.98)
	sb.border_color = Color(0.32, 0.58, 0.88, 1.0)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(12)
	sb.set_content_margin_all(10)
	_feedback_box.add_theme_stylebox_override("panel", sb)
	add_child(_feedback_box)

	_feedback_lbl = RichTextLabel.new()
	_feedback_lbl.bbcode_enabled = false
	_feedback_lbl.fit_content = true
	_feedback_lbl.scroll_active = false
	_feedback_lbl.add_theme_font_size_override("normal_font_size", 14)
	_feedback_lbl.add_theme_color_override("default_color", Color(0.14, 0.22, 0.36, 1))
	_feedback_box.add_child(_feedback_lbl)


func _connect_audio_signals() -> void:
	if AudioManager.speech_recorder != null:
		AudioManager.speech_recorder.level_updated.connect(_on_recorder_level)
		AudioManager.speech_recorder.recording_stopped.connect(_on_recorder_stopped)
		AudioManager.speech_recorder.recording_cancelled.connect(_on_recorder_cancelled)
		AudioManager.speech_recorder.permission_status_changed.connect(func(_st: String, msg: String) -> void:
			if is_inside_tree():
				_status_lbl.text = msg
				_refresh_controls()
		)
	if AudioManager.speech_recognition != null:
		AudioManager.speech_recognition.recognition_completed.connect(_on_stt_completed)
	if AudioManager.pronunciation_assessment != null:
		AudioManager.pronunciation_assessment.assessment_completed.connect(_on_assessment_completed)


func _play_model(slow: bool) -> void:
	if _target_text.is_empty() or AudioManager.voice_manager == null:
		return
	_listened_model = true
	var res := AudioManager.voice_manager.speak_learning_text(_target_text, _audio_path, SettingsManager.preferred_accent, slow)
	if bool(res.get("played", false)):
		_status_lbl.text = "Đang phát giọng mẫu (%s)..." % ("chậm" if slow else SettingsManager.preferred_accent)
	else:
		_status_lbl.text = str(res.get("message_vi", "Hãy nhìn phiên âm IPA và đọc theo mẫu."))


func _on_request_permission() -> void:
	if AudioManager.speech_recorder == null:
		return
	var res := AudioManager.speech_recorder.request_microphone_permission()
	_status_lbl.text = str(res.get("message_vi", ""))
	_refresh_controls()


func _on_start_rec() -> void:
	if AudioManager.speech_recorder == null:
		return
	_attempt_count += 1
	var res := AudioManager.speech_recorder.start_recording()
	if bool(res.get("started", false)):
		_status_lbl.text = "Đang ghi âm... Hãy nói to và rõ: \"%s\"" % _target_text
	else:
		_status_lbl.text = str(res.get("message_vi", "Chưa thể ghi âm."))
	_refresh_controls()


func _on_pause_resume_rec() -> void:
	if AudioManager.speech_recorder == null:
		return
	if AudioManager.speech_recorder.is_paused():
		AudioManager.speech_recorder.resume_recording()
		_status_lbl.text = "Tiếp tục ghi âm..."
	else:
		AudioManager.speech_recorder.pause_recording()
		_status_lbl.text = "Đã tạm dừng ghi âm."
	_refresh_controls()


func _on_stop_rec() -> void:
	if AudioManager.speech_recorder != null:
		AudioManager.speech_recorder.stop_recording()


func _on_replay_rec() -> void:
	if AudioManager.speech_recorder == null:
		return
	if AudioManager.speech_recorder.replay_recording():
		_replayed_own = true
		_status_lbl.text = "Đang phát lại bản ghi âm của bé để bé tự nghe đối chiếu!"
	else:
		_status_lbl.text = "Chưa có bản ghi âm để phát lại."


func _on_rerecord() -> void:
	if AudioManager.speech_recorder != null:
		AudioManager.speech_recorder.clear_recording(false)
	_on_start_rec()


func _on_cancel_rec() -> void:
	if AudioManager.speech_recorder != null:
		AudioManager.speech_recorder.clear_recording(true)


func _on_recorder_level(rms_lin: float, elapsed_sec: float) -> void:
	if not is_inside_tree():
		return
	_timer_lbl.text = "%.1fs / %.1fs" % [elapsed_sec, SpeechRecorder.MAX_DURATION_SEC]
	_level_bar.value = clampf(rms_lin * 140.0, 0.0, 100.0)


func _on_recorder_stopped(summary: Dictionary) -> void:
	if not is_inside_tree():
		return
	_last_rec_summary = summary
	_timer_lbl.text = "%.1fs / %.1fs" % [float(summary.get("duration_sec", 0.0)), SpeechRecorder.MAX_DURATION_SEC]
	_level_bar.value = 0.0
	_status_lbl.text = str(summary.get("quality_hint_vi", "Đã dừng ghi âm."))
	_refresh_controls()


func _on_recorder_cancelled() -> void:
	if not is_inside_tree():
		return
	_last_rec_summary = {}
	_timer_lbl.text = "0.0s / 15.0s"
	_level_bar.value = 0.0
	_status_lbl.text = "Đã hủy bản ghi âm tạm. Bé có thể ghi lại bất cứ lúc nào."
	_refresh_controls()


func _on_submit_for_assessment() -> void:
	if AudioManager.speech_recorder == null or not AudioManager.speech_recorder.has_recording():
		_status_lbl.text = "Bé hãy ghi âm giọng nói trước khi nhấn Gửi đánh giá nhé!"
		return
	var payload := AudioManager.speech_recorder.get_recorded_audio_base64()
	var acc := SettingsManager.preferred_accent
	if AudioManager.speech_recognition != null:
		AudioManager.speech_recognition.recognize_audio(payload, _target_text, acc, _learning_content_id)
	if AudioManager.pronunciation_assessment != null:
		AudioManager.pronunciation_assessment.assess_pronunciation(payload, _target_text, _learning_content_id, acc)


func _on_stt_completed(res: Dictionary) -> void:
	if not is_inside_tree():
		return
	_last_stt_result = res


func _on_assessment_completed(res: Dictionary) -> void:
	if not is_inside_tree():
		return
	_last_pron_result = res
	if AudioManager.pronunciation_feedback == null:
		return
	var fb := AudioManager.pronunciation_feedback.build_feedback(res)
	var lines: PackedStringArray = []
	if not str(fb.get("mock_banner", "")).is_empty():
		lines.append(str(fb.get("mock_banner", "")))
	lines.append("%s — %s" % [str(fb.get("headline_en", "")), str(fb.get("headline_vi", ""))])
	var rec_txt := str(fb.get("recognized_text", ""))
	if not rec_txt.is_empty():
		lines.append("Nội dung nhận diện (STT): \"%s\"" % rec_txt)
	var metrics: Array = fb.get("metric_lines", [])
	if not metrics.is_empty():
		lines.append("Chỉ số từ dịch vụ AI: " + " | ".join(PackedStringArray(metrics)))
	var tips: Array = fb.get("phoneme_tips_vi", [])
	for t in tips:
		lines.append("• " + str(t))
	_feedback_lbl.text = "\n".join(lines)
	_feedback_box.visible = true
	_status_lbl.text = str(res.get("message_vi", fb.get("headline_vi", "")))


func _emit_complete(choice: String) -> void:
	if AudioManager.speech_recorder != null and AudioManager.speech_recorder.is_recording():
		AudioManager.speech_recorder.stop_recording()
	practice_completed.emit(choice, {
		"practice_mode": "ai_assisted" if not _last_pron_result.is_empty() and bool(_last_pron_result.get("overall_score", null) != null) else "self_practice",
		"listened_model": _listened_model,
		"replayed_own": _replayed_own,
		"attempts": maxi(1, _attempt_count),
		"recording_summary": _last_rec_summary,
		"stt_result": _last_stt_result,
		"pronunciation_result": _last_pron_result
	})


func _refresh_controls() -> void:
	var rec := AudioManager.speech_recorder
	var cap: Dictionary = rec.get_capability_report() if rec != null else {}
	var mic_ok := bool(cap.get("mic_recording_available", false))
	var is_rec := rec != null and rec.is_recording()
	var is_paused := rec != null and rec.is_paused()
	var has_rec := rec != null and rec.has_recording()

	_perm_btn.visible = mic_ok and str(cap.get("permission_state", "unknown")) != "granted"
	_rec_btn.disabled = (not mic_ok) or is_rec
	_pause_btn.visible = is_rec
	_pause_btn.text = "Tiếp tục" if is_paused else "Tạm dừng"
	_stop_btn.disabled = not is_rec
	_replay_btn.disabled = (not has_rec) or is_rec
	_rerecord_btn.disabled = (not has_rec) or is_rec
	_cancel_btn.disabled = (not has_rec) and (not is_rec)
	_submit_ai_btn.disabled = (not has_rec) or is_rec
	_done_ok_btn.visible = _allow_completion_buttons
	_done_retry_btn.visible = _allow_completion_buttons

	if _status_lbl.text.is_empty():
		if mic_ok:
			_status_lbl.text = str(cap.get("privacy_notice_vi", "Microphone sẵn sàng! Nhấn '2. Ghi âm' để thu giọng nói của bé."))
		else:
			_status_lbl.text = "Thiết bị chưa có Micro khả dụng; bé vẫn có thể nghe mẫu, đọc to theo & hoàn thành bài học!"


func _make_btn(label_txt: String, bg_col: Color, min_sz: Vector2) -> Button:
	var b := Button.new()
	b.text = label_txt
	b.custom_minimum_size = min_sz
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_col
	sb.set_corner_radius_all(12)
	sb.set_content_margin_all(8)
	b.add_theme_stylebox_override("normal", sb)
	var sb_hover := sb.duplicate() as StyleBoxFlat
	sb_hover.bg_color = bg_col.lightened(0.12)
	b.add_theme_stylebox_override("hover", sb_hover)
	var sb_dis := sb.duplicate() as StyleBoxFlat
	sb_dis.bg_color = Color(0.55, 0.58, 0.64, 0.65)
	b.add_theme_stylebox_override("disabled", sb_dis)
	b.add_theme_font_size_override("font_size", 15)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_disabled_color", Color(0.9, 0.92, 0.95, 0.8))
	return b
