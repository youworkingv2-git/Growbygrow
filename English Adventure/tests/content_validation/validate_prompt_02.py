#!/usr/bin/env python3
"""
Prompt 02 Automated Verification Suite for ENGLISH ADVENTURE.
Validates:
1. All JSON files (worlds, areas, characters, NPCs, dialogues, quests, objects, localization).
2. All res:// paths in project.godot, .tscn scenes, .gd scripts, and .json data exist on disk.
3. All .tscn ExtResource/SubResource references and @onready node paths match scene trees.
4. Full Quest & Area Unlock progression graph simulation (no deadlocks).
"""

import json
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
errors = []


def res_to_path(res_path: str) -> Path:
    assert res_path.startswith("res://"), f"Not a res:// path: {res_path}"
    return ROOT / res_path[len("res://"):]


def check_json_files():
    json_files = list((ROOT / "data").rglob("*.json")) + list((ROOT / "localization").rglob("*.json"))
    parsed = {}
    for jf in json_files:
        try:
            with open(jf, "r", encoding="utf-8") as f:
                parsed[jf.relative_to(ROOT).as_posix()] = json.load(f)
        except Exception as e:
            errors.append(f"Invalid JSON {jf}: {e}")
    return parsed


def check_res_references():
    patterns = [
        re.compile(r'"(res://[^"]+)"'),
        re.compile(r'path="(res://[^"]+)"'),
        re.compile(r'=\*"?(res://[^"\s]+)"?'),
    ]
    checked = 0
    for ext in ("*.godot", "*.tscn", "*.gd", "*.json"):
        files = [ROOT / "project.godot"] if ext == "*.godot" else list(ROOT.rglob(ext))
        for fp in files:
            if ".godot" in fp.parts and fp.name != "project.godot":
                continue
            text = fp.read_text(encoding="utf-8")
            for pat in patterns:
                for m in pat.finditer(text):
                    rp = m.group(1)
                    if "*" in rp or "{" in rp:
                        continue
                    checked += 1
                    disk_path = res_to_path(rp)
                    if not disk_path.exists():
                        errors.append(f"Missing res:// target {rp} referenced in {fp.relative_to(ROOT)}")
    return checked


def parse_tscn_nodes(tscn_path: Path):
    text = tscn_path.read_text(encoding="utf-8")
    ext_ids = set(re.findall(r'\[ext_resource [^\]]*id="([^"]+)"', text))
    sub_ids = set(re.findall(r'\[sub_resource [^\]]*id="([^"]+)"', text))
    for ref in re.findall(r'ExtResource\("([^"]+)"\)', text):
        if ref not in ext_ids:
            errors.append(f"{tscn_path.relative_to(ROOT)}: undefined ExtResource({ref})")
    for ref in re.findall(r'SubResource\("([^"]+)"\)', text):
        if ref not in sub_ids:
            errors.append(f"{tscn_path.relative_to(ROOT)}: undefined SubResource({ref})")

    nodes = set()
    root_name = None
    for m in re.finditer(r'^\[node name="([^"]+)"(?: type="[^"]+")?(?: parent="([^"]*)")?', text, re.M):
        name, parent = m.group(1), m.group(2)
        if parent is None:
            root_name = name
            nodes.add(".")
        elif parent == ".":
            nodes.add(name)
        else:
            nodes.add(f"{parent}/{name}")
    return root_name, nodes


def check_onready_paths():
    checked = 0
    for tscn in ROOT.rglob("*.tscn"):
        _, nodes = parse_tscn_nodes(tscn)
        text = tscn.read_text(encoding="utf-8")
        # Map ext_resource id -> res:// script path
        script_map = {}
        for sm in re.finditer(r'\[ext_resource type="Script" path="(res://[^"]+)" id="([^"]+)"\]', text):
            script_map[sm.group(2)] = sm.group(1)
        if not script_map:
            continue

        # Parse each node block in tscn to get its path and attached script
        blocks = re.split(r'(?=^\[node )', text, flags=re.M)
        for blk in blocks:
            hm = re.match(r'^\[node name="([^"]+)"(?: type="[^"]+")?(?: parent="([^"]*)")?[^\]]*\]', blk)
            if not hm:
                continue
            name, parent = hm.group(1), hm.group(2)
            node_prefix = "" if parent is None else (name if parent == "." else f"{parent}/{name}")
            scm = re.search(r'script = ExtResource\("([^"]+)"\)', blk)
            if not scm or scm.group(1) not in script_map:
                continue
            gd_path = res_to_path(script_map[scm.group(1)])
            if not gd_path.exists():
                continue
            gd_text = gd_path.read_text(encoding="utf-8")
            for om in re.finditer(r'@onready\s+var\s+\w+[^=]*=\s*\$([A-Za-z0-9_/]+)', gd_text):
                rel = om.group(1)
                full_target = rel if node_prefix == "" else f"{node_prefix}/{rel}"
                checked += 1
                if full_target not in nodes:
                    errors.append(f"Node path ${rel} (resolved '{full_target}') in {gd_path.relative_to(ROOT)} not found in {tscn.relative_to(ROOT)}")
    return checked


def simulate_quest_and_unlock_graph(data):
    areas = {a["id"]: a for a in data["data/areas/alphabet_island_areas.json"]["areas"]}
    quests = {q["id"]: q for q in data["data/quests/world_01_quests.json"]["quests"]}
    npcs = {n["id"]: n for n in data["data/npcs/alphabet_island_npcs.json"]["npcs"]}
    objects = {o["id"]: o for o in data["data/interactions/alphabet_island_objects.json"]["objects"]}
    dialogues = data["data/dialogue/alphabet_island_dialogues.json"]["dialogues"]

    # Validate NPC dialogues exist
    for nid, npc in npcs.items():
        did = npc.get("default_dialogue_id")
        if did not in dialogues:
            errors.append(f"NPC {nid} references missing dialogue {did}")

    # Simulate progression
    state = {
        "unlocked_areas": ["welcome_village"],
        "completed_quests": [],
        "flags": {},
        "inventory": {}
    }

    def eval_cond(cond):
        t = cond.get("type", "always_unlocked")
        if t in ("always_unlocked", "always_available", "always"):
            return True
        if t == "quests_completed":
            return all(q in state["completed_quests"] for q in cond.get("required_quests", []))
        if t == "flags_required":
            return all(state["flags"].get(f, False) for f in cond.get("required_flags", []))
        if t == "quests_and_items":
            return (
                all(q in state["completed_quests"] for q in cond.get("required_quests", []))
                and all(state["inventory"].get(i, 0) > 0 for i in cond.get("required_items", []))
            )
        return False

    def refresh_unlocks():
        for aid, a in areas.items():
            if aid not in state["unlocked_areas"] and eval_cond(a.get("unlock_condition", {})):
                state["unlocked_areas"].append(aid)

    # Complete Quest 01
    assert eval_cond(quests["quest_01_new_adventure"]["start_condition"])
    state["completed_quests"].append("quest_01_new_adventure")
    refresh_unlocks()
    assert "alphabet_meadow" in state["unlocked_areas"], "Quest 01 failed to unlock alphabet_meadow"

    # Complete Quest 02
    assert eval_cond(quests["quest_02_lost_letters"]["start_condition"])
    state["completed_quests"].append("quest_02_lost_letters")
    refresh_unlocks()
    assert "letter_cave" in state["unlocked_areas"], "Quest 02 failed to unlock letter_cave"

    # Talk to Rocky -> flag -> unlocks crystal_lake
    rocky_flag = npcs["rocky"].get("on_talk_set_flag")
    assert rocky_flag == "rocky_clue_found"
    state["flags"][rocky_flag] = True
    refresh_unlocks()
    assert "crystal_lake" in state["unlocked_areas"], "Rocky clue failed to unlock crystal_lake"

    # Complete Quest 03 -> crystal shard + unlocks shadow_gate
    assert eval_cond(quests["quest_03_mysterious_gate"]["start_condition"])
    state["completed_quests"].append("quest_03_mysterious_gate")
    for item in quests["quest_03_mysterious_gate"]["rewards"]["items"]:
        state["inventory"][item["id"]] = item["quantity"]
    refresh_unlocks()
    assert "shadow_gate" in state["unlocked_areas"], "Quest 03 failed to unlock shadow_gate"

    # Inspect Shadow Gate
    gate_flag = objects["obj_shadow_gate_seal"]["set_flag"]
    state["flags"][gate_flag] = True
    assert eval_cond(areas["shadow_gate"]["completion_condition"]), "Shadow Gate completion condition not met"


def main():
    parsed_json = check_json_files()
    res_count = check_res_references()
    onready_count = check_onready_paths()
    if not errors:
        simulate_quest_and_unlock_graph(parsed_json)

    print(f"Checked JSON files: {len(parsed_json)}")
    print(f"Checked res:// references: {res_count}")
    print(f"Checked @onready node paths: {onready_count}")
    if errors:
        print("VALIDATION FAILED:")
        for e in errors:
            print(" -", e)
        sys.exit(1)
    print("ALL PROMPT 02 CHECKS PASSED SUCCESSFULLY!")


if __name__ == "__main__":
    main()
