shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float t;


void fragment(){
	float time = fract(TIME/2.);
	//float v = sin(10. - TIME);
	vec3 col = vec3(SCREEN_UV.x);
    COLOR = vec4(col, 1.);
}


