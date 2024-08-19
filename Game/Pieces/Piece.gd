class_name Piece

var blocks : Array[BaseBlock]

func dissolve_piece() -> void:
	for block in blocks: block.parent_piece = null
