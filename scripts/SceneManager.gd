extends Node2D

# Called when the node enters the scene tree for the first time.

@export var spawns: Node2D
@export var king_spawns: Node2D

@export var tilemap: TileMap
@export var king_initial_units: Array[GameManager.KingUnits]

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE	

func _process(_delta):
	pass
