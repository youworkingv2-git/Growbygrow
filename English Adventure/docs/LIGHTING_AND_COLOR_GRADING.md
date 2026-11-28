# Lighting, Atmospheric Depth & Color Grading

**Implementation:** `scripts/visual3d/world_environment_3d.gd`

---

## 1. Rendering Calibration
- **Renderer:** Godot 4 `gl_compatibility` (cross-platform Windows / WebGL2 / Android / iOS).
- **Tonemapping:** `TONE_MAPPER_FILMIC` with `tonemap_exposure = 0.88`, `tonemap_white = 5.5` to prevent washed-out pastel glare while keeping sunlit yellows and foliage vibrant.
- **Key Sun & Sky Fill:**
  - Welcome Village Sun: Warm Golden `#FFE2B2`, `light_energy = 1.04`, rotation `(-38°, -36°, 0°)` with `directional_shadow_blend_splits = true` and `shadow_blur = 1.6`.
  - Ambient Sky Fill: Cool Sky Blue `#8BB6E0` (`ambient_light_sky_contribution = 0.48`, `ambient_light_energy = 0.34`) to separate sunlit tops from cool shaded undersides.
- **Aerial Depth:** `fog_enabled = true` (`fog_density = 0.0062`, `#A6CAEB`) separating foreground plaza, midground trees/cottages, and distant mountain peaks.
- **Restrained Bloom:** `glow_intensity = 0.36` (`high`) / `0.22` (`medium`) / `off` (`low`), keeping crystal/lantern accents warm without blowing out sky or walls.
