extends Node2D
class_name NetworkComponent

var controlled_by: int = 1

func set_authority(player):
	controlled_by = player
