extends Node3D

var rotational_velocity : float = 0
@export var camera_rotational_speed_multiplier : float

var target_camera_position : int = 0
@export var max_camera_vertical_speed : float = 5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float) -> void:
	if (Global.b_drag_mouse): rotational_velocity = -Global.delta_mouse.x * camera_rotational_speed_multiplier
	else: rotational_velocity = Global.FrameIndependentDamping(rotational_velocity, 0.0, 0.07, delta)
	rotate_y(rotational_velocity * delta)
	
	position.y = Global.FrameIndependentDamping(position.y, float(target_camera_position), 0.05, delta)

func _input(event : InputEvent) -> void:
	#if (event.is_action_pressed("RotateCameraLeft")): rotational_velocity = -max_rotational_velocity
	#elif (event.is_action_pressed("RotateCameraRight")): rotational_velocity = max_rotational_velocity
	
	if (event.is_action_pressed("MoveCameraUp")):
		if (target_camera_position < Global.MAX_BLOCK_HEIGHT): target_camera_position += 1
	elif (event.is_action_pressed("MoveCameraDown")):
		if (target_camera_position > 0): target_camera_position -= 1
