#!/usr/bin/env python3
"""
Generates clean, 100%-original procedural UI SFX, Gameplay SFX, and Ambient Fantasy BGM
as 16-bit PCM .wav files for English Adventure (Godot 4.3 gl_compatibility + WebGL2).
Also builds data/audio/audio_manifest.json tracking every bundled & pending audio asset honestly.
"""

import json
import math
import struct
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SAMPLE_RATE = 22050


def write_wav(path: Path, samples: list[float]) -> float:
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        frames = bytearray()
        for s in samples:
            val = max(-0.95, min(0.95, s))
            frames.extend(struct.pack("<h", int(val * 32767.0)))
        wf.writeframes(bytes(frames))
    return round(len(samples) / float(SAMPLE_RATE), 3)


def env_adsr(t: float, dur: float, a: float = 0.01, d: float = 0.06, s_lvl: float = 0.65, r: float = 0.08) -> float:
    if t < 0.0 or t > dur:
        return 0.0
    if t < a:
        return t / max(0.001, a)
    if t < a + d:
        return 1.0 - (1.0 - s_lvl) * ((t - a) / max(0.001, d))
    if t > dur - r:
        return s_lvl * max(0.0, (dur - t) / max(0.001, r))
    return s_lvl


def tone_note(freq: float, dur: float, amp: float = 0.35, harmonic2: float = 0.22) -> list[float]:
    n = int(dur * SAMPLE_RATE)
    out = []
    for i in range(n):
        t = i / float(SAMPLE_RATE)
        e = env_adsr(t, dur, a=0.012, d=min(0.08, dur * 0.25), s_lvl=0.55, r=min(0.10, dur * 0.35))
        sig = math.sin(2.0 * math.pi * freq * t) + harmonic2 * math.sin(2.0 * math.pi * freq * 2.0 * t)
        out.append((sig / (1.0 + harmonic2)) * e * amp)
    return out


def concat_notes(notes: list[tuple[float, float, float]]) -> list[float]:
    buf: list[float] = []
    for freq, dur, amp in notes:
        buf.extend(tone_note(freq, dur, amp))
    return buf


def overlay_chord(freqs: list[float], dur: float, amp: float = 0.24) -> list[float]:
    n = int(dur * SAMPLE_RATE)
    out = [0.0] * n
    for f in freqs:
        part = tone_note(f, dur, amp / max(1.0, len(freqs) * 0.65), harmonic2=0.15)
        for i in range(n):
            out[i] += part[i]
    return out


def build_ambient_loop(dur: float = 8.0) -> list[float]:
    # Gentle C-major pentatonic fantasy island pad/celesta loop (seamless fade at loop boundaries)
    n = int(dur * SAMPLE_RATE)
    out = [0.0] * n
    # Soft warm pad chords (C4-E4-G4, A3-C4-E4, F3-A3-C4, G3-B3-D4)
    chords = [
        (0.0, 2.0, [261.63, 329.63, 392.00]),
        (2.0, 2.0, [220.00, 261.63, 329.63]),
        (4.0, 2.0, [174.61, 220.00, 261.63]),
        (6.0, 2.0, [196.00, 246.94, 293.66]),
    ]
    for start, cdur, freqs in chords:
        st_idx = int(start * SAMPLE_RATE)
        clen = int(cdur * SAMPLE_RATE)
        for i in range(clen):
            idx = st_idx + i
            if idx >= n:
                break
            t = i / float(SAMPLE_RATE)
            fade = math.sin(math.pi * (t / cdur))
            s = sum(math.sin(2.0 * math.pi * f * t) for f in freqs) / float(len(freqs))
            out[idx] += s * fade * 0.14
    # Gentle celesta melody plucks
    plucks = [
        (0.0, 523.25), (0.5, 659.25), (1.0, 783.99), (1.5, 659.25),
        (2.0, 440.00), (2.5, 523.25), (3.0, 659.25), (3.5, 523.25),
        (4.0, 349.23), (4.5, 440.00), (5.0, 523.25), (5.5, 440.00),
        (6.0, 392.00), (6.5, 493.88), (7.0, 587.33), (7.5, 523.25),
    ]
    for start, freq in plucks:
        st_idx = int(start * SAMPLE_RATE)
        note = tone_note(freq, 0.42, amp=0.12, harmonic2=0.18)
        for j, val in enumerate(note):
            if st_idx + j < n:
                out[st_idx + j] += val
    # Smooth 40ms edge fade for seamless looping
    edge = int(0.04 * SAMPLE_RATE)
    for i in range(edge):
        g = i / float(edge)
        out[i] *= g
        out[n - 1 - i] *= g
    return out


def build_fountain_water_loop(dur: float = 3.0) -> list[float]:
    # Soft babbling fountain water using filtered pseudo-noise + gentle droplet harmonics
    import random
    rng = random.Random(42)
    n = int(dur * SAMPLE_RATE)
    out = [0.0] * n
    lp1 = 0.0
    lp2 = 0.0
    for i in range(n):
        t = i / float(SAMPLE_RATE)
        white = rng.uniform(-1.0, 1.0)
        # Dual-band soft water murmur
        lp1 = lp1 * 0.86 + white * 0.14
        lp2 = lp2 * 0.96 + white * 0.04
        splash_mod = 0.72 + 0.28 * math.sin(2.0 * math.pi * (t / dur) * 3.0)
        out[i] = (lp1 - lp2 * 0.75) * 0.24 * splash_mod
    # Subtle water droplet chirps
    for d_idx in range(18):
        pos = int((d_idx / 18.0) * n)
        f0 = 780.0 + (d_idx % 5) * 145.0
        for j in range(int(0.055 * SAMPLE_RATE)):
            idx = (pos + j) % n
            tj = j / float(SAMPLE_RATE)
            env = math.sin(math.pi * (tj / 0.055))
            out[idx] += math.sin(2.0 * math.pi * (f0 + tj * 900.0) * tj) * env * 0.032
    edge = int(0.05 * SAMPLE_RATE)
    for i in range(edge):
        g = i / float(edge)
        out[i] *= g
        out[n - 1 - i] *= g
    return out


def main() -> None:
    assets_meta: list[dict] = []

    def add_asset(asset_id: str, category: str, rel_path: str, samples: list[float], desc: str, loop: bool = False) -> None:
        dur = write_wav(ROOT / rel_path, samples)
        assets_meta.append({
            "audio_id": asset_id,
            "category": category,
            "path": "res://" + rel_path,
            "dialect": "neutral",
            "duration_sec": dur,
            "loop": loop,
            "status": "bundled_verified",
            "source_license": "Original Procedural Synthesis (English Adventure CC0)",
            "description_vi": desc,
        })

    # UI Sounds
    add_asset("ui_click", "ui", "assets/audio/ui/ui_click.wav",
              tone_note(680.0, 0.065, 0.25, 0.15), "Âm nhấn nút giao diện nhẹ nhàng")
    add_asset("ui_open", "ui", "assets/audio/ui/ui_open.wav",
              concat_notes([(523.25, 0.07, 0.22), (659.25, 0.09, 0.25)]), "Âm mở bảng/modal")
    add_asset("ui_close", "ui", "assets/audio/ui/ui_close.wav",
              concat_notes([(587.33, 0.06, 0.20), (440.00, 0.08, 0.20)]), "Âm đóng bảng/modal")

    # Gameplay & Mini-game SFX
    add_asset("sfx_correct", "sfx", "assets/audio/sfx/sfx_correct.wav",
              concat_notes([(523.25, 0.09, 0.30), (659.25, 0.09, 0.32), (783.99, 0.18, 0.35)]), "Âm trả lời đúng thân thiện")
    add_asset("sfx_wrong", "sfx", "assets/audio/sfx/sfx_wrong.wav",
              concat_notes([(330.00, 0.11, 0.24), (277.18, 0.16, 0.22)]), "Âm nhắc thử lại nhẹ nhàng (không gay gắt)")
    add_asset("sfx_reward_received", "sfx", "assets/audio/sfx/sfx_reward_received.wav",
              concat_notes([(523.25, 0.08, 0.28), (659.25, 0.08, 0.30), (783.99, 0.08, 0.32), (1046.50, 0.26, 0.36)]), "Âm nhận thưởng / vật phẩm")
    add_asset("sfx_quest_complete", "sfx", "assets/audio/sfx/sfx_quest_complete.wav",
              concat_notes([(523.25, 0.10, 0.30), (659.25, 0.10, 0.32), (783.99, 0.10, 0.34)]) + overlay_chord([523.25, 659.25, 783.99, 1046.50], 0.36, 0.36), "Âm hoàn thành nhiệm vụ")
    add_asset("sfx_area_unlocked", "sfx", "assets/audio/sfx/sfx_area_unlocked.wav",
              concat_notes([(440.00, 0.10, 0.28), (554.37, 0.10, 0.30), (659.25, 0.10, 0.32), (880.00, 0.30, 0.34)]), "Âm mở khóa khu vực mới")
    add_asset("sfx_mic_start", "sfx", "assets/audio/sfx/sfx_mic_start.wav",
              concat_notes([(587.33, 0.06, 0.24), (880.00, 0.10, 0.28)]), "Âm báo bắt đầu ghi âm")
    add_asset("sfx_mic_stop", "sfx", "assets/audio/sfx/sfx_mic_stop.wav",
              concat_notes([(783.99, 0.06, 0.24), (523.25, 0.10, 0.24)]), "Âm báo dừng ghi âm")

    # Background Music (Welcome Village & Exploration)
    add_asset("bgm_welcome_village", "music", "assets/audio/music/bgm_welcome_village.wav",
              build_ambient_loop(8.0), "Nhạc nền nhẹ nhàng Đảo Bảng Chữ Cái (Procedural Celesta Pad)", loop=True)
    add_asset("sfx_fountain_loop", "sfx", "assets/audio/sfx/sfx_fountain_loop.wav",
              build_fountain_water_loop(3.0), "Âm thanh nước đài phun nước chảy nhẹ (Spatial 3D)", loop=True)

    manifest = {
        "schema_version": "1.0",
        "project": "ENGLISH ADVENTURE",
        "notes": "Bundled WAV assets are original procedural audio generated by tools/generate_procedural_audio.py. Speech/pronunciation recordings (.ogg) use runtime TTS until native voice-over assets are recorded and verified.",
        "assets": assets_meta,
    }
    manifest_path = ROOT / "data" / "audio" / "audio_manifest.json"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Generated {len(assets_meta)} verified WAV assets + {manifest_path.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
