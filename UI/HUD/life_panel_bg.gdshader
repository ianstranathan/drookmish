shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

uniform float flash_switch;
void fragment() {
	vec2 uv = 2. * UV - 1.;
	float d = sdBox(uv, vec2(0.5, 0.2));
	//float t = abs(sin(TIME));
	vec3 col = vec3(.8, 0., 0.) * d + 0.2 * abs(sin(10. * TIME));
	col = COLOR.xyz * (1. - flash_switch) + flash_switch * col;
	float alpha = d * flash_switch + (1. - flash_switch);
	COLOR = vec4(col, alpha);
}

