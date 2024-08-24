extends Node3D

func _ready() -> void:
	$BlockManager.SpawnedNewPiece.connect($CameraRoot.change_target_camera_position)
