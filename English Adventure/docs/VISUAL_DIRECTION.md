# Visual Direction – English Adventure

**Art Style:** Enchanted Fantasy Adventure – High Quality Stylized 3D Cartoon  
**Target Audience:** Children (ages 6–12) & families learning English on PC, WebGL2, Android, and iOS  

---

## 1. Core Pillars
1. **Rich Stylized Adventure World:** Warm, cohesive storybook proportions with clear architectural silhouettes, layered foliage, sculpted ground mounds, and deliberate landmarks rather than flat geometric cubes.
2. **Color Discipline (No Flat Mint Overload):** Ground, foliage, timber, stone, sky, and accents each sit at distinct hue, saturation, and value steps so characters and interactive objects pop naturally.
3. **Readable Hero & Landmarks:** The player (`Leo`/`Mia`), companion (`Buddy`), NPCs, and quest objects maintain high figure-ground contrast against grass and cobblestones through warm rim highlights, soft contact shadows, and restrained sky-tinted shadow fill.
4. **Fantasy HUD Integration:** Deep Navy translucent cards (`#0F1932` at ~84–88% alpha) with subtle Warm Golden borders (`#E8B949`) replace oversized flat colored buttons, keeping the 3D world front and center.

---

## 2. Official Color Palette

| Role | Name | Hex | Usage |
|---|---|---|---|
| Canopy Foliage | **Forest Green** | `#244F2B` / `#2A6332` | Oak/pine outer & mid tree crowns, distant forest ring |
| Meadow Turf | **Natural Grass Green** | `#2C5D33` / `#3F763B` | Ground terrain, sculpted grass mounds, park edges |
| Trails & Timber | **Earth Brown** | `#6A4B34` / `#8A6848` | Dirt paths, half-timber beams, benches, crates, tree trunks |
| Sunlight & Rewards | **Warm Golden** | `#FFE2B2` / `#E8B949` | Sun tint, HUD borders, quest highlights, chests, lanterns |
| Sky & Water | **Sky Blue** | `#4E92D6` / `#3F9AE0` | Daylight sky dome, fountain basin & spray, crystal highlights |
| Arcane Energy | **Magical Purple** | `#8D54E0` / `#A070FF` | Area portals, Buddy glow, letter runes, enchanted accents |
| Architecture Accent | **Coral Red** | `#D45A4A` / `#9E4438` | Cottage roofs, awnings, Academy trims, blossom highlights |
| UI Panels | **Deep Navy** | `#0F1932` / `#162344` | Quest tracker, Mini-Map rim, Top hero bar, Bottom icon dock |

---

## 3. Material & Surface Rules
- **Matte Organics (Grass, Soil, Bark, Leaves):** Roughness `0.80–0.96`, Metallic `0.0`.
- **Stone & Cobblestone:** Roughness `0.78–0.90`, subtle value variation between curb stone (`#696E78`) and warm cobbles (`#B69C6E`).
- **Painted Timber & Stucco:** Plaster walls `#EADBC4` (`roughness 0.88`), dark oak framing `#523929` (`roughness 0.80`).
- **Metals & Gems:** Brass/gold trim (`#E8B949`, `metallic 0.65`, `roughness 0.30`); portals/crystals (`emission_energy 0.85–1.6`, clamped below Filmic blowout).
- **Ground Contact Shadows:** Soft alpha-blended shadow discs (`_add_contact_shadow`) sit beneath characters, trees, cottages, and props so objects anchor to terrain across all quality tiers.

---

## 4. Implementation Files
- Palette & Material Builders: `scripts/visual3d/prop_factory_3d.gd`, `scripts/visual3d/character_rig_3d.gd`
- Environment Composition: `scripts/visual3d/area_environment_3d.gd`, `scripts/visual3d/world_environment_3d.gd`
- UI Styling: `scripts/ui/design_system.gd`, `scripts/ui/adventure_hud.gd`
