class_name BlockManager
extends Node3D

# 3D array of all blocks in scene
# BlockArray[level][row][column]
var BlockArray

# Block fall timer
var BlockFallTimer : float = 0
var FallTime : float = 1.0

func _ready() -> void:
	# initialize block array
	BlockArray = Array[Global.MAX_BLOCK_HEIGHT].fill(
		Array[5].fill(
			Array[5].fill(null)
		)
	)

func _process(delta: float) -> void:
	BlockFallTimer += delta
	if (BlockFallTimer >= FallTime):
		BlockFallTimer = 0
		
		for Level in BlockArray:
			var empty_row = true
			for Row in Level:
				for Block in Row:
					if Block == null: continue
					
