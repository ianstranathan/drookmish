shader_type canvas_item;

const vec3 red = vec3(1., 0., 0.);

uniform float t;          // [0., 1.]
uniform float is_paused;  // [0., 1.]


void fragment(){
	float flashing_time = t * t * 100.; // make the t parabolic to flash more at end
	float flashing_rate = 0.7 * abs(sin(flashing_time - 4.0 * TIME));
	float a = (1. - is_paused) * step(0.01, t);
	vec3 col = vec3(1., 0., 0.) + flashing_rate;
	COLOR = vec4(col, a);
}
