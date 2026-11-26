class_name UIDesignSystem
extends RefCounted
## Unified Fantasy Cartoon Adventure Design System (Colors, Typography, Button Styles, Global Theme).

# --- 3.1 Color Palette ---
const PRIMARY := Color("#2EA8FF")          # Adventure Sky Blue
const PRIMARY_DARK := Color("#1677C8")
const PRIMARY_LIGHT := Color("#63C0FF")

const SECONDARY := Color("#FFB800")        # Adventure Gold
const SECONDARY_DARK := Color("#D97706")
const SECONDARY_LIGHT := Color("#FFD454")

const BACKGROUND := Color("#0F1D36")       # Deep Twilight Sky
const BACKGROUND_MID := Color("#172B4D")
const SURFACE := Color("#1B2B48")          # Fantasy Slate Surface
const SURFACE_ELEVATED := Color("#223659")
const SURFACE_CREAM := Color("#FFFDF7")    # Light card option

const TEXT_LIGHT := Color("#F8FAFC")
const TEXT_MUTED := Color("#CBD5E1")
const TEXT_DARK := Color("#1E293B")
const TEXT_GOLD := Color("#FCD34D")
const TEXT_EN := Color("#60C5FF")

const SUCCESS := Color("#22C55E")
const SUCCESS_DARK := Color("#15803D")
const WARNING := Color("#F59E0B")
const ERROR := Color("#FB7185")            # Soft Warm Coral
const LOCKED := Color("#64748B")
const LOCKED_DARK := Color("#475569")
const REWARD := Color("#FACC15")
const CRYSTAL := Color("#38BDF8")
const MAGIC := Color("#A855F7")
const MAGIC_DARK := Color("#7E22CE")

const BORDER_DEFAULT := Color("#476B9E")
const BORDER_FOCUS := Color("#FDE047")

# --- 3.2 Typography Scale ---
const FONT_MAIN_TITLE := 32
const FONT_HEADING := 26
const FONT_SUBHEADING := 20
const FONT_BODY := 16
const FONT_CAPTION := 13
const FONT_BUTTON := 17
const FONT_DIALOGUE := 17
const FONT_LEARNING := 19


static func make_panel_style(
	bg: Color = SURFACE,
	border: Color = BORDER_DEFAULT,
	radius: int = 14,
	border_width: int = 2,
	pad_h: int = 14,
	pad_v: int = 12
) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.border_width_left = border_width
	sb.border_width_top = border_width
	sb.border_width_right = border_width
	sb.border_width_bottom = border_width
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_right = radius
	sb.corner_radius_bottom_left = radius
	sb.content_margin_left = pad_h
	sb.content_margin_right = pad_h
	sb.content_margin_top = pad_v
	sb.content_margin_bottom = pad_v
	sb.shadow_color = Color(0.0, 0.0, 0.0, 0.28)
	sb.shadow_size = 6
	sb.shadow_offset = Vector2(0, 3)
	return sb


static func make_button_style(base: Color, border: Color, radius: int = 12, pad_h: int = 16, pad_v: int = 10) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = base
	sb.border_color = border
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 4
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_right = radius
	sb.corner_radius_bottom_left = radius
	sb.content_margin_left = pad_h
	sb.content_margin_right = pad_h
	sb.content_margin_top = pad_v
	sb.content_margin_bottom = pad_v
	return sb


static func apply_button_variant(btn: Button, variant: String = "primary") -> void:
	if btn == null:
		return
	var normal_col := PRIMARY
	var border_col := PRIMARY_DARK
	var text_col := TEXT_LIGHT

	match variant:
		"secondary":
			normal_col = Color("#2C456E")
			border_col = Color("#4B6D9E")
		"confirm", "success":
			normal_col = SUCCESS
			border_col = SUCCESS_DARK
		"reward":
			normal_col = SECONDARY
			border_col = SECONDARY_DARK
			text_col = TEXT_DARK
		"back":
			normal_col = Color("#243B61")
			border_col = Color("#4B6D9E")
		"close", "danger":
			normal_col = Color("#B93855")
			border_col = Color("#881D38")
		"icon":
			normal_col = Color("#233A5E")
			border_col = BORDER_DEFAULT
		"disabled":
			normal_col = LOCKED
			border_col = LOCKED_DARK
			text_col = TEXT_MUTED

	var hover_col := normal_col.lightened(0.14)
	var pressed_col := normal_col.darkened(0.16)
	var focus_sb := make_button_style(hover_col, BORDER_FOCUS)

	btn.add_theme_stylebox_override("normal", make_button_style(normal_col, border_col))
	btn.add_theme_stylebox_override("hover", make_button_style(hover_col, border_col))
	btn.add_theme_stylebox_override("pressed", make_button_style(pressed_col, border_col))
	btn.add_theme_stylebox_override("focus", focus_sb)
	btn.add_theme_stylebox_override("disabled", make_button_style(Color(0.32, 0.37, 0.46, 0.85), Color(0.24, 0.28, 0.36, 0.9)))
	btn.add_theme_color_override("font_color", text_col)
	btn.add_theme_color_override("font_hover_color", text_col)
	btn.add_theme_color_override("font_pressed_color", text_col)
	btn.add_theme_color_override("font_focus_color", text_col)
	btn.add_theme_color_override("font_disabled_color", Color(0.74, 0.78, 0.85, 0.85))


static func build_global_theme() -> Theme:
	var t := Theme.new()
	t.default_font_size = FONT_BODY
	if ResourceLoader.exists("res://assets/fonts/NotoSans-Regular.ttf"):
		var f := load("res://assets/fonts/NotoSans-Regular.ttf") as Font
		if f != null:
			t.default_font = f

	# PanelContainer (opaque so background HUD/screens never bleed through in WebGL2)
	var opaque_panel := make_panel_style(Color(0.08, 0.13, 0.24, 1.0), BORDER_DEFAULT, 14, 2, 0, 0)
	t.set_stylebox("panel", "PanelContainer", opaque_panel)
	t.set_stylebox("panel", "PopupPanel", make_panel_style(Color(0.08, 0.13, 0.24, 1.0), BORDER_DEFAULT, 10, 2, 6, 6))
	t.set_stylebox("panel", "PopupMenu", make_panel_style(Color(0.08, 0.13, 0.24, 1.0), BORDER_DEFAULT, 10, 2, 8, 8))
	t.set_stylebox("hover", "PopupMenu", make_panel_style(Color(0.18, 0.36, 0.62, 1.0), PRIMARY_LIGHT, 8, 1, 8, 6))
	t.set_color("font_color", "PopupMenu", TEXT_LIGHT)
	t.set_color("font_hover_color", "PopupMenu", TEXT_LIGHT)

	# Buttons (default style = secondary adventure slate; primary CTAs use apply_button_variant)
	t.set_stylebox("normal", "Button", make_button_style(Color("#243A5E"), Color("#456799")))
	t.set_stylebox("hover", "Button", make_button_style(Color("#304D7D"), PRIMARY_LIGHT))
	t.set_stylebox("pressed", "Button", make_button_style(Color("#1A2B48"), PRIMARY_DARK))
	t.set_stylebox("focus", "Button", make_button_style(Color("#304D7D"), BORDER_FOCUS))
	t.set_stylebox("disabled", "Button", make_button_style(Color(0.28, 0.33, 0.42, 0.85), LOCKED_DARK))
	t.set_color("font_color", "Button", TEXT_LIGHT)
	t.set_color("font_hover_color", "Button", TEXT_LIGHT)
	t.set_color("font_pressed_color", "Button", TEXT_LIGHT)
	t.set_color("font_focus_color", "Button", TEXT_LIGHT)
	t.set_color("font_disabled_color", "Button", Color(0.7, 0.75, 0.84, 0.85))
	t.set_font_size("font_size", "Button", FONT_BUTTON)

	# Labels
	t.set_color("font_color", "Label", TEXT_LIGHT)
	t.set_font_size("font_size", "Label", FONT_BODY)

	# LineEdit
	t.set_stylebox("normal", "LineEdit", make_panel_style(Color(0.08, 0.12, 0.22, 0.98), BORDER_DEFAULT, 10, 2, 12, 8))
	t.set_stylebox("focus", "LineEdit", make_panel_style(Color(0.09, 0.14, 0.25, 1.0), PRIMARY, 10, 2, 12, 8))
	t.set_color("font_color", "LineEdit", TEXT_LIGHT)
	t.set_color("font_placeholder_color", "LineEdit", TEXT_MUTED)

	# ProgressBar
	t.set_stylebox("background", "ProgressBar", make_panel_style(Color(0.08, 0.13, 0.23, 0.95), Color("#36527D"), 8, 1, 0, 0))
	t.set_stylebox("fill", "ProgressBar", make_panel_style(SECONDARY, SECONDARY_DARK, 7, 0, 0, 0))

	# HSlider
	t.set_stylebox("slider", "HSlider", make_panel_style(Color(0.14, 0.22, 0.36, 1.0), BORDER_DEFAULT, 6, 1, 0, 6))
	t.set_stylebox("grabber_area", "HSlider", make_panel_style(PRIMARY, PRIMARY_DARK, 6, 0, 0, 6))
	t.set_stylebox("grabber_area_highlight", "HSlider", make_panel_style(PRIMARY_LIGHT, PRIMARY, 6, 0, 0, 6))

	return t
