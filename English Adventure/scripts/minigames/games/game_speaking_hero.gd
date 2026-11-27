class_name GameSpeakingHero
extends MiniGameController
## GAME 06 - SPEAKING HERO (Anh hùng luyện nói)
## Skill: Speaking
## Integrates SpeakingPracticePanel (Model Audio, SpeechRecorder, Replay, Explicit AI Submit,
## Honest AI Pronunciation Assessment status — NEVER fakes AI scores).

var _current_item: Dictionary = {}
var _resolved: bool = false
var _cap_report: Dictionary = {}

var _prompt_lbl: Label
var _target_lbl: Label
var _ipa_lbl: Label
var _mouth_lbl: Label
var _ai_status_lbl: Label
var _image_rect: TextureRect
var _practice_panel: SpeakingPracticePanel


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cap_report = LearningEngine.speaking_manager.get_capability_report()

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	_ai_status_lbl = Label.new()
	_ai_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ai_status_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_ai_status_lbl.add_theme_font_size_override("font_size", 14)
	_ai_status_lbl.add_theme_color_override("font_color", Color(0.65, 0.34, 0.08, 1))
	_ai_status_lbl.text = str(_cap_report.get("status_vi", "Chấm điểm phát âm AI đang chờ tích hợp dịch vụ ngoài — không chấm điểm giả."))
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
	_image_rect.custom_minimum_size = Vector2(96, 96)
	_image_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	card_hb.add_child(_image_rect)

	var text_vb := VBoxContainer.new()
	text_vb.alignment = BoxContainer.ALIGNMENT_CENTER
	text_vb.add_theme_constant_override("separation", 4)
	card_hb.add_child(text_vb)

	_target_lbl = Label.new()
	_target_lbl.add_theme_font_size_override("font_size", 28)
	_target_lbl.add_theme_color_override("font_color", Color(0.12, 0.28, 0.56, 1))
	text_vb.add_child(_target_lbl)

	_ipa_lbl = Label.new()
	_ipa_lbl.add_theme_font_size_override("font_size", 17)
	_ipa_lbl.add_theme_color_override("font_color", Color(0.32, 0.36, 0.48, 1))
	text_vb.add_child(_ipa_lbl)

	_mouth_lbl = Label.new()
	_mouth_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_mouth_lbl.custom_minimum_size = Vector2(460, 0)
	_mouth_lbl.add_theme_font_size_override("font_size", 15)
	_mouth_lbl.add_theme_color_override("font_color", Color(0.22, 0.42, 0.28, 1))
	text_vb.add_child(_mouth_lbl)

	_practice_panel = SpeakingPracticePanel.new()
	_practice_panel.practice_completed.connect(_complete_self_practice)
	root.add_child(_practice_panel)


func render_item(item: Dictionary, index: int, total: int) -> void:
	_current_item = item
	_resolved = false
	_cap_report = LearningEngine.speaking_manager.get_capability_report()
	_ai_status_lbl.text = str(_cap_report.get("status_vi", "Chấm điểm phát âm AI đang chờ tích hợp dịch vụ ngoài."))

	_prompt_lbl.text = "Thử thách nói %d/%d — %s" % [index + 1, total, str(item.get("prompt_vi", ""))]
	_target_lbl.text = str(item.get("target_text_en", ""))
	var meaning := str(item.get("meaning_vi", ""))
	_ipa_lbl.text = "%s%s" % [str(item.get("ipa", "")), (" — " + meaning if not meaning.is_empty() else "")]
	_mouth_lbl.text = "Mẹo khẩu hình: %s" % str(item.get("mouth_hint_vi", ""))

	var tex := _load_vocab_texture(str(item.get("image_path", "")))
	_image_rect.visible = tex != null
	_image_rect.texture = tex

	_practice_panel.setup_item(item, true)
	status_hint_changed.emit("Nghe mẫu, ghi âm, nghe lại giọng bé; AI chấm phát âm chỉ chấm khi có dịch vụ thật.")
	_play_model()


func _play_model() -> void:
	if audio == null or _current_item.is_empty():
		return
	var spoken := str(_current_item.get("spoken_text_en", _current_item.get("target_text_en", "")))
	if spoken.is_empty():
		spoken = str(_current_item.get("target_text_en", ""))
	audio.play_word_or_sentence(str(_current_item.get("audio_path", "")), spoken)


func _complete_self_practice(confidence_choice: String, extra_session_data: Dictionary = {}) -> void:
	if _resolved or session == null:
		return
	var eval := LearningEngine.speaking_manager.mark_self_practiced(_current_item, confidence_choice, extra_session_data)
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
		"%s (%s)" % [target, str(_current_item.get("ipa", ""))],
		str(_current_item.get("audio_path", "")),
		target
	)
	round_feedback_ready.emit(fb)
