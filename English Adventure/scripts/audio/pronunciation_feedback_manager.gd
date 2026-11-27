class_name PronunciationFeedbackManager
extends RefCounted
## Builds gentle, kid-friendly bilingual (EN + VI) feedback from PronunciationResult
## or local self-practice attempts.
## STRICT RULES:
## - Never shames or uses harsh negative language.
## - Never claims phoneme-level errors unless provider actually returned phoneme_feedback.
## - Never displays null scores as 0 or fake numbers.

func build_feedback(assessment_result: Dictionary) -> Dictionary:
	var status := str(assessment_result.get("assessment_status", "provider_unavailable"))
	var is_mock := bool(assessment_result.get("is_mock", false))
	var expected := str(assessment_result.get("expected_text", ""))
	var overall: Variant = assessment_result.get("overall_score", null)

	var metric_lines: Array[String] = []
	_append_metric_if_present(metric_lines, "Overall", overall)
	_append_metric_if_present(metric_lines, "Accuracy", assessment_result.get("accuracy_score", null))
	_append_metric_if_present(metric_lines, "Fluency", assessment_result.get("fluency_score", null))
	_append_metric_if_present(metric_lines, "Completeness", assessment_result.get("completeness_score", null))
	_append_metric_if_present(metric_lines, "Prosody", assessment_result.get("prosody_score", null))

	var headline_en := "Good effort! Keep practicing!"
	var headline_vi := "Bé đã luyện tập rất chăm chỉ! Hãy nghe lại mẫu và thử thêm nhé."

	if status == "offline":
		headline_en = "Offline Mode — Practice Recorded Locally"
		headline_vi = "Đang ngoại tuyến: AI chấm điểm tạm thời chưa kết nối được, nhưng bé vẫn nghe mẫu & nghe lại giọng mình bình thường!"
	elif status == "provider_unavailable":
		headline_en = "Self-Practice Recorded"
		headline_vi = "AI đánh giá phát âm chưa kích hoạt trên máy chủ. Bé hãy nghe lại bản ghi của mình và so sánh với giọng mẫu nhé!"
	elif overall != null:
		var score_f := float(overall)
		if score_f >= 80.0:
			headline_en = "Great job! Your pronunciation sounds good!"
			headline_vi = "Con làm tốt lắm! Phát âm rất rõ ràng!"
		elif score_f >= 60.0:
			headline_en = "Nice try! Let's listen and polish it together."
			headline_vi = "Khá lắm rồi! Hãy nghe lại mẫu và thử thêm một lần nữa nhé."
		else:
			headline_en = "Good try! Let's listen and practice again."
			headline_vi = "Cố gắng tốt lắm! Mình cùng nghe chậm lại và nói lại nhé."

	var phoneme_tips: Array[String] = []
	var phonemes: Array = assessment_result.get("phoneme_feedback", [])
	for ph_var in phonemes:
		if typeof(ph_var) != TYPE_DICTIONARY:
			continue
		var ph: Dictionary = ph_var
		var ph_score: Variant = ph.get("accuracy_score", null)
		var ph_sym := str(ph.get("phoneme", ""))
		if ph_score != null and float(ph_score) < 65.0 and not ph_sym.is_empty():
			phoneme_tips.append("Chú ý âm /%s/ trong '%s' (đọc chậm và rõ hơn một chút)." % [ph_sym, expected])
		if phoneme_tips.size() >= 2:
			break

	var words_highlight: Array[Dictionary] = []
	for w_var in assessment_result.get("word_feedback", []):
		if typeof(w_var) == TYPE_DICTIONARY:
			words_highlight.append(w_var as Dictionary)

	var mock_banner := "[DỮ LIỆU MOCK KIỂM THỬ — KHÔNG PHẢI KẾT QUẢ AI THẬT]" if is_mock else ""

	return {
		"headline_en": headline_en,
		"headline_vi": headline_vi,
		"mock_banner": mock_banner,
		"is_mock": is_mock,
		"metric_lines": metric_lines,
		"phoneme_tips_vi": phoneme_tips,
		"word_highlights": words_highlight,
		"recognized_text": str(assessment_result.get("recognized_text", "")),
		"can_retry": true,
		"can_complete": true
	}


func _append_metric_if_present(out: Array[String], label: String, val: Variant) -> void:
	if val == null:
		return
	out.append("%s: %d/100" % [label, int(round(float(val)))])
