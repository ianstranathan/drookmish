shader_type canvas_item;

//float DrawCircle(vec2 uv, vec2 center, float radius, float width)
//{
    //float sdf = distance(uv, center) - radius;
    //float pixelSize = fwidth(sdf);
    //return smoothstep((width * 0.5 + 1.0)*pixelSize, width * 0.5 * pixelSize, abs(sdf));
//}
float sdCircle( vec2 p, float r )
{
    return length(p) - r;
}

uniform float clikmi_is_inside = 0.0;
void fragment() {
	vec2 uv = 2. * UV - 1.;
	
	float dist = 1.0/abs(sdCircle(uv, 0.5)) - 0.5;
	// Dampen the glow to control the radius
	float dampen_coeff = 0.1  * clikmi_is_inside + 0.05 * (1. - clikmi_is_inside);
    dist *= dampen_coeff + 0.05 * dampen_coeff * sin(2.5 * TIME);
    
    //**********       Intensity     **********
    
    // Raising the result to a power allows us to change the glow fade behaviour
    // See https://www.desmos.com/calculator/eecd6kmwy9 for an illustration
    // (Move the slider of m to see different fade rates)
    dist = pow(dist, 0.8);
    
    // Knowing the distance from a fragment to the source of the glow, the above can be 
    // written compactly as: 
    //	float getGlow(float dist, float radius, float intensity){
    //		return pow(radius/dist, intensity);
	//	}
    // The returned value can then be multiplied with a colour to get the final result
       
    // Add colour
	vec3 is_active_col = vec3(1.0, 0.5, 0.25) * (clikmi_is_inside) + vec3(0.5) * (1. - clikmi_is_inside);
    vec3 col = dist * is_active_col;
	
    // Tonemapping. See comment by P_Malin
    col = 1.0 - exp( -col );
	COLOR = vec4(col, pow(col.r, 3.));
}
