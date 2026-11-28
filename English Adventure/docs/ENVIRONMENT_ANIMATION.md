# Dynamic Environment, NPC & Buddy Animation

**Implementation:** `scripts/visual3d/ambient_life_3d.gd`, `scripts/character/npc_controller.gd`, `scripts/character/buddy_controller.gd`, `scripts/visual3d/character_rig_3d.gd`

---

## 1. Living World Animations (Visible When Player Stands Still)
- **Vegetation:** Trees, shrubs, vines, flowers (`stylized_foliage_wind.gdshader`), and instanced grass tufts (`stylized_grass_wind.gdshader`) sway asynchronously across world space.
- **Water:** Fountain ripples, parabolic water jets, crystal spin, plume spray, splash droplets, and mist animate continuously.
- **Ambient Creatures (`AmbientLife3D`):**
  - 5 animated 3D **Butterflies** with twin flapping wing pivots gliding in figure-8 paths above village flowerbeds.
  - 4 distant **Soaring Birds** circling high above the valley horizon.
- **Sunlit Motes:** Gentle golden dust/pollen `CPUParticles3D` drifting through the plaza.

---

## 2. NPC & Buddy Articulated Animations (`CharacterRig3D`)
- **Shared Rig Capabilities (`update_blink_and_breath`):** Natural periodic eye blinking (`3.2–5.6s` cadence) + subtle chest breathing scale.
- **NPCs (`NpcController`):**
  - Weight-shift idle sway (`body_pivot.rotation.z`) + breathing bob (`body_pivot.position.y`).
  - Proximity head-tracking (`head_pivot.rotation.y` smoothly turns toward nearby player within `6m` before full body rotation on interaction).
  - Expressive arm gestures during dialogue/voice playback (`_is_talking` / `_is_speaking_audio`) and celebratory arm-raise when a quest reward is claimed.
- **Buddy (`BuddyController`):**
  - Wing flapping + tail wagging modulated by mood (`IDLE`, `HAPPY`, `THINKING`, `TALKING`, `CELEBRATING`).
  - `THINKING` tilts `head_pivot`, `TALKING` animates arm gestures + speaking mouth, `CELEBRATING` spins/flaps without shaking the entire root node.
