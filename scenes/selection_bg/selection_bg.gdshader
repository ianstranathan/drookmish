shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

float sdSegment( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 pa = p-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h );
}

void fragment() {
	vec2 uv = 2. * UV - 1.;
	float rd = 0.1 * cos(10. * atan(uv.y, uv.x) - 2. * TIME);
	float sdf = abs(sdSegment(uv, vec2(0., -0.5), vec2(0., 0.5)) + rd - 0.3);
	float dist = 1.0/(sdf);
	dist *= 0.1;
 	dist = pow(dist, 0.8);
	vec3 col = dist * vec3(1.0, 0.5, 0.25);
	COLOR = vec4( col, (1. - length(uv)) * dist);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
