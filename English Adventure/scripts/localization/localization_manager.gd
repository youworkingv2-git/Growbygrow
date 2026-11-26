extends Node
## Bilingual Localization Manager (Vietnamese primary instructions + English learning strings).

const SUPPORTED_LOCALES := ["vi", "en"]
var current_locale: String = "vi"
var _tables: Dictionary = {}


func _ready() -> void:
	_load_locale_file("vi", "res://localization/vi/ui_strings.json")
	_load_locale_file("en", "res://localization/en/ui_strings.json")


func _load_locale_file(locale_code: String, path: String) -> void:
	if not FileAccess.file_exists(path):
		AppLogger.warn("LocalizationManager", "Missing locale file: " + path)
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) == TYPE_DICTIONARY:
		_tables[locale_code] = parsed


func set_locale(locale_code: String) -> void:
	if not SUPPORTED_LOCALES.has(locale_code):
		return
	current_locale = locale_code
	TranslationServer.set_locale(locale_code)
	EventBus.ui_locale_changed.emit(current_locale)


func toggle_locale() -> void:
	set_locale("en" if current_locale == "vi" else "vi")


func tr_key(key: String, fallback: String = "") -> String:
	var table: Dictionary = _tables.get(current_locale, {})
	if table.has(key):
		return str(table[key])
	var vi_table: Dictionary = _tables.get("vi", {})
	if vi_table.has(key):
		return str(vi_table[key])
	return fallback if not fallback.is_empty() else key


func pick_text(data: Dictionary, prefix: String = "text") -> String:
	var primary_key := "%s_%s" % [prefix, current_locale]
	if data.has(primary_key) and not str(data[primary_key]).is_empty():
		return str(data[primary_key])
	var vi_key := "%s_vi" % prefix
	if data.has(vi_key) and not str(data[vi_key]).is_empty():
		return str(data[vi_key])
	var en_key := "%s_en" % prefix
	return str(data.get(en_key, ""))
