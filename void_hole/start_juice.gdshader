shader_type canvas_item;


float EaseOutExpo(float x)
{  
  return 1.0 - pow(2.0, -10.0 * x);;
}
//uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
//vec4 tex_sample = texture(screen_texture, SCREEN_UV - vec2(fn));
void fragment(){
	vec2 uv = 2. * UV - 1.;
	float r = 2. * length(uv);
	float t_0_to_1 = 0.5 * (sin(TIME) + 1.);
	float t = PI * EaseOutExpo(t_0_to_1);
	float fn = sin(r + t) / r;
	vec3 col = vec3(fn);
	COLOR = vec4( col, fn * fn * fn);
}