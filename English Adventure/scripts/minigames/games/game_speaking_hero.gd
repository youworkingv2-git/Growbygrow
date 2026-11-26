class_name GameSpeakingHero
extends MiniGameController
## GAME 06 - SPEAKING HERO (Anh hùng luyện nói)
## Skill: Speaking
## Strictly separates:
## 1) Model Audio Playback
## 2) Local Microphone Recording & Playback (when AudioServer input exists on native)
## 3) Speech Recognition / AI Pronunciation Assessment (explicitly marked Pending Integration; NEVER faked).

var _current_item: Dictionary = {}
var _resolved: bool = false
var _cap_report: Dictionary = {}

var _record_bus_idx: int = -1
var _record_effect: AudioEffectRecord = null
var _recorded_stream: AudioStreamWAV = null
var _is_recording: bool = false
var _mic_player: AudioStreamPlayer = null
var _playback_player: AudioStreamPlayer = null

var _prompt_lbl: Label
var _target_lbl: Label
var _ipa_lbl: Label
var _mouth_lbl: Label
var _ai_status_lbl: Label
var _rec_status_lbl: Label
var _image_rect: TextureRect
var _rec_btn: Button
var _play_own_btn: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cap_report = LearningEngine.speaking_manager.get_capability_report()

	_playback_player = AudioStreamPlayer.new()
	_playback_player.bus = AudioManager.BUS_VOICE
	add_child(_playback_player)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	_ai_status_lbl = Label.new()
	_ai_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ai_status_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_ai_status_lbl.add_theme_font_size_override("font_size", 14)
	_ai_status_lbl.add_theme_color_override("font_color", Color(0.65, 0.34, 0.08, 1))
	_ai_status_lbl.text = "Trạng thái hệ thống: Đã có nghe mẫu & tự luyện (ghi âm khi thiết bị hỗ trợ). Chấm điểm phát âm AI (ASR/Pronunciation Scoring) đang chờ tích hợp dịch vụ ngoài — không chấm điểm giả."
	root.add_child(_ai_status_lbl)

	_prompt_lbl = Label.new()
	_prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_lbl.add_theme_font_size_override("font_size", 20)
	_prompt_lbl.add_theme_color_override("font_color", Color(0.14, 0.2, 0.34, 1))
	root.add_child(_prompt_lbl)

	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _make_fantasy_card(Color(0.99, 0.97, 0.92, 1), Color(0.78, 0.62, 0.28, 1), 18))
	root.add_child(card)

	var card_hb := HBoxContainer.new()
	card_hb.alignment = BoxContainer.ALIGNMENT_CENTER
	card_hb.add_theme_constant_override("separation", 20)
	card.add_child(card_hb)

	_image_rect = TextureRect.new()
	_image_rect.custom_minimum_size = Vector2(105, 105)
	_image_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	card_hb.add_child(_image_rect)

	var text_vb := VBoxContainer.new()
	text_vb.alignment = BoxContainer.ALIGNMENT_CENTER
	text_vb.add_theme_constant_override("separation", 6)
	card_hb.add_child(text_vb)

	_target_lbl = Label.new()
	_target_lbl.add_theme_font_size_override("font_size", 30)
	_target_lbl.add_theme_color_override("font_color", Color(0.12, 0.28, 0.56, 1))
	text_vb.add_child(_target_lbl)

	_ipa_lbl = Label.new()
	_ipa_lbl.add_theme_font_size_override("font_size", 18)
	_ipa_lbl.add_theme_color_override("font_color", Color(0.32, 0.36, 0.48, 1))
	text_vb.add_child(_ipa_lbl)

	_mouth_lbl = Label.new()
	_mouth_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_mouth_lbl.custom_minimum_size = Vector2(460, 0)
	_mouth_lbl.add_theme_font_size_override("font_size", 16)
	_mouth_lbl.add_theme_color_override("font_color", Color(0.22, 0.42, 0.28, 1))
	text_vb.add_child(_mouth_lbl)

	var rec_row := HBoxContainer.new()
	rec_row.alignment = BoxContainer.ALIGNMENT_CENTER
	rec_row.add_theme_constant_override("separation", 12)
	root.add_child(rec_row)

	var model_btn := _make_action_button("1. Nghe mẫu", Color(0.15, 0.52, 0.86, 1))
	model_btn.pressed.connect(_play_model)
	rec_row.add_child(model_btn)

	_rec_btn = _make_action_button("2. Ghi âm giọng bé", Color(0.78, 0.28, 0.24, 1))
	_rec_btn.pressed.connect(_toggle_recording)
	rec_row.add_child(_rec_btn)

	_play_own_btn = _make_action_button("3. Nghe lại bản ghi", Color(0.46, 0.4, 0.72, 1))
	_play_own_btn.disabled = true
	_play_own_btn.pressed.connect(_play_own_recording)
	rec_row.add_child(_play_own_btn)

	_rec_status_lbl = Label.new()
	_rec_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_rec_status_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_rec_status_lbl.add_theme_font_size_override("font_size", 15)
	_rec_status_lbl.add_theme_color_override("font_color", Color(0.28, 0.34, 0.44, 1))
	root.add_child(_rec_status_lbl)

	var practice_row := HBoxContainer.new()
	practice_row.alignment = BoxContainer.ALIGNMENT_CENTER
	practice_row.add_theme_constant_override("separation", 14)
	root.add_child(practice_row)

	var confident_btn := _make_action_button("Mình đã nói to, rõ rồi!", Color(0.16, 0.64, 0.34, 1))
	confident_btn.pressed.connect(func() -> void:
		_complete_self_practice("confident")
	)
	practice_row.add_child(confident_btn)

	var retry_btn := _make_action_button("Cần luyện thêm câu này", Color(0.82, 0.54, 0.16, 1))
	retry_btn.pressed.connect(func() -> void:
		_complete_self_practice("need_more_practice")
	)
	practice_row.add_child(retry_btn)


func render_item(item: Dictionary, index: int, total: int) -> void:
	_current_item = item
	_resolved = false
	_recorded_stream = null
	_play_own_btn.disabled = true
	if _is_recording:
		_stop_recording()

	_prompt_lbl.text = "Thử thách nói %d/%d — %s" % [index + 1, total, str(item.get("prompt_vi", ""))]
	_target_lbl.text = str(item.get("target_text_en", ""))
	var meaning := str(item.get("meaning_vi", ""))
	_ipa_lbl.text = "%s%s" % [str(item.get("ipa", "")), (" — " + meaning if not meaning.is_empty() else "")]
	_mouth_lbl.text = "Mẹo khẩu hình: %s" % str(item.get("mouth_hint_vi", ""))

	var tex := _load_vocab_texture(str(item.get("image_path", "")))
	_image_rect.visible = tex != null
	_image_rect.texture = tex

	var has_mic := bool(_cap_report.get("mic_recording_available", false))
	_rec_btn.disabled = not has_mic
	if has_mic:
		_rec_status_lbl.text = "Microphone sẵn sàng! Nhấn 'Ghi âm giọng bé', nói theo mẫu, rồi nghe lại để tự đối chiếu."
	else:
		_rec_status_lbl.text = "Ghi âm trực tiếp chưa khả dụng trên nền tảng Web/thiết bị không có Mic; bé hãy nghe mẫu & đọc to thành tiếng nhé!"
	status_hint_changed.emit("AI Pronunciation Scoring đang chờ tích hợp; tiến trình tự luyện vẫn được ghi nhận.")
	_play_model()


func _play_model() -> void:
	if audio == null or _current_item.is_empty():
		return
	audio.play_word_or_sentence(str(_current_item.get("audio_path", "")), str(_current_item.get("target_text_en", "")))


func _toggle_recording() -> void:
	if _is_recording:
		_stop_recording()
	else:
		_start_recording()


func _start_recording() -> void:
	if OS.has_feature("web") or AudioServer.get_input_device_list().is_empty():
		_rec_status_lbl.text = "Thiết bị hiện tại chưa hỗ trợ thu âm trực tiếp."
		return
	_ensure_record_bus()
	if _record_effect == null:
		return
	if _mic_player == null:
		_mic_player = AudioStreamPlayer.new()
		_mic_player.stream = AudioStreamMicrophone.new()
		_mic_player.bus = "Record"
		add_child(_mic_player)
	_mic_player.play()
	_record_effect.set_recording_active(true)
	_is_recording = true
	_rec_btn.text = "Dừng ghi âm"
	_rec_status_lbl.text = "Đang ghi âm... Hãy nói câu mẫu!"


func _stop_recording() -> void:
	_is_recording = false
	_rec_btn.text = "2. Ghi âm lại"
	if _record_effect != null and _record_effect.is_recording_active():
		_record_effect.set_recording_active(false)
		_recorded_stream = _record_effect.get_recording()
	if _mic_player != null and _mic_player.playing:
		_mic_player.stop()
	_play_own_btn.disabled = (_recorded_stream == null)
	_rec_status_lbl.text = "Đã lưu bản ghi âm! Nhấn '3. Nghe lại bản ghi' để tự kiểm tra phát âm." if _recorded_stream != null else "Chưa thu được âm thanh, bé thử lại nhé."


func _play_own_recording() -> void:
	if _recorded_stream == null:
		return
	_playback_player.stream = _recorded_stream
	_playback_player.play()


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


func _complete_self_practice(confidence_choice: String) -> void:
	if _resolved or session == null:
		return
	if _is_recording:
		_stop_recording()
	var eval := LearningEngine.speaking_manager.mark_self_practiced(_current_item, confidence_choice)
	var is_ok := bool(eval.get("is_correct", true))
	audio.play_sfx("correct" if is_ok else "click")
	_resolved = true

	var target := str(_current_item.get("target_text_en", ""))
	var fb := session.record_answer(
		confidence_choice,
		is_ok,
		target,
		str(_current_item.get("meaning_vi", "")),
		str(eval.get("explanation_vi", "")),
		target,
		str(_current_item.get("audio_path", "")),
		target
	)
	fb["can_proceed"] = true
	fb["allow_retry"] = not is_ok
	round_feedback_ready.emit(fb)
