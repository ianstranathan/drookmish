shader_type canvas_item;

const vec3 red = vec3(1., 0., 0.);

uniform float t;
void fragment(){
	//float tt = 0.5 * (sin(0.25 * TIME) + 1.);
	float modulation = mix( sin(4. * TIME), sin(40. * TIME), t);
	vec3 col = mix(COLOR.rgb, red + modulation, t*t);
	COLOR = vec4(col, 1.);
}
