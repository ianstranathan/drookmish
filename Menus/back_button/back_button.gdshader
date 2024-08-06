shader_type canvas_item;


uniform float hover = 1.0;

float sdEquilateralTriangle( in vec2 p, in float r )
{
    const float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r/k;
    if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0*r, 0.0 );
    return -length(p)*sign(p.y);
}

//float sdBox( in vec2 p, in vec2 b )
//{
    //vec2 d = abs(p)-b;
    //return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
//}

mat2 rot(float angle){
	return mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
}
void fragment() {
	//vec4 tex_samp = texture(TEXTURE, UV);
	//float mask = length(tex_samp.rgb);
	//vec3 col = mask * vec3(1., 0.8, 0.6) * hover + (1. - hover) * mask * 0.5 * vec3(1., 0.8, 0.6);
	//COLOR = vec4(0.9 * col, smoothstep(0., 0.3, tex_samp.r));
	vec2 uv = 2. * UV - 1.;
	float tri_sdf = sdEquilateralTriangle(rot(0.5 * PI) * (uv - vec2(0.2, 0.)), 0.8);
	//float box_sdf = sdBox(uv - vec2(0.1, 0.), vec2(0.6, 0.1));
	//float mask = smoothstep(0., 0.1, tri_sdf) * smoothstep(0., 0.1, box_sdf);
	
	float mask = 1. - smoothstep(0., 0.1, tri_sdf);
	vec3 col = 0.8 * vec3(1., 0.75, .79) * mask * hover + (1. - hover) * vec3(mask);
	COLOR = vec4(col, mask);
}
