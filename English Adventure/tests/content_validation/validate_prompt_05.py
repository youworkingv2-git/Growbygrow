#!/usr/bin/env python3
"""
Prompt 05 Automated Verification Suite for ENGLISH ADVENTURE Mini-Game System.
"""

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
errors = []

REQUIRED_FILES = [
    "data/minigames/minigame_registry.json",
    "data/minigames/dialogue_adventures.json",
    "supabase/migrations/0004_minigame_system_extensions.sql",
    "scenes/minigames/minigame_host_modal.tscn",
    "scripts/minigames/minigame_registry.gd",
    "scripts/minigames/minigame_difficulty.gd",
    "scripts/minigames/minigame_scoring.gd",
    "scripts/minigames/minigame_reward.gd",
    "scripts/minigames/minigame_feedback.gd",
    "scripts/minigames/minigame_audio_manager.gd",
    "scripts/minigames/minigame_result.gd",
    "scripts/minigames/minigame_session.gd",
    "scripts/minigames/minigame_data_provider.gd",
    "scripts/minigames/minigame_controller.gd",
    "scripts/minigames/minigame_factory.gd",
    "scripts/minigames/minigame_manager.gd",
    "scripts/minigames/ui/minigame_ui.gd",
    "scripts/minigames/games/game_listen_and_find.gd",
    "scripts/minigames/games/game_word_builder.gd",
    "scripts/minigames/games/game_word_matching.gd",
    "scripts/minigames/games/game_sentence_builder.gd",
    "scripts/minigames/games/game_sound_detective.gd",
    "scripts/minigames/games/game_speaking_hero.gd",
    "scripts/minigames/games/game_memory_quest.gd",
    "scripts/minigames/games/game_dialogue_adventure.gd",
    "docs/MINIGAME_SYSTEM.md",
    "docs/MINIGAME_ARCHITECTURE.md",
    "docs/MINIGAME_REGISTRY.md",
    "docs/LISTENING_MINIGAMES.md",
    "docs/SPEAKING_MINIGAMES.md",
    "docs/READING_MINIGAMES.md",
    "docs/WRITING_MINIGAMES.md",
    "docs/MINIGAME_DIFFICULTY.md",
    "docs/MINIGAME_SCORING.md",
    "docs/MINIGAME_FEEDBACK.md",
    "docs/MINIGAME_ASSET_LIST.md",
    "docs/MINIGAME_TEST_REPORT.md",
]


def check_required_files():
    for rel in REQUIRED_FILES:
        if not (ROOT / rel).exists():
            errors.append(f"Missing Prompt 05 required file: {rel}")


def check_autoload_and_signals():
    pg = (ROOT / "project.godot").read_text(encoding="utf-8")
    if "MiniGameManager=" not in pg:
        errors.append("MiniGameManager autoload missing from project.godot")
    eb = (ROOT / "scripts/core/event_bus.gd").read_text(encoding="utf-8")
    for sig in ("minigame_started", "minigame_answered", "minigame_completed"):
        if f"signal {sig}" not in eb:
            errors.append(f"Missing signal in EventBus: {sig}")


def check_registry_and_dialogues():
    reg = json.loads((ROOT / "data/minigames/minigame_registry.json").read_text(encoding="utf-8"))
    entries = reg.get("minigames", [])
    by_id = {e["id"]: e for e in entries}
    core_8 = [
        "listen_and_find", "word_builder", "word_matching", "sentence_builder",
        "sound_detective", "speaking_hero", "memory_quest", "dialogue_adventure",
    ]
    for gid in core_8:
        if gid not in by_id:
            errors.append(f"Missing core minigame in registry: {gid}")
        elif not str(by_id[gid].get("availability_status", "")).startswith("playable"):
            errors.append(f"Core minigame {gid} must be playable_*")
    planned = [e for e in entries if e.get("availability_status") == "planned_template"]
    if len(planned) < 6:
        errors.append("Expected extensible planned_template entries in minigame_registry.json")

    vocab_doc = json.loads((ROOT / "data/vocabulary/world_01_vocab.json").read_text(encoding="utf-8"))
    vocab_ids = {w["id"] for w in vocab_doc.get("vocabulary", [])}
    dlg_doc = json.loads((ROOT / "data/minigames/dialogue_adventures.json").read_text(encoding="utf-8"))
    scenarios = dlg_doc.get("scenarios", [])
    if len(scenarios) < 8:
        errors.append(f"Expected 8 dialogue scenarios, found {len(scenarios)}")
    for sc in scenarios:
        for wid in sc.get("linked_vocab_ids", []):
            if wid not in vocab_ids:
                errors.append(f"Dialogue scenario {sc.get('id')} references unknown vocab id: {wid}")
        if len(sc.get("turns", [])) < 2:
            errors.append(f"Dialogue scenario {sc.get('id')} should have at least 2 turns")


def check_speaking_honesty():
    sh = (ROOT / "scripts/minigames/games/game_speaking_hero.gd").read_text(encoding="utf-8")
    if "chưa tích hợp" not in sh.lower() and "chờ tích hợp" not in sh.lower():
        errors.append("Speaking Hero must explicitly display pending ASR/AI pronunciation scoring status")


def main():
    check_required_files()
    check_autoload_and_signals()
    check_registry_and_dialogues()
    check_speaking_honesty()
    if errors:
        print("PROMPT 05 VALIDATION FAILED:")
        for e in errors:
            print(" -", e)
        sys.exit(1)
    print(f"Checked Prompt 05 files: {len(REQUIRED_FILES)}")
    print("ALL PROMPT 05 CHECKS PASSED SUCCESSFULLY!")


if __name__ == "__main__":
    main()
