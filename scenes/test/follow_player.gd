extends Node3D

@onready var Player = %Player

func _process(delta: float) -> void:
	if(Player != null):
		position.x = Player.position.x
		position.z = Player.position.z
	
