shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform sampler2D noise_tex: repeat_enable;

mat2 rot(float angle){
	return mat2( vec2(cos(angle), -sin(angle)), 
	             vec2(sin(angle), cos(angle)));
}

uniform float swirl_dist_normal;
void fragment()
{
    vec2 uv = 2. * UV - 1.;
	uv  = rot(-2. * TIME - swirl_dist_normal * 15. * length(uv)) * uv;
    vec2 polar = vec2( length(uv), atan(uv.y, uv.x));
	
	float spiral_d = cos( 2. * (polar.y - 3. * polar.x - 2. * TIME));
    vec4 noise_sample = texture(noise_tex, 0.2 * vec2(polar.x + TIME, abs(polar.y)) - 0.2 * spiral_d);
    
    vec3 stc = 0.5 + 0.5*cos(TIME+uv.xyx+vec3(0,2,4));
	
    float mask = 1. - smoothstep(0.5 + 0.1 * noise_sample.r, 0.52 + 0.1 * noise_sample.r, polar.x);
	
	vec3 col = smoothstep(0.8, 1.5, 2. * noise_sample.r * noise_sample.r) * mix(vec3(0.), stc, length(uv)) + 0.5 * pow(length(uv), 2.);
    COLOR = vec4( col, mask);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
