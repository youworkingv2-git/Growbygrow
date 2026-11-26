#!/usr/bin/env python3
"""
Prompt 03 Automated Verification Suite for ENGLISH ADVENTURE UI/UX System.
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
errors = []

REQUIRED_FILES = [
    "scripts/core/settings_manager.gd",
    "scripts/audio/audio_manager.gd",
    "scripts/ui/managers/ui_design_system.gd",
    "scripts/ui/managers/ui_manager.gd",
    "scripts/ui/animations/ui_animator.gd",
    "scripts/ui/responsive/responsive_helper.gd",
    "scripts/ui/components/confirmation_dialog.gd",
    "scripts/ui/components/reward_display.gd",
    "scripts/ui/components/quest_card.gd",
    "scripts/ui/components/loading_indicator.gd",
    "scripts/ui/components/avatar_badge.gd",
    "scripts/ui/components/world_card.gd",
    "scripts/ui/screens/main_menu_ui.gd",
    "scripts/ui/screens/settings_ui.gd",
    "scripts/ui/screens/pause_menu_ui.gd",
    "scenes/boot/main_entry.tscn",
    "scenes/ui/main_menu/main_menu.tscn",
    "scenes/ui/settings/settings_modal.tscn",
    "scenes/ui/pause_menu/pause_menu.tscn",
    "scenes/ui/common/confirmation_dialog.tscn",
    "scenes/ui/common/reward_display.tscn",
    "scenes/ui/common/quest_card.tscn",
    "scenes/ui/common/loading_indicator.tscn",
    "scenes/authentication/character_selection.tscn",
    "scenes/world/world_introduction.tscn",
    "scenes/world/world_map/world_map.tscn",
    "scenes/ui/adventure_hud.tscn",
]


def check_required_files():
    for rel in REQUIRED_FILES:
        if not (ROOT / rel).exists():
            errors.append(f"Missing required Prompt 03 file: {rel}")


def check_project_autoloads():
    pg = (ROOT / "project.godot").read_text(encoding="utf-8")
    for autoload in ("SettingsManager", "AudioManager", "UIManager", "SceneRouter", "QuestManager", "GameStateManager"):
        if f"{autoload}=" not in pg:
            errors.append(f"Missing autoload in project.godot: {autoload}")


def check_localization_parity():
    vi = json.loads((ROOT / "localization/vi/ui_strings.json").read_text(encoding="utf-8"))
    en = json.loads((ROOT / "localization/en/ui_strings.json").read_text(encoding="utf-8"))
    missing_en = set(vi.keys()) - set(en.keys())
    missing_vi = set(en.keys()) - set(vi.keys())
    if missing_en:
        errors.append(f"Missing EN keys: {sorted(missing_en)}")
    if missing_vi:
        errors.append(f"Missing VI keys: {sorted(missing_vi)}")


def check_gdscript_variant_trap():
    # Catch bare `var foo := bar.get(...)` which fails GDScript 4.3 Variant type inference
    pat = re.compile(r'var\s+\w+\s*:=\s*[A-Za-z0-9_.\[\]"\']+\.get\([^)]*\)\s*$')
    for gd in (ROOT / "scripts").rglob("*.gd"):
        text = gd.read_text(encoding="utf-8")
        for idx, line in enumerate(text.splitlines(), 1):
            if pat.search(line):
                errors.append(f"Possible GDScript 4.3 Variant inference trap in {gd.relative_to(ROOT)}:{idx}: {line.strip()}")


def main():
    check_required_files()
    check_project_autoloads()
    check_localization_parity()
    check_gdscript_variant_trap()
    if errors:
        print("PROMPT 03 VALIDATION FAILED:")
        for e in errors:
            print(" -", e)
        sys.exit(1)
    print(f"Checked required UI/UX files: {len(REQUIRED_FILES)}")
    print("ALL PROMPT 03 CHECKS PASSED SUCCESSFULLY!")


if __name__ == "__main__":
    main()
