shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, specular_schlick_ggx;

uniform vec4 jet_color : source_color = vec4(0.55, 0.90, 1.0, 0.82);
uniform vec4 foam_color : source_color = vec4(0.92, 0.98, 1.0, 0.95);
uniform float flow_speed = 2.6;

varying vec2 v_uv;

void vertex() {
	v_uv = UV;
	float pulse = sin(UV.y * 10.0 - TIME * flow_speed * 2.4) * 0.014;
	VERTEX.x += NORMAL.x * pulse;
	VERTEX.z += NORMAL.z * pulse;
}

void fragment() {
	float scroll = fract(v_uv.y * 2.2 - TIME * flow_speed);
	float streaks = smoothstep(0.35, 0.85, sin(v_uv.y * 22.0 - TIME * flow_speed * 4.5) * 0.5 + 0.5);
	float edge_fade = smoothstep(0.0, 0.18, v_uv.x) * smoothstep(1.0, 0.82, v_uv.x);
	float end_taper = smoothstep(0.0, 0.08, v_uv.y) * smoothstep(1.0, 0.86, v_uv.y);

	vec3 col = mix(jet_color.rgb, foam_color.rgb, streaks * 0.62 + scroll * 0.18);
	ALBEDO = col;
	ALPHA = clamp((0.55 + streaks * 0.35) * edge_fade * (0.45 + 0.55 * end_taper), 0.0, 0.92);
	ROUGHNESS = 0.12;
	SPECULAR = 0.80;
	EMISSION = jet_color.rgb * 0.22;
}
