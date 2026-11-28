# Visual Overhaul Test & Verification Report

**Date:** 2026-11-28  
**Verified WebGL2 Build Commit:** `fbcb1f4` (`https://youworkingv2-git.github.io/Growbygrow/?v=fbcb1f4`)  
**Renderer:** Godot 4 `gl_compatibility` (WebGL2)

---

## 1. Automated Static & Content Validation (Executed & Passed)

| Suite | Scope | Result |
|---|---|---|
| `validate_prompt_02.py` | 37 JSON schemas, 444 `res://` refs, 230 `@onready` paths | **PASSED** |
| `validate_prompt_03.py` | 27 required UI/UX scripts & scenes | **PASSED** |
| `validate_3d_visual_direction.py` | 10 3D gameplay/area scenes, 5 3D UI dioramas, 7 3D character rigs | **PASSED** |
| `validate_prompt_08.py` | Content, quests, security, regression & 3D optimization checks | **PASSED** |
| `validate_prompt_09.py` | Complete English curriculum dataset integrity | **PASSED** |
| `validate_prompt_10.py` | Version `0.9.0`, 5 export presets, secrets, save migration & release docs | **PASSED** |
| `run_p9_content_tests.py` | Integration Tests 01–08 across curriculum & question bank | **PASSED (0 failures)** |
| Cross-file GDScript signature audit | All modified `.gd` scripts & `PropFactory3D` call arities | **PASSED** |

---

## 2. Live WebGL2 Browser Verification (Executed & Passed on `fbcb1f4`)

1. **Runtime Error Detection & Fix:**
   - Live browser console inspection on `948aec1` detected `Parse Error: Too few arguments for "_cached_sphere()" call` at `scripts/visual3d/area_environment_3d.gd:286`.
   - Fixed in `fbcb1f4` (`_cached_sphere(0.65, 1.30, 8, 12)`); verified **0 runtime/script errors** in WebGL2 console logs upon entering Welcome Village.
2. **Welcome Village 3D Visuals & Lighting:**
   - Verified rich non-mint natural grass palette (`#2C5D33` / `#3F763B`), sculpted perimeter mounds, cobblestone-rimmed plaza with compass ring, Professor Owl's Academy (dormer, crest, shuttered windows, lectern), Lily's coral-roofed Garden Cottage (flower boxes, awning), Eastern Gateway Arch framing `ToAlphabetMeadow`, varied Oak/Pine/Blossom trees, distant mountains, warm Filmic daylight, and soft ground shadows.
3. **Third-Person Camera & Occlusion Fade:**
   - Verified close behind-shoulder framing (`6.2 m`, `-0.30 rad`), `SpringArm3D` wall/foundation collision near Lily's cottage, smooth `Q`/`C` camera rotation, and semi-transparent occluder fade (`transparency = 0.68`) when a building corner crossed the player-camera sightline.
4. **Character, Buddy & Proximity-Only Labels:**
   - Verified `Leo` + flowing scarf + contact shadow and `Buddy` floating beside Leo's shoulder (`follow_offset = Vector3(-1.18, 1.38, 0.32)`).
   - Verified far NPCs (`Lily`) show no distant nameplate clutter, while walking near `Professor Owl` reveals his framed nameplate (`LabelBackdrop3D`) and `!` badge.
5. **Redesigned HUD & Integrations:**
   - Verified Top-Left Hero Badge + translucent Quest Scroll (`Nhiệm vụ (2/3): Khởi Hành Mới`), Top-Right live circular Mini-Map (clicking opens the 3D World Map), compact Bottom Icon Dock, Quest Log modal (`SỔ TAY NHIỆM VỤ`), and Settings UI (`CÀI ĐẶT TRÒ CHƠI`).

---

## 3. Implemented But NOT Yet Tested on Target Hardware

| Area | Reason Not Tested Here | Recommended Test |
|---|---|---|
| **Windows Native `.exe` (60 FPS target)** | Godot desktop binary & GPU profiler were not available in this CLI environment | Export & run Windows Desktop build in Godot 4; measure FPS (`medium` & `high`) and draw calls via Godot Profiler |
| **Android & iOS Physical Devices (30–60 FPS target)** | No physical Android/iOS devices or mobile emulators attached | Build Android APK / iOS IPA; verify touch safe-area insets, joystick responsiveness, and thermal/FPS stability on `low` & `medium` tiers |
| **Native 1280×720+ Desktop Layout** | Browser pane in IDE rendered at compact viewport width (`300×383` CSS / `333×425` canvas); desktop wide-screen controls hint & 7-button dock width were verified by layout math & code audit | Run full-screen `1280×720` and `1920×1080` on Windows/Browser to inspect wide HUD spacing and PC `WASD / E / Esc` controls hint |
| **Other 4 Areas Live Playthrough** | Live inspection focused on Welcome Village as prioritized; `alphabet_meadow`, `letter_cave`, `crystal_lake`, and `shadow_gate` updates were verified by code audit & `validate_3d_visual_direction.py` | Play through portals across all 5 areas in live build |
