shader_type canvas_item;

//void vertex() {
	//VERTEX *= 1.75;
//}

//uniform float num_frames = 8.0;
//uniform float frame_num = 0.;
//const float zoom = 0.8;
//uniform sampler2D noise_tex: repeat_enable;
//
//float sdSegment( in vec2 p, in vec2 a, in vec2 b )
//{
    //vec2 pa = p-a, ba = b-a;
    //float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    //return length( pa - ba*h );
//}

//void fragment() {
	//float offset_to_center_of_a_frame = 0.5 / num_frames;
	//float dist_to_frame_dist_start = frame_num * (1.0 / num_frames);
	//vec2 offset = dist_to_frame_dist_start + vec2(offset_to_center_of_a_frame, 0.5); // UV space is entire sprite sheet
	//vec2 _UV_zoomed_out = 1.5 * (UV - offset) + offset;
	//vec4 tex_sample_zoomed =  texture(TEXTURE, _UV_zoomed_out);
	//
	//vec2 uv = 2. * vec2((UV.x / (1.0 / num_frames)) - frame_num, UV.y) - 1.;
	//uv.x *= 32. / 48.;
	//
	//float rd = 0.1 * cos(10. * atan(uv.y, uv.x) - 2. * TIME);
	//float sdf = abs(sdSegment(uv, vec2(0., -0.5), vec2(0., 0.5)) + rd - 0.3);
//
	//float dist = 1.0/(sdf);
	//dist *= 0.1;
 	//dist = pow(dist, 0.8);
	//vec3 col = dist * vec3(1.0, 0.5, 0.25) * (1. - tex_sample_zoomed.a) + tex_sample_zoomed.xyz;
	//COLOR = vec4( col, (1. - length(uv)) * dist * dist + tex_sample_zoomed.a);
//}


//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
