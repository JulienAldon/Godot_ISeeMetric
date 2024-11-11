extends Node2D

@export var scenes: Array[Skill]
@export var scenes_to_spawn: int = 100
@export var entity_spawner: MultiplayerSpawner

var objects_pool: Dictionary

func instantiate_entity(informations: Dictionary):
	var current_entity = load(informations['scene']).instantiate()
	for key in informations.keys():
		current_entity[key] = informations[key]
	objects_pool[informations['entity_id']].append(current_entity)
	return current_entity

func _enter_tree():
	entity_spawner.spawn_function = instantiate_entity

func spawn_initial_scenes():
	for skill in scenes:
		for _i in range(0, scenes_to_spawn):
			entity_spawner.spawn({"scene": skill.scene, "visible": false, "behaviours_models": skill.behaviours, "entity_id": skill.id})

func get_first_available_object(objects: Array):
	for object in objects:
		if object.visible == false:
			return object

func show_or_spawn(entity_id, informations):
	var object = get_first_available_object(objects_pool[entity_id])
	if object:
		for key in informations.keys():
			object[key] = informations[key]
		object.configure()
		object.start()

func _ready():
	if not multiplayer.is_server():
		return
	for skill in scenes:
		objects_pool[skill.id] = []
