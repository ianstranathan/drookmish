shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D noise_tex: repeat_enable;
uniform vec2 cam_offset;

void fragment() {
	vec2 resolution = 1. / SCREEN_PIXEL_SIZE; // vec2(1152., 778.);//
	vec2 half_res = 0.5 * resolution;

	//vec2 dummy_pos =  vec2(362.0, 252.0); // offset calc will be on CPU
	//vec2 uv_pos = (dummy_pos - half_res) / half_res;
	vec2 uv_pos = cam_offset /  half_res;
	uv_pos.x *= resolution.x / resolution.y;
	
	vec2 screen_uv = 2. * SCREEN_UV - 1.;
	screen_uv.x *= resolution.x / resolution.y;
	
	vec2 noise_sample_uv = screen_uv - uv_pos;
	vec2 screen_polar = vec2( length(noise_sample_uv), atan(noise_sample_uv.y, noise_sample_uv.x));
	vec4 noise_sample = texture(noise_tex, screen_polar +  vec2(0.3 * TIME, 0.));
	float v = smoothstep(0.3, 0.33, length(screen_uv - uv_pos));
	COLOR = vec4(noise_sample.xyz, v);
}
//vec2 uv_pos = (dummy_pos - half_res) / half_res;
	//uv_pos.x *= resolution.x / resolution.y;
	//
	//vec2 screen_uv = 2. * SCREEN_UV - 1.;
	//screen_uv.x *= resolution.x / resolution.y;
	//
	//vec2 noise_sample_uv = screen_uv - uv_pos;
	//vec2 screen_polar = vec2( length(noise_sample_uv), atan(noise_sample_uv.y, noise_sample_uv.x));
	//vec4 noise_sample = texture(noise_tex, screen_polar +  vec2(0.3 * TIME, 0.));
	//float v = smoothstep(0.3, 0.33, length(screen_uv - uv_pos));
	//COLOR = vec4(noise_sample.xyz, v);

