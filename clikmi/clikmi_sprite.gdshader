shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform vec4 color: source_color = vec4(1., 0.4, 0.9, 0.);

void fragment() {
	vec4 tex_sample = texture(TEXTURE, UV);
	float energy = (tex_sample.r + tex_sample.g + tex_sample.b) / 3.0;
	vec3 col = tex_sample.xyz * (1. - color.w) + (energy * color.xyz * color.w);
	COLOR = vec4(col, tex_sample.a);
}
