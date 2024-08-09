shader_type canvas_item;


uniform float points_lvl: hint_range(0.0, 1.0, 0.1);

void fragment() {
	float mask = 1. - smoothstep(points_lvl, points_lvl + 0.01, 1. - UV.y);
	vec3 col = vec3(1.) * mask + (1. - mask) * vec3(0.2);
	COLOR = vec4(col, 1.0);
}
