class_name LabelBackdrop3D
extends RefCounted
## High-contrast 3D dark rounded pill backdrop helper for Label3D nameplates
## (NPCs, Signposts, Chests, Portals) so text stays crisp and easy to read
## against bright pastel grass, sky, or white building walls.

const FONT_PATH := "res://assets/fonts/NotoSans-Regular.ttf"
const FILL_COLOR := Color(0.05, 0.09, 0.19, 0.92)
const NPC_BORDER := Color(0.98, 0.76, 0.16, 0.98)
const OBJECT_BORDER := Color(0.28, 0.78, 0.98, 0.98)
const FOCUS_BORDER := Color(0.99, 0.88, 0.28, 1.0)

static var _cached_font: Font = null
static var _pill_cache: Dictionary = {}


static func apply_to_label(label: Label3D, is_npc: bool = false, is_focused: bool = false) -> void:
	if label == null or not is_instance_valid(label):
		return

	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.render_priority = 2
	label.pixel_size = 0.0046
	label.font_size = 44
	label.outline_modulate = Color(0.03, 0.06, 0.12, 1.0)
	label.outline_size = 12
	if is_focused:
		label.modulate = Color(1.0, 0.93, 0.45, 1.0)
	elif is_npc:
		label.modulate = Color(1.0, 0.96, 0.78, 1.0)
	else:
		label.modulate = Color(0.98, 0.99, 1.0, 1.0)

	var text := label.text.strip_edges()
	var sprite := label.get_node_or_null("BackdropPill") as Sprite3D
	if text.is_empty():
		if sprite != null:
			sprite.visible = false
		return

	if sprite == null:
		sprite = Sprite3D.new()
		sprite.name = "BackdropPill"
		sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		sprite.no_depth_test = true
		sprite.shaded = false
		sprite.transparent = true
		sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
		sprite.render_priority = 1
		sprite.position = Vector3.ZERO
		label.add_child(sprite)

	sprite.visible = true
	sprite.pixel_size = label.pixel_size
	sprite.scale = Vector3.ONE

	var font := _get_font()
	var text_sz := Vector2(180.0, 56.0)
	if font != null:
		text_sz = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, label.font_size)

	var raw_w := int(ceil(text_sz.x)) + 52
	var pill_w := maxi(128, int(ceil(float(raw_w) / 16.0)) * 16)
	var raw_h := int(ceil(text_sz.y)) + 24
	var pill_h := maxi(72, int(ceil(float(raw_h) / 8.0)) * 8)

	var border_col := FOCUS_BORDER if is_focused else (NPC_BORDER if is_npc else OBJECT_BORDER)
	sprite.texture = _get_or_build_pill_texture(pill_w, pill_h, border_col)


static func _get_font() -> Font:
	if _cached_font == null and ResourceLoader.exists(FONT_PATH):
		_cached_font = load(FONT_PATH) as Font
	if _cached_font == null:
		_cached_font = ThemeDB.fallback_font
	return _cached_font


static func _get_or_build_pill_texture(w: int, h: int, border_col: Color) -> ImageTexture:
	var key := "%d_%d_%s" % [w, h, border_col.to_html(true)]
	if _pill_cache.has(key):
		return _pill_cache[key] as ImageTexture

	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var radius := float(h) * 0.42
	var border_w := 3.0
	var half_w := float(w) * 0.5
	var half_h := float(h) * 0.5
	var inner_half_w := half_w - radius
	var inner_half_h := half_h - radius
	var qw := int(ceil(float(w) / 2.0))
	var qh := int(ceil(float(h) / 2.0))

	for py in range(qh):
		var dy := absf((float(py) + 0.5) - half_h)
		var qy := maxf(0.0, dy - inner_half_h)
		var my := h - 1 - py
		for px in range(qw):
			var dx := absf((float(px) + 0.5) - half_w)
			var qx := maxf(0.0, dx - inner_half_w)
			var dist := (qx + qy - radius) if (qx == 0.0 or qy == 0.0) else (sqrt(qx * qx + qy * qy) - radius)
			if dist > 0.75:
				continue
			var col := FILL_COLOR
			if dist > -border_w:
				col = border_col
				col.a *= clampf(0.75 - dist, 0.0, 1.0)
			img.set_pixel(px, py, col)
			var mx := w - 1 - px
			if mx != px:
				img.set_pixel(mx, py, col)
			if my != py:
				img.set_pixel(px, my, col)
				if mx != px:
					img.set_pixel(mx, my, col)

	var tex := ImageTexture.create_from_image(img)
	_pill_cache[key] = tex
	return tex
