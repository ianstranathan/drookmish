shader_type canvas_item;

void fragment(){
	vec4 tex_sample = texture(TEXTURE, UV);
	
	float d = length(tex_sample.xyz);
	
	float dist = 1. / (d * d);
	dist *= 0.2 + abs(sin(4. * TIME));
    dist = pow(dist, 0.8);
	vec3 col = dist * vec3(1.0, 0.5, 0.25);
	COLOR = vec4(col, d);
}