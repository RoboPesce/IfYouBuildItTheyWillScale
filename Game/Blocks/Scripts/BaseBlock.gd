class_name BaseBlock
extends CharacterBody3D

# Position[level][row][column]
var target_position : Vector3
var parent_piece : Piece

# first block found in this connected component
var component_root : BaseBlock
var last_update : int = 0

func _process(delta: float) -> void:
	pass
