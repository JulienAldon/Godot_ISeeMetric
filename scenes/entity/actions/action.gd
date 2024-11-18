extends Node2D
class_name Action

@export var title: String
@export var icon: CompressedTexture2D
@export var cooldown: Timer
@export var time: Timer
@export var cost: Array[YieldResource]
@export var description: String
var start_position: Vector2

signal ActionFinished

func get_progression():
	if time.time_left == 0:
		return 0
	return time.wait_time - time.time_left
