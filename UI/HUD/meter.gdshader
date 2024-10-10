shader_type canvas_item;


uniform float real_time_points_lvl: hint_range(0.0, 1.0, 0.1);
uniform float total_points_lvl: hint_range(0.0, 1.0, 0.1);

uniform vec4 total_col: source_color;
uniform vec4 real_time_col: source_color;
uniform vec4 bg_col: source_color;
void fragment() {
	float real_time_mask = 1. - smoothstep(real_time_points_lvl, real_time_points_lvl + 0.01, 1. - UV.y);
	float total_points_mask = 1. - smoothstep(total_points_lvl, total_points_lvl + 0.01, 1. - UV.y);
	vec3 col = real_time_col.xyz * real_time_mask + (1. - real_time_mask) * (1. - total_points_mask) * bg_col.xyz
	           + (1. - real_time_mask) * total_points_mask * total_col.xyz;
	COLOR = vec4(col, 1.0);
}
