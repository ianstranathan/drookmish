shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform vec2 resolution; 
uniform vec2 positions[50];
uniform float times[50];
uniform int actual_index;

float shockwave(vec2 pos, float radius)
{
    float sdf = length(pos) - 0.1 * radius;
    float pixelSize = fwidth(sdf);
	float start = 0.;
	float stop = radius + 4. * pixelSize;
	float ss =       smoothstep(start, stop, sdf) * 
	           (1. - smoothstep(radius, stop, sdf));
    return ss;
}

// shake stuff
uniform float shake_t = 5.0;
uniform float shake_scale =  0.01;

uniform float shake_is_from_black_hole = 0.0;
const float shake_factor_a =  100.0;
const float shake_factor_b =  1.;


vec2 rapid_circular_shaking(float arg){
	return vec2(sin(arg), cos(arg));
}


void fragment() {
	float t = TIME * shake_factor_a + shake_factor_b;
    vec2 shake_dt = exp(-shake_t) * shake_scale * rapid_circular_shaking(t);
	
	//vec2 uv = 2. * SCREEN_UV - 1.;
	//vec2 resolution = 1. / SCREEN_PIXEL_SIZE;
	float ar = resolution.x / resolution.y;
	//uv.x *= ar;
	vec2 uv = 2. * UV - 1.;
	
	// --------------------------------------
	uv.x *= ar;
	//vec2 polar = vec2(length(uv), atan(uv.y, uv.x));
	float outline_mask = 1.0;
	float disp_mask = 0.0;
	// --------------------------------------
	for( int i = 0; i < actual_index; i++){
		vec2 pos = positions[i] / (0.5 * resolution);
		pos.x *= ar;
		vec2 uv_prime = uv - pos;
		float r_prime = length(uv_prime);
		float t = times[i];
		disp_mask += shockwave(uv - pos, t) * exp(-2. * PI * t * t);
	}
	float mask = disp_mask;
	COLOR = texture(screen_texture, SCREEN_UV + 0.1 * mask + shake_dt);
}

