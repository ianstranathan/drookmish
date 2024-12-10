shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

vec3 palette( float t, in vec3 a, vec3 b, vec3 c, vec3 d )
{
    return a + b*cos( 6.283185*(c*t+d) );
}

uniform sampler2D tex_icon;
uniform float hovered_over = 1.0;
uniform float offset_time = 1.0;

const vec3 a = vec3(0.5, 0.5, 0.5);
const vec3 b = vec3(0.5, 0.5, 0.5);
const vec3 c = vec3(2.0, 1.0, 0.0);
const vec3 d = vec3(0.50, 0.20, 0.25);

void fragment() {
	vec4 tex_sample = texture(TEXTURE, UV);
	float alpha = hovered_over + (1. - hovered_over) * 0.3;
	COLOR = vec4(palette(offset_time, a,b,c,d), alpha);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
