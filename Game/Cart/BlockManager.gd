class_name BlockManager
extends Node3D

# 3D array of all blocks in scene
# block_array[level][row][column]
var block_array : Array

# Block fall timer
var BlockFallTimer : float = 0
var FallTime : float = 1.0
var current_update : int = 0

func _ready() -> void:
	# initialize block array
	block_array.resize(Global.MAX_BLOCK_HEIGHT)
	for level : int in range(Global.MAX_BLOCK_HEIGHT):
		block_array[level] = Array()
		block_array[level].resize(Global.BLOCKS_PER_SIDE)
		for row in range(Global.BLOCKS_PER_SIDE):
			block_array[level][row] = Array()
			block_array[level][row].resize(Global.BLOCKS_PER_SIDE)
			block_array[level][row].fill(null)

func _process(delta : float) -> void:
	BlockFallTimer += delta
	if (BlockFallTimer >= FallTime):
		BlockFallTimer = 0
		current_update += 1
		handle_block_fall()

func handle_block_fall() -> void:
	# iterate through blocks/levels bottom up, skipping the first row
	for level in range(1, Global.MAX_BLOCK_HEIGHT):
		var empty_row = true
		for row in range(Global.BLOCKS_PER_SIDE):
			for col in range(Global.BLOCKS_PER_SIDE):
				var block : BaseBlock = block_array[level][row][col]
				if block == null: continue
				empty_row = false
				propagate_component_and_update(block, block)

func propagate_component_and_update(block : BaseBlock, root : BaseBlock) -> void:
	# propagate in 6 directions
	if (block == null): return
	if (block.last_update == current_update): return
	block.component_root = root
	block.last_update = current_update
	
	if block.col > 0: propagate_component_and_update(block_array[block.level][block.row][block.col-1], root)
	if block.col < Global.BLOCKS_PER_SIDE - 1: propagate_component_and_update(block_array[block.level][block.row][block.col+1], root)
	if block.row > 0: propagate_component_and_update(block_array[block.level][block.row-1][block.col], root)
	if block.row < Global.BLOCKS_PER_SIDE - 1: propagate_component_and_update(block_array[block.level][block.row+1][block.col], root)
	if block.level > 1: propagate_component_and_update(block_array[block.level-1][block.row][block.col], root)
	if block.level < Global.MAX_BLOCK_HEIGHT: propagate_component_and_update(block_array[block.level+1][block.row][block.col], root)

# returns null if no block found, or if the block is part of this block's component
func get_first_block_below(block : BaseBlock) -> BaseBlock:
	var iter_level : int = block.level - 1
	while(iter_level > 1):
		var found_block : BaseBlock = block_array[iter_level][block.row][block.col]
		if (found_block != null): 
			if found_block.component_root == block.component_root: return null 
			return found_block
	return null
