extends Node2D

var player_id
var tilemap

func set_tilemap(value):
	tilemap = value

func set_player_id(value):
	player_id = value

func set_player_name(value):
	name = value
# Called when the node enters the scene tree for the first time.
func _ready():
	$RtsController.name = str(player_id)
	$RtsUI.set_player_name(str(name))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
