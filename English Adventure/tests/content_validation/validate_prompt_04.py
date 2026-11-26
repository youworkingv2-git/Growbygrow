#!/usr/bin/env python3
"""
Prompt 04 Automated Verification Suite for ENGLISH ADVENTURE Learning Engine.
Validates modules, curriculum hierarchy, 26 letters, 30+ vocabulary + SVGs,
15 grammar structures, 4-skill datasets, referential integrity, and GDScript safety.
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
errors = []

REQUIRED_FILES = [
    "scripts/learning/learning_content_repository.gd",
    "scripts/learning/learning_path_manager.gd",
    "scripts/learning/vocabulary_manager.gd",
    "scripts/learning/phonics_manager.gd",
    "scripts/learning/grammar_manager.gd",
    "scripts/learning/listening_manager.gd",
    "scripts/learning/speaking_manager.gd",
    "scripts/learning/reading_manager.gd",
    "scripts/learning/writing_manager.gd",
    "scripts/learning/question_manager.gd",
    "scripts/learning/learning_engine.gd",
    "scripts/learning/learning_hub_modal.gd",
    "scripts/assessment/assessment_engine.gd",
    "scripts/progression/learning_progress_manager.gd",
    "scripts/progression/review_engine.gd",
    "scenes/learning/learning_hub_modal.tscn",
    "supabase/migrations/0003_learning_engine_extensions.sql",
    "data/curriculum/learning_curriculum.json",
    "data/curriculum/spaced_repetition_config.json",
    "data/alphabet/alphabet_a_z.json",
    "data/phonics/phonics_units.json",
    "data/vocabulary/world_01_vocab.json",
    "data/grammar/world_01_grammar.json",
    "data/listening/world_01_listening.json",
    "data/reading/world_01_reading.json",
    "data/writing/world_01_writing.json",
    "data/speaking/world_01_speaking.json",
]


def load_json(rel: str):
    p = ROOT / rel
    if not p.exists():
        errors.append(f"Missing JSON: {rel}")
        return {}
    return json.loads(p.read_text(encoding="utf-8"))


def main():
    for rel in REQUIRED_FILES:
        if not (ROOT / rel).exists():
            errors.append(f"Missing required file: {rel}")

    pg = (ROOT / "project.godot").read_text(encoding="utf-8")
    if 'LearningEngine="*res://scripts/learning/learning_engine.gd"' not in pg:
        errors.append("LearningEngine autoload missing in project.godot")

    # 1. Alphabet 26 letters
    alpha = load_json("data/alphabet/alphabet_a_z.json")
    letters = alpha.get("letters", [])
    if len(letters) != 26:
        errors.append(f"Expected 26 letters in alphabet_a_z.json, found {len(letters)}")
    for lt in letters:
        if lt.get("audio_name", {}).get("audio_status") != "missing_asset":
            errors.append(f"Letter {lt.get('id')} must mark audio_status='missing_asset' until real audio bundled")

    # 2. Phonics 10 categories
    phonics = load_json("data/phonics/phonics_units.json")
    req_cats = {
        "alphabet", "letter_names", "letter_sounds", "short_vowels",
        "long_vowels", "consonants", "consonant_digraphs", "vowel_teams",
        "common_sound_patterns", "basic_word_blending"
    }
    if not req_cats.issubset(set(phonics.get("categories", []))):
        errors.append("Phonics categories missing required items")

    # 3. Vocabulary >= 30 + SVG files exist
    vocab_doc = load_json("data/vocabulary/world_01_vocab.json")
    vocab = vocab_doc.get("vocabulary", [])
    if len(vocab) < 30:
        errors.append(f"Expected >= 30 vocab words, found {len(vocab)}")
    vocab_ids = set()
    for w in vocab:
        wid = w.get("id", "")
        if wid in vocab_ids:
            errors.append(f"Duplicate vocab ID: {wid}")
        vocab_ids.add(wid)
        if not w.get("meaning_vi") or not w.get("ipa_us") or not w.get("example_sentence"):
            errors.append(f"Incomplete vocab record: {wid}")
        img_rel = w.get("image_path", "").replace("res://", "")
        if not img_rel or not (ROOT / img_rel).exists():
            errors.append(f"Missing vocab SVG image for {wid}: {w.get('image_path')}")

    # 4. Grammar >= 15 structures & >= 10 model sentences
    gram = load_json("data/grammar/world_01_grammar.json")
    if len(gram.get("structures", [])) < 15:
        errors.append(f"Expected >= 15 grammar structures, found {len(gram.get('structures', []))}")
    if len(gram.get("model_sentences", [])) < 10:
        errors.append(f"Expected >= 10 model sentences, found {len(gram.get('model_sentences', []))}")

    # 5. Four Skills counts & referential integrity
    listening = {it["id"]: it for it in load_json("data/listening/world_01_listening.json").get("items", [])}
    reading = {it["id"]: it for it in load_json("data/reading/world_01_reading.json").get("items", [])}
    writing = {it["id"]: it for it in load_json("data/writing/world_01_writing.json").get("items", [])}
    speaking = {it["id"]: it for it in load_json("data/speaking/world_01_speaking.json").get("items", [])}

    if len(listening) < 10:
        errors.append(f"Expected >= 10 listening items, found {len(listening)}")
    if len(reading) < 10:
        errors.append(f"Expected >= 10 reading items, found {len(reading)}")
    if len(writing) < 10:
        errors.append(f"Expected >= 10 writing items, found {len(writing)}")
    if len(speaking) < 5:
        errors.append(f"Expected >= 5 speaking items, found {len(speaking)}")
    for sid, sit in speaking.items():
        if sit.get("ai_scoring_status") != "not_integrated_experimental":
            errors.append(f"Speaking item {sid} must honestly declare ai_scoring_status='not_integrated_experimental'")

    # 6. Curriculum -> Activity -> Source ID integrity & Quest link integrity
    cur = load_json("data/curriculum/learning_curriculum.json")
    lesson_ids = set()
    for w in cur.get("worlds", []):
        for t in w.get("topics", []):
            for ls in t.get("lessons", []):
                lesson_ids.add(ls["id"])
                for act in ls.get("activities", []):
                    st = act.get("source_type")
                    sid = act.get("source_id")
                    pool = {"listening": listening, "reading": reading, "writing": writing, "speaking": speaking}.get(st, {})
                    if sid not in pool:
                        errors.append(f"Broken activity ref in {ls['id']}: {st}/{sid}")

    quests = load_json("data/quests/world_01_quests.json").get("quests", [])
    for q in quests:
        hook_lid = q.get("learning_hook", {}).get("future_lesson_id", "")
        if hook_lid and hook_lid not in lesson_ids:
            errors.append(f"Quest {q.get('id')} learning_hook lesson '{hook_lid}' not found in curriculum")

    # 7. GDScript 4.3 Variant trap check
    pat = re.compile(r'var\s+\w+\s*:=\s*[A-Za-z0-9_.\[\]"\']+\.get\([^)]*\)\s*$')
    for gd in (ROOT / "scripts").rglob("*.gd"):
        for idx, line in enumerate(gd.read_text(encoding="utf-8").splitlines(), 1):
            if pat.search(line):
                errors.append(f"Variant inference trap in {gd.relative_to(ROOT)}:{idx}: {line.strip()}")

    if errors:
        print("PROMPT 04 VALIDATION FAILED:")
        for e in errors:
            print(" -", e)
        sys.exit(1)

    print(
        f"PROMPT 04 VALIDATION PASSED: {len(letters)} letters, {len(vocab)} vocab + SVGs, "
        f"{len(gram.get('structures', []))} grammar, {len(listening)} listening, "
        f"{len(reading)} reading, {len(writing)} writing, {len(speaking)} speaking, "
        f"{len(lesson_ids)} lessons."
    )


if __name__ == "__main__":
    main()
