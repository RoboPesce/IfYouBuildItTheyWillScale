extends Node3D

var rotational_velocity : float = 0
@export var max_rotational_velocity : float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rotational_velocity *= 0.93

	rotate_y(rotational_velocity * delta)

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("RotateCameraLeft")): rotational_velocity = max_rotational_velocity
	elif (event.is_action_pressed("RotateCameraRight")): rotational_velocity = -max_rotational_velocity
