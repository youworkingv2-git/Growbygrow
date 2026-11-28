extends RefCounted
class_name StylizedMeshKit
## Generates purposeful smooth-shaded & chamfered low-poly ArrayMeshes via SurfaceTool:
## - Organic multi-lobed stylized tree leaf clusters (no bare primitive cones)
## - Curved tapered tree trunks & forked boughs
## - Multi-blade curved grass tufts for MultiMeshInstance3D wind systems
## - Parabolic 3D water jet arc meshes for the animated village fountain

static var _mesh_cache: Dictionary = {}


static func build_leaf_clump_mesh(
	lump_seed: float = 1.0,
	radius: float = 1.0,
	height: float = 0.88,
	rings: int = 7,
	segs: int = 12,
	lumpiness: float = 0.18
) -> ArrayMesh:
	var key := "leaf|%.2f|%.2f|%.2f|%d|%d|%.2f" % [lump_seed, radius, height, rings, segs, lumpiness]
	if _mesh_cache.has(key):
		return _mesh_cache[key] as ArrayMesh

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var ring_verts: Array = []
	for r_idx in range(rings + 1):
		var v := float(r_idx) / float(rings)
		var phi := v * PI
		var sin_p := sin(phi)
		var cos_p := cos(phi)
		var row: Array[Vector3] = []
		for s_idx in range(segs + 1):
			var u := float(s_idx) / float(segs)
			var theta := u * TAU
			var dir := Vector3(sin_p * cos(theta), cos_p, sin_p * sin(theta))
			# Stylized organic lobe modulation + flatter settled base
			var lobe := 1.0 + lumpiness * (
				sin(theta * 3.0 + lump_seed * 2.1 + phi * 2.0) * 0.55 +
				cos(theta * 5.0 - lump_seed * 1.4 + phi * 3.0) * 0.30 +
				sin(phi * 4.0 + lump_seed) * 0.15
			)
			var flat_bottom := 0.82 if dir.y < -0.25 else 1.0
			var p := Vector3(dir.x * radius * lobe, dir.y * height * lobe * flat_bottom, dir.z * radius * lobe)
			row.append(p)
		ring_verts.append(row)

	for r_idx in range(rings):
		for s_idx in range(segs):
			var p00: Vector3 = ring_verts[r_idx][s_idx]
			var p10: Vector3 = ring_verts[r_idx + 1][s_idx]
			var p11: Vector3 = ring_verts[r_idx + 1][s_idx + 1]
			var p01: Vector3 = ring_verts[r_idx][s_idx + 1]

			var u0 := float(s_idx) / float(segs)
			var u1 := float(s_idx + 1) / float(segs)
			var v0 := float(r_idx) / float(rings)
			var v1 := float(r_idx + 1) / float(rings)

			st.set_uv(Vector2(u0, v0))
			st.add_vertex(p00)
			st.set_uv(Vector2(u0, v1))
			st.add_vertex(p10)
			st.set_uv(Vector2(u1, v1))
			st.add_vertex(p11)

			st.set_uv(Vector2(u0, v0))
			st.add_vertex(p00)
			st.set_uv(Vector2(u1, v1))
			st.add_vertex(p11)
			st.set_uv(Vector2(u1, v0))
			st.add_vertex(p01)

	st.generate_normals()
	var mesh := st.commit()
	_mesh_cache[key] = mesh
	return mesh


static func build_pine_bough_tier_mesh(
	radius: float = 1.4,
	tier_height: float = 1.05,
	lobes: int = 7,
	seed_val: float = 0.0
) -> ArrayMesh:
	# Multi-scalloped stylized pine foliage skirt (organic drooping branches instead of bare cone)
	var key := "pbough|%.2f|%.2f|%d|%.2f" % [radius, tier_height, lobes, seed_val]
	if _mesh_cache.has(key):
		return _mesh_cache[key] as ArrayMesh

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var segs := lobes * 3
	var rings := 5
	var grid: Array = []
	for r in range(rings + 1):
		var t := float(r) / float(rings) # 0 = top crown, 1 = outer drooping tips
		var row: Array[Vector3] = []
		for s in range(segs + 1):
			var ang := (float(s) / float(segs)) * TAU
			var scallop := 0.78 + 0.24 * cos(ang * float(lobes) + seed_val)
			var rad_t := radius * (0.14 + 0.86 * pow(t, 0.78)) * scallop
			var droop := pow(t, 1.35) * tier_height + (1.0 - scallop) * 0.22 * t
			var y := tier_height * 0.55 - droop
			row.append(Vector3(cos(ang) * rad_t, y, sin(ang) * rad_t))
		grid.append(row)

	for r in range(rings):
		for s in range(segs):
			var p00: Vector3 = grid[r][s]
			var p10: Vector3 = grid[r + 1][s]
			var p11: Vector3 = grid[r + 1][s + 1]
			var p01: Vector3 = grid[r][s + 1]
			var v0 := 1.0 - float(r) / float(rings)
			var v1 := 1.0 - float(r + 1) / float(rings)
			var u0 := float(s) / float(segs)
			var u1 := float(s + 1) / float(segs)

			st.set_uv(Vector2(u0, v0))
			st.add_vertex(p00)
			st.set_uv(Vector2(u1, v1))
			st.add_vertex(p11)
			st.set_uv(Vector2(u0, v1))
			st.add_vertex(p10)

			st.set_uv(Vector2(u0, v0))
			st.add_vertex(p00)
			st.set_uv(Vector2(u1, v0))
			st.add_vertex(p01)
			st.set_uv(Vector2(u1, v1))
			st.add_vertex(p11)

	# Underside cap closing each pine bough skirt cleanly
	var center_bot := Vector3(0.0, -tier_height * 0.18, 0.0)
	var bot_row: Array = grid[rings]
	for s in range(segs):
		var a: Vector3 = bot_row[s]
		var b: Vector3 = bot_row[s + 1]
		st.set_uv(Vector2(0.5, 0.1))
		st.add_vertex(center_bot)
		st.set_uv(Vector2(float(s) / float(segs), 0.0))
		st.add_vertex(a)
		st.set_uv(Vector2(float(s + 1) / float(segs), 0.0))
		st.add_vertex(b)

	st.generate_normals()
	var mesh := st.commit()
	_mesh_cache[key] = mesh
	return mesh


static func build_curved_trunk_mesh(
	r_bot: float = 0.36,
	r_top: float = 0.18,
	height: float = 2.2,
	bend_x: float = 0.18,
	bend_z: float = 0.08,
	segs: int = 9
) -> ArrayMesh:
	var key := "trunk|%.2f|%.2f|%.2f|%.2f|%.2f|%d" % [r_bot, r_top, height, bend_x, bend_z, segs]
	if _mesh_cache.has(key):
		return _mesh_cache[key] as ArrayMesh

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var rings := 5
	var grid: Array = []
	for r in range(rings + 1):
		var t := float(r) / float(rings)
		var root_flare := 1.38 if r == 0 else (1.12 if r == 1 else 1.0)
		var rad := lerpf(r_bot, r_top, t) * root_flare
		var cx := sin(t * PI * 0.85) * bend_x
		var cz := sin(t * PI * 0.70) * bend_z
		var y := t * height
		var row: Array[Vector3] = []
		for s in range(segs + 1):
			var ang := (float(s) / float(segs)) * TAU
			var bark_rib := 1.0 + (0.08 if r == 0 else 0.03) * cos(ang * 4.0 + t * 2.0)
			row.append(Vector3(cx + cos(ang) * rad * bark_rib, y, cz + sin(ang) * rad * bark_rib))
		grid.append(row)

	for r in range(rings):
		for s in range(segs):
			var p00: Vector3 = grid[r][s]
			var p10: Vector3 = grid[r + 1][s]
			var p11: Vector3 = grid[r + 1][s + 1]
			var p01: Vector3 = grid[r][s + 1]
			st.set_uv(Vector2(float(s) / float(segs), float(r) / float(rings)))
			st.add_vertex(p00)
			st.add_vertex(p01)
			st.add_vertex(p11)
			st.add_vertex(p00)
			st.add_vertex(p11)
			st.add_vertex(p10)

	st.generate_normals()
	var mesh := st.commit()
	_mesh_cache[key] = mesh
	return mesh


static func build_grass_tuft_mesh() -> ArrayMesh:
	var key := "grass_tuft_v2"
	if _mesh_cache.has(key):
		return _mesh_cache[key] as ArrayMesh

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# 6 curved tapered blades arranged at varied angles & heights
	var blade_specs := [
		{ "offset": Vector3(0.0, 0.0, 0.0),    "yaw": 0.0,  "h": 0.44, "w": 0.075, "lean": 0.12 },
		{ "offset": Vector3(0.09, 0.0, 0.05),  "yaw": 1.1,  "h": 0.38, "w": 0.068, "lean": 0.14 },
		{ "offset": Vector3(-0.08, 0.0, 0.06), "yaw": 2.2,  "h": 0.41, "w": 0.070, "lean": 0.13 },
		{ "offset": Vector3(0.06, 0.0, -0.09), "yaw": 3.4,  "h": 0.34, "w": 0.065, "lean": 0.11 },
		{ "offset": Vector3(-0.07, 0.0, -0.07),"yaw": 4.5,  "h": 0.36, "w": 0.065, "lean": 0.13 },
		{ "offset": Vector3(0.02, 0.0, 0.11),  "yaw": 5.4,  "h": 0.30, "w": 0.060, "lean": 0.10 },
	]

	for b in blade_specs:
		var pos: Vector3 = b["offset"]
		var yaw: float = float(b["yaw"])
		var h: float = float(b["h"])
		var w: float = float(b["w"])
		var lean: float = float(b["lean"])

		var right := Vector3(cos(yaw), 0.0, sin(yaw))
		var fwd := Vector3(-sin(yaw), 0.0, cos(yaw))

		var b_l := pos - right * (w * 0.5)
		var b_r := pos + right * (w * 0.5)
		var m_l := pos + Vector3(0.0, h * 0.52, 0.0) + fwd * (lean * 0.32) - right * (w * 0.30)
		var m_r := pos + Vector3(0.0, h * 0.52, 0.0) + fwd * (lean * 0.32) + right * (w * 0.30)
		var tip := pos + Vector3(0.0, h, 0.0) + fwd * lean

		# Lower quad
		st.set_normal(fwd)
		st.set_uv(Vector2(0.0, 0.0))
		st.add_vertex(b_l)
		st.set_uv(Vector2(1.0, 0.0))
		st.add_vertex(b_r)
		st.set_uv(Vector2(1.0, 0.52))
		st.add_vertex(m_r)

		st.set_uv(Vector2(0.0, 0.0))
		st.add_vertex(b_l)
		st.set_uv(Vector2(1.0, 0.52))
		st.add_vertex(m_r)
		st.set_uv(Vector2(0.0, 0.52))
		st.add_vertex(m_l)

		# Tapered blade tip triangle
		st.set_uv(Vector2(0.0, 0.52))
		st.add_vertex(m_l)
		st.set_uv(Vector2(1.0, 0.52))
		st.add_vertex(m_r)
		st.set_uv(Vector2(0.5, 1.0))
		st.add_vertex(tip)

	st.generate_normals()
	var mesh := st.commit()
	_mesh_cache[key] = mesh
	return mesh


static func build_water_jet_arc_mesh(
	start_r: float = 0.08,
	end_r: float = 1.25,
	start_y: float = 2.02,
	peak_y: float = 2.52,
	end_y: float = 0.54,
	width: float = 0.075,
	steps: int = 12
) -> ArrayMesh:
	var key := "wjet|%.2f|%.2f|%.2f|%.2f|%.2f|%.3f|%d" % [start_r, end_r, start_y, peak_y, end_y, width, steps]
	if _mesh_cache.has(key):
		return _mesh_cache[key] as ArrayMesh

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Crossed ribbon pair along parabolic curve for full 360-degree visibility
	for ribbon_idx in range(2):
		for i in range(steps):
			var t0 := float(i) / float(steps)
			var t1 := float(i + 1) / float(steps)

			var p0 := _arc_point(t0, start_r, end_r, start_y, peak_y, end_y)
			var p1 := _arc_point(t1, start_r, end_r, start_y, peak_y, end_y)
			var w0 := width * (0.65 + 0.55 * t0)
			var w1 := width * (0.65 + 0.55 * t1)
			var side := Vector3(0, 0, 1) if ribbon_idx == 0 else Vector3(0, 1, 0)

			st.set_uv(Vector2(0.0, t0))
			st.add_vertex(p0 - side * w0)
			st.set_uv(Vector2(1.0, t0))
			st.add_vertex(p0 + side * w0)
			st.set_uv(Vector2(1.0, t1))
			st.add_vertex(p1 + side * w1)

			st.set_uv(Vector2(0.0, t0))
			st.add_vertex(p0 - side * w0)
			st.set_uv(Vector2(1.0, t1))
			st.add_vertex(p1 + side * w1)
			st.set_uv(Vector2(0.0, t1))
			st.add_vertex(p1 - side * w1)

	st.generate_normals()
	var mesh := st.commit()
	_mesh_cache[key] = mesh
	return mesh


static func _arc_point(t: float, sr: float, er: float, sy: float, py: float, ey: float) -> Vector3:
	var r := lerpf(sr, er, t)
	# Quadratic Bezier arc: P0=(sr, sy), P1=(mid, py), P2=(er, ey)
	var omt := 1.0 - t
	var y := omt * omt * sy + 2.0 * omt * t * py + t * t * ey
	return Vector3(r, y, 0.0)
