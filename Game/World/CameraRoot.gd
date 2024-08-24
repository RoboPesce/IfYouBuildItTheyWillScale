extends Node3D

var rotational_velocity : float = 0
@export var camera_rotational_speed_multiplier : float

var target_camera_position : int = 7
@export var max_camera_vertical_speed : float = 5

func _ready() -> void:
	# bind input callbacks
	InputManager.MoveCameraUp.connect(change_target_camera_position.bind(1))
	InputManager.MoveCameraDown.connect(change_target_camera_position.bind(-1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float) -> void:
	if (InputManager.b_drag_mouse): rotational_velocity = -InputManager.delta_mouse.x * camera_rotational_speed_multiplier
	else: rotational_velocity = Global.FrameIndependentDamping(rotational_velocity, 0.0, 0.07, delta)
	rotate_y(rotational_velocity * delta)
	
	position.y = Global.FrameIndependentDamping(position.y, float(target_camera_position), 0.05, delta)

func change_target_camera_position(change : int) -> void:
	target_camera_position = clamp(target_camera_position + change, 0, Global.MAX_BLOCK_HEIGHT)
