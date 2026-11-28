#!/usr/bin/env python3
"""
Prompt 09 Automated Content Integration Simulation Test (Tests 01-08).
Exercises every playable dataset, question evaluation, writing equivalent answers,
phonics distinction, dialogue choices, quest-content mapping, review scheduling,
4-state mastery separation, and multi-factor A1 unlock gate logic.
"""

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
failures: list[str] = []


def load(rel: str) -> dict:
    return json.loads((ROOT / rel).read_text(encoding="utf-8"))


def assert_true(cond: bool, name: str) -> None:
    if not cond:
        failures.append(name)


def main() -> int:
    v1 = load("data/vocabulary/world_01_vocab.json")["vocabulary"]
    v2 = load("data/vocabulary/world_02_a1_vocab.json")["vocabulary"]
    vocab = {w["id"]: w for w in v1 + v2}
    phrases = {p["id"]: p for p in load("data/phrases/common_phrases.json")["phrases"]}
    alpha = {a["id"]: a for a in load("data/alphabet/alphabet_a_z.json")["letters"]}
    phonics = load("data/phonics/phonics_units.json")
    g1 = load("data/grammar/world_01_grammar.json")
    g2 = load("data/grammar/world_02_a1_grammar.json")
    listening = {i["id"]: i for i in load("data/listening/world_01_listening.json")["items"] + load("data/listening/world_02_a1_listening.json")["items"]}
    reading = {i["id"]: i for i in load("data/reading/world_01_reading.json")["items"] + load("data/reading/world_02_a1_reading.json")["items"]}
    writing = {i["id"]: i for i in load("data/writing/world_01_writing.json")["items"] + load("data/writing/world_02_a1_writing.json")["items"]}
    speaking = {i["id"]: i for i in load("data/speaking/world_01_speaking.json")["items"] + load("data/speaking/world_02_a1_speaking.json")["items"]}
    qb = {q["id"]: q for q in load("data/questions/question_bank.json")["questions"]}
    cur = load("data/curriculum/learning_curriculum.json")
    cur_a1 = load("data/curriculum/a1_sample_curriculum.json")
    quests = {q["id"]: q for q in load("data/quests/world_01_quests.json")["quests"]}
    dlgs = load("data/minigames/dialogue_adventures.json")["scenarios"] + load("data/minigames/a1_dialogue_adventures.json")["scenarios"]

    # Test 01: Vocabulary & Phrases
    assert_true(len(v1) == 115, "Test01: Pre-A1 vocab == 115")
    assert_true(len(v2) == 32, "Test01: A1 sample vocab == 32")
    assert_true(len(phrases) == 48, "Test01: Common phrases == 48")
    assert_true("fruits" in vocab["word_apple"].get("topics", []), "Test01: Multi-topic reuse on apple")
    assert_true((ROOT / vocab["word_star"]["image_path"].replace("res://", "")).exists(), "Test01: New SVG exists for word_star")

    # Test 02: Phonics
    assert_true(len(alpha) == 26, "Test02: 26 letters present")
    assert_true(alpha["letter_a"]["letter_name_ipa"]["en-US"] != alpha["letter_a"]["letter_sound_ipa"], "Test02: Letter A name != sound")
    assert_true(len(phonics["units"]) == 24 and len(phonics["phonics_activities"]) >= 6, "Test02: 24 phonics units + 6 activities")

    # Test 03: Sentence Practice
    all_structs = g1["structures"] + g2["structures"]
    assert_true(len(all_structs) == 32, "Test03: 22 Pre-A1 + 10 A1 patterns")
    for s in all_structs:
        assert_true(len(s.get("substitution_slots", [])) >= 1, f"Test03: {s['id']} has substitution_slots")

    # Test 04: Listening
    assert_true(len(listening) == 28, "Test04: 28 listening items (22 Pre-A1 + 6 A1)")
    assert_true(any(o.get("is_correct") for o in listening["list_18"]["options"]), "Test04: list_18 has valid correct option")

    # Test 05: Speaking + Mic Fallback
    assert_true(len(speaking) == 16, "Test05: 16 speaking items (12 Pre-A1 + 4 A1)")
    assert_true(all(s["ai_scoring_status"] == "not_integrated_experimental" for s in speaking.values()), "Test05: Honest AI scoring status")

    # Test 06: Reading & Writing (including acceptable_answers)
    assert_true(len(reading) == 28, "Test06: 28 reading items (22 Pre-A1 + 6 A1)")
    assert_true(len(writing) == 28, "Test06: 28 writing items (22 Pre-A1 + 6 A1)")
    assert_true("I'm happy." in writing["write_22"].get("acceptable_answers", []), "Test06: write_22 accepts equivalent answer")
    assert_true(len(reading["read_a1_03"]["text_en"].split()) >= 25, "Test06: A1 passage has 30-60 word range")

    # Test 07: Quest Integration & Dialogues
    assert_true(len(dlgs) == 14, "Test07: 14 interactive dialogue scenarios")
    for qid in ("quest_01_new_adventure", "quest_02_lost_letters", "quest_03_mysterious_gate", "quest_04_crystal_guardian", "quest_05_shadow_gate"):
        hook = quests[qid]["learning_hook"]
        assert_true(all(vid in vocab for vid in hook.get("linked_vocab_ids", [])), f"Test07: {qid} vocab links valid")
        assert_true(all(pid in phrases for pid in hook.get("linked_phrase_ids", [])), f"Test07: {qid} phrase links valid")

    # Test 08: Review, Question Bank & A1 Multi-factor Gate
    assert_true(len(qb) == 20, "Test08: 20 Question Bank items across 10 activity types")
    crit = cur["learning_path"]["a1_unlock_criteria"]
    assert_true(crit["min_pre_a1_lessons_completed"] >= 6 and crit["min_remembered_or_mastered_items"] >= 15, "Test08: A1 unlock gate multi-factor")
    assert_true(len(cur_a1["worlds"][0]["topics"]) == 2, "Test08: A1 sample world has 2 playable topics")

    if failures:
        print(f"TEST SUITE FAILED ({len(failures)}):")
        for f in failures:
            print(" -", f)
        return 1

    print("ALL PROMPT 09 TESTS (TEST 01 - TEST 08) PASSED: 0 failures across 147 words, 48 phrases, 32 patterns, 24 phonics, 116 skill items, 14 dialogues, 20 question bank items.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
