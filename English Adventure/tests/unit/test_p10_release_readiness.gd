extends SceneTree
## Godot 4.x Unit Test Suite for Prompt 10 Release Readiness:
## - ReleaseInfo unified version & build profile
## - SaveLoadManager v1 -> v2 non-destructive schema migration
## - AppLogger secret/token redaction
## - Audio background/focus safety hooks

var _failures: Array[String] = []


func _init() -> void:
	_run_tests()
	if _failures.is_empty():
		print("P10 GDSCRIPT UNIT TESTS PASSED (0 failures)")
		quit(0)
	else:
		for f in _failures:
			push_error("FAIL: " + f)
		quit(1)


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		_failures.append(msg)


func _run_tests() -> void:
	# 1. ReleaseInfo version consistency
	var ver := ReleaseInfo.get_version()
	var cfg_ver := str(ProjectSettings.get_setting("application/config/version", ""))
	_assert(ver == "0.9.0", "ReleaseInfo version expected 0.9.0, got " + ver)
	_assert(cfg_ver == ver, "ProjectSettings version must match ReleaseInfo: %s vs %s" % [cfg_ver, ver])
	_assert(ReleaseInfo.get_build_number() == 900, "Build number expected 900")

	# 2. Save migration v1 -> v2 preserves player progress
	var sl := SaveLoadManager
	if sl != null:
		var v1_save := {
			"schema_version": 1,
			"selected_character": "girl",
			"nickname": "Linh",
			"current_area_id": "alphabet_meadow",
			"unlocked_areas": ["welcome_village", "alphabet_meadow"],
			"rewarded_quests": ["quest_01_new_adventure"],
			"exp": 120,
			"gold": 45
		}
		var migrated: Dictionary = sl.migrate_save_data(v1_save)
		_assert(int(migrated.get("schema_version", 0)) == 2, "Migrated schema_version == 2")
		_assert((migrated.get("claimed_quests", []) as Array).has("quest_01_new_adventure"), "Migration preserves rewarded_quests -> claimed_quests")
		_assert(str(migrated.get("nickname", "")) == "Linh", "Migration preserves nickname")
		_assert(int(migrated.get("exp", 0)) == 120, "Migration preserves EXP")
