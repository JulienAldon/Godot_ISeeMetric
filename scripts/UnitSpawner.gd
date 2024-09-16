extends Node
var controlled_by := 1

@export var spawner: MultiplayerSpawner

func _enter_tree():
	controlled_by = str(name).to_int()
	set_multiplayer_authority(str(name).to_int())

func _ready():
	spawner.spawn_function = instantiate_entity

func instantiate_entity(informations: Dictionary):
	print(load(informations['scene']))
	var current_entity = load(informations['scene']).instantiate()
	for key in informations.keys():
		if key == "scene": 
			continue
		current_entity[key] = informations[key]
	return current_entity
