shader_type canvas_item;

uniform float hovered_over;

varying vec2 v;
void vertex() {
	//VERTEX.xy += hovered_over * 10.0 * vec2(sign(VERTEX.x), sign(VERTEX.y)) * sin(8. * TIME);
	//v = VERTEX.xy;
	// the svg texture is 128 x 128, I don't know why texture rect doesn't use NDC coords
	float x_gt_64_px = step(64, VERTEX.x);
	float y_gt_64_px = step(64, VERTEX.y);
	float sign_x = x_gt_64_px * 1.0 + (1. - x_gt_64_px) * -1.;
	float sign_y = y_gt_64_px * 1.0 + (1. - y_gt_64_px) * -1.;
	VERTEX.xy += hovered_over * 10.0 * vec2(sign_x, sign_y) * sin(8. * TIME);
}

float sdEquilateralTriangle( in vec2 p, in float r )
{
    const float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r/k;
    if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0*r, 0.0 );
    return -length(p)*sign(p.y);
}

mat2 rot( float angle){
	return mat2(vec2( cos(angle), -sin(angle)),
			    vec2(sin(angle), cos(angle)));
}

uniform float rot_offset;

void fragment() {
	vec2 uv = 2. * UV - 1.;
	uv.y *= -1.;
	uv = rot(rot_offset) * uv;
	float sdf = sdEquilateralTriangle(uv, 0.5);
	float val = smoothstep(0., 0.2, abs(sdf));
	float dist = 1.0 / val;
	dist *= 0.3 + hovered_over * 0.1 * sin(8. * TIME);
	dist = pow(dist, 0.8);
	vec3 col = dist * vec3(1.0, 0.5, 0.25);
	col = 1.0 - exp( -col );
	COLOR = vec4(col, (1. - val) - 0.5 * (1. - hovered_over));
	//COLOR = vec4(vec3(v/128., 0.), 1.);
}