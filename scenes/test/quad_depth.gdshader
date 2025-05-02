shader_type spatial;
render_mode unshaded;

uniform sampler2D depth_texture : hint_depth_texture;

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).r;
	// ALBEDO = vec3(depth);

	ALPHA = depth;
}
