class_name SpeakingManager
extends RefCounted
## Manages Speaking practice: model pronunciation playback, prompt display,
## cross-platform microphone recording + self-playback via SpeechRecorder,
## optional STT / AI Pronunciation Assessment integration via AudioManager adapters,
## and honest progress logging (never faking AI scores).

var _repo: LearningContentRepository
var _session_history: Array[Dictionary] = []


func _init(repo: LearningContentRepository) -> void:
	_repo = repo


func get_all_items() -> Array[Dictionary]:
	return _repo.speaking_ordered


func get_item(item_id: String) -> Dictionary:
	return _repo.speaking_by_id.get(item_id, {})


func get_capability_report() -> Dictionary:
	var rec_cap: Dictionary = AudioManager.speech_recorder.get_capability_report() if AudioManager.speech_recorder != null else {}
	var has_mic := bool(rec_cap.get("mic_recording_available", false))
	var stt_ready := AudioManager.speech_recognition != null and AudioManager.speech_recognition.is_real_service_configured()
	var ai_ready := AudioManager.pronunciation_assessment != null and AudioManager.pronunciation_assessment.is_real_service_configured()
	return {
		"model_audio_supported": true,
		"self_practice_supported": true,
		"mic_recording_available": has_mic,
		"stt_service_configured": stt_ready,
		"ai_pronunciation_scoring_available": ai_ready,
		"platform": str(rec_cap.get("platform", "unknown")),
		"privacy_notice_vi": str(rec_cap.get("privacy_notice_vi", "")),
		"status_vi": _build_status_summary(has_mic, stt_ready, ai_ready)
	}


func _build_status_summary(has_mic: bool, stt_ready: bool, ai_ready: bool) -> String:
	if ai_ready:
		return "Hoạt động: Nghe mẫu, ghi âm, nghe lại và AI chấm phát âm (qua máy chủ bảo mật)."
	if has_mic and stt_ready:
		return "Hoạt động: Nghe mẫu, ghi âm, nghe lại & nhận diện chữ (STT). AI chấm phát âm chi tiết đang chờ kích hoạt."
	if has_mic:
		return "Hoạt động: Nghe mẫu, ghi âm & nghe lại giọng bé. AI chấm phát âm (Pronunciation Assessment) đang chờ kết nối dịch vụ — không chấm điểm giả."
	return "Hoạt động: Nghe mẫu & tự luyện nói. Thiết bị chưa sẵn sàng ghi âm; AI chấm phát âm đang chờ tích hợp dịch vụ."


func mark_self_practiced(item: Dictionary, confidence_choice: String, extra_session_data: Dictionary = {}) -> Dictionary:
	var target := str(item.get("target_text_en", ""))
	var is_ok := confidence_choice != "need_more_practice"
	var assessment_res: Dictionary = extra_session_data.get("pronunciation_result", {})
	var stt_res: Dictionary = extra_session_data.get("stt_result", {})
	var rec_summary: Dictionary = extra_session_data.get("recording_summary", {})
	var practice_mode := str(extra_session_data.get("practice_mode", "self_practice"))

	var session_log := {
		"player_id": GameStateManager.profile_id,
		"learning_content_id": str(item.get("id", item.get("word_id", ""))),
		"word_id": str(item.get("word_id", "")),
		"recording_session_id": str(rec_summary.get("session_id", "")),
		"practice_mode": practice_mode,
		"expected_text": target,
		"recognized_text": str(stt_res.get("recognized_text", assessment_res.get("recognized_text", ""))),
		"pronunciation_result": assessment_res if not assessment_res.is_empty() else null,
		"listened_model": bool(extra_session_data.get("listened_model", true)),
		"recorded_audio": bool(rec_summary.get("has_recording", false)),
		"replayed_own": bool(extra_session_data.get("replayed_own", false)),
		"attempts": int(extra_session_data.get("attempts", 1)),
		"assessment_status": str(assessment_res.get("assessment_status", "self_practiced")),
		"completed_at": Time.get_datetime_string_from_system(true)
	}
	_session_history.append(session_log)
	if _session_history.size() > 100:
		_session_history = _session_history.slice(_session_history.size() - 100, _session_history.size())

	if SaveLoadManager != null:
		SaveLoadManager.enqueue_sync_event("speaking_practice_session", session_log)

	var ai_status := str(assessment_res.get("assessment_status", "not_integrated_experimental"))
	var expl := "Bé đã luyện phát âm '%s'. %s" % [target, str(item.get("mouth_hint_vi", ""))]
	if assessment_res.is_empty():
		expl += " (Ghi chú: AI chấm phát âm chưa kích hoạt, hệ thống chỉ ghi nhận quá trình luyện tập thực tế của bé.)"

	return {
		"is_correct": is_ok,
		"correct_answer": target,
		"explanation_vi": expl,
		"word_id": str(item.get("word_id", "")),
		"ai_scoring_status": ai_status,
		"session_log": session_log
	}


func get_recent_sessions() -> Array[Dictionary]:
	return _session_history.duplicate(true)


func play_recorded_sample() -> bool:
	if AudioManager.speech_recorder != null:
		return AudioManager.speech_recorder.replay_recording()
	return false
