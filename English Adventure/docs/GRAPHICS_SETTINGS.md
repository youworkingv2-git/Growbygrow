# Graphics Settings & Performance Tiers

**Implementation:** `scripts/core/settings_manager.gd`, `scripts/visual3d/world_environment_3d.gd`, `scripts/ui/screens/settings_ui.gd`

---

## 1. Visual Settings Isolation
Visual preferences live inside `SettingsManager` (`user://settings.cfg`) under `[graphics]` (`graphics_quality`, `fullscreen`, `resolution`, `reduced_motion`, `camera_sensitivity`), completely decoupled from gameplay state, quest progression, and learning save files (`SaveManager`). Changing quality never alters gameplay physics, collision shapes, or save data.

---

## 2. Quality Profiles (`low`, `medium`, `high`)

| Parameter | Low | Medium (Default) | High |
|---|---|---|---|
| **Target Hardware** | Entry-level Android / older iOS / low-power laptops | Mid-range Android / iOS / WebGL2 browsers | Windows / macOS Desktop & high-end tablets |
| **Directional Sun Shadows** | Off (relies on lightweight contact shadow discs) | On (`PARALLEL_2_SPLITS`, `256x256`–default, `56m` range) | On (`PARALLEL_4_SPLITS`, `blur 1.6`, `78m` range) |
| **Aerial Perspective Fog** | Off | On | On |
| **Post-Process Glow** | Off | Subtle (`0.22`) | Enhanced (`0.36`) |
| **Local Point Lights (`quality_lights`)** | Off | Off | On (Porch & street lamp `OmniLight3D`) |
| **Ambient Particles (`quality_particles`)** | Off | On (Fountain spray, dust motes, portal sparkles) | On |
| **SSAO / SSR / Volumetric Fog** | Off | Off | Off (kept off to preserve `gl_compatibility` WebGL2/mobile stability) |

---

## 3. Target Frame Rates & Profiling Notes
- **Targets (Measured vs. Design Goal):**
  - **Windows Desktop:** Target **60 FPS** (`Medium` / `High`).
  - **Android / iOS / WebGL2:** Target **30–60 FPS** (`Low` / `Medium`).
- **Optimizations Applied:**
  - Material caching (`_mat_cache`) inside `PropFactory3D` reduces redundant `StandardMaterial3D` allocations across repeated trees, cobbles, beams, and rocks.
  - Contact shadow discs use lightweight `unshaded` alpha meshes instead of dynamic shadow casters on small props.
  - `AreaEnvironment3D` builds static village geometry once on scene entry with zero per-frame allocations.
  - HUD Mini-Map redraws cleanly via Canvas2D `_draw()` at low vector cost.
- **Profiling Status:** Static scene structure, draw complexity, and WebGL2 live viewport rendering have been verified; native Windows `.exe` / Android APK / iOS IPA FPS telemetry remains pending hardware profiling (see `docs/VISUAL_OVERHAUL_TEST_REPORT.md`).
