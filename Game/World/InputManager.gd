extends Node

signal SlamBlock
signal SoftSlamBlock
signal ReleaseSoftSlamBlock
signal MoveForward
signal MoveBackward
signal MoveLeft
signal MoveRight
signal RotateClockwise
signal RotateCounterclockwise

func _input(event : InputEvent) -> void:
	if (event.is_action_pressed("SlamBlock")): SlamBlock.emit()
	elif (event.is_action_pressed("SoftSlamBlock")): SoftSlamBlock.emit()
	elif (event.is_action_released("SoftSlamBlock")): ReleaseSoftSlamBlock.emit()
	elif (event.is_action_pressed("MoveForward")): MoveForward.emit()
	elif (event.is_action_pressed("MoveBackward")): MoveBackward.emit()
	elif (event.is_action_pressed("MoveLeft")): MoveLeft.emit()
	elif (event.is_action_pressed("MoveRight")): MoveRight.emit()
	elif (event.is_action_pressed("RotateClockwise")): RotateClockwise.emit()
	elif (event.is_action_pressed("RotateCounterclockwise")): RotateCounterclockwise.emit()
