# Third-Person Camera Design

**Implementation:** `scenes/characters/player/player.tscn`, `scripts/character/player_controller.gd`

---

## 1. Framing & Ergonomics
- **Close Adventure Framing (No Top-Down Feeling):**
  - `camera_distance = 6.2 m` (zoom range `3.8 m` – `10.5 m` via mouse wheel)
  - `camera_height = 1.55 m` (pivot at upper torso/shoulder level)
  - `DEFAULT_CAM_PITCH = -0.30 rad` (~`-17.2°` downward tilt — replaces old `-0.58` top-down angle)
  - `Camera3D.fov = 55.0°`
- **Character Presence:** The player (`Leo` / `Mia`) fills a clear hero silhouette in the lower-center frame, while `Buddy` hovers gently over the left shoulder (`follow_offset = Vector3(-1.18, 1.38, 0.32)` in `scripts/character/buddy_controller.gd`) without obscuring the path ahead.

---

## 2. Smoothing & Camera Rotation
- **Follow Smoothing:** `camera_rig.position` lerps smoothly at `14.0 * delta` for responsive movement without jitter.
- **Rotation Controls:**
  - **Windows / Desktop:** Hold **Right Mouse Button** (or **Middle Mouse Button**) and drag horizontally/vertically, or use **Q / Left / Right** orbit keys (`yaw` 360°, `pitch` clamped between `-0.95 rad` and `0.28 rad`).
  - **Mobile / Touch:** Right-side touch drag pad routes yaw/pitch delta via `set_touch_look_delta()`.
- **Camera-Relative Movement:** `WASD` and touch joystick vectors align dynamically with `_cam_yaw` (`get_camera_yaw()`), ensuring forward always moves into the scene direction the player sees.

---

## 3. Collision Avoidance & Occlusion Fade
1. **SpringArm3D Anti-Clip:**
   - `SpringArm3D.spring_length = camera_distance`
   - `SpringArm3D.margin = 0.35`
   - `SpringArm3D.collision_mask = 66` (`layer 2` Terrain + `layer 64` Cottage walls, perimeter mounds, and Gateway Arch) so the camera never penetrates buildings or terrain.
2. **Line-of-Sight Occluder Fade (`_update_camera_occluders`):**
   - Casts a ray (`collision_mask = 16`) from the player chest (`+1.1m`) to the camera's world position.
   - Any tree or cottage blocking the player (`layer 16`) smoothly fades to `transparency = 0.68` while obstructing and restores cleanly once clear.
