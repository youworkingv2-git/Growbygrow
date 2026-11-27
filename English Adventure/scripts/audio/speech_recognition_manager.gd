class_name SpeechRecognitionManager
extends Node
## Speech-to-Text (STT) Adapter.
## STRICT PRINCIPLE: Speech Recognition ONLY transcribes what the user said.
## Recognizing the target word does NOT equal accurate pronunciation scoring!
## Never fabricates transcripts in normal gameplay; dev mock mode must be explicitly enabled for tests.

signal recognition_completed(result: Dictionary)

enum ProviderMode {
	DISABLED,
	SUPABASE_PROXY,
	MOCK_DEV_ONLY
}

var provider_mode: ProviderMode = ProviderMode.DISABLED
var supabase_edge_url: String = "" # e.g. "https://<project>.supabase.co/functions/v1/speech-recognize"
var _http: HTTPRequest = null
var _pending_context: Dictionary = {}


func _ready() -> void:
	_http = HTTPRequest.new()
	_http.timeout = 18.0
	_http.request_completed.connect(_on_http_completed)
	add_child(_http)


func configure_supabase_proxy(edge_function_url: String) -> void:
	supabase_edge_url = edge_function_url.strip_edges()
	provider_mode = ProviderMode.SUPABASE_PROXY if not supabase_edge_url.is_empty() else ProviderMode.DISABLED


func enable_dev_mock_mode(enabled: bool) -> void:
	# Safety guard: never allow mock mode in release exports
	if not OS.is_debug_build() and enabled:
		AppLogger.warn("SpeechRecognitionManager", "Mock STT mode is blocked outside debug/test builds.")
		return
	provider_mode = ProviderMode.MOCK_DEV_ONLY if enabled else (ProviderMode.SUPABASE_PROXY if not supabase_edge_url.is_empty() else ProviderMode.DISABLED)


func is_real_service_configured() -> bool:
	return provider_mode == ProviderMode.SUPABASE_PROXY and not supabase_edge_url.is_empty()


func recognize_audio(
	audio_payload: Dictionary,
	expected_text: String,
	accent: String = "en-US",
	learning_content_id: String = "",
	auth_bearer_token: String = ""
) -> void:
	if audio_payload.is_empty() or str(audio_payload.get("base64", "")).is_empty():
		_emit_result({
			"status": "no_audio",
			"recognized_text": "",
			"expected_text": expected_text,
			"matches_expected": null,
			"provider": "none",
			"is_mock": false,
			"message_vi": "Chưa có dữ liệu ghi âm để nhận diện."
		})
		return

	if not SaveLoadManager.is_online and provider_mode == ProviderMode.SUPABASE_PROXY:
		_emit_result({
			"status": "offline",
			"recognized_text": "",
			"expected_text": expected_text,
			"matches_expected": null,
			"provider": "none",
			"is_mock": false,
			"message_vi": "Đang ngoại tuyến (Offline): Không thể gửi nhận diện giọng nói lúc này."
		})
		return

	if provider_mode == ProviderMode.DISABLED:
		_emit_result({
			"status": "provider_unavailable",
			"recognized_text": "",
			"expected_text": expected_text,
			"matches_expected": null,
			"provider": "none",
			"is_mock": false,
			"message_vi": "Dịch vụ Speech Recognition (STT) chưa được kết nối máy chủ."
		})
		return

	if provider_mode == ProviderMode.MOCK_DEV_ONLY:
		# Explicitly tagged MOCK for automated/dev test harnesses ONLY
		_emit_result({
			"status": "mock_recognized",
			"recognized_text": expected_text,
			"expected_text": expected_text,
			"matches_expected": true,
			"provider": "MOCK_STT_DEV_ONLY",
			"is_mock": true,
			"note_pronunciation_warning_vi": "MOCK STT chỉ mô phỏng nhận diện chữ, KHÔNG phải đánh giá phát âm.",
			"message_vi": "[MOCK - Kiểm thử] Văn bản nhận diện mô phỏng: '%s'" % expected_text
		})
		return

	# SUPABASE_PROXY mode: never sends Azure/Google API keys from Godot client
	_pending_context = {
		"expected_text": expected_text,
		"learning_content_id": learning_content_id,
		"accent": accent
	}
	var headers := PackedStringArray(["Content-Type: application/json"])
	if not auth_bearer_token.is_empty():
		headers.append("Authorization: Bearer " + auth_bearer_token)
	var body := JSON.stringify({
		"audio_base64": str(audio_payload.get("base64", "")),
		"mime_type": str(audio_payload.get("mime_type", "audio/wav")),
		"language": accent,
		"expected_text": expected_text,
		"learning_content_id": learning_content_id
	})
	var err := _http.request(supabase_edge_url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		_emit_result({
			"status": "network_error",
			"recognized_text": "",
			"expected_text": expected_text,
			"matches_expected": null,
			"provider": "supabase_proxy",
			"is_mock": false,
			"message_vi": "Không gửi được yêu cầu nhận diện giọng nói (lỗi kết nối)."
		})


func _on_http_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var expected := str(_pending_context.get("expected_text", ""))
	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		_emit_result({
			"status": "service_error",
			"http_code": response_code,
			"recognized_text": "",
			"expected_text": expected,
			"matches_expected": null,
			"provider": "supabase_proxy",
			"is_mock": false,
			"message_vi": "Dịch vụ nhận diện giọng nói đang bận hoặc chưa khả dụng (HTTP %d)." % response_code
		})
		return

	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if typeof(parsed) != TYPE_DICTIONARY:
		_emit_result({
			"status": "invalid_response",
			"recognized_text": "",
			"expected_text": expected,
			"matches_expected": null,
			"provider": "supabase_proxy",
			"is_mock": false,
			"message_vi": "Phản hồi từ dịch vụ nhận diện không hợp lệ."
		})
		return

	var d: Dictionary = parsed
	var rec_text := str(d.get("recognized_text", "")).strip_edges()
	var recognized_ok := not rec_text.is_empty()
	var matched := _normalize_compare(rec_text) == _normalize_compare(expected) if recognized_ok else false
	_emit_result({
		"status": "recognized" if recognized_ok else "no_speech_detected",
		"recognized_text": rec_text,
		"expected_text": expected,
		"matches_expected": matched,
		"provider": str(d.get("provider", "supabase_proxy")),
		"is_mock": false,
		"message_vi": ("Nghe được: \"%s\"" % rec_text) if recognized_ok else "Hệ thống chưa nghe rõ lời nói hoặc có tiếng ồn, bé thử nói lại nhé."
	})


func _normalize_compare(txt: String) -> String:
	var s := txt.to_lower().strip_edges()
	for ch in [".", ",", "!", "?", "'", "\""]:
		s = s.replace(ch, "")
	return s


func _emit_result(res: Dictionary) -> void:
	recognition_completed.emit(res)
	EventBus.speech_recognition_completed.emit(res)
