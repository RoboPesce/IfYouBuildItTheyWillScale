class_name BlockManager
extends Node3D

const BlockContructors = [preload("res://Game/Blocks/Scenes/WoodBlock.tscn"),
						 preload("res://Game/Blocks/Scenes/StoneBlock.tscn"),
						 preload("res://Game/Blocks/Scenes/LadderBlock.tscn")]

# 3D array of all blocks in scene
# block_array[level][row][column]
var block_array : Array = Array()

var current_piece : Piece = null
var component_roots : Array[BaseBlock]

# Block fall timer
var BlockFallTimer : float = 0
var FallTime : float = 2.0
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
	
	# TESTING
	add_child(construct_block(0, 0, 0, BaseBlock.BlockType.STONE, "stone0"))
	add_child(construct_block(1, 0, 0, BaseBlock.BlockType.WOOD, "wood1"))
	add_child(construct_block(4, 0, 0, BaseBlock.BlockType.STONE, "stone4"))
	add_child(construct_block(5, 0, 0, BaseBlock.BlockType.STONE, "stone5"))
	add_child(construct_block(0, 1, 0, BaseBlock.BlockType.LADDER, "ladder0"))
	add_child(construct_block(1, 1, 0, BaseBlock.BlockType.LADDER, "ladder1"))
	add_child(construct_block(0, 4, 3, BaseBlock.BlockType.STONE, "stone2"))
	add_child(construct_block(0, 4, 4, BaseBlock.BlockType.STONE, "stone3"))

func _process(delta : float) -> void:
	BlockFallTimer += delta
	if (BlockFallTimer >= FallTime):
		BlockFallTimer = 0
		current_update += 1
		update_blocks()

# 1. Move the current piece downward. If not possible, relinquish control
#    over its blocks and delete it.
#    TODO: If there is no current piece, create a new one.
# 2. Iterate through all non-piece blocks from the bottom up. When a block is
#    encountered, if not previously encountered this update, create a new component.
#    Find all connected blocks (with some rules for ladders) and keep track of them.
# 3. Find how far each component should fall, then update each block's position in that component
func update_blocks() -> void:
	# handle piece moving downward
	if (current_piece):
		handle_piece_fall()
	else: # create new piece
		pass

	component_roots.clear()
	# iterate through blocks/levels bottom up
	for level in range(Global.MAX_BLOCK_HEIGHT):
		for row in range(Global.BLOCKS_PER_SIDE):
			for col in range(Global.BLOCKS_PER_SIDE):
				var block : BaseBlock = block_array[level][row][col]
				if (block == null
					or block.parent_piece
					or block.last_update == current_update): 
						continue
				
				component_roots.append(block)
				block.component_blocks.clear()
				propagate_component_and_update(block, block)
	
	# find how far each component needs to drop
	for root in component_roots:
		root.drop_distance = Global.MAX_BLOCK_HEIGHT
		for block in root.component_blocks:
			if (block.level == 0): 
				root.drop_distance = 0
				break
			var below_block : BaseBlock = get_first_block_below(block)
			var dist : int = (block.level - below_block.level - 1) if below_block else block.level
			if (dist < root.drop_distance): root.drop_distance = dist
	
	# set new positions
	for root in component_roots:
		for block in root.component_blocks:
			if (block_array[block.level][block.row][block.col] == block): block_array[block.level][block.row][block.col] = null
			block.level -= root.drop_distance
			block_array[block.level][block.row][block.col] = block

	# TESTING
	print("Update: ", current_update)
	for root in component_roots:
		print(" Root: ", root.name)
		print(" Drop distance: ", root.drop_distance)
		var blocks : String = ""
		for block in root.component_blocks:
			blocks += ' ' + block.name
		print(" Blocks:", blocks, '\n')
	print()

func handle_piece_fall() -> void:
	var can_drop : bool = true
	for block : BaseBlock in current_piece.blocks:
		if (block.level == 0):
			can_drop = false
			break
		var next_block = get_first_block_below(block)
		if (next_block and (not next_block.parent_piece == block.parent_piece) and (next_block.level == block.level - 1)):
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

# find all blocks in the connected component of the root block and update references
func propagate_component_and_update(block : BaseBlock, root : BaseBlock) -> void:
	# propagate in 6 directions
	if (block.parent_piece or block.last_update == current_update): return
	block.component_root = root
	block.last_update = current_update
	root.component_blocks.append(block)
	
	# ladders can only look up at other ladders
	# non-ladder blocks can only look at ladders if they are up
	# ladders cannot look to the sides
	var next_block : BaseBlock
	if block.level > 1:
		next_block = block_array[block.level-1][block.row][block.col]
		if next_block and (block.is_ladder() or !next_block.is_ladder()): propagate_component_and_update(next_block, root)
	if block.level < Global.MAX_BLOCK_HEIGHT:
		next_block = block_array[block.level+1][block.row][block.col]
		if next_block and (!block.is_ladder() or next_block.is_ladder()): propagate_component_and_update(next_block, root)
	if (block.is_ladder()): return
	if block.row > 0: 
		next_block = block_array[block.level][block.row-1][block.col]
		if next_block and (!next_block.is_ladder()): propagate_component_and_update(next_block, root)
	if block.row < Global.BLOCKS_PER_SIDE - 1: 
		next_block = block_array[block.level][block.row+1][block.col]
		if next_block and (!next_block.is_ladder()): propagate_component_and_update(next_block, root)
	if block.col > 0: 
		next_block = block_array[block.level][block.row][block.col-1]
		if next_block and (!next_block.is_ladder()): propagate_component_and_update(next_block, root)
	if block.col < Global.BLOCKS_PER_SIDE - 1: 
		next_block = block_array[block.level][block.row][block.col+1]
		if next_block and (!next_block.is_ladder()): propagate_component_and_update(next_block, root)

# returns null if no block found, or if the block is part of this block's component
func get_first_block_below(block : BaseBlock) -> BaseBlock:
	var iter_level : int = block.level
	while(iter_level > 1):
		iter_level -= 1
		var found_block : BaseBlock = block_array[iter_level][block.row][block.col]
		if (found_block): return found_block if found_block.component_root != block.component_root else null
	return null

func construct_block(level : int, row : int, col : int, type : BaseBlock.BlockType, _name : String = "") -> BaseBlock:
	if block_array[level][row][col]: return null
	var block = BlockContructors[type].instantiate()
	block.level = level
	block.row = row
	block.col = col
	block_array[level][row][col] = block
	block.name = _name
	# level is the y-coordinate
	block.transform.origin = Vector3(row, level, col)
	return block
	
	
