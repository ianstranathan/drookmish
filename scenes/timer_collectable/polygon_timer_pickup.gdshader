shader_type canvas_item;

uniform float t = 0.0;
void fragment(){
	COLOR = vec4(COLOR.xyz, 1. - (t * t));
}