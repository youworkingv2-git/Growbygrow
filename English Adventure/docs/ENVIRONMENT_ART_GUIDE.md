# Environment Art Guide – Welcome Village & Alphabet Island

**Primary Reference Zone:** Welcome Village (`scenes/world/welcome_village.tscn` + `scripts/visual3d/area_environment_3d.gd`)

---

## 1. Spatial Zones & Sightlines (Welcome Village)
Welcome Village preserves every gameplay coordinate, NPC position, chest, and portal trigger while organizing the space into intentional adventure zones:

1. **Central Fountain Plaza (`0, 0, 0`):** Warm cobblestone courtyard with a stepped stone ring, dual-tier fountain (`build_fountain`), active water spray particles (`high` tier), and wooden park benches (`build_wooden_bench`) framing social spaces.
2. **Professor Owl's Academy (North-West `-6.5, 0, -5.5`):** Coral-gabled cottage with stepped stone foundation, half-timber framing, shuttered windows, flower boxes, dormer window, stone chimney, porch lantern, and outdoor Academy Lectern (`build_academy_lectern`).
3. **Lily's Garden Cottage (North-East `6.2, 0, -5.2`):** Warm stucco cottage accented with blossom trees, flanking flowerbeds, and stone stepping paths leading back to the plaza.
4. **Explorer Supply Cottage & Treasure Corner (West `-10.2, 0, 5.4`):** Supports the village chest (`Chest_Welcome`) with grouped supply crates, barrel, and timber porch rather than floating props in empty grass.
5. **Eastern Meadow Gateway (`15.0, 0, 0`):** Carved stone & timber Welcome Arch (`build_gateway_arch`) with lantern posts framing the portal `ToAlphabetMeadow` and guiding player navigation eastward.
6. **Perimeter Framing & Distant Vista:** Gently sculpted perimeter grass mounds (`_add_grass_mound`), layered oak/pine/blossom trees (`build_stylized_tree`), stone boulders, distant forest canopy ring, misty mountain peaks (`#4B678E`), and a distant beacon watchtower (`34, 0, -40`).

---

## 2. Terrain & Ground Composition
- **No Flat Single-Green Plane:** Base terrain uses deep natural grass (`#2C5D33`), accented with raised perimeter grass mounds (`#3F763B`), earthen footpaths (`#8A6848`), and stepping stones (`#8D8E95`).
- **Path Network:** Earth & stone trails connect Spawn → Fountain Plaza → Professor Owl's Academy → Lily's Garden → Supply Chest → Eastern Meadow Gateway.

---

## 3. Architecture & Prop Standards (`scripts/visual3d/prop_factory_3d.gd`)
- **Cottages (`build_village_cottage`):** Multi-part silhouette (foundation plinth, stucco wall, corner/cross beams, overhanging pitched roof + fascia + dormer, stone chimney, recessed door + awning, shuttered glowing windows + flower boxes, porch steps, Academy crest, and optional porch `OmniLight3D`).
- **Trees (`build_stylized_tree`):** Three distinct silhouettes (`"oak"`, `"pine"`, `"blossom"`) with tapered root-flared trunks, asymmetrical foliage clusters, and soft ground contact shadows.
- **Collision & Camera Layers:**
  - Layer `2`: Ground / Terrain
  - Layer `16`: Camera Occluders (trees & cottages fade smoothly when obstructing player sightline)
  - Layer `32`: Player Physical Collision
  - Layer `64`: Camera `SpringArm3D` Wall/Terrain Collision

---

## 4. Other Areas & 3D Dioramas
Harmonized ground palettes, trees, and rocks were also applied to:
- `alphabet_meadow` (`#326736` meadow grass + stone/earth trail + oak/blossom trees)
- `letter_cave` (`#24293C` slate cavern floor + `#1C1F2F` walls + glowing crystal clusters)
- `crystal_lake` (`#336339` shore grass + `#2D85C8` tranquil water + reed/stone piers)
- `shadow_gate` (`#29283D` basalt ground + obsidian spires + magenta runes)
- `scripts/visual3d/diorama_3d_stage.gd` & `scripts/visual3d/alphabet_island_3d_map.gd`
