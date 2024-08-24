extends Node

# Each index is an array which represents a piece definition.
# Each array's length should be a multiple of 4, where every
# group of 4 elements starts with a block type, then a relative
# offset (in layer, row, col order) to the pivot block of the
# piece. The pivot should have an offset of 0, 0, 0.
var piece_definitions : Array = Array()
# Index of the next piece to return. When maxed out,
# shuffle the array and reset
var cur_piece : int = 0

func _init() -> void:
	# Stone Wall
	piece_definitions.append([ 
		BaseBlock.BlockType.STONE, 0, 0, 0,
		BaseBlock.BlockType.STONE, 1, 0, 0,
		BaseBlock.BlockType.STONE, 0, 1, 0,
		BaseBlock.BlockType.STONE, 1, 1, 0 
	])
	# Ladder Cross
	piece_definitions.append([
		BaseBlock.BlockType.LADDER, 0, 0, 0,
		BaseBlock.BlockType.LADDER, 1, 0, 0,
		BaseBlock.BlockType.LADDER, -1, 0, 0,
		BaseBlock.BlockType.WOOD, 0, 1, 0,
		BaseBlock.BlockType.WOOD, 0, -1, 0
	])
	# Wooden Stair
	piece_definitions.append([
		BaseBlock.BlockType.WOOD, 0, 0, 0,
		BaseBlock.BlockType.WOOD, -1, 0, 0,
		BaseBlock.BlockType.WOOD, 0, 1, 0,
		BaseBlock.BlockType.WOOD, 1, 1, 0,
		BaseBlock.BlockType.WOOD, -1, 1, 0,
		BaseBlock.BlockType.WOOD, -1, -1, 0
	])
	# Tall Ladder
	piece_definitions.append([
		BaseBlock.BlockType.LADDER, 0, 0, 0,
		BaseBlock.BlockType.LADDER, -1, 0, 0,
		BaseBlock.BlockType.LADDER, -2, 0, 0,
		BaseBlock.BlockType.LADDER, 1, 0, 0,
		BaseBlock.BlockType.LADDER, 2, 0, 0
	])
	piece_definitions.shuffle()

func get_new_piece_definition() -> Array:
	if cur_piece >= piece_definitions.size():
		piece_definitions.shuffle()
		cur_piece = 0
	var def = piece_definitions[cur_piece]
	cur_piece += 1
	return def
