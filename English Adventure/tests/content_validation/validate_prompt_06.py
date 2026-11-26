#!/usr/bin/env python3
"""
Prompt 06 Automated Verification Suite for ENGLISH ADVENTURE
Quest, NPC, Reward, Inventory & World Progression Integration.
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
errors = []

REQUIRED_FILES = [
    "data/quests/chapters.json",
    "data/items/world_01_items.json",
    "data/rewards/achievements.json",
    "supabase/migrations/0005_quest_reward_inventory_integration.sql",
    "scripts/quest/quest_repository.gd",
    "scripts/quest/quest_registry.gd",
    "scripts/quest/quest_instance.gd",
    "scripts/quest/quest_condition_evaluator.gd",
    "scripts/quest/quest_state_manager.gd",
    "scripts/quest/quest_objective_manager.gd",
    "scripts/quest/quest_progress_tracker.gd",
    "scripts/quest/quest_reward_manager.gd",
    "scripts/quest/quest_notification_manager.gd",
    "scripts/quest/quest_event_handler.gd",
    "scripts/quest/quest_manager.gd",
    "scripts/progression/reward_manager.gd",
    "scripts/progression/inventory_manager.gd",
    "scripts/progression/achievement_manager.gd",
    "docs/GAMEPLAY_LOOP.md",
    "docs/QUEST_INTEGRATION.md",
    "docs/NPC_INTERACTION.md",
    "docs/DIALOGUE_INTEGRATION.md",
    "docs/REWARD_SYSTEM.md",
    "docs/INVENTORY_SYSTEM.md",
    "docs/WORLD_PROGRESSION.md",
    "docs/EVENT_SYSTEM.md",
    "docs/SAVE_LOAD_INTEGRATION.md",
    "docs/CHAPTER_DESIGN.md",
    "docs/END_TO_END_TEST_REPORT.md",
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
            errors.append(f"Missing Prompt 06 file: {rel}")

    pg = (ROOT / "project.godot").read_text(encoding="utf-8")
    if "RewardManager=" not in pg:
        errors.append("RewardManager autoload missing from project.godot")

    eb = (ROOT / "scripts/core/event_bus.gd").read_text(encoding="utf-8")
    for sig in (
        "player_interacted_with_npc",
        "dialogue_completed",
        "quest_accepted",
        "quest_objective_updated",
        "quest_reward_claimed",
        "region_unlocked",
        "region_completed",
        "chapter_completed",
        "inventory_item_used",
        "reward_granted",
    ):
        if f"signal {sig}" not in eb:
            errors.append(f"Missing Prompt 06 signal in EventBus: {sig}")

    quests_doc = load_json("data/quests/world_01_quests.json")
    quests = {q["id"]: q for q in quests_doc.get("quests", [])}
    for req_q in (
        "quest_01_new_adventure",
        "quest_02_lost_letters",
        "quest_03_mysterious_gate",
        "quest_04_crystal_guardian",
        "quest_05_shadow_gate",
        "side_buddy_treasure",
        "side_lily_garden",
        "side_rocky_animals",
    ):
        if req_q not in quests:
            errors.append(f"Missing quest in world_01_quests.json: {req_q}")

    chapters_doc = load_json("data/quests/chapters.json")
    chapters = chapters_doc.get("chapters", [])
    if len(chapters) < 5:
        errors.append(f"Expected 5 chapters in chapters.json, found {len(chapters)}")

    items_doc = load_json("data/items/world_01_items.json")
    items = {it["id"]: it for it in items_doc.get("items", [])}
    for req_it in ("magic_crystal_shard", "golden_key", "star_fragment", "explorer_badge", "lost_letters_abc"):
        if req_it not in items:
            errors.append(f"Missing item definition in world_01_items.json: {req_it}")

    ach_doc = load_json("data/rewards/achievements.json")
    if len(ach_doc.get("achievements", [])) < 5:
        errors.append("Expected >= 5 achievements in achievements.json")

    dlgs = load_json("data/dialogue/alphabet_island_dialogues.json").get("dialogues", {})
    has_choices = any(
        isinstance(line, dict) and line.get("choices")
        for lines in dlgs.values() if isinstance(lines, list)
        for line in lines
    )
    if not has_choices:
        errors.append("Expected interactive dialogue choices in alphabet_island_dialogues.json")

    # GDScript 4.3 Variant trap check
    pat = re.compile(r'var\s+\w+\s*:=\s*[A-Za-z0-9_.\[\]"\']+\.get\([^)]*\)\s*$')
    for gd in (ROOT / "scripts").rglob("*.gd"):
        for idx, line in enumerate(gd.read_text(encoding="utf-8").splitlines(), 1):
            if pat.search(line):
                errors.append(f"GDScript 4.3 Variant inference trap in {gd.relative_to(ROOT)}:{idx}: {line.strip()}")

    if errors:
        print("PROMPT 06 VALIDATION FAILED:")
        for e in errors:
            print(" -", e)
        sys.exit(1)

    print(f"Checked Prompt 06 files: {len(REQUIRED_FILES)}")
    print(f"Checked quests: {len(quests)}, chapters: {len(chapters)}, items: {len(items)}")
    print("ALL PROMPT 06 CHECKS PASSED SUCCESSFULLY!")


if __name__ == "__main__":
    main()
