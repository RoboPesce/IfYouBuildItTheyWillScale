extends Node3D

var Wheels : Array[MeshInstance3D]

var wheel_velocity : float = 5

func _ready() -> void:
	Wheels = [ $Wheel1, $Wheel2, $Wheel3, $Wheel4 ]

func _process(delta: float) -> void:
	if (wheel_velocity != 0):
		for wheel in Wheels:
			wheel.rotate_z(wheel_velocity * delta)

func set_wheel_velocity(vel : float) -> void:
	wheel_velocity = vel
