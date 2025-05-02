shader_type canvas_item;

uniform sampler2D current_depth : filter_linear;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform vec2 plane_delta;
uniform float fade_factor = 0.998;

void fragment() {
	vec2 shifted_uv = UV - plane_delta;

	// vec2 shifted_uv = (UV * 50.)/100. - plane_delta;
	float depth = texture(current_depth, UV).r * 2.0;
	float accum = texture(screen_texture, shifted_uv).r; //shifted_uv / 50.);
	vec2 edge_distance = abs(UV * 2.0 - 1.0); // Maps [0,1] to [-1,1], then takes absolute value
    float mask = 1.0 - smoothstep(
        0.9,
        1.0,
        length(edge_distance)
    );

	accum = max(depth, accum * fade_factor) * mask;

	//accum += depth;
	//accum = depth > 0. ? (depth) : (accum);
	//accum = depth < 0.5 ? (2.0 * depth * accum) : (1.0 - 2.0 * (1.0 - depth) * (1.0 - accum));
	//COLOR = (accum * fade_factor + depth) * vec4(mask, mask, mask, 1.);
	COLOR = vec4(accum, accum, accum, 1.0);
	//COLOR = vec4(depth, depth, depth, 1.0);
}