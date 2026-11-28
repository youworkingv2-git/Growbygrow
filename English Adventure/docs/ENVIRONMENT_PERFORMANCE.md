# Environment Performance & Multi-Tier Optimization

**Implementation:** `scripts/visual3d/area_environment_3d.gd`, `prop_factory_3d.gd`, `fountain_controller.gd`, `ambient_life_3d.gd`, `world_environment_3d.gd`

---

## 1. Optimization Techniques Used
1. **Material & Mesh Caching:** `PropFactory3D._mat_cache` / `_mesh_cache`, `AreaEnvironment3D._mat_cache` / `_mesh_cache`, and `StylizedMeshKit._mesh_cache` reuse shared `ArrayMesh`, `ShaderMaterial`, and `StandardMaterial3D` instances across trees, buildings, stones, and props.
2. **Batched `MultiMeshInstance3D` Grass:** Up to `1,450` 6-blade grass tufts render in **1 single draw call** (`MeadowGrassField`) with shadows disabled on individual grass blades.
3. **Lightweight Contact Shadows:** Grounded discs (`cast_shadow = OFF`) keep objects anchored on `low` tier even when directional shadow maps are disabled.
4. **No Heavy Screen-Space Passes:** `ssao_enabled = false`, `ssr_enabled = false` to ensure WebGL2 & mobile GPU stability.

---

## 2. Quality Profile Matrix (`SettingsManager.graphics_quality`)

| Feature | `low` | `medium` (Default Web/Mobile) | `high` |
|---|---|---|---|
| **Trees & Foliage Wind** | Full multi-cluster trees + wind shader | Full + wind shader | Full + wind shader |
| **Instanced Grass Tufts** | `320` tufts | `820` tufts | `1,450` tufts |
| **Fountain Water & Jets** | Animated ripple shader (`q=0`) + 6 jets + plume/splash | Animated ripple (`q=1`) + 12 jets + mist | Full ripple (`q=2`) + 12 jets + full mist |
| **Ambient Butterflies & Birds** | 2 butterflies + 1 bird | 3 butterflies + 4 birds | 5 butterflies + 4 birds |
| **Directional Sun Shadows** | Off (contact shadows active) | `PARALLEL_2_SPLITS` | `PARALLEL_4_SPLITS` |
| **Porch/Lamp `OmniLight3D`** | Off | Off | On |
