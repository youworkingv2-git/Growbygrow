extends Node3D
class_name AmbientLife3D
## Dynamic Environment Animation Manager:
## - Fluttering 3D Butterflies hovering around village flowerbeds
## - Distant soaring valley birds gliding above the skyline
## - Scales cleanly across Low / Medium / High without breaking Low's living feel

var _butterflies: Array[Dictionary] = []
var _birds: Array[Dictionary] = []
var _time: float = 0.0
var _center_pos: Vector3 = Vector3.ZERO


func setup_village_life(butterfly_spots: Array[Vector3], center: Vector3 = Vector3.ZERO) -> void:
	_center_pos = center
	_butterflies.clear()
	_birds.clear()
	for child in get_children():
		child.queue_free()

	_spawn_butterflies(butterfly_spots)
	_spawn_birds()
	_apply_quality_visibility()
	if not EventBus.settings_changed.is_connected(_apply_quality_visibility):
		EventBus.settings_changed.connect(_apply_quality_visibility)


func _spawn_butterflies(spots: Array[Vector3]) -> void:
	var colors := [
		Color("#FFD54F"),
		Color("#FF80AB"),
		Color("#4FC3F7"),
		Color("#BA68C8"),
		Color("#FFB74D"),
	]
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = Color("#2C2233")
	body_mat.roughness = 0.7

	var wing_mesh := BoxMesh.new()
	wing_mesh.size = Vector3(0.11, 0.012, 0.085)

	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.016
	body_mesh.height = 0.09

	for i in range(spots.size()):
		var root := Node3D.new()
		root.name = "Butterfly_%d" % i
		add_child(root)

		var b_mi := MeshInstance3D.new()
		b_mi.mesh = body_mesh
		b_mi.material_override = body_mat
		b_mi.rotation_degrees = Vector3(90, 0, 0)
		b_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(b_mi)

		var w_mat := StandardMaterial3D.new()
		var c: Color = colors[i % colors.size()]
		w_mat.albedo_color = c
		w_mat.roughness = 0.45
		w_mat.emission_enabled = true
		w_mat.emission = c
		w_mat.emission_energy_multiplier = 0.35

		var lw := Node3D.new()
		root.add_child(lw)
		var l_mi := MeshInstance3D.new()
		l_mi.mesh = wing_mesh
		l_mi.material_override = w_mat
		l_mi.position = Vector3(-0.06, 0.0, 0.0)
		l_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		lw.add_child(l_mi)

		var rw := Node3D.new()
		root.add_child(rw)
		var r_mi := MeshInstance3D.new()
		r_mi.mesh = wing_mesh
		r_mi.material_override = w_mat
		r_mi.position = Vector3(0.06, 0.0, 0.0)
		r_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		rw.add_child(r_mi)

		_butterflies.append({
			"node": root,
			"lw": lw,
			"rw": rw,
			"anchor": spots[i],
			"phase": float(i) * 1.47,
			"radius": 0.65 + float(i % 3) * 0.25,
			"speed": 1.15 + float(i % 2) * 0.35,
		})


func _spawn_birds() -> void:
	var bird_mat := StandardMaterial3D.new()
	bird_mat.albedo_color = Color("#2C3E55")
	bird_mat.roughness = 0.8

	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.07
	body_mesh.height = 0.38
	var wing_mesh := BoxMesh.new()
	wing_mesh.size = Vector3(0.46, 0.025, 0.14)

	for i in range(4):
		var root := Node3D.new()
		root.name = "SoaringBird_%d" % i
		add_child(root)

		var bmi := MeshInstance3D.new()
		bmi.mesh = body_mesh
		bmi.material_override = bird_mat
		bmi.rotation_degrees = Vector3(90, 0, 0)
		bmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(bmi)

		var lw := Node3D.new()
		root.add_child(lw)
		var lmi := MeshInstance3D.new()
		lmi.mesh = wing_mesh
		lmi.material_override = bird_mat
		lmi.position = Vector3(-0.24, 0, 0)
		lmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		lw.add_child(lmi)

		var rw := Node3D.new()
		root.add_child(rw)
		var rmi := MeshInstance3D.new()
		rmi.mesh = wing_mesh
		rmi.material_override = bird_mat
		rmi.position = Vector3(0.24, 0, 0)
		rmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		rw.add_child(rmi)

		_birds.append({
			"node": root,
			"lw": lw,
			"rw": rw,
			"radius": 18.0 + float(i) * 4.2,
			"height": 11.5 + float(i % 2) * 2.4,
			"speed": 0.24 + float(i) * 0.035,
			"phase": float(i) * 1.6,
		})


func _apply_quality_visibility() -> void:
	var q := SettingsManager.graphics_quality
	for i in range(_butterflies.size()):
		var b_node: Node3D = _butterflies[i]["node"]
		if is_instance_valid(b_node):
			b_node.visible = true if q == "high" else (i < 3 if q == "medium" else i < 2)
	for i in range(_birds.size()):
		var bird_node: Node3D = _birds[i]["node"]
		if is_instance_valid(bird_node):
			bird_node.visible = (q != "low") or (i == 0)


func _process(delta: float) -> void:
	_time += delta
	for b in _butterflies:
		var node: Node3D = b["node"]
		if not is_instance_valid(node) or not node.visible:
			continue
		var ph: float = float(b["phase"])
		var sp: float = float(b["speed"])
		var r: float = float(b["radius"])
		var anchor: Vector3 = b["anchor"]
		var t := _time * sp + ph

		var nx := anchor.x + sin(t) * r
		var nz := anchor.z + sin(t * 2.0) * (r * 0.55)
		var ny := anchor.y + 0.55 + sin(t * 3.1) * 0.22
		var next_pos := Vector3(nx, ny, nz)
		var move_dir := next_pos - node.position
		node.position = next_pos
		if move_dir.length_squared() > 0.00001:
			node.rotation.y = atan2(move_dir.x, move_dir.z)

		var flap := sin(_time * 18.0 + ph) * 0.85
		(b["lw"] as Node3D).rotation.z = flap
		(b["rw"] as Node3D).rotation.z = -flap

	for bd in _birds:
		var node: Node3D = bd["node"]
		if not is_instance_valid(node) or not node.visible:
			continue
		var ph: float = float(bd["phase"])
		var sp: float = float(bd["speed"])
		var r: float = float(bd["radius"])
		var h: float = float(bd["height"])
		var ang := _time * sp + ph
		var next_pos := Vector3(
			_center_pos.x + cos(ang) * r,
			h + sin(ang * 2.0) * 0.7,
			_center_pos.z - 6.0 + sin(ang) * (r * 0.65)
		)
		var dir := next_pos - node.position
		node.position = next_pos
		if dir.length_squared() > 0.0001:
			node.rotation.y = atan2(dir.x, dir.z)

		var glide := sin(_time * 4.5 + ph) * 0.35
		(bd["lw"] as Node3D).rotation.z = glide
		(bd["rw"] as Node3D).rotation.z = -glide
