extends Node

signal MoveCameraUp
signal MoveCameraDown
signal SlamPiece
signal SoftSlamPiece
signal ReleaseSoftSlamPiece
signal MoveForward
signal MoveBackward
signal MoveLeft
signal MoveRight
signal RotateClockwise
signal RotateCounterclockwise

var b_drag_mouse : bool
var delta_mouse : Vector2 = Vector2.ZERO
var last_mouse_pos : Vector2

func _process(delta : float) -> void:
	if (b_drag_mouse):
		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		delta_mouse = mouse_pos - last_mouse_pos
		last_mouse_pos = mouse_pos

func _input(event : InputEvent) -> void:
	if (event.is_action_pressed("MoveCameraUp")): MoveCameraUp.emit()
	elif (event.is_action_pressed("MoveCameraDown")): MoveCameraDown.emit()
	elif (event.is_action_pressed("SlamPiece")): SlamPiece.emit()
	elif (event.is_action_pressed("SoftSlamPiece")): SoftSlamPiece.emit()
	elif (event.is_action_released("SoftSlamPiece")): ReleaseSoftSlamPiece.emit()
	elif (event.is_action_pressed("MoveForward")): MoveForward.emit()
	elif (event.is_action_pressed("MoveBackward")): MoveBackward.emit()
	elif (event.is_action_pressed("MoveLeft")): MoveLeft.emit()
	elif (event.is_action_pressed("MoveRight")): MoveRight.emit()
	elif (event.is_action_pressed("RotateClockwise")): RotateClockwise.emit()
	elif (event.is_action_pressed("RotateCounterclockwise")): RotateCounterclockwise.emit()
	
	elif (event.is_action_pressed("MouseDrag")): 
		b_drag_mouse = true
		last_mouse_pos = get_viewport().get_mouse_position()
	elif (event.is_action_released("MouseDrag")): b_drag_mouse = false
