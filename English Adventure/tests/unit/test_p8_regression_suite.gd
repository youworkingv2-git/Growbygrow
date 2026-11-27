extends Node
## Prompt 08 Automated Unit, Integration & Regression Test Suite (Godot 4.x)
## Can be invoked from a test runner scene or GUT/gdUnit4 in Godot Editor/CLI.


func run_all_checks() -> Dictionary:
	var results := { "passed": 0, "failed": 0, "notes": [] }

	# 1. Character & New Game setup
	SaveLoadManager.delete_save()
	GameStateManager.reset_new_game()
	GameStateManager.set_character_profile("girl", "MiaQA")
	_assert_true(results, GameStateManager.selected_character == "girl" and GameStateManager.nickname == "MiaQA", "Girl Adventurer profile persists")
	GameStateManager.set_character_profile("boy", "LeoQA")
	_assert_true(results, GameStateManager.selected_character == "boy" and GameStateManager.nickname == "LeoQA", "Boy Adventurer profile persists")

	# 2. Area Unlock Guard (5 Alphabet Island areas)
	_assert_true(results, GameStateManager.is_area_unlocked("welcome_village"), "Welcome Village starts unlocked")
	_assert_true(results, not GameStateManager.is_area_unlocked("alphabet_meadow"), "Alphabet Meadow starts locked")
	_assert_true(results, not GameStateManager.is_area_unlocked("letter_cave"), "Letter Cave starts locked")
	_assert_true(results, not GameStateManager.is_area_unlocked("crystal_lake"), "Crystal Lake starts locked")
	_assert_true(results, not GameStateManager.is_area_unlocked("shadow_gate"), "Shadow Gate starts locked")

	# 3. Quest 01 Lifecycle + No Duplicate Rewards
	_assert_true(results, QuestManager.start_quest("quest_01_new_adventure"), "Quest 01 can be accepted")
	_assert_true(results, not QuestManager.start_quest("quest_01_new_adventure"), "Cannot double-start active quest")
	QuestManager.report_npc_talk("professor_owl")
	QuestManager.report_npc_talk("buddy")
	for i in range(5):
		QuestManager._on_minigame_answered("listen_and_find", {
			"question_id": "qa_%d" % i,
			"knowledge_id": "word_%d" % i,
			"is_correct": true,
			"completed_at_utc": "t%d" % i
		})
	QuestManager._on_minigame_completed("listen_and_find", { "passed": true, "completed_at_utc": "done_1" })
	QuestManager.report_npc_talk("professor_owl")
	_assert_true(results, QuestManager.get_detailed_quest_status("quest_01_new_adventure") == "completed", "Quest 01 transitions to completed")

	var gold_before := GameStateManager.gold
	var claim_1 := QuestManager.claim_quest_reward("quest_01_new_adventure")
	var gold_after := GameStateManager.gold
	var claim_2 := QuestManager.claim_quest_reward("quest_01_new_adventure")
	_assert_true(results, bool(claim_1.get("granted", false)) and gold_after > gold_before, "First Quest 01 claim grants reward")
	_assert_true(results, not bool(claim_2.get("granted", false)) and GameStateManager.gold == gold_after, "Second Quest 01 claim blocked (no duplicate reward)")
	_assert_true(results, GameStateManager.is_area_unlocked("alphabet_meadow"), "Alphabet Meadow unlocks after Quest 01")

	# 4. Pre-collected world object soft-lock regression test (Quest 02 lost letters)
	GameStateManager.mark_object_collected("obj_letter_a")
	GameStateManager.mark_object_collected("obj_letter_b")
	GameStateManager.mark_object_collected("obj_letter_c")
	_assert_true(results, QuestManager.start_quest("quest_02_lost_letters"), "Quest 02 starts cleanly")
	QuestManager.report_area_visited("alphabet_meadow")
	var q2_step2 := QuestManager.get_objective_progress("quest_02_lost_letters", "q2_step_2")
	_assert_true(results, int(q2_step2.get("current", 0)) == 3, "Pre-collected letters A/B/C auto-sync to Quest 02 step 2")

	# 5. Save/Load + Rolling Backup Corruption Recovery
	_assert_true(results, GameStateManager.save_now("p8_test_1"), "Primary save succeeds")
	GameStateManager.add_exp_and_gold(15, 25, 0)
	_assert_true(results, GameStateManager.save_now("p8_test_2"), "Second save creates rolling .bak.json")
	var corrupt_f := FileAccess.open(SaveLoadManager.SAVE_PATH, FileAccess.WRITE)
	if corrupt_f != null:
		corrupt_f.store_string("{corrupted_json_!!!")
		corrupt_f.close()
	var recovered := SaveLoadManager.load_state()
	_assert_true(results, not recovered.is_empty() and str(recovered.get("nickname", "")) == "LeoQA", "SaveLoadManager recovers from rolling backup when primary save is corrupted")

	# 6. Online/Offline flag compatibility with SpeechRecognition & PronunciationAssessment
	SaveLoadManager.set_online_status(false)
	_assert_true(results, SaveLoadManager.is_online == false, "SaveLoadManager.is_online toggles cleanly for offline tests")
	SaveLoadManager.set_online_status(true)

	# 7. Cleanup test save
	SaveLoadManager.delete_save()
	return results


func _assert_true(results: Dictionary, cond: bool, label: String) -> void:
	if cond:
		results["passed"] += 1
	else:
		results["failed"] += 1
		results["notes"].append("FAIL: " + label)
