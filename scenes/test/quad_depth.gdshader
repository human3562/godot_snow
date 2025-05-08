shader_type spatial;
render_mode unshaded;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear;

void fragment() {
	vec4 clipSpacePosition = vec4(SCREEN_UV * 2.0 - 1.0, texture(DEPTH_TEXTURE, SCREEN_UV).r, 1.0);
	vec4 viewSpacePosition = INV_PROJECTION_MATRIX * clipSpacePosition;
	viewSpacePosition /= viewSpacePosition.w;
	vec4 worldSpacePosition = INV_VIEW_MATRIX * viewSpacePosition;
	ALBEDO = vec3(worldSpacePosition.g / 50.);
}
