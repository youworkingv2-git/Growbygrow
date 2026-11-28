# Fantasy HUD & Responsive UI Design

**Implementation:** `scenes/ui/adventure_hud.tscn`, `scripts/ui/adventure_hud.gd`, `scripts/ui/components/minimap_widget.gd`

---

## 1. Layout Architecture
Designed to maximize 3D world visibility while keeping active quest progress, navigation, and actions effortless for young learners:

| Screen Corner | Element | Purpose |
|---|---|---|
| **Top-Left** | `TopBar` + `QuestTracker` | Compact Hero Badge (`Lv.1`, Hero Name, XP progress bar, Stars) and translucent Deep Navy / Warm Gold **Quest Scroll** showing current quest title, next objective, and progress bar. Clicking opens full Quest Log. |
| **Top-Right** | `TopRightCluster` | Circular live **Mini-Map** (`MiniMapWidget`: player heading arrow, quest NPC markers, chests/collectibles, area portals — click to expand World Map), compact **Area Badge**, and icon-only **Settings** & **Menu** buttons. |
| **Bottom-Center** | `BottomDock` | Compact icon-first fantasy toolbar (`Map [M]`, `Quests [Tab]`, `Bag`, `Buddy [H]`, `Learn [L]`, `Games [G]`, `Save`) with custom SVG icons in `assets/icons/` and localized tooltips. |
| **Bottom-Left (PC)** | `ControlsHint` | Subtle single-line key hint (`WASD Di chuyển · Chuột phải Xoay · E Tương tác · Esc Menu`) hidden automatically on touch devices or compact viewports `< 960px`. |
| **Center-Lower** | `InteractBanner` + `ToastBanner` | Contextual `[E] Tương tác: ...` prompt (only visible near an interactable) and non-intrusive animated achievement/quest/item toasts. |

---

## 2. Proximity-Only World Labels
- **No Wall-of-Text Clutter:** NPCs (`npc_controller.gd`) and collectibles (`interactable_object.gd`) hide floating 3D nameplates beyond `6.0 m` (`PROXIMITY_LABEL_RADIUS_SQ = 36.0`).
- **Distant Signposting:** Quest-relevant NPCs retain a compact floating `!` / `?` badge and a subtle pulsing ground ring (`QuestAuraRing`), while area exit portals remain visible at distance for clear wayfinding.
- **Close Proximity:** Walking within `6.0 m` smoothly reveals the NPC/object nameplate + dark backdrop pill (`LabelBackdrop3D`) and activates the `[E]` / touch prompt.

---

## 3. Platform & Screen Responsiveness (`_apply_responsive`)
- **Windows / Desktop (`>= 960px`):** Full `118×118` Mini-Map, all 7 dock icons with short hotkey labels, bottom-left PC controls hint, virtual joystick hidden.
- **Tablet / Medium (`740px – 959px`):** Compact top-left card (`30%` width), touch controls shown only when touch/mobile mode is active.
- **Mobile / Compact (`< 740px`):** Mini-Map scales to `88×88`, `Save` button moves into Pause Menu to save dock width, touch `Joystick` (bottom-left) and `TouchRightPad` (`Nhảy` + `Tương tác` + look drag, bottom-right) position cleanly above `BottomDock` (`touch_bottom_base = 72 + safe_bottom`), respecting `ResponsiveHelper.get_safe_area_margins()`.
