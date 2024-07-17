shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform sampler2D noise_tex: repeat_enable;
uniform sampler2D noise_tex_2: repeat_enable;

mat2 rot(float angle){
	return mat2( vec2(cos(angle), -sin(angle)), 
	             vec2(sin(angle), cos(angle)));
}

void fragment() {
	vec2 uv = 2. * UV - 1.;
	
	uv *= 1.5;
	float val = 1. - abs(uv.x * uv.x);
	
	//vec2 rot_uv = rot(TIME) * uv;
	vec4 noise_sample = texture(noise_tex, 1.1 * UV - vec2(0., 0.67 * 0.1 * TIME));
	vec4 noise_sample_2 = texture(noise_tex_2, 0.6 * UV + vec2(0., 0.356 * 0.7 * TIME));
	float prod_disp = 2. * (noise_sample_2 * noise_sample).r;
	//float ss = smoothstep(0.5, 1., (step(0.6, pow(noise_sample.r, 2.))));
	val += 0.1 * prod_disp + 0.3 * (1.- (uv.y * uv.y));
	vec3 col = vec3(val);
	COLOR =vec4(col, val * val * val);
}