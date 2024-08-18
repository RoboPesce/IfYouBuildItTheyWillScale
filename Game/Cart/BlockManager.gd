class_name BlockManager
extends Node3D

# 3D array of all blocks in scene
# BlockArray[level][row][column]
var BlockArray : Array

# Block fall timer
var BlockFallTimer : float = 0
var FallTime : float = 1.0
var update : int = 1

func _ready() -> void:
	# initialize block array
	BlockArray.resize(Global.MAX_BLOCK_HEIGHT)
	var TempArray : Array = Array()
	TempArray.resize(Global.BLOCKS_PER_SIDE)
	var TempArrayNested : Array = Array()
	TempArrayNested.resize(Global.BLOCKS_PER_SIDE)
	TempArray.fill(TempArrayNested)
	BlockArray.fill(TempArray)

func _process(delta: float) -> void:
	BlockFallTimer += delta
	if (BlockFallTimer >= FallTime):
		BlockFallTimer = 0
		
		for Level in BlockArray:
			var empty_row = true
			for Row in Level:
				for Block in Row:
					if Block == null: continue
					
