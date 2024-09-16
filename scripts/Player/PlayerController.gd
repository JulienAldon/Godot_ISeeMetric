extends Node2D

@export var experience: int = 0
@export var level: int = 0
@export var max_level: int = 20
@export var level_threshold: int = 300
@export var level_scaling: int = 1

@export var current_controller: Controller
@export var gui: Control
var spawn: Vector2
var color: Color
var player_id: int
var player_name: String
var spawner_path: String

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

func _enter_tree():
	set_multiplayer_authority(player_id)

func _ready():
	var suffix = " (client)"
	if player_id == 1:
		suffix = " (host)"
	gui.set_player_name(str(player_name) + suffix)

@rpc("any_peer", "call_local")
func set_experience(value):
	experience += value
	on_experience_changed()

func open_hub_inventory():
	pass

func on_experience_changed():
	if is_multiplayer_authority():
		var current_level = experience / level_threshold
		level = current_level
		gui.set_player_level(level)
	
func _process(_delta):
	pass

