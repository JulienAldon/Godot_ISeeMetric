extends Node2D
class_name NetworkComponent

var controlled_by: int = 1

func set_authority(player):
	controlled_by = player

func is_authority():
	if multiplayer:
		return multiplayer.get_unique_id() == 1
	return false

func has_ownership():
	return multiplayer.get_unique_id() == controlled_by
