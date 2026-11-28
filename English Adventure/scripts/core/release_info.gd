class_name ReleaseInfo
extends RefCounted
## Single source of truth for application version, build profile, and child-privacy metadata.

const VERSION_JSON_PATH := "res://data/release/version.json"
const FALLBACK_VERSION := "0.9.0"
const FALLBACK_BUILD_NUMBER := 900

static var _cached_meta: Dictionary = {}


static func get_metadata() -> Dictionary:
	if not _cached_meta.is_empty():
		return _cached_meta
	if FileAccess.file_exists(VERSION_JSON_PATH):
		var f := FileAccess.open(VERSION_JSON_PATH, FileAccess.READ)
		if f != null:
			var parsed: Variant = JSON.parse_string(f.get_as_text())
			f.close()
			if typeof(parsed) == TYPE_DICTIONARY:
				_cached_meta = parsed as Dictionary
				return _cached_meta
	_cached_meta = {
		"app_name": "English Adventure",
		"version": str(ProjectSettings.get_setting("application/config/version", FALLBACK_VERSION)),
		"build_number": FALLBACK_BUILD_NUMBER,
		"stage": "release_candidate",
		"content_pack_version": "p9-2026.11"
	}
	return _cached_meta


static func get_version() -> String:
	var meta := get_metadata()
	return str(meta.get("version", ProjectSettings.get_setting("application/config/version", FALLBACK_VERSION)))


static func get_build_number() -> int:
	return int(get_metadata().get("build_number", FALLBACK_BUILD_NUMBER))


static func is_release_build() -> bool:
	return not OS.is_debug_build()


static func get_build_profile_name() -> String:
	return "release" if is_release_build() else "development"


static func get_display_version() -> String:
	var v := get_version()
	var bn := get_build_number()
	var mode_tag := "Release" if is_release_build() else "Dev"
	return "v%s (Build %d · %s)" % [v, bn, mode_tag]


static func get_about_summary_vi() -> String:
	var meta := get_metadata()
	return (
		"%s %s\n"
		+ "Gói học liệu: %s (Pre-A1 & A1 mẫu)\n"
		+ "Lưu dữ liệu cục bộ (Offline-First) — Không quảng cáo, không chat công khai.\n"
		+ "Micro chỉ bật khi bé bấm nút luyện nói và có xác nhận quyền."
	) % [
		str(meta.get("app_name", "English Adventure")),
		get_display_version(),
		str(meta.get("content_pack_version", "p9-2026.11"))
	]


static func get_about_summary_en() -> String:
	var meta := get_metadata()
	return (
		"%s %s\n"
		+ "Content Pack: %s (Pre-A1 & A1 Sample)\n"
		+ "Offline-First Local Save — No ads, no public chat.\n"
		+ "Microphone only activates when the player presses Record with permission."
	) % [
		str(meta.get("app_name", "English Adventure")),
		get_display_version(),
		str(meta.get("content_pack_version", "p9-2026.11"))
	]
