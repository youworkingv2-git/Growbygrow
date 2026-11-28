shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform vec4 root_color : source_color = vec4(0.24, 0.44, 0.14, 1.0);
uniform vec4 mid_color : source_color = vec4(0.42, 0.64, 0.19, 1.0);
uniform vec4 tip_color : source_color = vec4(0.58, 0.80, 0.25, 1.0);
uniform float wind_speed = 2.2;
uniform float wind_strength = 0.16;

varying float v_tip;
varying float v_hue_shift;

void vertex() {
	// UV.y goes 0.0 at ground root -> 1.0 at blade tip
	float t = clamp(UV.y, 0.0, 1.0);
	v_tip = t;
	v_hue_shift = INSTANCE_CUSTOM.z;

	vec3 world_pos = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	float wave_phase = world_pos.x * 0.55 + world_pos.z * 0.42 + INSTANCE_CUSTOM.x * 6.2831;
	float gust = sin(TIME * wind_speed + wave_phase) * 0.72 + sin(TIME * (wind_speed * 1.85) + wave_phase * 1.9) * 0.28;
	float bend = t * t * wind_strength;

	VERTEX.x += gust * bend;
	VERTEX.z += cos(TIME * (wind_speed * 0.85) + wave_phase * 0.8) * bend * 0.55;
	VERTEX.y -= abs(gust) * bend * 0.18;
}

void fragment() {
	vec3 c_root = root_color.rgb * (0.90 + v_hue_shift * 0.20);
	vec3 c_mid = mid_color.rgb * (0.92 + v_hue_shift * 0.18);
	vec3 c_tip = tip_color.rgb * (0.94 + v_hue_shift * 0.16);

	vec3 col = mix(c_root, c_mid, smoothstep(0.0, 0.52, v_tip));
	col = mix(col, c_tip, smoothstep(0.45, 1.0, v_tip));

	ALBEDO = col;
	ROUGHNESS = 0.72;
	SPECULAR = 0.14;
	BACKLIGHT = tip_color.rgb * 0.24 * v_tip;
}
