shader_type canvas_item;

float Hash21(vec2 p) {
    p = fract(p*vec2(234.34, 435.345));
    p+= dot(p, p+34.23);
    return fract(p.x*p.y);
}

void fragment()
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = 2. * UV - 1.;
    uv*=1.0;
	
	vec2 sample_uv = uv;
	float t = 0.001 * TIME;//pow(spin_speed, 2.);
	float MAX_SPIN_SPEED = 1.0;
	float spin_dir = 1.0;
	uv.x = acos(1. * uv.x) - spin_dir * t * MAX_SPIN_SPEED * TIME;

    // grid initialization
    vec2 gv = fract(uv)-0.5;
    
    // randomize
    vec2 id = floor(uv);
    float n = Hash21(id);
	
	//
	gv.x = -1. * gv.x * step(0.5, n) + (1. - step(0.5, n) ) * gv.x; //if (n < 0.5) gv.x*=-1.0;

	// diagonal lines
    float d = abs(abs(gv.x+gv.y)-0.5); // recenter dist

    // Output to screen
    COLOR = vec4(vec3(d),smoothstep(0.05, 0.06, d));
}