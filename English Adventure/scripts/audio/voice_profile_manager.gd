class_name VoiceProfileManager
extends RefCounted
## Manages NPC & narrator voice profiles (Professor Owl, Buddy, Lily, Rocky, Crystal Guardian)
## and enforces consistent en-US / en-GB dialect selection without mixing arbitrarily.

const PROFILES_PATH := "res://data/audio/voice_profiles.json"

var _profiles: Dictionary = {}
var _default_accent: String = "en-US"


func _init() -> void:
	reload_profiles()


func reload_profiles() -> void:
	_profiles.clear()
	if not FileAccess.file_exists(PROFILES_PATH):
		return
	var f := FileAccess.open(PROFILES_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var doc: Dictionary = parsed
	_default_accent = str(doc.get("default_accent", "en-US"))
	for p_var in doc.get("profiles", []):
		if typeof(p_var) != TYPE_DICTIONARY:
			continue
		var p: Dictionary = p_var
		var pid := str(p.get("id", ""))
		if not pid.is_empty():
			_profiles[pid] = p


func get_profile(speaker_id: String) -> Dictionary:
	var clean := speaker_id.strip_edges().to_lower()
	if _profiles.has(clean):
		return (_profiles[clean] as Dictionary).duplicate(true)
	if _profiles.has("learning_narrator"):
		return (_profiles["learning_narrator"] as Dictionary).duplicate(true)
	return {
		"id": clean if not clean.is_empty() else "learning_narrator",
		"pitch_scale": 1.0,
		"rate_scale": 0.85,
		"volume_scale": 1.0,
		"lip_sync_mode": "basic_mouth_animation"
	}


func get_active_accent() -> String:
	var acc := SettingsManager.preferred_accent
	if acc in ["en-US", "en-GB"]:
		return acc
	return _default_accent


func get_all_profiles() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for k in _profiles.keys():
		out.append((_profiles[k] as Dictionary).duplicate(true))
	return out
