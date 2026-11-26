#!/usr/bin/env python3
"""
Addendum 3D Visual Direction Verification Suite for ENGLISH ADVENTURE.
Validates:
1. Gameplay entities (Player, Buddy, NPC, InteractableObject) and all 5 areas are true 3D scenes (no Sprite2D pretending to be 3D characters).
2. Third-person camera rig (CameraPivot -> SpringArm3D -> Camera3D) exists on Player.
3. All 7 required 3D characters are supported in CharacterRig3D.
4. WorldMap, CharacterSelection, MainMenu, and WorldIntroduction embed own_world_3d SubViewport 3D dioramas.
5. Graphics Quality tiers (low, medium, high) and Asset3DSlot pipeline exist.
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
errors = []

SCENE_3D_CHECKS = [
    ("scenes/characters/player/player.tscn", 'type="CharacterBody3D"', ["SpringArm3D", "Camera3D", "VisualSlot"]),
    ("scenes/characters/buddy/buddy.tscn", 'type="Node3D"', ["VisualSlot", "SpeechLayer"]),
    ("scenes/characters/npcs/npc.tscn", 'type="Area3D"', ["VisualSlot", "NameLabel3D", "QuestBadge3D"]),
    ("scenes/interactions/interactable_object.tscn", 'type="Area3D"', ["VisualSlot", "Label3D", "FocusRing"]),
    ("scenes/world/alphabet_island/area_exploration.tscn", 'type="Node3D"', ["WorldEnvironment", "DirectionalLight3D", "Entities3D"]),
    ("scenes/world/areas/welcome_village.tscn", 'type="Node3D"', ["ObjectSpawns", "PortalSpawns"]),
    ("scenes/world/areas/alphabet_meadow.tscn", 'type="Node3D"', ["ObjectSpawns", "PortalSpawns"]),
    ("scenes/world/areas/letter_cave.tscn", 'type="Node3D"', ["ObjectSpawns", "PortalSpawns"]),
    ("scenes/world/areas/crystal_lake.tscn", 'type="Node3D"', ["ObjectSpawns", "PortalSpawns"]),
    ("scenes/world/areas/shadow_gate.tscn", 'type="Node3D"', ["ObjectSpawns", "PortalSpawns"]),
]

UI_3D_SUBVIEWPORT_SCENES = [
    "scenes/boot/main_entry.tscn",
    "scenes/world/world_map/world_map.tscn",
    "scenes/authentication/character_selection.tscn",
    "scenes/ui/main_menu/main_menu.tscn",
    "scenes/world/world_introduction.tscn",
]

REQUIRED_CHARACTER_RIGS = [
    "boy",
    "girl",
    "buddy",
    "professor_owl",
    "lily",
    "rocky",
    "crystal_guardian",
]


def check_3d_scenes():
    for rel, root_type, required_tokens in SCENE_3D_CHECKS:
        p = ROOT / rel
        if not p.exists():
            errors.append(f"Missing 3D scene: {rel}")
            continue
        text = p.read_text(encoding="utf-8")
        if root_type not in text:
            errors.append(f"{rel} does not have expected root {root_type}")
        if "Sprite2D" in text or "CharacterBody2D" in text or "Node2D" in text:
            errors.append(f"{rel} still contains 2D world nodes (Sprite2D/CharacterBody2D/Node2D)!")
        for tok in required_tokens:
            if tok not in text:
                errors.append(f"{rel} missing required 3D node/token: {tok}")


def check_ui_3d_dioramas():
    for rel in UI_3D_SUBVIEWPORT_SCENES:
        p = ROOT / rel
        text = p.read_text(encoding="utf-8")
        if "SubViewportContainer" not in text or "own_world_3d = true" not in text:
            errors.append(f"{rel} missing SubViewportContainer with own_world_3d = true")


def check_character_rigs():
    rig_file = ROOT / "scripts/visual3d/character_rig_3d.gd"
    if not rig_file.exists():
        errors.append("Missing scripts/visual3d/character_rig_3d.gd")
        return
    text = rig_file.read_text(encoding="utf-8")
    if "is_placeholder" not in text:
        errors.append("CharacterRig3D must explicitly mark placeholder models via is_placeholder")
    for cid in REQUIRED_CHARACTER_RIGS:
        if cid not in text:
            errors.append(f"CharacterRig3D missing character implementation for: {cid}")


def check_quality_and_asset_slot():
    sm = (ROOT / "scripts/core/settings_manager.gd").read_text(encoding="utf-8")
    if "graphics_quality" not in sm:
        errors.append("SettingsManager missing graphics_quality setting")
    env3d = (ROOT / "scripts/visual3d/world_environment_3d.gd").read_text(encoding="utf-8")
    for tier in ('"low"', '"medium"', '"high"'):
        if tier not in env3d:
            errors.append(f"WorldEnvironment3DController missing quality tier {tier}")
    slot = (ROOT / "scripts/visual3d/asset_3d_slot.gd").read_text(encoding="utf-8")
    if "override_model_path" not in slot or "is_placeholder" not in slot or "attach_or_placeholder" not in slot or "asset_id" not in slot:
        errors.append("Asset3DSlot missing override_model_path, is_placeholder, asset_id, or attach_or_placeholder")


def main():
    check_3d_scenes()
    check_ui_3d_dioramas()
    check_character_rigs()
    check_quality_and_asset_slot()
    if errors:
        print("3D VISUAL DIRECTION VALIDATION FAILED:")
        for e in errors:
            print(" -", e)
        sys.exit(1)
    print(f"Checked 3D gameplay & area scenes: {len(SCENE_3D_CHECKS)}")
    print(f"Checked 3D UI dioramas: {len(UI_3D_SUBVIEWPORT_SCENES)}")
    print(f"Checked 3D character rigs: {len(REQUIRED_CHARACTER_RIGS)}")
    print("ALL 3D VISUAL DIRECTION CHECKS PASSED SUCCESSFULLY!")


if __name__ == "__main__":
    main()
