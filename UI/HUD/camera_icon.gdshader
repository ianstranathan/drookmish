shader_type canvas_item;

uniform float hovered_over_hotkey_jump = 0.0;
uniform float hovered_over_bind_hotkey = 0.0;

mat2 rot(float angle){
	return mat2( vec2(cos(angle), -sin(angle)),
	             vec2(sin(angle), cos(angle)));
}
void vertex() {
	//VERTEX.xy += hovered_over * 10.0 * vec2(sign(VERTEX.x), sign(VERTEX.y)) * sin(8. * TIME);
	float sign_x = sign(VERTEX.x) * 1.0 + (1. - sign(VERTEX.x)) * -1.;
	float sign_y = sign(VERTEX.y) * 1.0 + (1. - sign(VERTEX.y)) * -1.;

	// wiggle if you want to set it
	vec2 hover_bind = hovered_over_bind_hotkey * 5.0 * vec2(sign_x, 0.0) * sin(8. * TIME);//vec2(sign_x, sign_y);

	// just enlarge if you want to jump to cam hotkey
	vec2 hover_jump = hovered_over_hotkey_jump * 8.0 * vec2(sign_x, sign_y);

	// superposition of both
	vec2 hover_anim = hover_jump * (1. - hovered_over_bind_hotkey) + hover_bind * (1. - hovered_over_hotkey_jump);

	//
	VERTEX.xy +=  hover_anim;
}

// maybe this is different for each cam
uniform vec4 default_col:source_color = vec4(vec3(1., 0.4, 0.2), 1.);
//uniform float cam_loc_is_set = 0.0;
uniform vec4 set_col; // w is switch encoded
uniform vec4 hover_set_bind_col;
void fragment() {
	//vec2 _UV = rot(hovered_over * sin(8. * TIME) * PI / 8.0) * (UV - vec2(0.5)) + vec2(0.5);
	vec4 tex = texture(TEXTURE, UV);
	//vec3 col = (select_cam_col.xyz) * hovered_over_to_set * (1. - hovered_already_set) +
			   //(default_col.xyz)    * hovered_already_set * (1. - hovered_over_to_set);
	//col += tex.xyz * (1. - hovered_over_to_set) * (1. - hovered_already_set);
	vec3 col = default_col.xyz * (1. - set_col.w) * (1. - hover_set_bind_col.w) +
	           set_col.xyz * (1. - hover_set_bind_col.w) +
			   hover_set_bind_col.xyz;
	COLOR = vec4(col, tex.a);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
