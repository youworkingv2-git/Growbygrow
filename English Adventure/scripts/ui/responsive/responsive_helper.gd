class_name ResponsiveHelper
extends RefCounted
## Responsive layout & safe-area margin utilities for Desktop, Tablet, Mobile Landscape, and Mobile Portrait.


static func get_safe_area_margins(viewport: Viewport) -> Dictionary:
	var vp_rect := viewport.get_visible_rect()
	var win_size := Vector2(DisplayServer.window_get_size())
	if win_size.x <= 0.0 or win_size.y <= 0.0:
		return { "left": 0, "top": 0, "right": 0, "bottom": 0 }
	var safe: Rect2i = DisplayServer.get_display_safe_area()
	if safe.size.x <= 0 or safe.size.y <= 0:
		return { "left": 0, "top": 0, "right": 0, "bottom": 0 }
	var scale_x := vp_rect.size.x / win_size.x
	var scale_y := vp_rect.size.y / win_size.y
	return {
		"left": int(round(maxf(0.0, float(safe.position.x) * scale_x))),
		"top": int(round(maxf(0.0, float(safe.position.y) * scale_y))),
		"right": int(round(maxf(0.0, (win_size.x - float(safe.end.x)) * scale_x))),
		"bottom": int(round(maxf(0.0, (win_size.y - float(safe.end.y)) * scale_y)))
	}


static func apply_safe_margin_to_container(margin: MarginContainer, viewport: Viewport, base_pad: int = 12) -> void:
	if margin == null or viewport == null:
		return
	var safe := get_safe_area_margins(viewport)
	margin.add_theme_constant_override("margin_left", base_pad + int(safe["left"]))
	margin.add_theme_constant_override("margin_top", base_pad + int(safe["top"]))
	margin.add_theme_constant_override("margin_right", base_pad + int(safe["right"]))
	margin.add_theme_constant_override("margin_bottom", base_pad + int(safe["bottom"]))


static func is_compact_width(viewport: Viewport) -> bool:
	return viewport.get_visible_rect().size.x < 780.0


static func is_portrait(viewport: Viewport) -> bool:
	var sz := viewport.get_visible_rect().size
	return sz.y > sz.x
