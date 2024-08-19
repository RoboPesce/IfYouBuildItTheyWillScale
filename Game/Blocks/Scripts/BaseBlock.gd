class_name BaseBlock
extends CharacterBody3D

enum BlockType { WOOD=0, STONE=1, LADDER=2 }

@export var type : BlockType

# Positioning
# note that Vector3(row, level, col) gives 3D position
var level : int = -1
var row : int
var col : int
var parent_piece : Piece

# Physics
static var gravity : float = 1

# first block found in this connected component
var component_root : BaseBlock
var last_update : int = 0

# used by root, only access through root
var component_blocks : Array[BaseBlock]
var drop_distance : int

func _physics_process(delta : float) -> void:
	if (!component_root and !parent_piece): return
	
	# assumption: blocks only fall downward
	# check if we will arrive to our spot next frame, if so just teleport there
	if (position.y - level > -velocity.y * delta):
		var dist : float = component_root.drop_distance if component_root else 1
		velocity.y -= dist * gravity * delta
		move_and_collide(velocity)
	else:
		velocity = Vector3.ZERO
		move_and_collide(Vector3(row, level, col) - position)

func is_ladder() -> bool:
	return type == BlockType.LADDER
