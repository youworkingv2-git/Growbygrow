#!/usr/bin/env python3
"""
Prompt 09 Automated Content Validation & Quality Assurance Suite.
Checks duplicate IDs/words, missing translations/topics/levels, IPA syntax,
asset existence, honest audio_status, question/option integrity, dialogue speakers,
review_status, A1 unlock rules, and GDScript 4.3 Variant safety.
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
errors: list[str] = []
warnings: list[str] = []


def load_json(rel: str) -> dict:
    p = ROOT / rel
    if not p.exists():
        errors.append(f"Missing JSON: {rel}")
        return {}
    try:
        return json.loads(p.read_text(encoding="utf-8"))
    except Exception as exc:
        errors.append(f"Invalid JSON in {rel}: {exc}")
        return {}


def check_ipa(ipa: str, ctx: str) -> None:
    if not ipa or not (ipa.startswith("/") and ipa.endswith("/") and len(ipa) >= 3):
        errors.append(f"{ctx}: invalid IPA structure '{ipa}'")


def check_audio_honesty(audio_status: str, audio_path: str, ctx: str) -> None:
    if audio_status == "ready":
        if not audio_path or not (ROOT / audio_path.replace("res://", "")).exists():
            errors.append(f"{ctx}: audio_status='ready' but file does not exist ({audio_path})")


def main() -> int:
    # 1. Alphabet (26)
    alpha = load_json("data/alphabet/alphabet_a_z.json").get("letters", [])
    if len(alpha) != 26:
        errors.append(f"Alphabet count expected 26, got {len(alpha)}")

    # 2. Vocabulary Pre-A1 + A1 Sample
    v1 = load_json("data/vocabulary/world_01_vocab.json").get("vocabulary", [])
    v2 = load_json("data/vocabulary/world_02_a1_vocab.json").get("vocabulary", [])
    all_vocab = v1 + v2
    if len(v1) < 100:
        errors.append(f"Expected >= 100 Pre-A1 vocab words, got {len(v1)}")
    if len(v2) < 24:
        errors.append(f"Expected >= 24 A1 sample vocab words, got {len(v2)}")

    seen_wids: set[str] = set()
    seen_words: set[str] = set()
    vocab_by_id: dict[str, dict] = {}
    for w in all_vocab:
        wid = str(w.get("id", ""))
        word_en = str(w.get("word", "")).strip().lower()
        if not wid or wid in seen_wids:
            errors.append(f"Duplicate or missing vocab id: {wid}")
        if not word_en or word_en in seen_words:
            errors.append(f"Duplicate or missing vocab word: {word_en} ({wid})")
        seen_wids.add(wid)
        seen_words.add(word_en)
        vocab_by_id[wid] = w

        if not w.get("meaning_vi"):
            errors.append(f"Vocab {wid} missing meaning_vi")
        if not w.get("cefr_level"):
            errors.append(f"Vocab {wid} missing cefr_level")
        if not w.get("topic"):
            errors.append(f"Vocab {wid} missing topic")
        if not w.get("example_sentence") or not w.get("example_translation"):
            errors.append(f"Vocab {wid} missing example_sentence or example_translation")
        check_ipa(str(w.get("ipa_us", "")), f"vocab:{wid}:us")
        if w.get("ipa_uk"):
            check_ipa(str(w.get("ipa_uk", "")), f"vocab:{wid}:uk")
        img_rel = str(w.get("image_path", "")).replace("res://", "")
        if not img_rel or not (ROOT / img_rel).exists():
            errors.append(f"Vocab {wid} missing image file: {w.get('image_path')}")
        check_audio_honesty(str(w.get("audio_status", "")), str(w.get("audio_us_path", "")), f"vocab:{wid}")
        if w.get("review_status") not in ("draft", "under_review", "approved", "published", "archived"):
            errors.append(f"Vocab {wid} missing/invalid review_status: {w.get('review_status')}")

    # Check alphabet anchor words resolve cleanly
    for lt in alpha:
        for aw in lt.get("anchor_word_ids", []):
            if aw not in vocab_by_id:
                errors.append(f"Alphabet {lt.get('id')} unknown anchor_word_id: {aw}")

    # 3. Common Phrases
    phrases = load_json("data/phrases/common_phrases.json").get("phrases", [])
    if len(phrases) < 30:
        errors.append(f"Expected >= 30 common phrases, got {len(phrases)}")
    seen_pids: set[str] = set()
    for p in phrases:
        pid = str(p.get("id", ""))
        if not pid or pid in seen_pids:
            errors.append(f"Duplicate/missing phrase id: {pid}")
        seen_pids.add(pid)
        if not p.get("meaning_vi") or not p.get("example_sentence") or not p.get("example_translation"):
            errors.append(f"Phrase {pid} missing translation or example")
        check_ipa(str(p.get("ipa_us", "")), f"phrase:{pid}")
        for lwid in p.get("linked_vocab_ids", []):
            if lwid not in vocab_by_id:
                errors.append(f"Phrase {pid} references unknown vocab id: {lwid}")

    # 4. Phonics
    ph_doc = load_json("data/phonics/phonics_units.json")
    units = ph_doc.get("units", [])
    ph_acts = ph_doc.get("phonics_activities", [])
    if len(units) < 20:
        errors.append(f"Expected >= 20 phonics units, got {len(units)}")
    for u in units:
        for ex in u.get("examples", []):
            if ex.get("word_id") not in vocab_by_id:
                errors.append(f"Phonics {u.get('id')} references unknown word_id {ex.get('word_id')}")
    for pa in ph_acts:
        if pa.get("correct_answer") not in pa.get("options", []):
            errors.append(f"Phonics activity {pa.get('id')} correct_answer not in options")

    # 5. Grammar / Sentence Patterns
    g1 = load_json("data/grammar/world_01_grammar.json")
    g2 = load_json("data/grammar/world_02_a1_grammar.json")
    all_structs = g1.get("structures", []) + g2.get("structures", [])
    all_models = g1.get("model_sentences", []) + g2.get("model_sentences", [])
    if len(g1.get("structures", [])) < 20:
        errors.append(f"Expected >= 20 Pre-A1 sentence patterns, got {len(g1.get('structures', []))}")
    if len(g2.get("structures", [])) < 8:
        errors.append(f"Expected >= 8 A1 sentence patterns, got {len(g2.get('structures', []))}")
    for st in all_structs:
        if not st.get("explanation_vi") or not st.get("example_sentences"):
            errors.append(f"Grammar {st.get('id')} missing explanation_vi or example_sentences")

    # 6. 4 Skills (Pre-A1 + A1)
    skill_pools = {}
    for sk, files in [
        ("listening", ["data/listening/world_01_listening.json", "data/listening/world_02_a1_listening.json"]),
        ("reading", ["data/reading/world_01_reading.json", "data/reading/world_02_a1_reading.json"]),
        ("writing", ["data/writing/world_01_writing.json", "data/writing/world_02_a1_writing.json"]),
        ("speaking", ["data/speaking/world_01_speaking.json", "data/speaking/world_02_a1_speaking.json"]),
    ]:
        items_map = {}
        for f in files:
            for it in load_json(f).get("items", []):
                iid = str(it.get("id", ""))
                if iid in items_map:
                    errors.append(f"Duplicate {sk} id across files: {iid}")
                items_map[iid] = it
                wid = str(it.get("word_id", ""))
                if wid and wid not in vocab_by_id:
                    errors.append(f"{f}:{iid} references unknown word_id={wid}")
                opts = it.get("options", [])
                if opts:
                    cc = sum(1 for o in opts if isinstance(o, dict) and o.get("is_correct"))
                    if cc != 1:
                        errors.append(f"{f}:{iid} must have exactly 1 correct option, found {cc}")
                    labels = [str(o.get("label_en", o.get("label_vi", o.get("id", "")))) for o in opts if isinstance(o, dict)]
                    if len(labels) != len(set(labels)):
                        errors.append(f"{f}:{iid} duplicate option labels: {labels}")
                if sk == "speaking" and it.get("ai_scoring_status") != "not_integrated_experimental":
                    errors.append(f"{f}:{iid} must keep ai_scoring_status='not_integrated_experimental'")
        skill_pools[sk] = items_map

    if len(skill_pools["listening"]) < 20 or len(skill_pools["reading"]) < 20 or len(skill_pools["writing"]) < 20 or len(skill_pools["speaking"]) < 14:
        errors.append("Expanded 4-skill item count below P9 threshold")

    # 7. Dialogues (10 Pre-A1 + 4 A1 = 14 scenarios)
    dlgs = (
        load_json("data/minigames/dialogue_adventures.json").get("scenarios", [])
        + load_json("data/minigames/a1_dialogue_adventures.json").get("scenarios", [])
    )
    if len(dlgs) < 12:
        errors.append(f"Expected >= 12 dialogue scenarios (10 Pre-A1 + A1 sample), got {len(dlgs)}")
    for sc in dlgs:
        if not sc.get("npc_id") or not sc.get("npc_name_vi"):
            errors.append(f"Dialogue {sc.get('id')} missing NPC speaker info")
        for lwid in sc.get("linked_vocab_ids", []):
            if lwid not in vocab_by_id:
                errors.append(f"Dialogue {sc.get('id')} unknown vocab id: {lwid}")

    # 8. Question Bank
    qb = load_json("data/questions/question_bank.json").get("questions", [])
    if len(qb) < 20:
        errors.append(f"Expected >= 20 reusable question bank items, got {len(qb)}")
    for q in qb:
        opts = q.get("options", [])
        if opts:
            opt_ids = [str(o.get("id", "")) for o in opts]
            if q.get("correct_answer") not in opt_ids:
                errors.append(f"QuestionBank {q.get('id')} correct_answer not in options")

    # 9. Curriculum & A1 Unlock Criteria
    cur = load_json("data/curriculum/learning_curriculum.json")
    cur_a1 = load_json("data/curriculum/a1_sample_curriculum.json")
    a1_crit = cur.get("learning_path", {}).get("a1_unlock_criteria", {})
    if int(a1_crit.get("min_pre_a1_lessons_completed", 0)) < 4 or int(a1_crit.get("min_remembered_or_mastered_items", 0)) < 10:
        errors.append("A1 unlock criteria must require multiple Pre-A1 lessons and remembered items")
    for w in cur.get("worlds", []) + cur_a1.get("worlds", []):
        for t in w.get("topics", []):
            for ls in t.get("lessons", []):
                for act in ls.get("activities", []):
                    st = str(act.get("source_type", ""))
                    sid = str(act.get("source_id", ""))
                    if sid not in skill_pools.get(st, {}):
                        errors.append(f"Curriculum lesson {ls.get('id')} broken ref: {st}/{sid}")

    # 10. GDScript 4.3 Variant trap check
    pat = re.compile(r'var\s+\w+\s*:=\s*[A-Za-z0-9_.\[\]"\']+\.get\([^)]*\)\s*$')
    for gd in (ROOT / "scripts").rglob("*.gd"):
        for idx, line in enumerate(gd.read_text(encoding="utf-8").splitlines(), 1):
            if pat.search(line):
                errors.append(f"GDScript 4.3 Variant trap in {gd.relative_to(ROOT)}:{idx}: {line.strip()}")

    # 11. Migration 0007 RLS check
    mig7 = ROOT / "supabase/migrations/0007_content_expansion_system.sql"
    if not mig7.exists() or "ENABLE ROW LEVEL SECURITY" not in mig7.read_text(encoding="utf-8"):
        errors.append("Missing or insecure supabase/migrations/0007_content_expansion_system.sql")

    if errors:
        print(f"PROMPT 09 VALIDATION FAILED ({len(errors)} errors):")
        for e in errors:
            print(" -", e)
        return 1

    print(
        f"PROMPT 09 VALIDATION PASSED:\n"
        f"  Letters={len(alpha)}, PreA1_Vocab={len(v1)}, A1_Vocab={len(v2)}, Phrases={len(phrases)},\n"
        f"  PhonicsUnits={len(units)}, PhonicsActs={len(ph_acts)}, Grammar={len(all_structs)}, ModelSentences={len(all_models)},\n"
        f"  Listening={len(skill_pools['listening'])}, Reading={len(skill_pools['reading'])}, "
        f"Writing={len(skill_pools['writing'])}, Speaking={len(skill_pools['speaking'])},\n"
        f"  Dialogues={len(dlgs)}, QuestionBank={len(qb)}, Worlds={len(cur.get('worlds', []))}."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
