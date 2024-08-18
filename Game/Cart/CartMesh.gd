extends Node3D

var wheels : Array[MeshInstance3D]

var wheel_velocity : float = 0

func _ready() -> void:
	wheels = [ $Wheel1, $Wheel2, $Wheel3, $Wheel4 ]

func _process(delta : float) -> void:
	if (wheel_velocity != 0):
		for wheel : MeshInstance3D in wheels:
			wheel.rotate_z(wheel_velocity * delta)

func set_wheel_velocity(vel : float) -> void:
	wheel_velocity = vel
