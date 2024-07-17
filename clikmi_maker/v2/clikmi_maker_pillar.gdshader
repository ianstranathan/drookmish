shader_type canvas_item;

uniform sampler2D pillar_mat: repeat_enable;

void vertex() {
	// Called for every vertex the material is visible on.
}

const float scale = 0.25;
const vec2 sprite_scale = vec2(1.);//vec2(1.06, 0.16);
const vec2 res = vec2(128.);
const vec2 sprite_res = sprite_scale * res;

uniform float spin_speed = 0.0;
uniform float spin_dir = 1.0;

const float MAX_SPIN_SPEED = 10.0;

void fragment() {
	vec2 uv = 2. * UV - 1.;
	float ar = sprite_res.x / sprite_res.y;
	//uv.x = sprite_res.x / sprite_res.y;
	//vec2 zoomed_UV = scale * (uv - vec2(0.5)) + vec2(0.5);
	//vec2 ar_correct_UV =  vec2(zoomed_UV.x / ar, zoomed_UV.y);
	//vec2 cylindar_map = vec2(ar_correct_UV.x, asin(uv.y) - 0.2 * TIME);
	//vec2 sample_uv = vec2(UV.x, UV.y);
	vec2 sample_uv = 2. * UV - 1.;
	float t = pow(spin_speed, 2.);
	sample_uv.y = asin(sample_uv.y) - spin_dir * t * MAX_SPIN_SPEED * TIME;
	sample_uv.x *= ar;
	sample_uv *= 0.1;
	vec4 tex_s = texture(pillar_mat, sample_uv);
	
	float fake_bake = 1. - length(vec2(0., uv.y * uv.y));
	vec3 col = vec3(fake_bake);
	COLOR = vec4(tex_s.xyz * fake_bake, 1.);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
