shader_type canvas_item;

uniform sampler2D tex: repeat_enable;
//uniform sampler2D noise_tex: repeat_enable;
uniform sampler2D normal_map: repeat_enable;
//uniform sampler2D rock_tex: repeat_enable;

uniform float rock_uv_coeff;
uniform float tex_uv_coeff;

uniform vec2 selection_pos;

float avg(vec3 c){
	return (c.x + c.y + c.z) / 3.0;
}

const float height_offset = 10.0;

void fragment(){
	//vec4 splat_map_from_noise_tex = texture(noise_tex, 0.5 * UV);
	//float just_rock = 1. - smoothstep(0.2, 0.3, splat_map_from_noise_tex.r);
	//vec4 rock_tex_sample = texture(rock_tex, rock_uv_coeff * UV) * just_rock;
	vec2 uv = 2. * UV - 1.;
	uv.y *= -1.0;
	vec4 tex_sample = texture(tex, tex_uv_coeff * UV); //* (1. - just_rock);
	vec4 normal_map_sample = texture(normal_map, uv);

	vec3 light_dir = vec3(selection_pos, height_offset) - vec3(uv, 0.); // light pos - uv pos

	// light model, simple lambertian
	//
	float diffuse = max(dot( normalize(normal_map_sample.xyz),
	                         normalize(light_dir)), 0.);

	vec3 avg_tex_col = 1. - vec3(avg(tex_sample.xyz)) + 0.1;
	vec3 col = vec3(avg_tex_col) * diffuse;
	COLOR = vec4(col, 1.);
}

//const float n_div = 5.;
//void light() {
	//float cNdotL = max(0.0, dot(NORMAL, LIGHT_DIRECTION));
	//float cel = floor(cNdotL * n_div) / n_div;
	//LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY * cel, LIGHT_COLOR.a);
//}