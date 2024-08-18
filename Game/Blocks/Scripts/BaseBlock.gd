class_name BaseBlock
extends CharacterBody3D

enum BlockType { WOOD, STONE, LADDER }

@export var type : BlockType

var level : int = -1
var row : int
var col : int
var parent_piece : Piece

# first block found in this connected component
var component_root : BaseBlock
var last_update : int = 0

func _process(delta : float) -> void:
	pass
