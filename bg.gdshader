shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
float avg_col(vec3 col){
	return (col.x + col.y + col.z) / 3.0;
}
void fragment() {
	vec2 uv = 2. * UV - 1.;
	vec2 screen_pixel_size = SCREEN_PIXEL_SIZE;
	float min_pixel_dir = min(screen_pixel_size.x, screen_pixel_size.y);
	vec2 f_uv = smoothstep(0.5, 0.5 + min_pixel_dir, fract(vec2(length(uv), atan(uv.y, uv.x))));
	vec3 col = vec3(avg_col(vec3(f_uv, 0.)));
	COLOR = vec4(col, 1.);
}