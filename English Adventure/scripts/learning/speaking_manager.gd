class_name SpeakingManager
extends RefCounted
## Manages Speaking practice: model pronunciation playback, prompt display,
## optional microphone recording + self-playback, and honest experimental status
## for future AI Pronunciation Assessment (never faking AI scores).

var _repo: LearningContentRepository
var _recorded_stream: AudioStreamWAV = null
var _has_recording: bool = false
var _is_recording: bool = false


func _init(repo: LearningContentRepository) -> void:
	_repo = repo


func get_all_items() -> Array[Dictionary]:
	return _repo.speaking_ordered


func get_item(item_id: String) -> Dictionary:
	return _repo.speaking_by_id.get(item_id, {})


func get_capability_report() -> Dictionary:
	var devices := AudioServer.get_input_device_list()
	var has_mic := (not OS.has_feature("web")) and devices.size() > 0
	return {
		"model_audio_supported": true,
		"self_practice_supported": true,
		"mic_recording_available": has_mic,
		"ai_pronunciation_scoring_available": false,
		"status_vi": "Hoạt động: Xem chữ/IPA, nghe mẫu & tự luyện nói. Chức năng chấm điểm phát âm AI đang ở trạng thái Thử nghiệm (chưa tích hợp dịch vụ ASR/AI)."
	}


func mark_self_practiced(item: Dictionary, confidence_choice: String) -> Dictionary:
	var target := str(item.get("target_text_en", ""))
	return {
		"is_correct": confidence_choice != "need_more_practice",
		"correct_answer": target,
		"explanation_vi": "Bé đã tự luyện phát âm '%s'. %s (Lưu ý: AI chấm phát âm tự động chưa kích hoạt, kết quả này ghi nhận nỗ lực tự luyện của bé)." % [
			target,
			str(item.get("mouth_hint_vi", ""))
		],
		"word_id": str(item.get("word_id", "")),
		"ai_scoring_status": "not_integrated_experimental"
	}


func play_recorded_sample() -> bool:
	if not _has_recording or _recorded_stream == null:
		return false
	return true
