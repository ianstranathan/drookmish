shader_type canvas_item;

uniform float selectable = 0.0;
uniform float hovering = 0.0;
void vertex() {
	//VERTEX.xy += hovered_over * 10.0 * vec2(sign(VERTEX.x), sign(VERTEX.y)) * sin(8. * TIME);
	float sign_x = sign(VERTEX.x) * 1.0 + (1. - sign(VERTEX.x)) * -1.;
	float sign_y = sign(VERTEX.y) * 1.0 + (1. - sign(VERTEX.y)) * -1.;
	
	//// wiggle if you want to set it
	//vec2 hover_bind = hovered_over_bind_hotkey * 5.0 * vec2(sign_x, 0.0) * sin(8. * TIME);//vec2(sign_x, sign_y);
	//
	//// just enlarge if you want to jump to cam hotkey
	//vec2 hover_jump = hovered_over_hotkey_jump * 8.0 * vec2(sign_x, sign_y);
	//
	//// superposition of both
	//vec2 hover_anim = hover_jump * (1. - hovered_over_bind_hotkey) + hover_bind * (1. - hovered_over_hotkey_jump);
	//
	//// 
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
