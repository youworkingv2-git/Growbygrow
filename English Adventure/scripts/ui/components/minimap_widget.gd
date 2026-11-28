class_name MiniMapWidget
extends Control
## Live Top-Right Fantasy Mini-Map rendering the active 3D area's layout,
## player position & facing arrow, NPC quest indicators (! / ? / ...),
## and portals/destinations. Clicking emits `map_clicked`.

signal map_clicked()

var _area_id: String = "welcome_village"
var _player_pos_xz: Vector2 = Vector2.ZERO
var _player_yaw: float = 0.0
var _npc_markers: Array[Dictionary] = []
var _portal_markers: Array[Dictionary] = []
var _object_markers: Array[Dictionary] = []
var _refresh_accum: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	custom_minimum_size = Vector2(118, 118)
	_refresh_world_markers()


func set_area(area_id: String) -> void:
	_area_id = area_id
	_refresh_world_markers()
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			map_clicked.emit()
	elif event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			map_clicked.emit()


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	_refresh_accum += delta
	if _refresh_accum >= 0.08:
		_refresh_accum = 0.0
		_refresh_live_positions()
		queue_redraw()


func _refresh_world_markers() -> void:
	_npc_markers.clear()
	_portal_markers.clear()
	_object_markers.clear()

	var tree := get_tree()
	if tree == null:
		return
	var root := tree.current_scene
	if root == null:
		return
	var entities := root.get_node_or_null("Entities3D")
	if entities == null:
		return

	for child in entities.get_children():
		if child is NpcController:
			var npc := child as NpcController
			var col := Color("#E2E8F0")
			if npc.current_state == NpcController.NpcState.QUEST_COMPLETED:
				col = Color("#22C55E")
			elif npc.current_state == NpcController.NpcState.QUEST_AVAILABLE:
				col = Color("#FBBF24")
			elif npc.current_state == NpcController.NpcState.QUEST_IN_PROGRESS:
				col = Color("#38BDF8")
			_npc_markers.append({
				"pos": Vector2(npc.global_position.x, npc.global_position.z),
				"color": col,
				"is_quest": npc.quest_badge.visible
			})
		elif child is InteractableObject:
			var obj := child as InteractableObject
			if not obj.visible:
				continue
			if obj.object_type == "portal":
				_portal_markers.append({
					"pos": Vector2(obj.global_position.x, obj.global_position.z),
					"unlocked": GameStateManager.is_area_unlocked(obj.target_area_id)
				})
			elif obj.object_type in ["chest", "lost_letter", "crystal"]:
				_object_markers.append({
					"pos": Vector2(obj.global_position.x, obj.global_position.z),
					"type": obj.object_type
				})


func _refresh_live_positions() -> void:
	var tree := get_tree()
	if tree == null:
		return
	var player := tree.get_first_node_in_group("player") as Node3D
	if player != null and is_instance_valid(player):
		_player_pos_xz = Vector2(player.global_position.x, player.global_position.z)
		if player is PlayerController:
			_player_yaw = (player as PlayerController).get_facing_yaw()
	_refresh_world_markers()


func _world_to_minimap(xz: Vector2, center: Vector2, radius: float) -> Vector2:
	# Normalize world coordinates (~20m x 12m) around player or area center
	var rel := xz - _player_pos_xz
	var scale_px := radius / 18.0
	var pt := center + Vector2(rel.x * scale_px, rel.y * scale_px)
	var offset := pt - center
	if offset.length() > radius - 7.0:
		offset = offset.normalized() * (radius - 7.0)
	return center + offset


func _draw() -> void:
	var sz := size
	if sz.x < 24.0 or sz.y < 24.0:
		return
	var center := sz * 0.5
	var radius := minf(sz.x, sz.y) * 0.5 - 3.0

	# Deep Navy background disc + subtle terrain rings
	draw_circle(center, radius, Color(0.05, 0.10, 0.20, 0.88))
	var terrain_col := Color(0.16, 0.34, 0.22, 0.55)
	if _area_id == "letter_cave":
		terrain_col = Color(0.16, 0.20, 0.32, 0.65)
	elif _area_id == "crystal_lake":
		terrain_col = Color(0.12, 0.32, 0.44, 0.62)
	elif _area_id == "shadow_gate":
		terrain_col = Color(0.20, 0.14, 0.32, 0.65)
	draw_circle(center, radius - 4.0, terrain_col)

	# Compass grid & plaza marker in world coordinates
	var plaza_pt := _world_to_minimap(Vector2(0.0, 1.5), center, radius)
	if plaza_pt.distance_to(center) < radius - 6.0:
		draw_arc(plaza_pt, radius * 0.22, 0.0, TAU, 20, Color(0.84, 0.72, 0.48, 0.32), 1.5)

	# Collectibles / chests
	for om in _object_markers:
		var pt := _world_to_minimap(om["pos"], center, radius)
		draw_circle(pt, 3.0, Color("#FDE047"))

	# Portals / Destinations
	for pm in _portal_markers:
		var pt := _world_to_minimap(pm["pos"], center, radius)
		var pcol := Color("#38BDF8") if bool(pm.get("unlocked", true)) else Color("#94A3B8")
		draw_circle(pt, 5.2, Color(pcol.r, pcol.g, pcol.b, 0.32))
		draw_arc(pt, 4.6, 0.0, TAU, 16, pcol, 2.0)

	# NPCs (with highlight ring on quest NPCs)
	for nm in _npc_markers:
		var pt := _world_to_minimap(nm["pos"], center, radius)
		var ncol: Color = nm["color"]
		if bool(nm.get("is_quest", false)):
			draw_circle(pt, 6.0, Color(ncol.r, ncol.g, ncol.b, 0.28))
		draw_circle(pt, 3.8, ncol)
		draw_arc(pt, 3.8, 0.0, TAU, 12, Color(0.05, 0.08, 0.15, 0.9), 1.2)

	# Player directional triangle at center
	var fwd := Vector2(sin(_player_yaw), cos(_player_yaw))
	var right := Vector2(fwd.y, -fwd.x)
	var tri := PackedVector2Array([
		center + fwd * 7.5,
		center - fwd * 4.5 + right * 5.0,
		center - fwd * 4.5 - right * 5.0
	])
	draw_colored_polygon(tri, Color("#FACC15"))
	draw_polyline(PackedVector2Array([tri[0], tri[1], tri[2], tri[0]]), Color("#1E293B"), 1.5)

	# Outer Warm Golden Fantasy Rim
	draw_arc(center, radius, 0.0, TAU, 36, Color(0.92, 0.74, 0.28, 0.85), 2.2)
	draw_arc(center, radius - 2.4, 0.0, TAU, 36, Color(0.32, 0.56, 0.86, 0.45), 1.0)
