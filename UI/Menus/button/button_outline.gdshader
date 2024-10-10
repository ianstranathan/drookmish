shader_type canvas_item;

uniform float t;

void fragment() {
	vec2 uv = 2. * UV - 1.;
	//float t_is_not_zero = step(0., hovered_over_time);
	COLOR = vec4(0.8 * vec3(1., 0.75, .79), t);
}
