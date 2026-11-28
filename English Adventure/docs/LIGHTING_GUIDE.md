# Lighting & Atmosphere Guide

**Implementation:** `scripts/visual3d/world_environment_3d.gd`

---

## 1. Calibration Goals
- **Eliminate Blown-Out White / Washed Pastel Look:** Use Godot 4's `TONE_MAPPER_FILMIC` (`exposure = 0.88`, `tonemap_white = 5.5`) so bright surfaces retain warmth without clipping.
- **Warm Daylight Key + Cool Sky Fill:** Pair a warm golden directional sun (`#FFE2B2`) with a sky-blue ambient fill (`#8BB6E0`) so sunlit grass feels rich while shadows carry natural cool depth rather than harsh black or flat white.
- **Soft Readable Shadows:** Enable `directional_shadow_blend_splits = true` and tune `shadow_blur` + `shadow_bias` per graphics tier.

---

## 2. Area Lighting Presets (`WorldEnvironment3D`)

| Area | Sun Color | Sun Energy | Sun Pitch / Yaw | Sky Top / Horizon | Fog Density | Ambient Energy |
|---|---|---|---|---|---|---|
| `welcome_village` | `#FFE2B2` | `1.04` | `-38° / -36°` | `#4E92D6` / `#CFE4F8` | `0.0062` | `0.34` |
| `alphabet_meadow` | `#FFE5BA` | `1.08` | `-41° / -30°` | `#5299DE` / `#D6EAFB` | `0.0056` | `0.34` |
| `letter_cave` | `#A2BDFF` | `0.58` | `-50° / -25°` | `#161B30` / `#283052` | `0.0155` | `0.40` |
| `crystal_lake` | `#FFF0D2` | `1.02` | `-33° / -42°` | `#4A8FD6` / `#C4E4FA` | `0.0068` | `0.35` |
| `shadow_gate` | `#D7B6FF` | `0.78` | `-38° / -34°` | `#22193A` / `#4A3472` | `0.0125` | `0.36` |

---

## 3. Quality Tier Scaling (Cross-Platform Mobile & PC Safety)

| Setting | `low` | `medium` (Default Web/Mobile) | `high` |
|---|---|---|---|
| `shadow_enabled` | `false` (uses contact shadow discs) | `true` | `true` |
| `directional_shadow_mode` | `ORTHOGONAL` | `PARALLEL_2_SPLITS` | `PARALLEL_4_SPLITS` |
| `shadow_blur` | `1.0` | `1.3` | `1.6` |
| `directional_shadow_max_distance` | `42.0` | `56.0` | `78.0` |
| `glow_enabled` | `false` | `true` (`0.22` intensity) | `true` (`0.36` intensity) |
| `ssao_enabled` | `false` | `false` | `false` (disabled on Compatibility/WebGL2 safety) |
| `fog_enabled` | `false` | `true` (aerial depth) | `true` (aerial depth) |
| `quality_particles` group | Hidden / paused | Active | Active |
| `quality_lights` group (Porch/Lantern `OmniLight3D`) | Hidden | Hidden | Visible |

> **Compatibility Renderer Note:** Project renders with Godot's `gl_compatibility` renderer (`project.godot`), ensuring reliable WebGL2, Android GLES3, iOS Metal/ANGLE, and Windows compatibility without expensive Forward+ SSAO/SSR passes.
