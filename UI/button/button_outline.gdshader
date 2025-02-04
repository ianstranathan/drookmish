shader_type canvas_item;

uniform float t;
uniform float disabled;

void fragment() {
	vec2 uv = 2. * UV - 1.;
	//float t_is_not_zero = step(0., hovered_over_time);
	float energy = disabled * 0.75 + (1. - disabled);
	COLOR = energy * vec4(0.8 * vec3(1., 0.75, .79), t);
}
