shader_type canvas_item;

float sdHexagon( in vec2 p, in float r )
{
    const vec3 k = vec3(-0.866025404,0.5,0.577350269);
    p = abs(p);
    p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
    return length(p)*sign(p.y);
}

uniform float is_not_good;

void fragment() {
	vec2 uv = 2. * UV - 1.;
	float dist = 1.0/abs(sdHexagon(uv, 0.5))- 0.5;
    dist *= 0.15;
    
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
	
    vec3 col = dist * ((1. - is_not_good) * vec3(1.0, 0.5, 0.25) + is_not_good * vec3(1.0, 0.2, 0.15));
	
    // Tonemapping. See comment by P_Malin
    col = 1.0 - exp( -col );
	COLOR = vec4(col, pow(col.r, 3.));
}
