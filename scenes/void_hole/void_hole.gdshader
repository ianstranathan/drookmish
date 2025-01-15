shader_type canvas_item;

const float max_swirl = 1.0;
uniform float swirl_dist_normal: hint_range(0.0, 1.0, 0.01);
uniform sampler2D noise_tex: repeat_enable;

mat2 rot(float angle){
	return mat2( vec2(cos(angle), -sin(angle)),
	             vec2(sin(angle), cos(angle)));
}

void fragment()
{
	float swirl_param = max_swirl * swirl_dist_normal* swirl_dist_normal;
    vec2 uv = 2. * UV - 1.;
	uv  = rot(-2. * TIME - swirl_param * 15. * length(uv)) * uv;

    vec2 polar = vec2( length(uv), atan(uv.y, uv.x));

	float spiral_d = cos( 2. * (polar.y - 3. * polar.x - 2. * TIME));
    vec4 noise_sample = texture(noise_tex, 0.2 * vec2(polar.x + TIME, abs(polar.y)) - 0.2 * spiral_d);

	// shadertoy col
    vec3 stc = 0.5 + 0.5*cos(TIME+uv.xyx+vec3(0,2,4));

	// white circle outline
	float circ_mask = 1. - smoothstep(0.65, 0.65, polar.r + 0.1 * noise_sample.r);
    float mask = 1. - smoothstep(0.5 + 0.1 * noise_sample.r, 0.52 + 0.1 * noise_sample.r, polar.x);
	
	// cut away the mask from the circle mask
	circ_mask *= (1. - mask);
	vec3 col = smoothstep(0.8, 1.5, 2. * noise_sample.r * noise_sample.r) * mix(vec3(0.), stc, length(uv)) + 0.5 * pow(length(uv), 2.);
    COLOR = vec4( col + vec3(circ_mask), circ_mask + mask);
}
