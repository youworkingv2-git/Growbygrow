shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, specular_schlick_ggx;

uniform vec4 shallow_color : source_color = vec4(0.20, 0.76, 0.94, 0.78);
uniform vec4 deep_color : source_color = vec4(0.08, 0.42, 0.74, 0.90);
uniform vec4 foam_color : source_color = vec4(0.86, 0.97, 1.0, 0.92);
uniform float wave_speed = 1.65;
uniform float wave_amp = 0.024;
uniform float ripple_scale = 20.0;
uniform float radial_mode = 1.0; // 1.0 for concentric fountain ripples, 0.0 for lake
uniform float quality_level = 2.0; // 0=low, 1=medium, 2=high

varying vec2 v_uv;
varying float v_wave_h;

void vertex() {
	v_uv = UV;
	float dist = length(UV - vec2(0.5)) * 2.0;
	float w1 = sin(VERTEX.x * 3.2 + TIME * wave_speed) * cos(VERTEX.z * 2.9 - TIME * (wave_speed * 0.8));
	float w2 = sin(dist * 14.0 - TIME * (wave_speed * 2.2)) * radial_mode;
	float amp = wave_amp * (quality_level < 0.5 ? 0.55 : 1.0);
	float h = (w1 * 0.65 + w2 * 0.45) * amp;
	VERTEX.y += h;
	v_wave_h = h;
}

void fragment() {
	vec2 centered = (v_uv - vec2(0.5)) * 2.0;
	float r_dist = length(centered);

	float concentric = sin(r_dist * ripple_scale - TIME * (wave_speed * 2.4));
	float cross_rip = sin(v_uv.x * (ripple_scale * 1.15) + TIME * 1.9) * cos(v_uv.y * (ripple_scale * 1.15) - TIME * 1.5);
	float combined = mix(cross_rip, concentric * 0.65 + cross_rip * 0.35, radial_mode);

	// Depth & rim tint
	float depth_t = clamp(0.45 + combined * 0.25 + (1.0 - r_dist) * 0.22, 0.0, 1.0);
	vec3 water_rgb = mix(deep_color.rgb, shallow_color.rgb, depth_t);

	// Rim & jet impact foam rings (visible even on Low, richer on Med/High)
	float rim_foam = smoothstep(0.83, 0.98, r_dist) * 0.55;
	float inner_ring = radial_mode * smoothstep(0.62, 0.94, sin(r_dist * 18.0 - TIME * 3.2)) * (1.0 - smoothstep(0.18, 0.85, r_dist)) * 0.42;
	float sparkle = (quality_level > 0.5) ? smoothstep(0.76, 0.98, cross_rip) * 0.32 : 0.0;

	// Fresnel reflection boost on edges
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	vec3 sky_reflect = vec3(0.72, 0.91, 1.0) * fresnel * (quality_level > 1.5 ? 0.45 : 0.25);

	vec3 final_col = mix(water_rgb, foam_color.rgb, clamp(rim_foam + inner_ring, 0.0, 0.78)) + vec3(sparkle) + sky_reflect;

	ALBEDO = final_col;
	ALPHA = clamp(mix(deep_color.a, shallow_color.a, depth_t) + rim_foam * 0.25, 0.68, 0.96);
	ROUGHNESS = quality_level > 1.5 ? 0.08 : 0.14;
	METALLIC = 0.12;
	SPECULAR = 0.85;
}
