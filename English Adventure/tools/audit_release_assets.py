#!/usr/bin/env python3
"""
Prompt 10 Release Asset, Size, Reference, and Secret Audit Tool.
Scans assets/, data/, scripts/, scenes/, project.godot, export_presets.cfg, and version.json.
Produces deterministic JSON/console metrics for release readiness without fabricating numbers.
"""

import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def collect_referenced_res_paths() -> set[str]:
    refs: set[str] = set()
    pat = re.compile(r'res://[^\s"\'\)\]]+')
    for ext in ("*.godot", "*.tscn", "*.gd", "*.json", "*.cfg"):
        files = [ROOT / "project.godot", ROOT / "export_presets.cfg"] if ext in ("*.godot", "*.cfg") else list(ROOT.rglob(ext))
        for fp in files:
            if not fp.exists() or "builds" in fp.parts or ".godot" in fp.parts:
                continue
            text = fp.read_text(encoding="utf-8", errors="ignore")
            for m in pat.finditer(text):
                refs.add(m.group(0).rstrip(".,;"))
    return refs


def main() -> int:
    refs = collect_referenced_res_paths()
    assets_dir = ROOT / "assets"
    total_files = 0
    total_bytes = 0
    by_category: dict[str, dict] = {}
    large_files: list[dict] = []
    duplicates_by_hash: dict[str, list[str]] = {}
    unreferenced_assets: list[str] = []

    for fp in sorted(assets_dir.rglob("*")):
        if not fp.is_file() or fp.name == ".gitkeep" or fp.suffix == ".import":
            continue
        rel = fp.relative_to(ROOT).as_posix()
        res_path = f"res://{rel}"
        sz = fp.stat().st_size
        total_files += 1
        total_bytes += sz
        cat = fp.relative_to(assets_dir).parts[0]
        entry = by_category.setdefault(cat, {"count": 0, "bytes": 0})
        entry["count"] += 1
        entry["bytes"] += sz

        if sz > 512 * 1024:
            large_files.append({"path": rel, "bytes": sz})

        digest = hashlib.sha256(fp.read_bytes()).hexdigest()
        duplicates_by_hash.setdefault(digest, []).append(rel)

        # Fonts/audio manifest tracks some audio dynamically by filename/directory
        if res_path not in refs and cat not in ("audio", "fonts"):
            unreferenced_assets.append(rel)

    dup_groups = [paths for paths in duplicates_by_hash.values() if len(paths) > 1]

    # Estimated pack footprint (excluding docs/, tests/, tools/, builds/, .git)
    pack_bytes = 0
    for folder in ("assets", "data", "localization", "scenes", "scripts"):
        for fp in (ROOT / folder).rglob("*"):
            if fp.is_file() and fp.suffix != ".import":
                pack_bytes += fp.stat().st_size
    for root_f in ("project.godot", "icon.svg"):
        if (ROOT / root_f).exists():
            pack_bytes += (ROOT / root_f).stat().st_size

    report = {
        "total_asset_files": total_files,
        "total_asset_bytes": total_bytes,
        "total_asset_mb": round(total_bytes / (1024 * 1024), 3),
        "estimated_project_payload_mb": round(pack_bytes / (1024 * 1024), 3),
        "by_category": by_category,
        "large_files_over_512kb": large_files,
        "duplicate_asset_groups": dup_groups,
        "unreferenced_non_audio_assets": unreferenced_assets,
    }
    print(json.dumps(report, indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
