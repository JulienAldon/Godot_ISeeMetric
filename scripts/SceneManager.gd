extends Node2D

@export var tilemap: TileMapLayer
@export var spawns: Node2D
@export var outpost_container: Node2D
var outposts: Array = []

func get_tilemap():
	return tilemap

func get_outposts():
	return outposts

func _ready():
	outposts = outpost_container.get_children()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(_delta):
	pass
