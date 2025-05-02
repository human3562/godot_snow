extends CharacterBody3D

@export var animation_tree : AnimationTree


func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	var multiplier = 1.0 if Input.is_action_pressed("sprint") else 0.5
	
	var horizontal_input = -Input.get_axis("move_right", "move_left") * multiplier
	var vertical_input = Input.get_axis("move_backward", "move_forward") * multiplier
	var move_vector = Vector2(horizontal_input, vertical_input)
	
	animation_tree.set("parameters/Locomotion/blend_position", move_vector)

func _physics_process(delta: float) -> void:		
	set_quaternion(get_quaternion() * animation_tree.get_root_motion_rotation())
	velocity = (animation_tree.get_root_motion_rotation_accumulator().inverse() * get_quaternion()) * animation_tree.get_root_motion_position() / delta
	
	velocity.y -= 40 * delta
	
	move_and_slide()
