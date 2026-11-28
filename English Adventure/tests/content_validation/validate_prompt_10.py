#!/usr/bin/env python3
"""
Prompt 10 Automated Release Readiness & Multi-Platform Config Validator.
Checks:
1. Unified semantic versioning across version.json, project.godot, export_presets.cfg.
2. Development vs Release build configuration hygiene & zero embedded secrets.
3. Save schema migration (v1->v2) & backup safeguards in SaveLoadManager.
4. Background audio/microphone pause safeguards in AudioManager.
5. Export presets integrity (Web, Windows Desktop, Android APK, Android AAB, iOS).
6. Required 20 release documents in docs/release/.
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
errors: list[str] = []


def main() -> int:
    ver_path = ROOT / "data/release/version.json"
    if not ver_path.exists():
        errors.append("Missing data/release/version.json")
        return 1
    ver_meta = json.loads(ver_path.read_text(encoding="utf-8"))
    ver = str(ver_meta.get("version", ""))
    bnum = int(ver_meta.get("build_number", 0))
    if not re.match(r"^\d+\.\d+\.\d+$", ver):
        errors.append(f"Version '{ver}' does not follow MAJOR.MINOR.PATCH semver")
    if bnum <= 0:
        errors.append(f"Invalid build_number: {bnum}")

    # 1. Check project.godot alignment
    godot_txt = (ROOT / "project.godot").read_text(encoding="utf-8")
    m = re.search(r'config/version="([^"]+)"', godot_txt)
    if not m or m.group(1) != ver:
        errors.append(f"project.godot config/version ({m.group(1) if m else 'missing'}) != version.json ({ver})")

    # 2. Check export_presets.cfg alignment & zero secret leakage
    ep_path = ROOT / "export_presets.cfg"
    if not ep_path.exists():
        errors.append("Missing export_presets.cfg")
    else:
        ep_txt = ep_path.read_text(encoding="utf-8")
        for req_preset in ('name="Web"', 'name="Windows Desktop"', 'name="Android"', 'name="Android AAB"', 'name="iOS"'):
            if req_preset not in ep_txt:
                errors.append(f"export_presets.cfg missing preset {req_preset}")
        if f'application/product_version="{ver}.0"' not in ep_txt:
            errors.append("Windows export preset product_version mismatch")
        if f'version/name="{ver}"' not in ep_txt or f'version/code={bnum}' not in ep_txt:
            errors.append("Android export preset version/code mismatch")
        if f'application/short_version="{ver}"' not in ep_txt or f'application/version="{bnum}"' not in ep_txt:
            errors.append("iOS export preset version mismatch")
        # Must NOT contain non-empty keystore passwords or team ids
        for sec_key in ("keystore/release_password", "keystore/debug_password", "application/app_store_team_id"):
            for sm in re.finditer(rf'{re.escape(sec_key)}="([^"]*)"', ep_txt):
                if sm.group(1).strip():
                    errors.append(f"Security violation: non-empty {sec_key} in export_presets.cfg")

    # 3. Secret scan across client scripts, scenes, data, and configs
    forbidden_patterns = [
        re.compile(r"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+"),  # Hardcoded JWT
        re.compile(r"SUPABASE_SERVICE_ROLE_KEY\s*=\s*['\"][^'\"]+['\"]"),
        re.compile(r"AZURE_SPEECH_KEY\s*=\s*['\"][^'\"]+['\"]"),
    ]
    for folder in ("scripts", "scenes", "data", "localization"):
        for fp in (ROOT / folder).rglob("*"):
            if fp.is_file():
                txt = fp.read_text(encoding="utf-8", errors="ignore")
                for pat in forbidden_patterns:
                    if pat.search(txt):
                        errors.append(f"Potential secret detected in {fp.relative_to(ROOT)}")

    # 4. Save migration & Audio background pause checks
    save_txt = (ROOT / "scripts/services/save_load_manager.gd").read_text(encoding="utf-8")
    if "func migrate_save_data(" not in save_txt or "_backup_pre_migration(" not in save_txt:
        errors.append("SaveLoadManager missing migrate_save_data or _backup_pre_migration")

    audio_txt = (ROOT / "scripts/audio/audio_manager.gd").read_text(encoding="utf-8")
    if "NOTIFICATION_APPLICATION_PAUSED" not in audio_txt or "_on_app_backgrounded" not in audio_txt:
        errors.append("AudioManager missing background/focus-out audio & microphone safety")

    settings_txt = (ROOT / "scripts/ui/screens/settings_ui.gd").read_text(encoding="utf-8")
    if "ReleaseInfo" not in settings_txt:
        errors.append("SettingsModalUI must display unified ReleaseInfo version/privacy summary")

    # 5. Check all 20 required release docs
    required_docs = [
        "RELEASE_PLAN.md",
        "VERSIONING.md",
        "BUILD_CONFIGURATION.md",
        "WINDOWS_RELEASE_GUIDE.md",
        "ANDROID_RELEASE_GUIDE.md",
        "IOS_RELEASE_GUIDE.md",
        "WEB_RELEASE_GUIDE.md",
        "STORE_ASSETS_CHECKLIST.md",
        "STORE_DESCRIPTION_VI.md",
        "STORE_DESCRIPTION_EN.md",
        "PRIVACY_POLICY_DRAFT.md",
        "TERMS_OF_USE_DRAFT.md",
        "DATA_DELETION_GUIDE.md",
        "SAVE_MIGRATION_GUIDE.md",
        "RELEASE_TEST_PLAN.md",
        "RELEASE_TEST_REPORT.md",
        "KNOWN_RELEASE_ISSUES.md",
        "RELEASE_NOTES.md",
        "RELEASE_CHECKLIST.md",
        "POST_RELEASE_SUPPORT.md",
    ]
    rel_dir = ROOT / "docs/release"
    for d in required_docs:
        dp = rel_dir / d
        if not dp.exists() or dp.stat().st_size < 100:
            errors.append(f"Missing or incomplete release doc: docs/release/{d}")

    if errors:
        print(f"PROMPT 10 VALIDATION FAILED ({len(errors)} errors):")
        for e in errors:
            print(" -", e)
        return 1

    print(f"PROMPT 10 VALIDATION PASSED: Version={ver} (Build {bnum}), 5 export presets, zero secrets, save migration & 20 release docs verified.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
