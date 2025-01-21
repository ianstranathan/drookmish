shader_type canvas_item;

uniform float num_clikmis = 0.0;

void vertex() {
	//VERTEX += 10. * sin(TIME) * vec2(sign(VERTEX.x), 0.);
}

const vec3 base_col = vec3(1.);
const vec3 highest_col = vec3(1., 0., 0.);

vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.283185*(c*t+d) );
}

float rand(float co)
{
	return fract(sin(co*(91.3458)) * 47453.5453);
}

const vec3 col1 = vec3(0.5, 0.5, 0.5   );
const vec3 col2 = vec3(0.5, 0.5, 0.5   );
const vec3 col3 = vec3(1.0, 1.0, 1.0   );
const vec3 col4 = vec3(0.00, 0.33, 0.67);

void fragment() {
	COLOR = vec4(COLOR);
	vec3 palette_col = palette(rand(num_clikmis), col1, col2, col3, col4);
	float mask = smoothstep(1.3, 1.735, length(COLOR.xyz));
	vec3 col = palette_col * mask + vec3(1.) * (1. - mask);
	COLOR = vec4(col, COLOR.a);
}
