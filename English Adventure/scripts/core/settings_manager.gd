extends Node
## Persistent Settings Manager handling audio volumes, UI language, fullscreen,
## desktop resolution, control mode, and reduced motion accessibility option.

const SETTINGS_PATH := "user://settings.json"
const RESOLUTION_PRESETS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080)
]

var music_volume: float = 0.75
var sfx_volume: float = 0.85
var language: String = "vi"
var fullscreen: bool = false
var resolution_index: int = 0
var control_mode: String = "auto" # auto | keyboard | touch
var reduced_motion: bool = false
var graphics_quality: String = "medium" # low | medium | high
var camera_sensitivity: float = 1.0 # 0.4 .. 2.0
var preferred_accent: String = "en-US" # en-US | en-GB


func _ready() -> void:
	graphics_quality = default_graphics_quality()
	load_settings()
	apply_settings()


static func default_graphics_quality() -> String:
	if OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios"):
		return "low"
	if OS.has_feature("web"):
		return "medium"
	return "high"


func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var d: Dictionary = parsed
	music_volume = clampf(float(d.get("music_volume", 0.75)), 0.0, 1.0)
	sfx_volume = clampf(float(d.get("sfx_volume", 0.85)), 0.0, 1.0)
	var lang := str(d.get("language", "vi"))
	language = lang if lang in ["vi", "en"] else "vi"
	fullscreen = bool(d.get("fullscreen", false))
	resolution_index = clampi(int(d.get("resolution_index", 0)), 0, RESOLUTION_PRESETS.size() - 1)
	var cm := str(d.get("control_mode", "auto"))
	control_mode = cm if cm in ["auto", "keyboard", "touch"] else "auto"
	reduced_motion = bool(d.get("reduced_motion", false))
	var gq := str(d.get("graphics_quality", default_graphics_quality()))
	graphics_quality = gq if gq in ["low", "medium", "high"] else "medium"
	camera_sensitivity = clampf(float(d.get("camera_sensitivity", 1.0)), 0.4, 2.0)
	var acc := str(d.get("preferred_accent", "en-US"))
	preferred_accent = acc if acc in ["en-US", "en-GB"] else "en-US"


func save_settings() -> bool:
	var payload := {
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"language": language,
		"fullscreen": fullscreen,
		"resolution_index": resolution_index,
		"control_mode": control_mode,
		"reduced_motion": reduced_motion,
		"graphics_quality": graphics_quality,
		"camera_sensitivity": camera_sensitivity,
		"preferred_accent": preferred_accent
	}
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if f == null:
		AppLogger.error("SettingsManager", "Failed to save settings file")
		return false
	f.store_string(JSON.stringify(payload, "\t"))
	f.close()
	apply_settings()
	EventBus.settings_changed.emit()
	return true


func apply_settings() -> void:
	if LocalizationManager.current_locale != language:
		LocalizationManager.set_locale(language)

	if supports_fullscreen_toggle():
		var target_mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
		if DisplayServer.window_get_mode() != target_mode:
			DisplayServer.window_set_mode(target_mode)

	if supports_resolution_change() and not fullscreen:
		var target_res: Vector2i = RESOLUTION_PRESETS[clampi(resolution_index, 0, RESOLUTION_PRESETS.size() - 1)]
		DisplayServer.window_set_size(target_res)

	EventBus.settings_changed.emit()


func supports_fullscreen_toggle() -> bool:
	return not OS.has_feature("mobile")


func supports_resolution_change() -> bool:
	return (not OS.has_feature("web")) and (not OS.has_feature("mobile"))
