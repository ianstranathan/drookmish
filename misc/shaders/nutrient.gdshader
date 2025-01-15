shader_type canvas_item;

uniform float is_reversed = 0.0;
uniform vec3 first_col  = vec3(0., 1.2, 0.1);
uniform float gas_interval       = 4.0;
uniform float transform_interval = 6.0;
uniform float fade_time = 0.0;
//uniform float total_interval_until_mineral_change; //  = gas_interval + transform_interval;
uniform float _time;

float nutrient_blob(vec2 uv, vec2 pos)
{
    float radius_disp = 0.2 * sin(2. * TIME);
	return length(uv - pos) +  radius_disp * cos( 10.0 * atan(uv.y,  uv.x) - TIME);
}

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

mat2 rot(float angle){
	return mat2( vec2(cos(angle), -sin(angle)),
	             vec2(sin(angle),  cos(angle))
	           );
}

float EaseInOutCubic(float x)
{
  //x < 0.5f ? 4.0f * x * x * x : 1 - Mathf.Pow(-2 *x + 2,3)/2;
  float inValue = 4.0 * x * x * x;
  float outValue = 1.0 -pow(-2.0 * x + 2.0 ,3.0) /2.0;
  return step(inValue , 0.5) * inValue + step(0.5,outValue) * outValue;
}


void fragment()
{
 	vec2 uv = 2. * UV - 1.;
	vec2 _uv = uv; // just a copy for the shadertoy col
	float total_interval_until_mineral_change = gas_interval + transform_interval;
	// debug time
	float _t = _time;// mod(TIME, total_interval_until_mineral_change + 4.0);
	
	// bounds
	float greater_than_gas_interval     = step(gas_interval, _t);
	float greater_than_mineral_interval = step(total_interval_until_mineral_change, _t);
	float on_transform_interval         = greater_than_gas_interval * (1. - greater_than_mineral_interval);
	
	// interpolation
	float blinking_interval_time            = on_transform_interval * (_t - gas_interval); // start time at gas end boundary
	float blinking_interval_time_normalized = blinking_interval_time / transform_interval; // [0, 1]
	float _e_t = EaseInOutCubic(blinking_interval_time_normalized);
	float interpolant = sin((8. + 25. * _e_t) * blinking_interval_time);
	
	
	uv = rot(_e_t * PI) * uv;
	
	// sdfs
    float box_sdf  = sdBox(        uv, vec2(0.3, 0.3));
    float blob_sdf = nutrient_blob(uv, vec2(0.,  0. ));
    
	// masks
    float nutrient_blob_mask = 1. - smoothstep(0.7, 0.78,  blob_sdf);
	float box_mask           = 1. - smoothstep(0.25, 0.33, box_sdf);
    
	//
	// shadertoy col
	vec3 second_col = 0.5 + 0.5*cos(2. * TIME + 1.5 * _uv.xyx+vec3(0,2,4)); // shadertoy col
	
	float first_mask  = (1. - is_reversed) * nutrient_blob_mask + is_reversed * box_mask;
	float second_mask = (1. - is_reversed) * box_mask + is_reversed * nutrient_blob_mask;
	
	vec3 _first_col  = (1. - is_reversed) * first_col + is_reversed * second_col;
	vec3 _second_col = (1. - is_reversed) * second_col + is_reversed * first_col;
	
	vec3 col = mix(_first_col * first_mask, _second_col * second_mask, interpolant);
	col = greater_than_mineral_interval * second_mask * _second_col + (1. - greater_than_mineral_interval) * col;
    COLOR = vec4(col, max(col.g, col.b) * (1. - fade_time));
}
