#!/usr/bin/env python3
"""
Prompt 08 Automated QA, Content Quality, Security & Regression Verification Suite
for ENGLISH ADVENTURE.
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
errors: list[str] = []
warnings: list[str] = []


def check_json_file(rel: str) -> dict:
    p = ROOT / rel
    if not p.exists():
        errors.append(f"Missing required data file: {rel}")
        return {}
    try:
        return json.loads(p.read_text(encoding="utf-8"))
    except Exception as exc:
        errors.append(f"Invalid JSON in {rel}: {exc}")
        return {}


def check_res_asset(path_str: str, context: str) -> None:
    if not path_str:
        return
    if not path_str.startswith("res://"):
        errors.append(f"{context}: asset path must start with res:// -> {path_str}")
        return
    disk_path = ROOT / path_str[len("res://"):]
    if not disk_path.exists():
        errors.append(f"{context}: referenced asset does not exist -> {path_str}")


def validate_content_quality() -> None:
    vocab_doc = check_json_file("data/vocabulary/world_01_vocab.json")
    vocab_list = vocab_doc.get("vocabulary", [])
    vocab_by_id = {w["id"]: w for w in vocab_list if "id" in w}

    if len(vocab_by_id) < 12:
        errors.append(f"Expected >= 12 vocabulary entries, got {len(vocab_by_id)}")

    for wid, w in vocab_by_id.items():
        if not w.get("word") or not w.get("meaning_vi") or not w.get("ipa_us"):
            errors.append(f"Vocabulary {wid} missing word, meaning_vi, or ipa_us")
        check_res_asset(str(w.get("image_path", "")), f"vocab:{wid}")

    # Validate 4-skill learning files
    skill_files = [
        ("listening", "data/listening/world_01_listening.json", "items"),
        ("speaking", "data/speaking/world_01_speaking.json", "items"),
        ("reading", "data/reading/world_01_reading.json", "items"),
        ("writing", "data/writing/world_01_writing.json", "items"),
    ]
    for skill, rel, list_key in skill_files:
        doc = check_json_file(rel)
        items = doc.get(list_key, [])
        if not items:
            errors.append(f"{rel} has no '{list_key}'")
            continue
        seen_ids = set()
        for it in items:
            iid = str(it.get("id", ""))
            if not iid:
                errors.append(f"{rel}: item missing id")
                continue
            if iid in seen_ids:
                errors.append(f"{rel}: duplicate item id {iid}")
            seen_ids.add(iid)

            wid = str(it.get("word_id", ""))
            if wid:
                if wid not in vocab_by_id:
                    errors.append(f"{rel}:{iid} unknown word_id={wid}")
                else:
                    w = vocab_by_id[wid]
                    word_lc = str(w.get("word", "")).lower()
                    if skill == "reading" and it.get("activity_type") in ("fill_word_in_sentence", "match_word_image"):
                        ans_lc = str(it.get("correct_answer", "")).lower()
                        if word_lc and ans_lc and word_lc != ans_lc and word_lc not in ans_lc:
                            errors.append(f"{rel}:{iid} word_id={wid} ('{word_lc}') mismatches correct_answer='{ans_lc}'")
                    if skill == "writing" and it.get("activity_type") == "assemble_letters_word":
                        ans_lc = str(it.get("correct_answer", "")).lower()
                        if word_lc and ans_lc and word_lc != ans_lc:
                            errors.append(f"{rel}:{iid} word_id={wid} ('{word_lc}') mismatches writing answer='{ans_lc}'")

            if skill == "speaking":
                has_meaning = bool(it.get("meaning_vi")) or (wid in vocab_by_id)
                if not it.get("target_text_en") or not has_meaning or not it.get("mouth_hint_vi"):
                    errors.append(f"{rel}:{iid} missing speaking text/meaning/mouth_hint")
                target_en = str(it.get("target_text_en", ""))
                if "/" in target_en and not it.get("spoken_text_en"):
                    errors.append(f"{rel}:{iid} contains IPA slashes in target_text_en without spoken_text_en")

            # Check options for duplicates or missing answers
            opts = it.get("options", [])
            if isinstance(opts, list) and opts:
                opt_ids = []
                opt_labels = []
                correct_count = 0
                for o in opts:
                    if isinstance(o, dict):
                        opt_ids.append(str(o.get("id", "")))
                        opt_labels.append(str(o.get("label_en", o.get("label_vi", o.get("id", "")))))
                        if o.get("is_correct"):
                            correct_count += 1
                if len(opt_ids) != len(set(opt_ids)):
                    errors.append(f"{rel}:{iid} duplicate option ids: {opt_ids}")
                if len(opt_labels) != len(set(opt_labels)):
                    errors.append(f"{rel}:{iid} duplicate option labels: {opt_labels}")
                if correct_count != 1:
                    errors.append(f"{rel}:{iid} expected 1 is_correct option, found {correct_count}")
                ca = str(it.get("correct_answer", ""))
                if ca and ca not in opt_ids:
                    errors.append(f"{rel}:{iid} correct_answer '{ca}' not in option ids {opt_ids}")

    # Validate phonics Letter Name vs Letter Sound distinction
    phonics_doc = check_json_file("data/phonics/phonics_units.json")
    for ph in phonics_doc.get("phonics", []):
        pid = str(ph.get("id", ""))
        if not ph.get("letter") or not ph.get("letter_name_ipa") or not ph.get("letter_sound_ipa"):
            errors.append(f"Phonics {pid} missing letter, letter_name_ipa, or letter_sound_ipa")
        if str(ph.get("letter_name_ipa", "")) == str(ph.get("letter_sound_ipa", "")):
            errors.append(f"Phonics {pid} confuses letter_name_ipa with letter_sound_ipa")

    # Validate dialogue adventures mini-game scenarios
    dlg_mg = check_json_file("data/minigames/dialogue_adventures.json")
    for sc in dlg_mg.get("scenarios", []):
        sid = str(sc.get("id", ""))
        for turn in sc.get("turns", []):
            opts = turn.get("options", [])
            correct_count = sum(1 for o in opts if isinstance(o, dict) and o.get("is_correct"))
            if correct_count != 1:
                errors.append(f"dialogue_adventures:{sid} turn has {correct_count} correct options (expected 1)")
            texts = [str(o.get("text_en", "")) for o in opts if isinstance(o, dict)]
            if len(texts) != len(set(texts)):
                errors.append(f"dialogue_adventures:{sid} duplicate option text_en")


def validate_world_quest_progression() -> None:
    areas_doc = check_json_file("data/areas/alphabet_island_areas.json")
    areas = {a["id"]: a for a in areas_doc.get("areas", []) if "id" in a}
    for req_area in ("welcome_village", "alphabet_meadow", "letter_cave", "crystal_lake", "shadow_gate"):
        if req_area not in areas:
            errors.append(f"Missing required area: {req_area}")
        else:
            sp = str(areas[req_area].get("scene_path", ""))
            check_res_asset(sp, f"area:{req_area}")

    npcs_doc = check_json_file("data/npcs/alphabet_island_npcs.json")
    npcs = {n["id"]: n for n in npcs_doc.get("npcs", []) if "id" in n}
    chars_doc = check_json_file("data/characters/playable_characters.json")
    if isinstance(chars_doc.get("buddy"), dict) and chars_doc["buddy"].get("id"):
        npcs[chars_doc["buddy"]["id"]] = chars_doc["buddy"]
    for req_npc in ("professor_owl", "buddy", "lily", "rocky", "crystal_guardian"):
        if req_npc not in npcs:
            errors.append(f"Missing required NPC: {req_npc}")

    dlgs_doc = check_json_file("data/dialogue/alphabet_island_dialogues.json")
    dlgs = dlgs_doc.get("dialogues", {})
    for nid, n in npcs.items():
        did = str(n.get("default_dialogue_id", ""))
        if did and did not in dlgs:
            errors.append(f"NPC {nid} missing default_dialogue_id {did}")
        for rule in n.get("dialogue_rules", []):
            rdid = str(rule.get("dialogue_id", ""))
            if rdid and rdid not in dlgs:
                errors.append(f"NPC {nid} missing rule dialogue_id {rdid}")

    quests_doc = check_json_file("data/quests/world_01_quests.json")
    quests = {q["id"]: q for q in quests_doc.get("quests", []) if "id" in q}
    for req_q in (
        "quest_01_new_adventure",
        "quest_02_lost_letters",
        "quest_03_mysterious_gate",
        "quest_04_crystal_guardian",
        "quest_05_shadow_gate",
    ):
        if req_q not in quests:
            errors.append(f"Missing required quest: {req_q}")
        else:
            q = quests[req_q]
            if not q.get("steps"):
                errors.append(f"Quest {req_q} has no steps")
            if str(q.get("area_id", "")) not in areas:
                errors.append(f"Quest {req_q} references unknown area_id {q.get('area_id')}")


def validate_security_and_privacy() -> None:
    secret_patterns = [
        re.compile(r"service_role", re.IGNORECASE),
        re.compile(r"AZURE_SPEECH_KEY\s*=\s*['\"][A-Za-z0-9]{10,}"),
        re.compile(r"sk-[A-Za-z0-9]{20,}"),
        re.compile(r"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\.[A-Za-z0-9_-]{10,}"),
    ]
    for folder in ("scripts", "data", "scenes"):
        for fp in (ROOT / folder).rglob("*"):
            if fp.suffix.lower() not in (".gd", ".json", ".tscn", ".cfg"):
                continue
            txt = fp.read_text(encoding="utf-8", errors="ignore")
            for pat in secret_patterns:
                if pat.search(txt):
                    errors.append(f"Potential secret/key pattern '{pat.pattern}' found in {fp.relative_to(ROOT)}")

    for cfg_name in ("project.godot", "export_presets.cfg"):
        txt = (ROOT / cfg_name).read_text(encoding="utf-8", errors="ignore")
        for pat in secret_patterns:
            if pat.search(txt):
                errors.append(f"Potential secret/key pattern in {cfg_name}")

    # Verify RLS coverage on Supabase
    rls_p = ROOT / "supabase/migrations/0002_rls_policies.sql"
    if rls_p.exists():
        rls_txt = rls_p.read_text(encoding="utf-8")
        if "ENABLE ROW LEVEL SECURITY" not in rls_txt or "is_profile_owner" not in rls_txt:
            errors.append("Supabase RLS migration missing ownership policy checks")
    else:
        errors.append("Missing supabase/migrations/0002_rls_policies.sql")

    # Verify Edge Functions require Authorization header and read secrets via Deno.env
    for fn_rel in ("supabase/functions/pronunciation-assess/index.ts", "supabase/functions/speech-recognize/index.ts"):
        fn_p = ROOT / fn_rel
        if not fn_p.exists():
            errors.append(f"Missing Edge Function: {fn_rel}")
            continue
        fn_txt = fn_p.read_text(encoding="utf-8")
        if "Authorization" not in fn_txt or 'Deno.env.get("AZURE_SPEECH_KEY")' not in fn_txt:
            errors.append(f"Edge Function {fn_rel} missing auth or env secret guard")


def validate_p8_regressions_and_fixes() -> None:
    # 1. No duplicate achievement toast
    rm_txt = (ROOT / "scripts/progression/reward_manager.gd").read_text(encoding="utf-8")
    if 'EventBus.toast_requested.emit("Thành tựu mới' in rm_txt:
        errors.append("RewardManager.evaluate_achievements still emits duplicate toast_requested alongside achievement_unlocked")

    # 2. No duplicate quest start/completed toast
    qn_txt = (ROOT / "scripts/quest/quest_notification_manager.gd").read_text(encoding="utf-8")
    if 'toast_requested.emit("Nhiệm vụ mới:' in qn_txt or 'toast_requested.emit("Hoàn thành nhiệm vụ:' in qn_txt:
        errors.append("QuestNotificationManager still emits duplicate toast_requested alongside UIManager quest events")

    # 3. MiniGame input lock during feedback
    mgc_txt = (ROOT / "scripts/minigames/minigame_controller.gd").read_text(encoding="utf-8")
    if "func set_input_locked(" not in mgc_txt:
        errors.append("MiniGameController missing set_input_locked() to block multi-answer spam during feedback")

    mgui_txt = (ROOT / "scripts/minigames/ui/minigame_ui.gd").read_text(encoding="utf-8")
    if "set_input_locked(true)" not in mgui_txt or "set_input_locked(false)" not in mgui_txt:
        errors.append("MiniGameUI must lock/unlock controller input around feedback panel")

    # 4. Audio stops cleanly on closing modals & scene transitions
    lhm_txt = (ROOT / "scripts/learning/learning_hub_modal.gd").read_text(encoding="utf-8")
    if "stop_all_speech()" not in lhm_txt:
        errors.append("LearningHubModal must stop playback audio on close/tab switch")

    sr_txt = (ROOT / "scripts/core/scene_router.gd").read_text(encoding="utf-8")
    if "stop_all_speech()" not in sr_txt:
        errors.append("SceneRouter must stop active speech playback before scene transition")

    # 5. SaveLoadManager backup recovery & schema type validation
    slm_txt = (ROOT / "scripts/services/save_load_manager.gd").read_text(encoding="utf-8")
    if "active_profile.bak.json" not in slm_txt:
        errors.append("SaveLoadManager missing rolling backup file active_profile.bak.json")
    if "typeof(data.get(\"unlocked_areas\")) != TYPE_ARRAY" not in slm_txt:
        errors.append("SaveLoadManager._validate_save_schema must validate unlocked_areas type")

    # 6. Pre-collected world objective sync in QuestManager
    qm_txt = (ROOT / "scripts/quest/quest_manager.gd").read_text(encoding="utf-8")
    if "_sync_precompleted_world_objectives" not in qm_txt:
        errors.append("QuestManager missing _sync_precompleted_world_objectives to prevent soft-locks on pre-collected letters/crystals")

    # 7. 3D material/mesh caching & dynamic particle quality
    ae_txt = (ROOT / "scripts/visual3d/area_environment_3d.gd").read_text(encoding="utf-8")
    if "_mat_cache" not in ae_txt:
        errors.append("AreaEnvironment3D missing shared _mat_cache for draw-call/VRAM optimization")
    we_txt = (ROOT / "scripts/visual3d/world_environment_3d.gd").read_text(encoding="utf-8")
    if "quality_particles" not in we_txt:
        errors.append("WorldEnvironment3DController missing dynamic quality_particles handling")


def main() -> int:
    validate_content_quality()
    validate_world_quest_progression()
    validate_security_and_privacy()
    validate_p8_regressions_and_fixes()

    if warnings:
        print(f"Prompt 08 Warnings ({len(warnings)}):")
        for w in warnings:
            print("  WARN:", w)

    if errors:
        print(f"Prompt 08 Verification FAILED ({len(errors)} errors):")
        for e in errors:
            print("  ERROR:", e)
        return 1

    print("Prompt 08 Verification PASSED (Content, Quests, Security, Regression & 3D Optimization checks passed).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
