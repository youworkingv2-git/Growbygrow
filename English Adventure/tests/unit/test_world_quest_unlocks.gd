extends Node
## Unit test suite specification (for GUT / gdUnit4 when Godot 4 editor/CLI is available)
## Verifies UnlockEvaluator, Quest progression, and SaveLoadManager persistence.


func run_all_checks() -> Dictionary:
	var results := { "passed": 0, "failed": 0, "notes": [] }

	# 1. UnlockEvaluator checks
	var empty_state := { "completed_quests": [], "unlocked_areas": ["welcome_village"], "flags": {}, "inventory": {} }
	var meadow := DataRepository.get_area("alphabet_meadow")
	var meadow_locked := not UnlockEvaluator.is_condition_met(meadow.get("unlock_condition", {}), empty_state)
	_record(results, meadow_locked, "Alphabet Meadow starts locked before Quest 01")

	var q1_done_state := { "completed_quests": ["quest_01_new_adventure"], "unlocked_areas": ["welcome_village"], "flags": {}, "inventory": {} }
	var meadow_unlocked := UnlockEvaluator.is_condition_met(meadow.get("unlock_condition", {}), q1_done_state)
	_record(results, meadow_unlocked, "Alphabet Meadow unlocks after Quest 01")

	# 2. Duplicate reward protection check
	GameStateManager.reset_new_game()
	QuestManager.start_quest("quest_01_new_adventure")
	QuestManager.report_npc_talk("professor_owl")
	QuestManager.report_npc_talk("lily")
	QuestManager.report_object_interacted("obj_village_sign")
	var gold_after_q1 := GameStateManager.gold
	QuestManager._complete_quest("quest_01_new_adventure")
	_record(results, GameStateManager.gold == gold_after_q1, "Duplicate quest completion does not grant duplicate Gold")

	# 3. Save/Load round-trip check
	GameStateManager.set_character_profile("girl", "MiaTest")
	var saved_ok := GameStateManager.save_now("unit_test")
	_record(results, saved_ok, "SaveLoadManager writes profile atomically")
	var loaded := SaveLoadManager.load_state()
	_record(results, str(loaded.get("selected_character", "")) == "girl" and str(loaded.get("nickname", "")) == "MiaTest", "SaveLoadManager restores Girl profile and nickname")

	return results


func _record(results: Dictionary, cond: bool, msg: String) -> void:
	if cond:
		results["passed"] += 1
	else:
		results["failed"] += 1
		results["notes"].append("FAIL: " + msg)
