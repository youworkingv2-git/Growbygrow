extends Node
## Leveled logger for ENGLISH ADVENTURE with token redaction and rolling local file logs.

enum Level { DEBUG, INFO, WARN, ERROR }

const LOG_DIR := "user://logs"
const LOG_PATH := "user://logs/app.log"
const MAX_LOG_BYTES := 524288

var min_level: Level = Level.INFO


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(LOG_DIR)
	info("AppLogger", "Logger initialized")


func debug(tag: String, message: String) -> void:
	_log(Level.DEBUG, tag, message)


func info(tag: String, message: String) -> void:
	_log(Level.INFO, tag, message)


func warn(tag: String, message: String) -> void:
	_log(Level.WARN, tag, message)


func error(tag: String, message: String) -> void:
	_log(Level.ERROR, tag, message)


func _log(level: Level, tag: String, message: String) -> void:
	if level < min_level:
		return
	var level_str: String = Level.keys()[level]
	var safe_msg: String = _redact(message)
	var line := "[%s] [%s] [%s] %s" % [Time.get_datetime_string_from_system(true), level_str, tag, safe_msg]
	if level == Level.ERROR:
		push_error(line)
	elif level == Level.WARN:
		push_warning(line)
	else:
		print(line)
	_append_to_file(line)


func _redact(text: String) -> String:
	var redacted := text
	if redacted.contains("Bearer "):
		redacted = redacted.split("Bearer ")[0] + "Bearer [REDACTED]"
	return redacted


func _append_to_file(line: String) -> void:
	if FileAccess.file_exists(LOG_PATH):
		var read_f := FileAccess.open(LOG_PATH, FileAccess.READ)
		if read_f != null and read_f.get_length() > MAX_LOG_BYTES:
			read_f.close()
			DirAccess.rename_absolute(LOG_PATH, LOG_DIR + "/app.prev.log")
		elif read_f != null:
			read_f.close()
	var mode := FileAccess.READ_WRITE if FileAccess.file_exists(LOG_PATH) else FileAccess.WRITE
	var f := FileAccess.open(LOG_PATH, mode)
	if f == null:
		return
	f.seek_end()
	f.store_line(line)
	f.close()
