shader_type canvas_item;

uniform vec4 color: source_color = vec4(1., 0.4, 0.9, 0.);
uniform float col_switch = 1.0;
uniform float invincibility;
// for the invincibility col
vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

void vertex() {
	VERTEX.xy += (1. - col_switch) * vec2( sign(VERTEX.x), 1. - step(0.0, VERTEX.y)) * sin(10.0 * TIME);
}

void fragment() {
	vec2 _UV = UV;
	vec4 tex_sample = texture(TEXTURE, _UV +  (col_switch) * vec2(0.02 * sin(5. * UV.y - 10. * TIME), 0.));
	float energy = (tex_sample.r + tex_sample.g + tex_sample.b) / 3.0;
	vec3 col = tex_sample.xyz * (1. - color.w) + (energy * color.xyz * color.w);
	col = col*(1. - invincibility) + 
	palette(4. * TIME, vec3(.5), vec3(.5), vec3(1.0), vec3(0.0, 0.33, 0.67)) * invincibility;
	COLOR = vec4(col, tex_sample.a);
}
