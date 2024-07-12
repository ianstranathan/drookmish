shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

float normalize_on_range(float a, float b, float x){
	return (x - a) / (b-a);
}
void fragment() {
	float x = smoothstep(1. / 8., 2. / 8., UV.x);
	vec2 dist = vec2( 0.1 * pow(1. - abs((x - 0.5)), 2.0), pow(UV.y, 2.0));
	vec4 tex_sample = texture(TEXTURE, UV + 0.5 * dist);
	COLOR = tex_sample;//vec4(vec3(), 1.);
}


