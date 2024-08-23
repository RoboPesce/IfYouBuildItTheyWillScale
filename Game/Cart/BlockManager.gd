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
@export var base_update_time : float
@export var soft_slam_update_time : float
var block_update_timer : float = 0
var update_time : float
var current_update : int = 0

func _ready() -> void:
	update_time = base_update_time
	# initialize block array
	block_array.resize(Global.MAX_BLOCK_HEIGHT)
	for level : int in range(Global.MAX_BLOCK_HEIGHT):
		block_array[level] = Array()
		block_array[level].resize(Global.BLOCKS_PER_SIDE)
		for row in range(Global.BLOCKS_PER_SIDE):
			block_array[level][row] = Array()
			block_array[level][row].resize(Global.BLOCKS_PER_SIDE)
			block_array[level][row].fill(null)
	
	# bind input callbacks
	InputManager.SlamBlock.connect(slam_block)
	InputManager.SoftSlamBlock.connect(soft_slam_block.bind(true))
	InputManager.ReleaseSoftSlamBlock.connect(soft_slam_block.bind(false))
	InputManager.MoveForward.connect(translate_piece.bind(0, -1, 0))
	InputManager.MoveBackward.connect(translate_piece.bind(0, 1, 0))
	InputManager.MoveLeft.connect(translate_piece.bind(0, 0, 1))
	InputManager.MoveRight.connect(translate_piece.bind(0, 0, -1))
	InputManager.RotateClockwise.connect(rotate_piece.bind(true))
	InputManager.RotateCounterclockwise.connect(rotate_piece.bind(false))
	
	# TESTING
	construct_block(0, 0, 0, BaseBlock.BlockType.STONE, "stone0")
	construct_block(1, 0, 0, BaseBlock.BlockType.WOOD, "wood1")
	construct_block(4, 0, 0, BaseBlock.BlockType.STONE, "stone4")
	construct_block(5, 0, 0, BaseBlock.BlockType.STONE, "stone5")
	construct_block(5, 1, 0, BaseBlock.BlockType.WOOD, "wood2")
	construct_block(0, 1, 0, BaseBlock.BlockType.LADDER, "ladder0")
	construct_block(1, 1, 0, BaseBlock.BlockType.LADDER, "ladder1")
	construct_block(1, 2, 0, BaseBlock.BlockType.LADDER, "ladder3")
	construct_block(0, 4, 3, BaseBlock.BlockType.STONE, "stone2")
	construct_block(0, 4, 4, BaseBlock.BlockType.STONE, "stone3")
	construct_block(1, 4, 4, BaseBlock.BlockType.LADDER, "ladder4")
	current_piece = Piece.new()
	current_piece.blocks.append(construct_block(5, 2, 2, BaseBlock.BlockType.LADDER, "ladder01"))
	current_piece.blocks.append(construct_block(6, 2, 2, BaseBlock.BlockType.LADDER, "ladder02"))
	current_piece.blocks.append(construct_block(7, 2, 2, BaseBlock.BlockType.LADDER, "ladder03"))
	current_piece.blocks.append(construct_block(6, 3, 2, BaseBlock.BlockType.WOOD, "wood01"))
	current_piece.blocks.append(construct_block(6, 1, 2, BaseBlock.BlockType.WOOD, "wood02"))
	for block in current_piece.blocks:
		block.parent_piece = current_piece
	current_piece.pivot = current_piece.blocks[1]

func _process(delta : float) -> void:
	block_update_timer += delta
	if (block_update_timer >= update_time):
		block_update_timer = 0
		current_update += 1
		print("Invoking block update ", current_update)
		update_blocks()
		
		# TESTING
		#print("Update: ", current_update)
		#for root in component_roots:
			#print(" Root: ", root.name)
			#print(" Drop distance: ", root.drop_distance)
			#var blocks : String = ""
			#for block in root.component_blocks:
				#blocks += ' ' + block.name
			#print(" Blocks:", blocks, '\n')
		#print()

func slam_block() -> void:
	if (current_piece):
		current_piece.dissolve_piece()
		current_piece = null
		block_update_timer = update_time

func soft_slam_block(b_active : bool) -> void:
	update_time = soft_slam_update_time if b_active else base_update_time

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
			reposition_block(block, block.level - root.drop_distance, block.row, block.col)

func handle_piece_fall() -> void:
	var b_can_drop : bool = true
	for block : BaseBlock in current_piece.blocks:
		if (block.level == 0):
			b_can_drop = false
			break
		var next_block = get_first_block_below(block)
		if (next_block
		  and (not next_block.parent_piece == block.parent_piece)
		  and (next_block.level == block.level - 1)):
			b_can_drop = false
			break
	
	if (b_can_drop): # lower blocks by 1
		for block : BaseBlock in current_piece.blocks:
			reposition_block(block, block.level - 1, block.row, block.col)
	else: # dissolve piece grouping, blocks become part of tower
		current_piece.dissolve_piece()
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
	if block.level < Global.MAX_BLOCK_HEIGHT - 1:
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
		if (found_block): 
			return (found_block
			  if found_block.component_root != block.component_root
			  or found_block.parent_piece != block.parent_piece
				else null)
	return null

func construct_block(level : int, row : int, col : int, type : BaseBlock.BlockType, _name : String = "") -> BaseBlock:
	# if block_array[level][row][col]: return null
	var block = BlockContructors[type].instantiate()
	block.level = level
	block.row = row
	block.col = col
	block_array[level][row][col] = block
	block.name = _name
	# level is the y-coordinate
	block.transform.origin = Vector3(row, level, col)
	add_child(block)
	return block

func reposition_block(block : BaseBlock, level : int, row : int, col : int):
	# if block_array[level][row][col]: return null
	if (block_array[block.level][block.row][block.col] == block): block_array[block.level][block.row][block.col] = null
	block.level = level
	block.row = row
	block.col = col
	block_array[block.level][block.row][block.col] = block

# repositions and teleports all blocks in the current piece if possible
# returns false if translation fails
func translate_piece(d_level : int, d_row : int, d_col : int) -> bool:
	if (!current_piece): return false
	# verify the translation is valid
	for block in current_piece.blocks:
		var n_level : int = block.level + d_level
		var n_row : int = block.row + d_row
		var n_col : int = block.col + d_col
		if (not valid_index(n_level, n_row, n_col)
		  or (block_array[n_level][n_row][n_col] and block_array[n_level][n_row][n_col].parent_piece != block.parent_piece)):
			return false

	for block in current_piece.blocks:
		reposition_block(block, block.level + d_level, block.row + d_row, block.col + d_col)
		block.position += Vector3(d_row, d_level, d_col)
	return true

# repositions and teleports all blocks in the current piece if possible
# returns false if rotation fails
# @param b_left: if true, rotates clockwise; else rotates counterclockwise
func rotate_piece(b_clockwise : bool) -> bool:
	if (!current_piece): return false
	# verify the rotation is valid
	for block in current_piece.blocks:
		var d_row : int = block.row - current_piece.pivot.row
		var d_col : int = block.col - current_piece.pivot.col
		var n_row : int = current_piece.pivot.row + (-d_col if b_clockwise else d_col)
		var n_col : int = current_piece.pivot.col + (d_row if b_clockwise else -d_row)
		if (!valid_index(block.level, n_row, n_col)
		  or (block_array[block.level][n_row][n_col] and block_array[block.level][n_row][n_col].parent_piece != block.parent_piece)):
			return false

	for block in current_piece.blocks:
		var d_row : int = block.row - current_piece.pivot.row
		var d_col : int = block.col - current_piece.pivot.col
		var n_row : int = current_piece.pivot.row + (-d_col if b_clockwise else d_col)
		var n_col : int = current_piece.pivot.col + (d_row if b_clockwise else -d_row)
		reposition_block(block, block.level, n_row, n_col)
		block.position = Vector3(n_row, block.level, n_col)
		pass 
	return true

func valid_index(level : int, row : int, col : int) -> bool:
	return (level >= 0 and level < Global.MAX_BLOCK_HEIGHT
			and row >= 0 and row < Global.BLOCKS_PER_SIDE
			and col >= 0 and col < Global.BLOCKS_PER_SIDE)
