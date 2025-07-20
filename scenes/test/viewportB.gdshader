shader_type canvas_item;

uniform sampler2D current_depth : filter_linear, repeat_disable;
uniform sampler2D current_height : filter_linear, repeat_disable;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform vec2 plane_delta;

void fragment() {
	vec2 shifted_uv = UV - plane_delta;

	// vec2 shifted_uv = (UV * 50.)/100. - plane_delta;
	float depth = texture(current_depth, UV).r;
	float height = texture(current_height, vec2(UV.r, 1.0 - UV.g)).r;
	float accum = texture(screen_texture, shifted_uv).r; //shifted_uv / 50.);
	//float accum = max(texture(screen_texture, shifted_uv).r, blur(screen_texture, shifted_uv, ps).r);
	vec2 edge_distance = abs(UV * 2.0 - 1.0); // Maps [0,1] to [-1,1], then takes absolute value
    float mask = 1.0 - smoothstep(
        0.9,
        1.0,
        length(edge_distance)
    );

	// float intersect2 = depth < height ? 1.0 : 0.0;
	// float intersect = min(depth, height);	

	//float height_corrected_depth = depth < height ? height - depth : 0.0;
	float height_corrected_depth = (height - depth) * 2.0;
	accum = max(height_corrected_depth + accum, accum);
	//accum = height_corrected_depth;


	//accum += depth;
	//accum = depth > 0. ? (depth) : (accum);
	//accum = depth < 0.5 ? (2.0 * depth * accum) : (1.0 - 2.0 * (1.0 - depth) * (1.0 - accum));
	
	vec3 final = vec3(accum) * mask;
	COLOR = vec4(final, 1.0);
	//COLOR = vec4(texture(current_depth, UV).rgb, 1.0);
	//COLOR = vec4(blur(current_depth, UV, ps), 1.0);
	//COLOR = vec4(accum, accum, accum, 1.0);
	//COLOR = vec4(height_corrected_depth, height_corrected_depth, height_corrected_depth, 1.0);
}