class_name AudioAssetManager
extends RefCounted
## Manages audio asset registry (data/audio/audio_manifest.json), offline cache paths
## (user://audio_cache/), missing-asset audits, and verified local stream loading.
## Never fabricates fake res:// paths or claims unbundled assets exist.

const MANIFEST_PATH := "res://data/audio/audio_manifest.json"
const CACHE_DIR := "user://audio_cache/"

var _assets_by_id: Dictionary = {}
var _assets_by_path: Dictionary = {}
var _stream_cache: Dictionary = {}
var _missing_assets: Array[Dictionary] = []


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(CACHE_DIR)
	reload_manifest()


func reload_manifest() -> void:
	_assets_by_id.clear()
	_assets_by_path.clear()
	_missing_assets.clear()
	if not FileAccess.file_exists(MANIFEST_PATH):
		AppLogger.warn("AudioAssetManager", "Audio manifest not found: " + MANIFEST_PATH)
		return
	var f := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var doc: Dictionary = parsed
	var arr: Array = doc.get("assets", [])
	for item_var in arr:
		if typeof(item_var) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = item_var
		var aid := str(item.get("audio_id", ""))
		var apath := str(item.get("path", ""))
		if aid.is_empty():
			continue
		var verified := false
		if not apath.is_empty() and ResourceLoader.exists(apath):
			verified = true
		var rec := item.duplicate(true)
		rec["verified_on_disk"] = verified
		_assets_by_id[aid] = rec
		if not apath.is_empty():
			_assets_by_path[apath] = rec
		if not verified and str(item.get("status", "")) == "bundled_verified":
			_missing_assets.append(rec)


func has_asset(audio_id: String) -> bool:
	if not _assets_by_id.has(audio_id):
		return false
	var rec: Dictionary = _assets_by_id[audio_id]
	return bool(rec.get("verified_on_disk", false))


func get_asset_metadata(audio_id: String) -> Dictionary:
	return (_assets_by_id.get(audio_id, {}) as Dictionary).duplicate(true)


func get_all_assets() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for k in _assets_by_id.keys():
		out.append((_assets_by_id[k] as Dictionary).duplicate(true))
	return out


func get_missing_assets() -> Array[Dictionary]:
	return _missing_assets.duplicate(true)


func load_stream_by_id(audio_id: String, cache_in_memory: bool = true) -> AudioStream:
	if not _assets_by_id.has(audio_id):
		return null
	var rec: Dictionary = _assets_by_id[audio_id]
	var path := str(rec.get("path", ""))
	return load_stream_by_path(path, cache_in_memory)


func load_stream_by_path(audio_path: String, cache_in_memory: bool = true) -> AudioStream:
	if audio_path.is_empty():
		return null
	if _stream_cache.has(audio_path):
		return _stream_cache[audio_path] as AudioStream
	if ResourceLoader.exists(audio_path):
		var stream := load(audio_path) as AudioStream
		if stream != null and cache_in_memory:
			_stream_cache[audio_path] = stream
		return stream
	var cached := _try_load_cached_file(audio_path)
	if cached != null and cache_in_memory:
		_stream_cache[audio_path] = cached
	return cached


func get_offline_cache_path(audio_id: String, accent: String = "en-US", ext: String = "ogg") -> String:
	var safe_id := audio_id.replace("/", "_").replace("\\", "_")
	return "%s%s_%s.%s" % [CACHE_DIR, safe_id, accent, ext]


func has_offline_cached_audio(audio_id: String, accent: String = "en-US") -> bool:
	for ext in ["ogg", "wav", "mp3"]:
		if FileAccess.file_exists(get_offline_cache_path(audio_id, accent, ext)):
			return true
	return false


func _try_load_cached_file(path_or_id: String) -> AudioStream:
	if path_or_id.begins_with("user://") and FileAccess.file_exists(path_or_id):
		if path_or_id.ends_with(".ogg"):
			return AudioStreamOggVorbis.load_from_file(path_or_id)
		elif path_or_id.ends_with(".wav"):
			var bytes := FileAccess.get_file_as_bytes(path_or_id)
			if not bytes.is_empty():
				return _wav_bytes_to_stream(bytes)
	return null


func _wav_bytes_to_stream(bytes: PackedByteArray) -> AudioStreamWAV:
	if bytes.size() < 44:
		return null
	var wav := AudioStreamWAV.new()
	var channels := bytes.decode_u16(22)
	var sample_rate := bytes.decode_u32(24)
	var bits := bytes.decode_u16(34)
	wav.mix_rate = int(sample_rate)
	wav.stereo = (channels == 2)
	wav.format = AudioStreamWAV.FORMAT_16_BITS if bits == 16 else AudioStreamWAV.FORMAT_8_BITS
	wav.data = bytes.slice(44)
	return wav


func get_audit_summary() -> Dictionary:
	var bundled := 0
	var by_cat: Dictionary = {}
	for k in _assets_by_id.keys():
		var rec: Dictionary = _assets_by_id[k]
		var cat := str(rec.get("category", "other"))
		by_cat[cat] = int(by_cat.get(cat, 0)) + 1
		if bool(rec.get("verified_on_disk", false)):
			bundled += 1
	return {
		"total_registered": _assets_by_id.size(),
		"bundled_verified": bundled,
		"missing_declared": _missing_assets.size(),
		"categories": by_cat
	}
