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

# used by root
var component_blocks : Array[BaseBlock] = Array()
var drop_distance : int

func _process(delta : float) -> void:
	pass

func is_ladder() -> bool:
	return type == BlockType.LADDER
