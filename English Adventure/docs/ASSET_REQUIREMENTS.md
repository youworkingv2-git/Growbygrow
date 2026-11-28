# Asset Requirements & Procedural Placeholder Inventory

**Context:** The current codebase builds 3D architecture, terrain, foliage, props, and characters procedurally (`PropFactory3D`, `CharacterRig3D`, `AreaEnvironment3D`) so the project runs cleanly across Git/WebGL2/desktop without external binary bloat. While the visual overhaul significantly elevated silhouettes, materials, and proportions, replacing key procedural meshes with authored `.glb` assets is recommended for commercial polish.

---

## 1. Current Procedural Placeholders (Marked for Future Art Replacement)

| Category | Current Placeholder Implementation | Priority | Recommended Production Asset (`.glb`) |
|---|---|---|---|
| **Main Heroes (`Leo`, `Mia`)** | `scripts/visual3d/character_rig_3d.gd` (`build_hero_rig`) | **High** | Rigged stylized cartoon kid meshes (~3.5k–5k tris) with facial blendshapes + `Idle`, `Walk`, `Run`, `Jump`, `Interact`, `Celebrate` skeletal animations (`AnimationTree`). |
| **Companion (`Buddy`)** | `character_rig_3d.gd` (`build_buddy_rig`) | **High** | Rigged stylized magical fairy/owl-sprite `.glb` with wing-flap & happy-spin animations. |
| **Key NPCs (Professor Owl, Lily, Captain Alex, Fairy, Guardians)** | `character_rig_3d.gd` (`build_npc_rig`) | **High** | Distinct rigged NPC `.glb` characters with `Idle`, `Talk`, `Wave`, and `GiveQuest` animations + feathered/cloth detail. |
| **Village Cottages (Academy, Garden House, Supply House)** | `prop_factory_3d.gd` (`build_village_cottage`) | **Medium** | Hand-sculpted stylized storybook cottage `.glb` variants with baked ambient occlusion & painted tile roof normal/albedo maps (`1024x1024`). |
| **Foliage (Oak, Pine, Blossom, Bushes, Flowers)** | `prop_factory_3d.gd` (`build_stylized_tree`) | **Medium** | Multi-LOD `.glb` stylized foliage packs with alpha-tested leaf cards and wind-sway vertex shader. |
| **Village Props (Fountain, Chest, Gateway Arch, Bench, Crates)** | `prop_factory_3d.gd` | **Low–Medium** | Author-textured `.glb` hero props (especially animated chest lid & sculpted fountain statue). |

---

## 2. Custom 2D / UI & Audio Assets

| Asset Type | Status | Location / Notes |
|---|---|---|
| **HUD Toolbar SVG Icons** | **Completed** | `assets/icons/{map_icon,quest_icon,bag_icon,buddy_icon,learn_icon,games_icon,save_icon,settings_icon,menu_icon}.svg` |
| **Terrain & Stone Textures** | **Missing (Procedural Flat Colors Used)** | Stylized seamless `512x512`–`1024x1024` albedo + roughness + subtle normal maps for meadow grass, cobblestone plaza, dirt trail, and roof shingles. |
| **Audio (SFX / BGM / Pronunciation)** | **Tracked Separately** | See `docs/AUDIO_ASSET_MANIFEST.md` (currently optional/unbundled; HUD/Learning safety floors remain active). |

---

## 3. Technical Import Guidelines for Future `.glb` Assets
- **Scale:** `1 Godot unit = 1 meter`, character height `~1.55–1.75 m`.
- **Triangle Budget (Mobile-Safe):** Hero `<= 6,000 tris`, NPC `<= 4,500 tris`, Cottage `<= 3,500 tris`, Tree `<= 1,200 tris` (with LOD1 at 50%).
- **Texture Budget:** Max `1024x1024` (`VRAM Compressed` / `ETC2` for mobile, `WebP` or `BPTC` where supported).
- **Collider Discipline:** Keep `StaticBody3D` collision shapes simple (`BoxShape3D` / `CylinderShape3D` / `CapsuleShape3D`), never raw high-poly trimesh colliders on characters or foliage.
