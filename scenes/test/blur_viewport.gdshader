shader_type canvas_item;

#define pow2(x) (x * x)
#define iResolution 1.0/SCREEN_PIXEL_SIZE

uniform sampler2D snow_depth_texture : repeat_disable, filter_linear;

uniform float strength : hint_range(0.0, 5.0) = 1.0;
const int samples = 8;
const float sigma = float(samples) * 0.25;

float gaussian(vec2 i) {
    return 1.0 / (2.0 * PI * pow2(sigma)) * exp(-((pow2(i.x) + pow2(i.y)) / (2.0 * pow2(sigma))));
}

vec3 blur(sampler2D sp, vec2 uv, vec2 scale) {
    vec3 col = vec3(0.0);
    float accum = 0.0;
    float weight;
    vec2 offset;
    
    for (int x = -samples / 2; x < samples / 2; ++x) {
        for (int y = -samples / 2; y < samples / 2; ++y) {
            offset = vec2(float(x), float(y));
            weight = gaussian(offset);
            col += texture(sp, uv + scale * offset).rgb * weight;
            accum += weight;
        }
    }
    
    return col / accum;
}


void fragment() {
	vec2 ps = vec2(1.0) / iResolution.xy * .000001 * strength;
	
	COLOR.rgb = max(texture(snow_depth_texture, UV).rgb, blur(snow_depth_texture, UV, ps)*5.0);
    COLOR.a = 1.0;
	//COLOR = vec4(1.0 - textureLod(screen_texture, SCREEN_UV, 1.0).rgb, 1.0);
}

