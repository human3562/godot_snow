shader_type spatial;
render_mode unshaded;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

float getDepth(vec2 screen_uv, float raw_depth, mat4 inv_projection_matrix){
//	Credit: https://godotshaders.com/shader/depth-modulated-pixel-outline-in-screen-space/
	vec3 normalized_device_coordinates = vec3(screen_uv * 2.0 - 1.0, raw_depth);
    vec4 view_space = inv_projection_matrix * vec4(normalized_device_coordinates, 1.0);
	view_space.xyz /= view_space.w;	 //wut
	return -view_space.z;
}

float linear_depth(in sampler2D depth_texture, in vec2 screen_uv, in mat4 inv_projection_matrix){
	// get raw depth, this is not a linear value in godot 4.0 vulkan rendering
	float raw_depth = texture(depth_texture, screen_uv)[0];

	vec3 normalized_device_coordinates = vec3(screen_uv * 2.0 - 1.0, raw_depth);

	//convert NDC to view space via the inverse projection matrix
    vec4 view_space = inv_projection_matrix * vec4(normalized_device_coordinates, 1.0);

	//linearize the depth
	view_space.xyz /= view_space.w;

	// camera view points in the negative Z direction, so all depths are negative
	// we invert the sign here to get positive depth values
	return -view_space.z;
}

void fragment() {

	vec4 clipSpacePosition = vec4(SCREEN_UV * 2.0 - 1.0, texture(DEPTH_TEXTURE, SCREEN_UV).r, 1.0);
	vec4 viewSpacePosition = INV_PROJECTION_MATRIX * clipSpacePosition;
	viewSpacePosition /= viewSpacePosition.w;
	vec4 worldSpacePosition = INV_VIEW_MATRIX * viewSpacePosition;
	ALBEDO = vec3(worldSpacePosition.g / 50.);

	//float raw_depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
//
	////float depth = getDepth(SCREEN_UV, raw_depth, INV_PROJECTION_MATRIX);
//
	//float depth = linear_depth(DEPTH_TEXTURE, SCREEN_UV, INV_PROJECTION_MATRIX);
//
	////float depth = getDepth(SCREEN_UV, texture(DEPTH_TEXTURE, SCREEN_UV).x, INV_PROJECTION_MATRIX);
	////float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
//
	//ALBEDO = vec3(depth / 50.);
	//ALPHA = depth;
}
