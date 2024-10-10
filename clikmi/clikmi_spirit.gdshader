shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

float circ( vec2 uv, float r){
	return smoothstep(r, r + 0.03, length(uv));
}

mat2 rot(float angle){
	return mat2( vec2(cos(angle), -sin(angle)),
	             vec2(sin(angle), cos(angle)));
}

float avg(vec3 c){
	return (c.x + c.y + c.z) / 3.0;
}

uniform sampler2D noise_tex: repeat_enable;
uniform float t = 0.;
void fragment() {
	vec2 uv = 2. * UV - 1.;
	//uv.x *= 32.0/ 48.0;

	//
	vec4 noise_tex_sample = UV.y * UV.y * texture(noise_tex, UV - vec2(0., TIME));
	//
	vec2 scale = vec2(mix(1., 3., pow(UV.y, 2.)), 1.15);
	vec2 disp = vec2(pow(UV.y, 4.) * sin(4. * UV.y - 6. * TIME), 0.);
	vec4 tex_sample = texture(TEXTURE, scale * (UV - vec2(0.5)) + vec2(0.5) + disp - 0.2 * noise_tex_sample.r);

	//some grey-pink
	vec3 step_col = vec3(0.5, 0.1, 0.25);
	float s = step(length(step_col), length(tex_sample.xyz));

	//
	vec3 c1 = vec3(circ(vec2(abs(uv.x), uv.y) - vec2(0.15, -0.5), 0.13));
	vec3 col = c1 * vec3(avg(tex_sample.xyz));

	float dist = 1.0/length(uv + disp + vec2(0., 0.15));
	dist *= 0.25;
	dist = pow(dist, 1.2);
	vec3 glow = dist * vec3(1.0, 0.5, 0.25);
	col += glow;

	col = 1.0 - exp( -col );
	COLOR = vec4(col, tex_sample.a * s * (1. - t));
	//COLOR = tex_sample;
	//COLOR = vec4(vec3(UV.y), 1.);
}
