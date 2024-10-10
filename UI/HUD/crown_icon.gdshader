shader_type canvas_item;

uniform float selectable = 0.0;
uniform float hovering = 0.0;
void vertex() {
	float sign_x = sign(VERTEX.x) * 1.0 + (1. - sign(VERTEX.x)) * -1.;
	float sign_y = sign(VERTEX.y) * 1.0 + (1. - sign(VERTEX.y)) * -1.;
	VERTEX.xy +=  6.0 * selectable * hovering * vec2(sign_x, sign_y);
}
void fragment(){
	vec4 tex_sample = texture(TEXTURE, UV);
	
	float d = length(tex_sample.xyz);
	
	float dist = 1. / (d * d);
	dist *= 0.2 + abs(sin(4. * TIME));
    dist = pow(dist, 0.8);
	vec3 col = dist * vec3(1.0, 0.5, 0.25);
	
	col = col * selectable + tex_sample.xyz * (1. - selectable);
	COLOR = vec4(col, d);
}
