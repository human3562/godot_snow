extends CharacterBody3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var camera_mounting_point: Node3D = $camera_mounting_point
@onready var camera_mount: Node3D = $camera_mounting_point/camera_mount

@export var mouse_sens = 0.005
const CAMERA_MAX_PITCH: float = deg_to_rad(70)
const CAMERA_MIN_PITCH: float = deg_to_rad(-89.9)
const CAMERA_RATIO: float = .625

@export var movement_smoothing = 10
var desired_move_vector = Vector2()
var current_move_vector = Vector2()

var current_player_rotation = 0.0;

var idling_time = 0.0;

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera_mount.rotation.y -= event.relative.x * mouse_sens
		camera_mount.rotation.x += event.relative.y * mouse_sens * CAMERA_RATIO 
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, CAMERA_MIN_PITCH, CAMERA_MAX_PITCH)
	
	get_viewport().set_input_as_handled()
		#rotate_y(-event.relative.x * mouse_sens)
		#camera_mount.rotate_x(event.relative.y * mouse_sens)

func _process(delta: float) -> void:
	camera_mount.position = camera_mounting_point.global_position
	
	var sprint_mul = 1.0 if Input.is_action_pressed("sprint") else 0.5
	
	var horizontal_input = -Input.get_axis("move_right", "move_left")
	var vertical_input = Input.get_axis("move_backward", "move_forward")
	var move_vector = Vector2(horizontal_input, vertical_input)
	if move_vector.length() > 1:
		move_vector = move_vector.normalized()
	
	if move_vector.length() == 0:
		idling_time += delta
	else: 
		idling_time = 0
		animation_tree.set("parameters/Locomotion/0/Transition/transition_request", "idle01")
		rotation.y = rotate_toward(rotation.y, camera_mount.rotation.y, delta * 10)
		# rotate_y(camera_mount.rotation.y * 0.5)
		
		
	
	desired_move_vector = move_vector * sprint_mul
	current_move_vector = lerp(current_move_vector, desired_move_vector, delta * movement_smoothing)
	
	animation_tree.set("parameters/Locomotion/blend_position", current_move_vector)
	
	if idling_time > 10 and animation_tree.get("parameters/Locomotion/0/Transition/current_state") == "idle01":
		animation_tree.set("parameters/Locomotion/0/Transition/transition_request", "idle01-to-idle02")

func _physics_process(delta: float) -> void:		
	set_quaternion(get_quaternion() * animation_tree.get_root_motion_rotation())
	velocity = (animation_tree.get_root_motion_rotation_accumulator().inverse() * get_quaternion()) * animation_tree.get_root_motion_position() / delta
	
	velocity.y -= 40 * delta
	
	move_and_slide()
