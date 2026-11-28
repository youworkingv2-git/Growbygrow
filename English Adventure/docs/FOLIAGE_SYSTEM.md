# Stylized Foliage System

**Implementation:** `scripts/visual3d/stylized_mesh_kit.gd`, `scripts/visual3d/prop_factory_3d.gd`, `shaders/stylized_foliage_wind.gdshader`

---

## 1. Tree Variants (No Bare Stacked Cones)
- **3 Big Tree Variants:**
  1. `"oak"`: Curved buttressed trunk (`build_curved_trunk_mesh`), 3 forked wooden boughs, and 6 multi-lobed smooth-shaded leaf clusters (`build_leaf_clump_mesh`) in layered forest-to-sunlit green shades.
  2. `"pine"`: Curved evergreen trunk with exposed lower boughs and 3 tiered scalloped drooping bough skirts (`build_pine_bough_tier_mesh`) + top tuft (eliminates bare geometric cones, including across `DistantForestRing`).
  3. `"blossom"`: Warm curved trunk, forked branches, and multi-clustered pink/coral blossom canopy.
- **3 Small Tree / Sapling Variants:**
  1. `"sapling_oak"`: Young slender forked tree with soft two-cluster canopy.
  2. `"berry_tree"`: Low orchard tree accented with glowing red berry clusters.
  3. `"cypress_small"`: Three-tier sculpted garden topiary cypress.
- **3 Shrub & Ground Flora Variants (`build_shrub_variant`):**
  1. Berry Woodland Bush (`variant = 0`)
  2. Woodland Fern Rosette (`variant = 1`)
  3. Flowering Garden Shrub (`variant = 2`)

---

## 2. Wind-Animated Foliage Shader (`shaders/stylized_foliage_wind.gdshader`)
- Uses `MODEL_MATRIX[3].xyz` world-space phase offsets so each tree crown, shrub, vine, and flower cluster sways independently rather than shaking as a rigid block.
- Masks vertex displacement by vertical height inside each clump (`h_norm`) and adds subtle leaf-tip flutter + `BACKLIGHT` warmth.
