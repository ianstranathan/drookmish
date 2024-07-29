shader_type canvas_item;

const vec3 red = vec3(1., 0., 0.);

uniform float t;
uniform float is_paused;

float avg_col(vec3 col){
	return (col.x + col.y + col.z) / 3.0;
}
void fragment(){
	// I wanted it to turn gray in safe zone?
	//vec3 base_col = COLOR.rgb;// * (1. - is_paused) + avg_col(COLOR.rgb) * is_paused;
	//float tt = 0.5 * (sin(0.25 * TIME) + 1.);
	float modulation = mix( sin(4. * TIME), sin(40. * TIME), t);
	vec3 col = mix(COLOR.rgb, red + modulation, t*t * (1. - is_paused));
	COLOR = vec4(col, 1.);
}
