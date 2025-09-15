extends Node

@onready var Player = %Player
@onready var HeightmapScanner = $"../HeightmapViewport/heightmap_root"
@onready var IntersectScanner = $"../IntersectionViewport/intersection_root"

@onready var ViewportB = $"../ViewportB/ColorRect"
@onready var Terrain = ($"../Terrain3D" as Terrain3D)

var last_pos = Vector3(0,0,0)
var delta_vec = Vector2(0, 0)

var snap_step = 5.0

func _process(_delta):
	var player_pos: Vector3 = Player.position.snapped(Vector3(snap_step, 0, snap_step))
	
	HeightmapScanner.position.x = player_pos.x
	HeightmapScanner.position.z = player_pos.z
	
	IntersectScanner.position.x = player_pos.x
	IntersectScanner.position.z = player_pos.z
	
	
	delta_vec = Vector2(
		(last_pos.x - player_pos.x) / 64.,
		-(last_pos.z - player_pos.z) / 64.
	)
	
	ViewportB.material.set_shader_parameter("plane_delta", delta_vec)
	
	Terrain.material.set_shader_param("trail_plane_position", Vector2(
		player_pos.x,
		player_pos.z
	))
	
	last_pos = player_pos
	

#func _process(delta: float) -> void:
	#if(Player != null):
		#position.x = Player.position.x
		#position.z = Player.position.z
	
