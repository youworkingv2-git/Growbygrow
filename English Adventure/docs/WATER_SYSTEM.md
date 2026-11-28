# Real Fountain Water System

**Implementation:** `scripts/visual3d/prop_factory_3d.gd` (`build_fountain`), `scripts/visual3d/fountain_controller.gd`, `shaders/stylized_water.gdshader`, `shaders/stylized_water_jet.gdshader`

---

## 1. Basin Architecture
- **Hollow Carved Stone Basin:** Built with 16 interlocking curved stone wall segments surrounding a recessed dark-blue wet stone floor (`#244864`) and rounded rim coping (`RimTorus`), giving real visual basin depth underneath translucent water.
- **Two Water Tiers:** Main lower basin water surface + upper stone bowl water surface + rotating crystal finial.

---

## 2. Animated Water & Parabolic Jets
- **Water Surface Shader (`stylized_water.gdshader`):**
  - Gentle multi-directional vertex wave displacement (`wave_amp`)
  - Concentric radial fountain ripples (`radial_mode = 1.0`) + foam rings near basin edges and jet impact zones
  - Deep-to-shallow translucent color blending + Fresnel sky reflection + sunlight sparkle highlights
- **3D Arching Water Jets (`build_water_jet_arc_mesh` + `stylized_water_jet.gdshader`):**
  - 6 parabolic water arcs from the central crystal spout into the upper bowl + 6 cascading streams spilling from the upper bowl into the main basin, with scrolling translucent foam streaks.
- **Particles (`CPUParticles3D`):**
  - `FountainPlume`: upward central spray
  - `FountainBasinSplash`: splash droplets rising where lower jets impact the basin surface
  - `FountainMist`: soft alpha mist hovering above the water

---

## 3. Spatial Audio & Tier Scaling
- **3D Spatial Sound:** `AudioStreamPlayer3D` plays `res://assets/audio/sfx/sfx_fountain_loop.wav` (generated via `tools/generate_procedural_audio.py`) with `unit_size = 4.2`, `max_distance = 17.5`, naturally attenuating by distance.
- **Low / Medium / High Scaling (`FountainController`):**
  - `low`: `quality_level = 0.0`, 6 main water jets + compact plume (`6`) + splash (`8`) remain active so water is **never** hidden or static.
  - `medium`: `quality_level = 1.0`, all 12 jets + plume (`16`) + splash (`18`) + mist (`8`).
  - `high`: `quality_level = 2.0`, all 12 jets + plume (`28`) + splash (`34`) + mist (`14`) + full Fresnel sparkle.
