shader_type canvas_item;

float sdStar5(in vec2 p, in float r, in float rf)
{
    const vec2 k1 = vec2(0.809016994375, -0.587785252292);
    const vec2 k2 = vec2(-k1.x,k1.y);
    p.x = abs(p.x);
    p -= 2.0*max(dot(k1,p),0.0)*k1;
    p -= 2.0*max(dot(k2,p),0.0)*k2;
    p.x = abs(p.x);
    p.y -= r;
    vec2 ba = rf*vec2(-k1.y,k1.x) - vec2(0,1);
    float h = clamp( dot(p,ba)/dot(ba,ba), 0.0, r );
    return length(p-ba*h) * sign(p.y*ba.x-p.x*ba.y);
}

void fragment(){
	vec2 uv = 2. * UV - 1.;
	uv.y *= -1.;
	uv *= 2.;
	float dist = sdStar5(uv, 0.4, 0.5);
	dist = 1.0/length(dist);
	dist *= 0.1;
	dist = pow(dist, 0.8);
	vec3 col = dist * vec3(1.0, 0.5, 0.25);
	col = 1.0 - exp( -col );
	COLOR = vec4(col, dist * dist * smoothstep(0., 8.7, dist));
}