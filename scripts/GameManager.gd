extends Node2D

const Unit = preload("res://scenes/unit.tscn")
var Players = {}

func set_players(value):
	Players = value
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

@rpc("any_peer", "call_local")
func spawn_unit(pos, playerName):
	var currentUnit = Unit.instantiate()
	currentUnit.controlled_by = playerName
	currentUnit.position = pos
	get_tree().root.add_child(currentUnit)

@rpc("any_peer", "call_local")
func destroy_unit(path):
	var unit = get_node_or_null(path)
	if not unit:
		return
	if is_instance_valid(unit):
		unit.call_deferred("queue_free")
