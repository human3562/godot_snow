extends Node3D

var last_pos = Vector3(0,0,0)
var delta_vec = Vector2(0, 0)

func _ready() -> void:
	$ViewportB.get_texture().get_image().fill(Color(0,0,0,0))
	last_pos = $IntersectionViewport/intersection_root.position

func _process(delta: float) -> void:
	var current_pos = $IntersectionViewport/intersection_root.position
	#var plane_world = Vector2(
	#	-current_pos.x / 50.,
	#	current_pos.z / 50.
	#)
	
	var depth_camera_size = ($IntersectionViewport/intersection_root/IntersectionCamera as Camera3D).size
	
	
	delta_vec = Vector2(
		(last_pos.x - current_pos.x) / 256.,
		-(last_pos.z - current_pos.z) / 256.
	)
	
	$ViewportB/ColorRect.material.set_shader_parameter("plane_delta", delta_vec)
	$test_snowplane.material_override.set_shader_parameter("trail_plane_position", Vector2(
		current_pos.x,
		current_pos.z
	))
	
	$test_snowplane_x2meshdetail.material_override.set_shader_parameter("trail_plane_position", Vector2(
		current_pos.x,
		current_pos.z
	))
	
	# $Terrain3D.material.set_shader_parameter("trail_plane_position", Vector2(
	# 	current_pos.x,
	# 	current_pos.z
	# ))
	
	($Terrain3D as Terrain3D).material.set_shader_param("trail_plane_position", Vector2(
		current_pos.x,
		current_pos.z
	))
	#print(delta_vec * 100.)
	last_pos = current_pos
