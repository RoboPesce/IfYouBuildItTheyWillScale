class_name BlockManager
extends Node3D

# 3D array of all blocks in scene
# block_array[level][row][column]
var block_array : Array

var current_piece : Piece = null

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
	# handle piece moving downward
	if (current_piece):
		handle_piece_fall()
	else: # create new piece
		pass

	var component_roots : Array[BaseBlock]
	# iterate through blocks/levels bottom up, skipping the first row
	for level in range(1, Global.MAX_BLOCK_HEIGHT):
		for row in range(Global.BLOCKS_PER_SIDE):
			for col in range(Global.BLOCKS_PER_SIDE):
				var block : BaseBlock = block_array[level][row][col]
				if block == null: continue
				# piece already handled separately
				if (block.piece): continue
				if (block.last_update == current_update): continue
				
				component_roots.append(block)
				propagate_component_and_update(block, block)
	
	# find how far each component needs to drop
	for component in component_roots:
		pass

func handle_piece_fall() -> void:
	var can_drop : bool = true
	for block : BaseBlock in current_piece.blocks:
		if (block.level == 0):
			can_drop = false
			break
		var next_block = get_first_block_below(block)
		if (next_block and (not next_block.piece == block.piece) and (next_block.level == block.level - 1)):
			can_drop = false
			break
	
	if (can_drop): # lower blocks by 1
		for block : BaseBlock in current_piece.blocks:
			block_array[block.level][block.row][block.col] = null
			block.level -= 1
		for block : BaseBlock in current_piece.blocks: block_array[block.level][block.row][block.col] = block
	else: # dissolve piece grouping, blocks become part of tower
		for block : BaseBlock in current_piece.blocks:
			block.parent_piece = null
		current_piece = null

# propagate remaining blocks
func propagate_component_and_update(block : BaseBlock, root : BaseBlock) -> void:
	# propagate in 6 directions
	if (block == null
		or block.piece
		or block.last_update == current_update): 
			return
	block.component_root = root
	block.last_update = current_update
	
	var not_both_ladder: bool = (block.type == BaseBlock.BlockType.LADDER) != (root.type == BaseBlock.BlockType.LADDER)
	
	# ladders form their own components unless on the ground, so skip these if looking to the side
	# ladders can look down for non-ladder components and non-ladders can look up
	if block.level > 1: propagate_component_and_update(block_array[block.level-1][block.row][block.col], root)
	if block.level < Global.MAX_BLOCK_HEIGHT: propagate_component_and_update(block_array[block.level+1][block.row][block.col], root)
	if not_both_ladder: return
	if block.row > 0: propagate_component_and_update(block_array[block.level][block.row-1][block.col], root)
	if block.row < Global.BLOCKS_PER_SIDE - 1: propagate_component_and_update(block_array[block.level][block.row+1][block.col], root)
	if block.col > 0: propagate_component_and_update(block_array[block.level][block.row][block.col-1], root)
	if block.col < Global.BLOCKS_PER_SIDE - 1: propagate_component_and_update(block_array[block.level][block.row][block.col+1], root)

# returns null if no block found, or if the block is part of this block's component
func get_first_block_below(block : BaseBlock) -> BaseBlock:
	var iter_level : int = block.level
	while(iter_level > 1):
		iter_level -= 1
		var found_block : BaseBlock = block_array[iter_level][block.row][block.col]
		if (found_block): 
			if found_block.component_root == block.component_root: return null 
			return found_block
	return null
