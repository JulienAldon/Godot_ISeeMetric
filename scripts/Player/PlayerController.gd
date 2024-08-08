extends Node2D

@export var current_controller: Controller
@export var gui: Control
var spawn: Vector2
var color: Color
var player_id: int
var player_name: String

func set_spawn(pos):
	spawn = pos
	position = pos

func set_player_id(id: int):
	player_id = id
	name = str(id)

func set_player_color(_color: Color):
	color = _color
	
func set_player_name(value):
	player_name = value

func _ready():
	var suffix = " (client)"
	if player_id == 1:
		suffix = " (host)"
	gui.set_player_name(str(player_name) + suffix)

func _process(_delta):
	pass
