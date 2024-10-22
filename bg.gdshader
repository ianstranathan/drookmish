shader_type canvas_item;

uniform sampler2D tex: repeat_enable;
//uniform sampler2D noise_tex: repeat_enable;
uniform sampler2D normal_map: repeat_enable;
//uniform sampler2D rock_tex: repeat_enable;

uniform float rock_uv_coeff;
uniform float tex_uv_coeff;

float avg(vec3 c){
	return (c.x + c.y + c.z) / 3.0;
}

void fragment(){
	//vec4 splat_map_from_noise_tex = texture(noise_tex, 0.5 * UV);
	//float just_rock = 1. - smoothstep(0.2, 0.3, splat_map_from_noise_tex.r);
	//vec4 rock_tex_sample = texture(rock_tex, rock_uv_coeff * UV) * just_rock;
	vec4 tex_sample = texture(tex, tex_uv_coeff * UV); //* (1. - just_rock);

	vec4 normal_map_sample = texture(normal_map, UV);
	vec3 normal = normalize(normal_map_sample.xyz);
	vec3 light_pos = vec3(0., 0., 10.);
	vec3 light_dir = light_pos - (vec3(UV, 0.) + normal);
	float diffuse = dot( normal, normalize(light_dir));

	vec3 avg_tex_col = vec3(avg(tex_sample.xyz));
	vec3 col = vec3(avg_tex_col) * diffuse;
	COLOR = vec4(col, 1.);
}