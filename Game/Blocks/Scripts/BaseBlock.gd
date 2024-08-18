class_name BaseBlock
extends CharacterBody3D

var level : int
var row : int
var col : int
var parent_piece : Piece

# first block found in this connected component
var component_root : BaseBlock
var last_update : int = 0

func _process(delta : float) -> void:
	pass
