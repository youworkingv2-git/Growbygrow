shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.16, 0.42, 0.21, 1.0);
uniform vec4 tip_color : source_color = vec4(0.32, 0.68, 0.28, 1.0);
uniform float wind_speed = 1.85;
uniform float wind_strength = 0.085;
uniform float cluster_height = 1.4;
uniform float roughness_val = 0.66;

varying float v_height_t;

void vertex() {
	vec3 world_origin = MODEL_MATRIX[3].xyz;
	float h_norm = clamp((VERTEX.y + cluster_height * 0.45) / max(0.25, cluster_height), 0.0, 1.0);
	v_height_t = h_norm;

	float phase = world_origin.x * 0.65 + world_origin.z * 0.55 + VERTEX.x * 1.15 + VERTEX.z * 0.95;
	float sway_x = sin(TIME * wind_speed + phase) * wind_strength * (0.35 + h_norm * 0.85);
	float sway_z = cos(TIME * (wind_speed * 0.82) + phase * 1.17) * wind_strength * 0.65 * (0.35 + h_norm * 0.85);
	float flutter = sin(TIME * (wind_speed * 2.4) + VERTEX.x * 4.5 + VERTEX.z * 4.5) * (wind_strength * 0.16) * h_norm;

	VERTEX.x += sway_x + flutter;
	VERTEX.z += sway_z;
	VERTEX.y += sin(TIME * (wind_speed * 1.3) + phase) * (wind_strength * 0.18) * h_norm;
}

void fragment() {
	vec3 col = mix(base_color.rgb, tip_color.rgb, smoothstep(0.10, 0.92, v_height_t));
	ALBEDO = col;
	ROUGHNESS = roughness_val;
	SPECULAR = 0.18;
	BACKLIGHT = tip_color.rgb * 0.22;
}
