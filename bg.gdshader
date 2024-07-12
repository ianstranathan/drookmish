shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

float sdCircle( vec2 p, float r )
{
    return length(p) - r;
}

float sdBox( vec2 p, vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}
const float N = 2.0; // grid ratio
float gridTexture( in vec2 p )
{
    // coordinates
    vec2 i = step( fract(p), vec2(1.0/N) );
    //pattern
    //return (1.0-i.x)*(1.0-i.y);   // grid (N=10)
    
    // other possible patterns are these
    //return 1.0-i.x*i.y;           // squares (N=4)
    return 1.0-i.x-i.y+2.0*i.x*i.y; // checker (N=2)
}
void fragment() {
	
    vec2 uv = 2. * UV - 1.;
	float border = smoothstep(0., 0.01, sdBox(uv, vec2(0.95)));
    vec3 col = 1. -  0.5*cos(TIME+uv.xyx+vec3(0,2,4));
	
	float grid = mix(0.5, gridTexture(10. * vec2(length(uv), atan(uv.y, uv.x))), 0.5 * length(uv));
	vec3 inner_col = col * (1. - border) * grid;
	vec3 border_col = vec3(0.)* border;
	COLOR = 1.2 * vec4(border_col + inner_col, 0.5);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
