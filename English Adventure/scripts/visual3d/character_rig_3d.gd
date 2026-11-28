extends Node3D
class_name CharacterRig3D
## Stylized 3D Fantasy Cartoon Character Rig Builder (Placeholder Rig).
## Builds articulated multi-part 3D placeholder models for all 7 core characters:
## - boy, girl, buddy, professor_owl, lily, rocky, crystal_guardian
## Designed to be cleanly swapped out via Asset3DSlot when official .glb/.gltf models arrive.

@export var character_id: String = "boy"
@export var is_placeholder: bool = true

var body_pivot: Node3D
var head_pivot: Node3D
var left_arm_pivot: Node3D
var right_arm_pivot: Node3D
var left_leg_pivot: Node3D
var right_leg_pivot: Node3D
var left_wing_pivot: Node3D
var right_wing_pivot: Node3D
var tail_pivot: Node3D
var prop_pivot: Node3D

var left_eye: MeshInstance3D
var right_eye: MeshInstance3D
var left_brow: MeshInstance3D
var right_brow: MeshInstance3D
var mouth_mesh: MeshInstance3D
var aura_mesh: MeshInstance3D

var _current_mood: String = "neutral"
var _materials_cache: Dictionary = {}
var _is_speaking: bool = false
var _speak_phase: float = 0.0
var _blink_timer: float = 2.6
var _blink_closing: float = 0.0


static func build_character(char_id: String) -> CharacterRig3D:
	var rig := CharacterRig3D.new()
	rig.name = "CharacterRig3D_%s" % char_id
	rig.character_id = char_id
	rig.is_placeholder = true
	rig._build()
	return rig


func _build() -> void:
	for child in get_children():
		child.queue_free()

	body_pivot = Node3D.new()
	body_pivot.name = "BodyPivot"
	add_child(body_pivot)

	match character_id:
		"girl":
			_build_adventurer(true)
		"buddy":
			_build_buddy()
		"professor_owl":
			_build_professor_owl()
		"lily":
			_build_lily()
		"rocky":
			_build_rocky()
		"crystal_guardian":
			_build_crystal_guardian()
		_:
			_build_adventurer(false)

	set_expression(_current_mood)


func _mat(key: String, albedo: Color, roughness: float = 0.55, metallic: float = 0.0, emission: Color = Color.BLACK, emission_energy: float = 0.0) -> StandardMaterial3D:
	if _materials_cache.has(key):
		return _materials_cache[key] as StandardMaterial3D
	var m := StandardMaterial3D.new()
	m.albedo_color = albedo
	m.roughness = roughness
	m.metallic = metallic
	if emission_energy > 0.0:
		m.emission_enabled = true
		m.emission = emission
		m.emission_energy_multiplier = emission_energy
	_materials_cache[key] = m
	return m


func _add_part(parent: Node3D, part_name: String, mesh: Mesh, material: Material, pos: Vector3 = Vector3.ZERO, rot_deg: Vector3 = Vector3.ZERO, scale_v: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = part_name
	mi.mesh = mesh
	mi.material_override = material
	mi.position = pos
	mi.rotation_degrees = rot_deg
	mi.scale = scale_v
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)
	return mi


func _sphere(r: float, h: float = -1.0, rings: int = 12, radial: int = 18) -> SphereMesh:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0 if h < 0.0 else h
	s.rings = rings
	s.radial_segments = radial
	return s


func _capsule(r: float, h: float, rings: int = 6, radial: int = 14) -> CapsuleMesh:
	var c := CapsuleMesh.new()
	c.radius = r
	c.height = h
	c.rings = rings
	c.radial_segments = radial
	return c


func _cylinder(r_top: float, r_bot: float, h: float, radial: int = 16) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = r_top
	c.bottom_radius = r_bot
	c.height = h
	c.radial_segments = radial
	return c


func _box(sz: Vector3) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = sz
	return b


func _torus(inner_r: float, outer_r: float) -> TorusMesh:
	var t := TorusMesh.new()
	t.inner_radius = inner_r
	t.outer_radius = outer_r
	t.rings = 16
	t.ring_segments = 12
	return t


func _add_ground_shadow(radius: float, opacity: float = 0.28) -> void:
	var shadow_mat := StandardMaterial3D.new()
	shadow_mat.albedo_color = Color(0.05, 0.09, 0.14, opacity)
	shadow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shadow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var shadow_disc := _add_part(self, "GroundShadow", _cylinder(radius, radius, 0.015), shadow_mat, Vector3(0, 0.012, 0))
	shadow_disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _add_face(parent: Node3D, z_face: float, y_center: float, eye_sep: float = 0.095, eye_scale: float = 1.0) -> void:
	var eye_white := _mat("eye_white", Color(0.98, 0.99, 1.0), 0.25)
	var eye_dark := _mat("eye_dark", Color(0.11, 0.14, 0.22), 0.12)
	var brow_mat := _mat("brow_dark", Color(0.24, 0.15, 0.10), 0.6)
	var cheek_mat := _mat("cheek", Color(0.98, 0.56, 0.54), 0.65)
	var mouth_mat := _mat("mouth", Color(0.68, 0.22, 0.24), 0.4)

	# Sclera + Pupil combo
	_add_part(parent, "LeftEyeWhite", _sphere(0.048 * eye_scale, 0.095 * eye_scale), eye_white, Vector3(-eye_sep, y_center, z_face - 0.01), Vector3.ZERO, Vector3(1.0, 1.15, 0.55))
	_add_part(parent, "RightEyeWhite", _sphere(0.048 * eye_scale, 0.095 * eye_scale), eye_white, Vector3(eye_sep, y_center, z_face - 0.01), Vector3.ZERO, Vector3(1.0, 1.15, 0.55))
	left_eye = _add_part(parent, "LeftPupil", _sphere(0.032 * eye_scale, 0.064 * eye_scale), eye_dark, Vector3(-eye_sep, y_center, z_face + 0.012), Vector3.ZERO, Vector3(1.0, 1.1, 0.55))
	right_eye = _add_part(parent, "RightPupil", _sphere(0.032 * eye_scale, 0.064 * eye_scale), eye_dark, Vector3(eye_sep, y_center, z_face + 0.012), Vector3.ZERO, Vector3(1.0, 1.1, 0.55))
	_add_part(parent, "LeftSparkle", _sphere(0.011 * eye_scale), eye_white, Vector3(-eye_sep + 0.012 * eye_scale, y_center + 0.014 * eye_scale, z_face + 0.025))
	_add_part(parent, "RightSparkle", _sphere(0.011 * eye_scale), eye_white, Vector3(eye_sep + 0.012 * eye_scale, y_center + 0.014 * eye_scale, z_face + 0.025))

	left_brow = _add_part(parent, "LeftBrow", _capsule(0.012, 0.068), brow_mat, Vector3(-eye_sep, y_center + 0.072 * eye_scale, z_face + 0.004), Vector3(0, 0, 90))
	right_brow = _add_part(parent, "RightBrow", _capsule(0.012, 0.068), brow_mat, Vector3(eye_sep, y_center + 0.072 * eye_scale, z_face + 0.004), Vector3(0, 0, 90))

	_add_part(parent, "LeftCheek", _sphere(0.032 * eye_scale), cheek_mat, Vector3(-eye_sep - 0.045, y_center - 0.052, z_face - 0.02), Vector3.ZERO, Vector3(1.1, 0.7, 0.45))
	_add_part(parent, "RightCheek", _sphere(0.032 * eye_scale), cheek_mat, Vector3(eye_sep + 0.045, y_center - 0.052, z_face - 0.02), Vector3.ZERO, Vector3(1.1, 0.7, 0.45))

	mouth_mesh = _add_part(parent, "Mouth", _capsule(0.014, 0.062), mouth_mat, Vector3(0, y_center - 0.075, z_face + 0.002), Vector3(0, 0, 90))


func _build_adventurer(is_girl: bool) -> void:
	var skin := _mat("skin", Color(0.98, 0.80, 0.67), 0.62)
	var tunic_color := Color(0.90, 0.34, 0.45) if is_girl else Color(0.18, 0.48, 0.88)
	var accent_color := Color(0.24, 0.78, 0.72) if is_girl else Color(0.96, 0.72, 0.20)
	var hair_color := Color(0.56, 0.24, 0.14) if is_girl else Color(0.32, 0.20, 0.12)
	var tunic := _mat("tunic", tunic_color, 0.55)
	var accent := _mat("accent", accent_color, 0.45)
	var pants := _mat("pants", Color(0.25, 0.29, 0.40), 0.65)
	var boots := _mat("boots", Color(0.38, 0.23, 0.14), 0.50)
	var hair := _mat("hair", hair_color, 0.65)
	var gold := _mat("gold", Color(0.98, 0.82, 0.28), 0.28, 0.75)

	# Ground drop shadow disc (subtle grounding cue even if dynamic shadow off on Low)
	_add_ground_shadow(0.36, 0.30)

	# Legs
	left_leg_pivot = Node3D.new()
	left_leg_pivot.name = "LeftLegPivot"
	left_leg_pivot.position = Vector3(-0.12, 0.46, 0)
	body_pivot.add_child(left_leg_pivot)
	_add_part(left_leg_pivot, "Leg", _capsule(0.085, 0.34), pants, Vector3(0, -0.17, 0))
	_add_part(left_leg_pivot, "Boot", _capsule(0.098, 0.18), boots, Vector3(0, -0.37, 0.03), Vector3(75, 0, 0))

	right_leg_pivot = Node3D.new()
	right_leg_pivot.name = "RightLegPivot"
	right_leg_pivot.position = Vector3(0.12, 0.46, 0)
	body_pivot.add_child(right_leg_pivot)
	_add_part(right_leg_pivot, "Leg", _capsule(0.085, 0.34), pants, Vector3(0, -0.17, 0))
	_add_part(right_leg_pivot, "Boot", _capsule(0.098, 0.18), boots, Vector3(0, -0.37, 0.03), Vector3(75, 0, 0))

	# Torso & tunic flare
	_add_part(body_pivot, "Torso", _cylinder(0.18, 0.23, 0.44), tunic, Vector3(0, 0.68, 0))
	_add_part(body_pivot, "Belt", _cylinder(0.225, 0.23, 0.07), boots, Vector3(0, 0.54, 0))
	_add_part(body_pivot, "BeltBuckle", _box(Vector3(0.10, 0.08, 0.04)), gold, Vector3(0, 0.54, 0.225))
	_add_part(body_pivot, "ScarfCollar", _torus(0.11, 0.20), accent, Vector3(0, 0.90, 0))
	if is_girl:
		_add_part(body_pivot, "SkirtFlare", _cylinder(0.22, 0.30, 0.20), tunic, Vector3(0, 0.47, 0))
		_add_part(body_pivot, "StarBrooch", _sphere(0.045), gold, Vector3(0, 0.80, 0.20))

	# Adventurer Backpack
	var pack := _add_part(body_pivot, "Backpack", _box(Vector3(0.28, 0.32, 0.15)), boots, Vector3(0, 0.72, -0.22))
	_add_part(pack, "Bedroll", _cylinder(0.055, 0.055, 0.30), accent, Vector3(0, 0.19, 0), Vector3(0, 0, 90))
	_add_part(body_pivot, "ScarfTailL", _box(Vector3(0.11, 0.30, 0.04)), accent, Vector3(-0.08, 0.76, -0.31), Vector3(-14, 0, 8))
	_add_part(body_pivot, "ScarfTailR", _box(Vector3(0.10, 0.24, 0.04)), accent, Vector3(0.07, 0.78, -0.31), Vector3(-18, 0, -10))

	# Arms
	left_arm_pivot = Node3D.new()
	left_arm_pivot.name = "LeftArmPivot"
	left_arm_pivot.position = Vector3(-0.26, 0.84, 0)
	body_pivot.add_child(left_arm_pivot)
	_add_part(left_arm_pivot, "Sleeve", _capsule(0.075, 0.28), tunic, Vector3(-0.02, -0.14, 0), Vector3(0, 0, 8))
	_add_part(left_arm_pivot, "Hand", _sphere(0.072), skin, Vector3(-0.04, -0.30, 0))

	right_arm_pivot = Node3D.new()
	right_arm_pivot.name = "RightArmPivot"
	right_arm_pivot.position = Vector3(0.26, 0.84, 0)
	body_pivot.add_child(right_arm_pivot)
	_add_part(right_arm_pivot, "Sleeve", _capsule(0.075, 0.28), tunic, Vector3(0.02, -0.14, 0), Vector3(0, 0, -8))
	_add_part(right_arm_pivot, "Hand", _sphere(0.072), skin, Vector3(0.04, -0.30, 0))

	# Head
	head_pivot = Node3D.new()
	head_pivot.name = "HeadPivot"
	head_pivot.position = Vector3(0, 1.14, 0)
	body_pivot.add_child(head_pivot)

	_add_part(head_pivot, "Head", _sphere(0.26, 0.50), skin, Vector3.ZERO)
	_add_part(head_pivot, "LeftEar", _sphere(0.055), skin, Vector3(-0.25, -0.02, 0))
	_add_part(head_pivot, "RightEar", _sphere(0.055), skin, Vector3(0.25, -0.02, 0))
	_add_face(head_pivot, 0.23, 0.0, 0.092, 1.0)

	# Stylized hair + headwear
	_add_part(head_pivot, "HairCap", _sphere(0.275, 0.42), hair, Vector3(0, 0.07, -0.03))
	_add_part(head_pivot, "Bangs", _sphere(0.14, 0.16), hair, Vector3(-0.06, 0.18, 0.18), Vector3(20, 0, -15), Vector3(1.2, 0.7, 0.7))
	if is_girl:
		_add_part(head_pivot, "LeftPigtail", _capsule(0.075, 0.24), hair, Vector3(-0.27, 0.04, -0.08), Vector3(12, 0, 22))
		_add_part(head_pivot, "RightPigtail", _capsule(0.075, 0.24), hair, Vector3(0.27, 0.04, -0.08), Vector3(12, 0, -22))
		_add_part(head_pivot, "StarClip", _sphere(0.045), gold, Vector3(0.17, 0.17, 0.17))
		_add_part(head_pivot, "Headband", _torus(0.23, 0.27), accent, Vector3(0, 0.14, -0.02), Vector3(-18, 0, 0))
	else:
		# Explorer cap + feather
		_add_part(head_pivot, "CapCrown", _sphere(0.27, 0.28), accent, Vector3(0, 0.16, -0.02))
		_add_part(head_pivot, "CapVisor", _cylinder(0.24, 0.24, 0.04), boots, Vector3(0, 0.12, 0.16), Vector3(12, 0, 0), Vector3(0.95, 1.0, 0.75))
		_add_part(head_pivot, "Feather", _capsule(0.022, 0.16), _mat("feather", Color(0.95, 0.30, 0.35)), Vector3(-0.22, 0.28, -0.04), Vector3(-20, 0, 28))


func _build_buddy() -> void:
	_add_ground_shadow(0.26, 0.22)
	var jade := _mat("buddy_jade", Color(0.20, 0.78, 0.48), 0.45)
	var belly := _mat("buddy_belly", Color(0.98, 0.90, 0.62), 0.55)
	var wing_mat := _mat("buddy_wing", Color(0.98, 0.74, 0.24), 0.35, 0.0, Color(0.98, 0.70, 0.20), 0.35)
	var horn_mat := _mat("buddy_horn", Color(1.0, 0.85, 0.36), 0.30, 0.2)
	var glow_mat := _mat("buddy_glow", Color(0.45, 0.96, 0.78), 0.2, 0.0, Color(0.40, 0.95, 0.72), 0.9)

	body_pivot.position = Vector3(0, 0.55, 0)
	_add_part(body_pivot, "Torso", _sphere(0.22, 0.48), jade, Vector3(0, 0.0, 0), Vector3(12, 0, 0))
	_add_part(body_pivot, "Belly", _sphere(0.16, 0.36), belly, Vector3(0, -0.02, 0.09), Vector3(12, 0, 0))

	# Cute stubby limbs
	left_arm_pivot = Node3D.new()
	left_arm_pivot.position = Vector3(-0.18, 0.08, 0.06)
	body_pivot.add_child(left_arm_pivot)
	_add_part(left_arm_pivot, "Arm", _capsule(0.045, 0.14), jade, Vector3(0, -0.06, 0.04), Vector3(45, 0, 15))

	right_arm_pivot = Node3D.new()
	right_arm_pivot.position = Vector3(0.18, 0.08, 0.06)
	body_pivot.add_child(right_arm_pivot)
	_add_part(right_arm_pivot, "Arm", _capsule(0.045, 0.14), jade, Vector3(0, -0.06, 0.04), Vector3(45, 0, -15))

	left_leg_pivot = Node3D.new()
	left_leg_pivot.position = Vector3(-0.12, -0.18, 0.0)
	body_pivot.add_child(left_leg_pivot)
	_add_part(left_leg_pivot, "Foot", _sphere(0.065), jade, Vector3(0, -0.04, 0.04))

	right_leg_pivot = Node3D.new()
	right_leg_pivot.position = Vector3(0.12, -0.18, 0.0)
	body_pivot.add_child(right_leg_pivot)
	_add_part(right_leg_pivot, "Foot", _sphere(0.065), jade, Vector3(0, -0.04, 0.04))

	# Wings
	left_wing_pivot = Node3D.new()
	left_wing_pivot.position = Vector3(-0.14, 0.10, -0.14)
	body_pivot.add_child(left_wing_pivot)
	_add_part(left_wing_pivot, "WingMembrane", _box(Vector3(0.32, 0.22, 0.025)), wing_mat, Vector3(-0.18, 0.06, -0.04), Vector3(-12, 22, 14))

	right_wing_pivot = Node3D.new()
	right_wing_pivot.position = Vector3(0.14, 0.10, -0.14)
	body_pivot.add_child(right_wing_pivot)
	_add_part(right_wing_pivot, "WingMembrane", _box(Vector3(0.32, 0.22, 0.025)), wing_mat, Vector3(0.18, 0.06, -0.04), Vector3(-12, -22, -14))

	# Tail with glowing orb tip
	tail_pivot = Node3D.new()
	tail_pivot.position = Vector3(0, -0.14, -0.18)
	body_pivot.add_child(tail_pivot)
	_add_part(tail_pivot, "TailSeg1", _capsule(0.055, 0.22), jade, Vector3(0, -0.02, -0.10), Vector3(72, 0, 0))
	_add_part(tail_pivot, "TailFlame", _sphere(0.06), glow_mat, Vector3(0, 0.03, -0.24))

	# Head & Snout
	head_pivot = Node3D.new()
	head_pivot.position = Vector3(0, 0.28, 0.06)
	body_pivot.add_child(head_pivot)
	_add_part(head_pivot, "Head", _sphere(0.20, 0.36), jade, Vector3.ZERO)
	_add_part(head_pivot, "Snout", _sphere(0.11, 0.16), jade, Vector3(0, -0.04, 0.17), Vector3.ZERO, Vector3(1.15, 0.85, 1.0))
	_add_part(head_pivot, "LeftHorn", _cylinder(0.01, 0.045, 0.15), horn_mat, Vector3(-0.10, 0.18, -0.02), Vector3(-18, 0, 18))
	_add_part(head_pivot, "RightHorn", _cylinder(0.01, 0.045, 0.15), horn_mat, Vector3(0.10, 0.18, -0.02), Vector3(-18, 0, -18))
	_add_part(head_pivot, "Crest", _sphere(0.055), horn_mat, Vector3(0, 0.20, -0.05))
	_add_face(head_pivot, 0.185, 0.02, 0.082, 0.95)


func _build_professor_owl() -> void:
	_add_ground_shadow(0.38, 0.28)
	var feather := _mat("owl_feather", Color(0.55, 0.36, 0.22), 0.7)
	var chest := _mat("owl_chest", Color(0.95, 0.89, 0.76), 0.72)
	var robe := _mat("owl_robe", Color(0.20, 0.28, 0.62), 0.55)
	var gold := _mat("owl_gold", Color(0.98, 0.80, 0.24), 0.25, 0.8)
	var beak := _mat("owl_beak", Color(0.96, 0.62, 0.14), 0.45)

	_add_part(body_pivot, "Body", _sphere(0.32, 0.76), feather, Vector3(0, 0.58, 0))
	_add_part(body_pivot, "Chest", _sphere(0.24, 0.54), chest, Vector3(0, 0.55, 0.11))
	_add_part(body_pivot, "ScholarRobe", _cylinder(0.28, 0.35, 0.34), robe, Vector3(0, 0.34, 0))
	_add_part(body_pivot, "LeftFoot", _sphere(0.07), beak, Vector3(-0.12, 0.08, 0.10), Vector3.ZERO, Vector3(1.1, 0.6, 1.4))
	_add_part(body_pivot, "RightFoot", _sphere(0.07), beak, Vector3(0.12, 0.08, 0.10), Vector3.ZERO, Vector3(1.1, 0.6, 1.4))

	left_arm_pivot = Node3D.new()
	left_arm_pivot.position = Vector3(-0.30, 0.70, 0)
	body_pivot.add_child(left_arm_pivot)
	_add_part(left_arm_pivot, "LeftWing", _sphere(0.16, 0.44), feather, Vector3(-0.04, -0.14, 0), Vector3(0, 0, 14), Vector3(0.55, 1.0, 0.8))

	right_arm_pivot = Node3D.new()
	right_arm_pivot.position = Vector3(0.30, 0.70, 0)
	body_pivot.add_child(right_arm_pivot)
	_add_part(right_arm_pivot, "RightWing", _sphere(0.16, 0.44), feather, Vector3(0.04, -0.14, 0), Vector3(0, 0, -14), Vector3(0.55, 1.0, 0.8))

	head_pivot = Node3D.new()
	head_pivot.position = Vector3(0, 1.06, 0.02)
	body_pivot.add_child(head_pivot)
	_add_part(head_pivot, "Head", _sphere(0.27, 0.48), feather, Vector3.ZERO)
	_add_part(head_pivot, "LeftTuft", _cylinder(0.01, 0.06, 0.16), feather, Vector3(-0.17, 0.20, 0.02), Vector3(0, 0, 25))
	_add_part(head_pivot, "RightTuft", _cylinder(0.01, 0.06, 0.16), feather, Vector3(0.17, 0.20, 0.02), Vector3(0, 0, -25))
	_add_part(head_pivot, "Beak", _cylinder(0.01, 0.06, 0.12), beak, Vector3(0, -0.02, 0.28), Vector3(85, 0, 0))
	_add_face(head_pivot, 0.24, 0.04, 0.105, 1.2)
	# Golden glasses frames
	_add_part(head_pivot, "LeftGlass", _torus(0.055, 0.072), gold, Vector3(-0.105, 0.04, 0.24), Vector3(90, 0, 0))
	_add_part(head_pivot, "RightGlass", _torus(0.055, 0.072), gold, Vector3(0.105, 0.04, 0.24), Vector3(90, 0, 0))
	# Mortarboard Hat
	_add_part(head_pivot, "HatCap", _cylinder(0.18, 0.20, 0.14), robe, Vector3(0, 0.24, 0))
	_add_part(head_pivot, "HatBoard", _box(Vector3(0.46, 0.035, 0.46)), robe, Vector3(0, 0.32, 0), Vector3(0, 24, 0))
	_add_part(head_pivot, "Tassel", _capsule(0.018, 0.14), gold, Vector3(0.22, 0.23, 0.04))


func _build_lily() -> void:
	_build_humanoid_npc(
		Color(0.22, 0.68, 0.38),
		Color(0.98, 0.88, 0.56),
		Color(0.55, 0.30, 0.16),
		true
	)
	# Wide sunhat + daisy flower
	var straw := _mat("straw", Color(0.95, 0.84, 0.50), 0.72)
	var flower := _mat("daisy", Color(1.0, 0.45, 0.68), 0.45)
	_add_part(head_pivot, "SunHatBrim", _cylinder(0.42, 0.42, 0.03), straw, Vector3(0, 0.20, -0.02), Vector3(-10, 0, 0))
	_add_part(head_pivot, "SunHatCrown", _cylinder(0.20, 0.25, 0.14), straw, Vector3(0, 0.27, -0.03), Vector3(-10, 0, 0))
	_add_part(head_pivot, "Daisy", _sphere(0.055), flower, Vector3(-0.22, 0.25, 0.16))


func _build_rocky() -> void:
	_build_humanoid_npc(
		Color(0.28, 0.48, 0.62),
		Color(0.92, 0.56, 0.18),
		Color(0.24, 0.18, 0.14),
		false
	)
	# Miner helmet with glowing lantern gem
	var helmet := _mat("helmet", Color(0.96, 0.72, 0.18), 0.35, 0.2)
	var lamp := _mat("lamp", Color(0.75, 0.98, 1.0), 0.1, 0.0, Color(0.65, 0.95, 1.0), 1.8)
	_add_part(head_pivot, "Helmet", _sphere(0.28, 0.30), helmet, Vector3(0, 0.16, -0.01))
	_add_part(head_pivot, "HelmetLamp", _cylinder(0.055, 0.055, 0.06), lamp, Vector3(0, 0.22, 0.25), Vector3(90, 0, 0))


func _build_humanoid_npc(tunic_c: Color, accent_c: Color, hair_c: Color, skirt: bool) -> void:
	_add_ground_shadow(0.35, 0.28)
	var skin := _mat("npc_skin", Color(0.98, 0.80, 0.68), 0.62)
	var tunic := _mat("npc_tunic", tunic_c, 0.55)
	var accent := _mat("npc_accent", accent_c, 0.45)
	var hair := _mat("npc_hair", hair_c, 0.65)
	var boots := _mat("npc_boots", Color(0.36, 0.22, 0.14), 0.55)

	left_leg_pivot = Node3D.new()
	left_leg_pivot.position = Vector3(-0.12, 0.46, 0)
	body_pivot.add_child(left_leg_pivot)
	_add_part(left_leg_pivot, "Leg", _capsule(0.085, 0.34), boots, Vector3(0, -0.17, 0))

	right_leg_pivot = Node3D.new()
	right_leg_pivot.position = Vector3(0.12, 0.46, 0)
	body_pivot.add_child(right_leg_pivot)
	_add_part(right_leg_pivot, "Leg", _capsule(0.085, 0.34), boots, Vector3(0, -0.17, 0))

	_add_part(body_pivot, "Torso", _cylinder(0.19, 0.24, 0.46), tunic, Vector3(0, 0.68, 0))
	_add_part(body_pivot, "Sash", _torus(0.12, 0.22), accent, Vector3(0, 0.90, 0))
	if skirt:
		_add_part(body_pivot, "Skirt", _cylinder(0.22, 0.32, 0.22), tunic, Vector3(0, 0.47, 0))

	left_arm_pivot = Node3D.new()
	left_arm_pivot.position = Vector3(-0.26, 0.84, 0)
	body_pivot.add_child(left_arm_pivot)
	_add_part(left_arm_pivot, "Arm", _capsule(0.072, 0.28), tunic, Vector3(-0.02, -0.14, 0))
	_add_part(left_arm_pivot, "Hand", _sphere(0.068), skin, Vector3(-0.02, -0.29, 0))

	right_arm_pivot = Node3D.new()
	right_arm_pivot.position = Vector3(0.26, 0.84, 0)
	body_pivot.add_child(right_arm_pivot)
	_add_part(right_arm_pivot, "Arm", _capsule(0.072, 0.28), tunic, Vector3(0.02, -0.14, 0))
	_add_part(right_arm_pivot, "Hand", _sphere(0.068), skin, Vector3(0.02, -0.29, 0))

	head_pivot = Node3D.new()
	head_pivot.position = Vector3(0, 1.14, 0)
	body_pivot.add_child(head_pivot)
	_add_part(head_pivot, "Head", _sphere(0.255, 0.48), skin, Vector3.ZERO)
	_add_part(head_pivot, "Hair", _sphere(0.268, 0.40), hair, Vector3(0, 0.06, -0.03))
	_add_face(head_pivot, 0.225, 0.0, 0.09, 1.0)


func _build_crystal_guardian() -> void:
	_add_ground_shadow(0.42, 0.26)
	var robe := _mat("cg_robe", Color(0.22, 0.42, 0.86), 0.35, 0.15, Color(0.18, 0.45, 0.90), 0.25)
	var crystal := _mat("cg_crystal", Color(0.38, 0.92, 1.0), 0.12, 0.2, Color(0.35, 0.90, 1.0), 1.2)
	var violet := _mat("cg_violet", Color(0.72, 0.45, 0.98), 0.2, 0.2, Color(0.68, 0.40, 0.95), 0.9)

	body_pivot.position = Vector3(0, 0.18, 0)
	_add_part(body_pivot, "RobeBase", _cylinder(0.18, 0.36, 0.82), robe, Vector3(0, 0.46, 0))
	_add_part(body_pivot, "ChestGem", _sphere(0.085), crystal, Vector3(0, 0.72, 0.20), Vector3.ZERO, Vector3(0.8, 1.3, 0.6))
	aura_mesh = _add_part(body_pivot, "HoverRing", _torus(0.34, 0.39), crystal, Vector3(0, 0.10, 0))

	left_arm_pivot = Node3D.new()
	left_arm_pivot.position = Vector3(-0.26, 0.78, 0)
	body_pivot.add_child(left_arm_pivot)
	_add_part(left_arm_pivot, "Arm", _capsule(0.065, 0.30), robe, Vector3(-0.04, -0.14, 0))
	_add_part(left_arm_pivot, "Orb", _sphere(0.06), violet, Vector3(-0.06, -0.32, 0))

	right_arm_pivot = Node3D.new()
	right_arm_pivot.position = Vector3(0.26, 0.78, 0)
	body_pivot.add_child(right_arm_pivot)
	_add_part(right_arm_pivot, "Arm", _capsule(0.065, 0.30), robe, Vector3(0.04, -0.14, 0))
	_add_part(right_arm_pivot, "Orb", _sphere(0.06), violet, Vector3(0.06, -0.32, 0))

	head_pivot = Node3D.new()
	head_pivot.position = Vector3(0, 1.06, 0)
	body_pivot.add_child(head_pivot)
	_add_part(head_pivot, "Head", _sphere(0.23, 0.44), _mat("cg_skin", Color(0.82, 0.95, 1.0), 0.3, 0.0, Color(0.4, 0.8, 1.0), 0.2), Vector3.ZERO)
	_add_face(head_pivot, 0.20, 0.0, 0.085, 1.05)
	_add_part(head_pivot, "CrystalCrown1", _cylinder(0.01, 0.045, 0.24), crystal, Vector3(0, 0.28, 0))
	_add_part(head_pivot, "CrystalCrown2", _cylinder(0.01, 0.035, 0.18), violet, Vector3(-0.11, 0.24, 0), Vector3(0, 0, 20))
	_add_part(head_pivot, "CrystalCrown3", _cylinder(0.01, 0.035, 0.18), violet, Vector3(0.11, 0.24, 0), Vector3(0, 0, -20))


func set_expression(mood: String) -> void:
	_current_mood = mood
	if left_brow == null or right_brow == null or mouth_mesh == null:
		return

	left_brow.rotation_degrees = Vector3(0, 0, 90)
	right_brow.rotation_degrees = Vector3(0, 0, 90)
	mouth_mesh.scale = Vector3.ONE
	if left_eye:
		left_eye.scale = Vector3(1.0, 1.1, 0.55)
	if right_eye:
		right_eye.scale = Vector3(1.0, 1.1, 0.55)

	match mood:
		"happy", "proud":
			left_brow.rotation_degrees = Vector3(0, 0, 80)
			right_brow.rotation_degrees = Vector3(0, 0, 100)
			mouth_mesh.scale = Vector3(1.35, 1.4, 1.0)
		"excited":
			left_brow.rotation_degrees = Vector3(0, 0, 75)
			right_brow.rotation_degrees = Vector3(0, 0, 105)
			mouth_mesh.scale = Vector3(1.5, 1.8, 1.2)
		"thinking":
			left_brow.rotation_degrees = Vector3(0, 0, 102)
			right_brow.rotation_degrees = Vector3(0, 0, 82)
			mouth_mesh.scale = Vector3(0.65, 0.8, 1.0)
		"encouraging":
			left_brow.rotation_degrees = Vector3(0, 0, 82)
			right_brow.rotation_degrees = Vector3(0, 0, 98)
			mouth_mesh.scale = Vector3(1.2, 1.15, 1.0)
		"surprised":
			if left_eye:
				left_eye.scale = Vector3(1.25, 1.35, 0.65)
			if right_eye:
				right_eye.scale = Vector3(1.25, 1.35, 0.65)
			mouth_mesh.scale = Vector3(0.85, 2.2, 1.2)
		_:
			pass


## Basic procedural mouth open/close speaking animation (placeholder rig; NOT phoneme viseme lip-sync).
func set_speaking(active: bool, delta_sec: float = 0.0) -> void:
	_is_speaking = active
	if mouth_mesh == null:
		return
	if not active:
		_speak_phase = 0.0
		set_expression(_current_mood)
		if head_pivot != null:
			head_pivot.rotation.x = 0.0
		return
	_speak_phase += maxf(0.016, delta_sec) * 14.0
	var open_amt := 0.85 + absf(sin(_speak_phase)) * 1.45
	mouth_mesh.scale = Vector3(1.15, open_amt, 1.05)
	if head_pivot != null:
		head_pivot.rotation.x = sin(_speak_phase * 0.5) * 0.05


func update_blink_and_breath(delta_sec: float, time_sec: float) -> void:
	if left_eye != null and right_eye != null:
		_blink_timer -= delta_sec
		if _blink_timer <= 0.0:
			_blink_closing = 0.14
			_blink_timer = 3.2 + fmod(absf(sin(time_sec * 1.7)) * 2.4, 2.4)
		var base_y := 1.35 if _current_mood == "surprised" else 1.10
		if _blink_closing > 0.0:
			_blink_closing = maxf(0.0, _blink_closing - delta_sec)
			var t_b := sin((_blink_closing / 0.14) * PI)
			var ey := lerpf(base_y, 0.12, t_b)
			left_eye.scale.y = ey
			right_eye.scale.y = ey
		else:
			left_eye.scale.y = base_y
			right_eye.scale.y = base_y
	if body_pivot != null:
		var breath := 1.0 + sin(time_sec * 2.4) * 0.018
		body_pivot.scale = Vector3(breath, 1.0 / sqrt(breath), breath)
