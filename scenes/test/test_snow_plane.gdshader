shader_type spatial;

render_mode world_vertex_coords;

uniform sampler2D albedo_base : hint_default_white, repeat_enable, filter_nearest;
uniform sampler2D snow_map : hint_default_black, repeat_disable, filter_linear;
uniform vec3 ground_color = vec3(0.8);
uniform vec3 trail_color = vec3(1.0);
uniform vec2 trail_plane_position;
uniform float trail_max_depth : hint_range(0.0, 1.0) = 0.5;

vec3 getNormal(vec2 uv, float texelSize) {
	float t = texture(snow_map, uv + vec2(texelSize * vec2(0.0, -1.0))).r * trail_max_depth;
	float r = texture(snow_map, uv + vec2(texelSize * vec2(1.0, 0.0))).r * trail_max_depth;
	float l = texture(snow_map, uv + vec2(texelSize * vec2(-1.0, 0.0))).r * trail_max_depth;
	float b = texture(snow_map, uv + vec2(texelSize * vec2(0.0, 1.0))).r * trail_max_depth;

	return -normalize(vec3(2.0 * (r - l), 2.0 * (b - t), -4.0));
}

void vertex() {
	vec2 world_uv = NODE_POSITION_WORLD.rb + (UV) * 64.;
	vec2 adjusted_uv = (world_uv + vec2(32., 32.) - trail_plane_position) / 128.;
	adjusted_uv.g = 1.0 - adjusted_uv.g;
	float trail = texture(snow_map, adjusted_uv).r;

	VERTEX.y -= trail * trail_max_depth;
	NORMAL = getNormal(adjusted_uv, 1.0 / float(textureSize(snow_map, 0).x));
}


void fragment(){
	vec2 world_uv = NODE_POSITION_WORLD.rb + (UV) * 64.;
	vec2 adjusted_uv = (world_uv + vec2(32., 32.) - trail_plane_position) / 128.;
	adjusted_uv.g = 1.0 - adjusted_uv.g;
	float trail = texture(snow_map, adjusted_uv).r;
	vec3 trail_colored = 1.0 - trail * trail_color;
	ALBEDO = texture(albedo_base, UV * 64.).rgb * ground_color * trail_colored;
}
