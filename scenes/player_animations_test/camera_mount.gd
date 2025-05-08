class_name CamMount
extends Node3D

@onready var camera_3d: Camera3D = $Camera3D

@export var Camera_pos_list: Array[Vector3]
var current_cam_pos : int = 0

func cycle_positions():
	current_cam_pos = (current_cam_pos + 1) % len(Camera_pos_list)
	print(current_cam_pos)

func _process(delta: float) -> void:
	camera_3d.position = camera_3d.position.move_toward(Camera_pos_list[current_cam_pos], delta)
