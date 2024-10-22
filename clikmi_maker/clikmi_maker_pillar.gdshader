shader_type canvas_item;

uniform sampler2D pillar_mat: repeat_enable;
uniform float decay_interpolant = 10.0;

void vertex() {
	float sign_x = sign(VERTEX.x) * 1.0 + (1. - sign(VERTEX.x)) * -1.;
	float sign_y = sign(VERTEX.y) * 1.0 + (1. - sign(VERTEX.y)) * -1.;
	VERTEX += 10.0 * exp(-decay_interpolant * 5.0) * vec2(sign_x, sign_y);
}

const float scale = 0.25;
const vec2 sprite_scale = vec2(1.);//vec2(1.06, 0.16);
const vec2 res = vec2(128.);
const vec2 sprite_res = sprite_scale * res;

uniform float spin_speed = 0.0;
uniform float spin_dir = 1.0;
uniform float out_of_lives = 0.0;

const float MAX_SPIN_SPEED = 10.0;

float Hash21(vec2 p) {
    p = fract(p*vec2(234.34, 435.345));
    p+= dot(p, p+34.23);
    return fract(p.x*p.y);
}

void fragment() {
	vec2 uv = 2. * UV - 1.;
	vec2 uv_copy = uv;
	float ar = sprite_res.x / sprite_res.y;

	//---------------------------------------------
	//vec2 sample_uv = 2. * UV - 1.;
	float t = pow(spin_speed, 2.);

	// -----------------------------------------------------
	uv.x = acos(1. * uv.x) - spin_dir * t * MAX_SPIN_SPEED * TIME;

    // grid initialization
    vec2 gv = fract(2. * uv)-0.5;

    // randomize
    vec2 id = floor(2. * uv);
    float n = Hash21(id);

	//
	gv.x = -1. * gv.x * step(0.5, n) + (1. - step(0.5, n) ) * gv.x; //if (n < 0.5) gv.x*=-1.0;

	// diagonal lines
    float d = 2. * (abs(abs(gv.x+gv.y)-0.5)); // (abs(abs(gv.x+gv.y)-0.5))

    // Output to screen
    //COLOR = vec4(vec3(d),smoothstep(0.05, 0.06, d));

	// fake shading
	float fake_bake = 1. - uv_copy.x * uv_copy.x;

	// glow
	float dist = 1.0 / d;
	dist *= mix(0.1, 0.6, t);
	dist = pow(dist, 0.8);

	vec3 col = vec3(0.9, 0.6, 0.8) * (1. - step(0.9, t)) + step(0.9,t) * vec3(0.2);
	col += 0.1 * sin(20. * mod(TIME, 10.0)) * out_of_lives * vec3(1., 0., 0.);

	col = (dist * fake_bake) * (col * (1. - out_of_lives) + out_of_lives * vec3(1., 0., 0.) * abs(sin(4. * TIME)));
	// White flash when clicked
	col += exp(-decay_interpolant * 5.0);

	COLOR = vec4(col, 1.);
}
