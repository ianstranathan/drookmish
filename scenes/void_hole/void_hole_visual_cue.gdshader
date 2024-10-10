shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D noise_tex: repeat_enable;

uniform float t;

mat2 rot(float a) {
	float s=sin(a), c=cos(a);
    return mat2(vec2(c,-s), vec2(s,c));
}

void fragment() {
	vec2 uv = 2. * UV - 1.;
	uv = rot(0.2 * TIME) * uv;
	vec2 polar = vec2(length(uv), atan(uv.y, uv.x));
	vec4 polar_noise_sample = texture(noise_tex, polar+ vec2(0.3 * TIME, 0.));
	
	vec4 noise = texture(noise_tex, 1.5 * (UV + 0.05 * TIME));
	vec4 noise_2 = texture(noise_tex, 0.5 * (UV - 0.05 * TIME));
	float nn = (noise_2 * noise).r;

	float circle_dist_1 = 0.2 * cos(2.0 *  polar.y - 0.1 * TIME) * sin(5.0 * polar.y - 0.2 * TIME);
	float circle_dist_2 = 0.2 * cos(4.0 *  polar.y + 0.2 * TIME) * sin(3.0 * polar.y - 0.1 * TIME);
	float circ = mix(circle_dist_1, circle_dist_2, 0.5 + sin(TIME)/ 2.);
	
	float mask = 1. - smoothstep(0.7, 0.75, circ + polar.x + 0.1 * nn + 0.1 * polar_noise_sample.r);
	
	float polar_nn = smoothstep( 1., 1.5, cos(t * TIME) * 2. * polar_noise_sample.x * polar_noise_sample.x);
	
	vec4 screen_tex_sample = texture(screen_texture, SCREEN_UV + 0.1 * 2. * sin(0.6 * TIME) * nn - 0.5 *  3. * cos(0.7* TIME) * polar_nn) * mask;
	vec3 col = screen_tex_sample.xyz * mask;

	col += polar_nn * (sin(20. * t)) + 0.1 * cos(40. * t);
	COLOR = vec4(col, mask);
}

//void fragment() {
	//vec2 resolution = 1. / SCREEN_PIXEL_SIZE; // vec2(1152., 778.);//
	//vec2 half_res = 0.5 * resolution;
	////
	//vec2 uv_pos = cam_offset /  half_res;
	//uv_pos.x *= resolution.x / resolution.y;
	////
	//vec2 screen_uv = 2. * SCREEN_UV - 1.;
	//screen_uv.x *= resolution.x / resolution.y;
	////
	//vec2 noise_sample_uv = screen_uv - uv_pos;
	//vec2 screen_polar = vec2( length(noise_sample_uv), atan(noise_sample_uv.y, noise_sample_uv.x));
	//vec4 noise_sample = texture(noise_tex, screen_polar +  vec2(0.3 * TIME, 0.));
	//vec4 screen_sample = textureLod(screen_texture, SCREEN_UV + 0.1 * noise_sample.r, 0.0);
	//float v = smoothstep(0.2, 0.23 + 0.1 * noise_sample.r, length(screen_uv - uv_pos));
	//
	////
	//COLOR = vec4(screen_sample.xyz, 1. - v);
//}

