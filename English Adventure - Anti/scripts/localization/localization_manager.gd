extends Node
## Loads Vietnamese UI localization strings from CSV.

const UI_CSV_PATH := "res://localization/vi/ui_common.csv"
var strings: Dictionary = {}

func _ready() -> void:
	_load_csv(UI_CSV_PATH)

func _load_csv(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	var is_header := true
	while not file.eof_reached():
		var row := file.get_csv_line()
		if is_header:
			is_header = false
			continue
		if row.size() >= 2:
			strings[row[0]] = row[1]
	file.close()

func get_string(key: String, fallback: String = "") -> String:
	return strings.get(key, fallback if fallback != "" else key)
