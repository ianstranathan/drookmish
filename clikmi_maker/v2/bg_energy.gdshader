shader_type canvas_item;


uniform sampler2D noise_tex: repeat_enable;
uniform sampler2D noise_tex_2: repeat_enable;

//mat2 rot(float angle){
	//return mat2( vec2(cos(angle), -sin(angle)), 
	             //vec2(sin(angle), cos(angle)));
//}


void fragment() {
	
	vec2 uv = 2. * UV - 1.;
	
	// -----------------------------------
	vec4 noise_sample = texture(noise_tex, 1.2 * UV - vec2(0., 0.17 * TIME));
	vec4 noise_sample_2 = texture(noise_tex_2, 0.5 * UV + vec2(0., 0.056 * TIME));
	float prod_disp = 2. * (noise_sample_2 * noise_sample).r;

	// -----------------------------------
	vec2 _uv = vec2(uv.x, 0.6 * uv.y); // domain disp to make more portal shape
	float d = 1. - smoothstep(0.3 + 0.1 * prod_disp, 0.6, length(_uv));

	COLOR =vec4(vec3(d), pow(d, 3.));
}
