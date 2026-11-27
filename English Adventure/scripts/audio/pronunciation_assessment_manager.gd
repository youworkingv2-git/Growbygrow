class_name PronunciationAssessmentManager
extends Node
## AI Pronunciation Assessment Adapter.
## Supports backend proxy integration (Supabase Edge Function -> Microsoft Azure AI Speech)
## and an explicit debug/test-only MOCK mode.
## STRICT RULES:
## - Never places API secrets in the Godot client.
## - Never fabricates AI pronunciation scores or phoneme errors when no real service responds.
## - Unsupported/unavailable metrics remain null in PronunciationResult.

signal assessment_completed(result: Dictionary)

enum ProviderMode {
	DISABLED,
	SUPABASE_PROXY,
	MOCK_DEV_ONLY
}

var provider_mode: ProviderMode = ProviderMode.DISABLED
var supabase_edge_url: String = "" # e.g. "https://<project>.supabase.co/functions/v1/pronunciation-assess"
var _http: HTTPRequest = null
var _pending_ctx: Dictionary = {}


func _ready() -> void:
	_http = HTTPRequest.new()
	_http.timeout = 22.0
	_http.request_completed.connect(_on_http_completed)
	add_child(_http)


func configure_supabase_proxy(edge_function_url: String) -> void:
	supabase_edge_url = edge_function_url.strip_edges()
	provider_mode = ProviderMode.SUPABASE_PROXY if not supabase_edge_url.is_empty() else ProviderMode.DISABLED


func enable_dev_mock_mode(enabled: bool) -> void:
	if not OS.is_debug_build() and enabled:
		AppLogger.warn("PronunciationAssessmentManager", "Mock AI assessment mode is blocked in non-debug builds.")
		return
	provider_mode = ProviderMode.MOCK_DEV_ONLY if enabled else (ProviderMode.SUPABASE_PROXY if not supabase_edge_url.is_empty() else ProviderMode.DISABLED)


func is_real_service_configured() -> bool:
	return provider_mode == ProviderMode.SUPABASE_PROXY and not supabase_edge_url.is_empty()


func create_empty_result(
	player_id: String,
	learning_content_id: String,
	expected_text: String,
	provider_name: String,
	status: String,
	is_mock: bool = false
) -> Dictionary:
	return {
		"assessment_id": "pa_%d_%d" % [Time.get_unix_time_from_system(), randi() % 10000],
		"player_id": player_id,
		"learning_content_id": learning_content_id,
		"expected_text": expected_text,
		"recognized_text": "",
		"overall_score": null,
		"accuracy_score": null,
		"fluency_score": null,
		"completeness_score": null,
		"prosody_score": null,
		"word_feedback": [],
		"phoneme_feedback": [],
		"provider": provider_name,
		"assessment_status": status,
		"is_mock": is_mock,
		"created_at": Time.get_datetime_string_from_system(true)
	}


func assess_pronunciation(
	audio_payload: Dictionary,
	expected_text: String,
	learning_content_id: String,
	accent: String = "en-US",
	auth_bearer_token: String = ""
) -> void:
	var pid := GameStateManager.profile_id
	if audio_payload.is_empty() or str(audio_payload.get("base64", "")).is_empty():
		var no_aud := create_empty_result(pid, learning_content_id, expected_text, "none", "no_audio", false)
		no_aud["message_vi"] = "Chưa có bản ghi âm để đánh giá phát âm."
		_emit_result(no_aud)
		return

	if not SaveLoadManager.is_online and provider_mode == ProviderMode.SUPABASE_PROXY:
		var off := create_empty_result(pid, learning_content_id, expected_text, "none", "offline", false)
		off["message_vi"] = "Đang ngoại tuyến (Offline): Tính năng AI chấm phát âm tạm thời không khả dụng; bản ghi của bé vẫn dùng để tự nghe lại."
		_emit_result(off)
		return

	if provider_mode == ProviderMode.DISABLED:
		var unavail := create_empty_result(pid, learning_content_id, expected_text, "none", "provider_unavailable", false)
		unavail["message_vi"] = "Chưa kết nối dịch vụ AI Pronunciation Assessment thực tế (Azure Speech Backend chưa cấu hình)."
		_emit_result(unavail)
		return

	if provider_mode == ProviderMode.MOCK_DEV_ONLY:
		# Explicitly labeled MOCK for automated/development verification only; NEVER shown as real AI
		var mock_res := create_empty_result(pid, learning_content_id, expected_text, "MOCK_DEV_ONLY", "mock_test_only", true)
		mock_res["recognized_text"] = expected_text
		mock_res["overall_score"] = 84.0
		mock_res["accuracy_score"] = 82.0
		mock_res["fluency_score"] = 88.0
		mock_res["completeness_score"] = 100.0
		mock_res["prosody_score"] = null
		mock_res["word_feedback"] = [{
			"word": expected_text,
			"accuracy_score": 82.0,
			"error_type": "None"
		}]
		mock_res["phoneme_feedback"] = []
		mock_res["message_vi"] = "[MOCK KIỂM THỬ] Dữ liệu mô phỏng cho nhà phát triển — KHÔNG phải kết quả AI thật."
		_emit_result(mock_res)
		return

	# SUPABASE_PROXY mode: securely forwards audio only after explicit Submit
	_pending_ctx = {
		"player_id": pid,
		"learning_content_id": learning_content_id,
		"expected_text": expected_text,
		"accent": accent
	}
	var headers := PackedStringArray(["Content-Type: application/json"])
	if not auth_bearer_token.is_empty():
		headers.append("Authorization: Bearer " + auth_bearer_token)
	var body := JSON.stringify({
		"audio_base64": str(audio_payload.get("base64", "")),
		"mime_type": str(audio_payload.get("mime_type", "audio/wav")),
		"expected_text": expected_text,
		"language": accent,
		"learning_content_id": learning_content_id
	})
	var err := _http.request(supabase_edge_url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		var net_err := create_empty_result(pid, learning_content_id, expected_text, "azure_speech_proxy", "network_error", false)
		net_err["message_vi"] = "Không thể kết nối tới máy chủ đánh giá phát âm."
		_emit_result(net_err)


func _on_http_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var pid := str(_pending_ctx.get("player_id", GameStateManager.profile_id))
	var cid := str(_pending_ctx.get("learning_content_id", ""))
	var expected := str(_pending_ctx.get("expected_text", ""))

	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		var status := "rate_limited" if response_code == 429 else "service_error"
		var err_res := create_empty_result(pid, cid, expected, "azure_speech_proxy", status, false)
		err_res["message_vi"] = "Đã vượt giới hạn lượt thử lúc này, bé thử lại sau ít phút nhé." if response_code == 429 else ("Dịch vụ đánh giá phát âm đang tạm gián đoạn (HTTP %d)." % response_code)
		_emit_result(err_res)
		return

	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if typeof(parsed) != TYPE_DICTIONARY:
		var inv := create_empty_result(pid, cid, expected, "azure_speech_proxy", "invalid_response", false)
		inv["message_vi"] = "Phản hồi từ dịch vụ đánh giá phát âm không hợp lệ."
		_emit_result(inv)
		return

	var d: Dictionary = parsed
	var out := create_empty_result(
		pid,
		cid,
		expected,
		str(d.get("provider", "azure_speech")),
		str(d.get("assessment_status", "assessed")),
		false
	)
	out["recognized_text"] = str(d.get("recognized_text", ""))
	out["overall_score"] = d.get("overall_score", null)
	out["accuracy_score"] = d.get("accuracy_score", null)
	out["fluency_score"] = d.get("fluency_score", null)
	out["completeness_score"] = d.get("completeness_score", null)
	out["prosody_score"] = d.get("prosody_score", null)
	out["word_feedback"] = d.get("word_feedback", [])
	out["phoneme_feedback"] = d.get("phoneme_feedback", [])
	out["message_vi"] = str(d.get("message_vi", ""))
	_emit_result(out)


func _emit_result(res: Dictionary) -> void:
	assessment_completed.emit(res)
	EventBus.pronunciation_assessment_completed.emit(res)
