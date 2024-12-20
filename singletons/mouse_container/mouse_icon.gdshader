shader_type canvas_item;

// uniform sampler2D   open_palm;
uniform sampler2D closed_palm;
uniform float grabbing = 0.0;
//uniform float hovering = 0.0;

//void vertex() {
	//VERTEX += hovering * 5.0 * abs(sin(4. * TIME)) * vec2(sign(VERTEX.x), sign(VERTEX.y));
//}

void fragment() {
	vec4 open_palm_sample   = texture(TEXTURE,     UV);
	vec4 closed_palm_sample = texture(closed_palm, UV);
	vec4 col = (open_palm_sample * (1. - grabbing) + closed_palm_sample * grabbing);
	COLOR = col;
}
