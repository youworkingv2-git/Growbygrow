#!/usr/bin/env python3
"""
Prompt 07 Automated Verification Suite for ENGLISH ADVENTURE Audio, Voice & AI Pronunciation System.
"""

import json
import re
import sys
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
errors = []

REQUIRED_FILES = [
    "scripts/audio/audio_manager.gd",
    "scripts/audio/audio_asset_manager.gd",
    "scripts/audio/audio_settings_manager.gd",
    "scripts/audio/music_manager.gd",
    "scripts/audio/sound_effect_manager.gd",
    "scripts/audio/voice_profile_manager.gd",
    "scripts/audio/text_to_speech_manager.gd",
    "scripts/audio/audio_playback_manager.gd",
    "scripts/audio/voice_manager.gd",
    "scripts/audio/speech_recorder.gd",
    "scripts/audio/speech_recognition_manager.gd",
    "scripts/audio/pronunciation_assessment_manager.gd",
    "scripts/audio/pronunciation_feedback_manager.gd",
    "scripts/audio/audio_event_handler.gd",
    "scripts/ui/components/speaking_practice_panel.gd",
    "data/audio/audio_manifest.json",
    "data/audio/voice_profiles.json",
    "supabase/migrations/0006_audio_voice_pronunciation.sql",
    "supabase/functions/pronunciation-assess/index.ts",
    "supabase/functions/speech-recognize/index.ts",
    "docs/AUDIO_SYSTEM.md",
    "docs/AUDIO_ASSET_PIPELINE.md",
    "docs/VOICE_SYSTEM.md",
    "docs/TTS_INTEGRATION.md",
    "docs/SPEECH_RECORDING.md",
    "docs/SPEECH_RECOGNITION.md",
    "docs/PRONUNCIATION_ASSESSMENT.md",
    "docs/PRONUNCIATION_FEEDBACK.md",
    "docs/VOICE_PRIVACY.md",
    "docs/NPC_VOICE_DESIGN.md",
    "docs/AUDIO_TEST_REPORT.md",
    "docs/AI_PROVIDER_COMPARISON.md",
]


def main():
    for rel in REQUIRED_FILES:
        if not (ROOT / rel).exists():
            errors.append(f"Missing Prompt 07 required file: {rel}")

    pg = (ROOT / "project.godot").read_text(encoding="utf-8")
    if "general/text_to_speech=true" not in pg:
        errors.append("project.godot must enable general/text_to_speech=true")

    # Verify bundled audio manifest & WAV integrity
    manifest_p = ROOT / "data/audio/audio_manifest.json"
    if manifest_p.exists():
        manifest = json.loads(manifest_p.read_text(encoding="utf-8"))
        assets = manifest.get("assets", [])
        if len(assets) < 10:
            errors.append(f"Expected >= 10 verified bundled audio assets, found {len(assets)}")
        for a in assets:
            rp = str(a.get("path", ""))
            if not rp.startswith("res://"):
                errors.append(f"Invalid asset path in manifest: {rp}")
                continue
            disk = ROOT / rp[len("res://"):]
            if not disk.exists():
                errors.append(f"Manifest audio asset missing on disk: {rp}")
            elif disk.suffix.lower() == ".wav":
                try:
                    with wave.open(str(disk), "rb") as wf:
                        if wf.getnframes() <= 0 or wf.getframerate() <= 0:
                            errors.append(f"Empty WAV frames in {rp}")
                except Exception as exc:
                    errors.append(f"Corrupt WAV {rp}: {exc}")

    # Verify all 5 NPC + narrator profiles
    vp_p = ROOT / "data/audio/voice_profiles.json"
    if vp_p.exists():
        vp = json.loads(vp_p.read_text(encoding="utf-8"))
        ids = {p.get("id") for p in vp.get("profiles", [])}
        for req in ("professor_owl", "buddy", "lily", "rocky", "crystal_guardian", "learning_narrator"):
            if req not in ids:
                errors.append(f"Missing voice profile: {req}")

    # Verify vocab syllables & phonemes enrichment
    vocab_p = ROOT / "data/vocabulary/world_01_vocab.json"
    if vocab_p.exists():
        vocab = json.loads(vocab_p.read_text(encoding="utf-8")).get("vocabulary", [])
        for w in vocab:
            if not w.get("syllables") or not w.get("phonemes"):
                errors.append(f"Vocab {w.get('id')} missing syllables or phonemes")

    # Verify EventBus signals
    eb = (ROOT / "scripts/core/event_bus.gd").read_text(encoding="utf-8")
    for sig in (
        "voice_playback_started",
        "voice_playback_finished",
        "speech_recording_started",
        "speech_recording_stopped",
        "speech_recognition_completed",
        "pronunciation_assessment_completed",
    ):
        if f"signal {sig}" not in eb:
            errors.append(f"Missing Prompt 07 signal in EventBus: {sig}")

    # Verify zero secret keys in Godot scripts & non-faked AI default mode
    pa_gd = (ROOT / "scripts/audio/pronunciation_assessment_manager.gd").read_text(encoding="utf-8")
    if "var provider_mode: ProviderMode = ProviderMode.DISABLED" not in pa_gd:
        errors.append("PronunciationAssessmentManager must default to ProviderMode.DISABLED until configured")
    if "OS.is_debug_build()" not in pa_gd:
        errors.append("PronunciationAssessmentManager must guard MOCK_DEV_ONLY behind OS.is_debug_build()")

    for gd in (ROOT / "scripts").rglob("*.gd"):
        txt = gd.read_text(encoding="utf-8")
        if "Ocp-Apim-Subscription-Key" in txt:
            errors.append(f"Client GDScript must NEVER contain Azure subscription key header: {gd.relative_to(ROOT)}")

    # GDScript 4.3 Variant trap check
    pat = re.compile(r'var\s+\w+\s*:=\s*[A-Za-z0-9_.\[\]"\']+\.get\([^)]*\)\s*$')
    for gd in (ROOT / "scripts").rglob("*.gd"):
        text = gd.read_text(encoding="utf-8")
        for idx, line in enumerate(text.splitlines(), 1):
            if pat.search(line):
                errors.append(f"Possible GDScript 4.3 Variant inference trap in {gd.relative_to(ROOT)}:{idx}: {line.strip()}")

    if errors:
        print("PROMPT 07 VALIDATION FAILED:")
        for e in errors:
            print(" -", e)
        sys.exit(1)

    print(f"Checked Prompt 07 files: {len(REQUIRED_FILES)}")
    print("ALL PROMPT 07 CHECKS PASSED SUCCESSFULLY!")


if __name__ == "__main__":
    main()
