shader_type canvas_item;

uniform float col_switch = 1.0;

void vertex() {
	VERTEX.xy += (1. - col_switch) * vec2( sign(VERTEX.x), 1. - step(0.0, VERTEX.y)) * sin(10.0 * TIME);
}

uniform vec4 color: source_color = vec4(1., 0.4, 0.9, 0.);

void fragment() {
	vec2 _UV = UV;
	vec4 tex_sample = texture(TEXTURE, _UV +  (col_switch) * vec2(0.02 * sin(5. * UV.y - 10. * TIME), 0.));
	float energy = (tex_sample.r + tex_sample.g + tex_sample.b) / 3.0;
	vec3 col = tex_sample.xyz * (1. - color.w) + (energy * color.xyz * color.w);
	COLOR = vec4(col, tex_sample.a);
}
