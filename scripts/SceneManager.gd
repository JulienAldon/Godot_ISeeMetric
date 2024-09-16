extends Node2D

@export var tilemap: TileMap
@export var spawns: Node2D
@export var entity_spawns: Node2D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(_delta):
	pass
