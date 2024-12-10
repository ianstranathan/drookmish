shader_type canvas_item;

uniform float tt;
uniform float is_paused_message = 1.0;

void vertex() {
	VERTEX.y += (25. * sin(10. * TIME - VERTEX.x) * exp(-5. * tt)) * is_paused_message;
}
