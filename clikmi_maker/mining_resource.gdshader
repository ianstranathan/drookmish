shader_type canvas_item;

float EaseInQuart(float x)
{
 return x * x * x * x;
}

mat2 rot(float angle)
{
	return mat2( vec2( cos(angle), -sin(angle)),
	             vec2( sin(angle),  cos(angle)));
}

uniform float _t;               // desaturation interpolant
uniform float decay_time = 5.0; // shake decay time
// this assumes a row increasing square sprite sheet
// 0 1 2 3 4
// 5 6 7 8 9
// ...
// 20 21 22 23 24
uniform float row_number = 5.0;  
uniform vec2 index_vec;

const float shake_angle_range = PI / 6.0;


const vec4 line_color = vec4(1.);
const float line_thickness = 5.0;

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
	
	float decay = exp(-3. * decay_time);
	float angle = sin(10. * TIME) * shake_angle_range * decay;
	vec2 offset = (1. / row_number) * ( index_vec + 0.5 ); // the center of each UV index cell
	mat2 rotation = rot(angle);
	float zoom = 0.94;
	vec2 _UV        = rotation * (UV - offset) + offset;
	vec2 _UV_zoomed = rotation * zoom * (UV - offset) + offset;
	vec2 half_cell_size = 0.5 * vec2(1. / row_number);
	vec4 tex_sample           = texture(TEXTURE, _UV);
	vec4 tex_sample_zoomed_in = texture(TEXTURE, _UV_zoomed);
	vec3 grey_scale = vec3( (tex_sample.r + tex_sample.g + tex_sample.b) / 3.);
	vec3 col = mix(tex_sample.xyz, grey_scale, _t);
	col = mix(col, col + vec3(0.3), decay);
	//vec2 k = offset - vec2(0.005, -0.0025); // f drawings...
	//float outline_a = smoothstep(0.002, 0.065, length(_UV - k)) * tex_sample_zoomed_in.a * (1. - tex_sample.a);
	vec3 outline_col = mix(vec3(1., 1., 0.), vec3(1.), decay);
	float _t_switch = step(0.99, _t);
	outline_col = (_t_switch) * vec3(1.) + (1. - _t_switch) * outline_col;
	COLOR = vec4( outline_col * (1. - tex_sample.a) + col, tex_sample_zoomed_in.a);
}
