shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
//vec4 tex_sample = texture(screen_texture, SCREEN_UV - vec2(fn));

uniform vec2 resolution; 
uniform vec2 positions[50];
uniform float times[50];
uniform int actual_index;

float DrawCircle(vec2 uv, vec2 center, float radius, float width)
{
    float sdf = distance(uv, center) - radius;
    float pixelSize = fwidth(sdf);
    return smoothstep((width * 0.5 + 1.0)*pixelSize, width * 0.5 * pixelSize, abs(sdf));
}

const float speed_mult = 3.;
void fragment() {
	//vec2 uv = 2. * SCREEN_UV - 1.;
	//vec2 resolution = 1. / SCREEN_PIXEL_SIZE;
	float ar = resolution.x / resolution.y;
	//uv.x *= ar;
	vec2 uv = 2. * UV - 1.;
	uv.x *= ar;
	//vec2 polar = vec2(length(uv), atan(uv.y, uv.x));
	float outline_mask = 1.0;
	float disp_mask = 0.0;
	
	// --------------------------------------
	float iTime = 0.5 * (sin(TIME) + 1.);
	// --------------------------------------
	for( int i = 0; i < actual_index; i++){
		vec2 pos = positions[i] / (0.5 * resolution);
		pos.x *= ar;

		float x = length(uv - pos);
		disp_mask += DrawCircle(uv - pos, vec2(0.), times[i] * times[i], 4.);
		outline_mask *= smoothstep(0.7, 0.72, x);
	}
	
	float mask = (1. - outline_mask) * clamp(disp_mask, 0., 1.);
	COLOR = vec4(vec3(mask), mask); 
	COLOR = texture(screen_texture, SCREEN_UV + 0.1 * mask);
	//COLOR.xyz += disp_mask;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
