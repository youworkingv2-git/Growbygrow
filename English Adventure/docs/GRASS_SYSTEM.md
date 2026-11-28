# Instanced 3D Grass & Ground Detail System

**Implementation:** `scripts/visual3d/stylized_mesh_kit.gd` (`build_grass_tuft_mesh`), `shaders/stylized_grass_wind.gdshader`, `scripts/visual3d/area_environment_3d.gd` (`_add_grass_field`)

---

## 1. Real 3D Grass Geometry & MultiMesh Rendering
- Each grass tuft (`ArrayMesh`) consists of **6 curved, tapered 3D blades** angled across 360° with `UV.y` mapped from `0.0` (ground root) to `1.0` (blade tip).
- Rendered as a single batched `MultiMeshInstance3D` (`MeadowGrassField`) using `INSTANCE_CUSTOM` per-instance data:
  - `custom.x`: Randomized wave phase offset (`0..1`)
  - `custom.y`: Height scale (`0.68..1.38`)
  - `custom.z`: Color/hue shift (`0..1`) so grass tufts naturally vary in tone across the meadow.
- **Exclusion Zones:** Placement cleanly skips the Cobblestone Plaza, Fountain footprint, Cottages, Supply Chest camp, Portal pad, and Earth/Flagstone trails.

---

## 2. Wind Animation & Quality Scaling
- `stylized_grass_wind.gdshader` pins blade roots (`t = 0`) to the ground while bending tips (`t^2`) in rolling sinusoidal wind gusts across XZ world space.
- **Tiered Density (`visible_instance_count`, never 0):**
  - `high`: Up to `1,450` tufts
  - `medium`: Up to `820` tufts
  - `low`: Up to `320` tufts (preserves living, swaying grass even on entry-level devices)

---

## 3. Ground Micro-Details (`area_environment_3d.gd`)
- Wind-swaying multi-petal wildflower patches (`_add_flower_cluster`)
- Spotted woodland mushrooms (`_add_mushroom_patch`)
- Mossy tree stump surrounded by fallen leaves (`_add_stump_and_leaves`)
- River pebble clusters along path borders (`_add_pebble_cluster`)
