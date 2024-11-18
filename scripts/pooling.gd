extends Node2D

@export var scenes: Array[SkillResource]
@export var scenes_to_spawn: int = 100
@export var entity_spawner: MultiplayerSpawner

var objects_pool: Dictionary

func instantiate_entity(informations: Dictionary):
	var current_entity = load(informations['scene']).instantiate()
	for key in informations.keys():
		current_entity[key] = informations[key]
	objects_pool[informations['scene']].append(current_entity)
	return current_entity

func _enter_tree():
	entity_spawner.spawn_function = instantiate_entity

func spawn_initial_scenes():
	for skill in scenes:
		for _i in range(0, scenes_to_spawn):
			var info = {"scene": skill.scene, "visible": false, "spawned_in_editor": false}
			if skill.behaviours.size() > 0:
				info.merge({"behaviours_models": skill.behaviours})
			entity_spawner.spawn(info)

func get_first_available_object(objects: Array):
	for object in objects:
		if object.is_active == false:
			return object

func show_or_spawn(scene, informations):
	var object = get_first_available_object(objects_pool[scene])
	if object:
		for key in informations.keys():
			object[key] = informations[key]
		object.configure()
		object.start()

func _ready():
	if not multiplayer.is_server():
		return
	for skill in scenes:
		objects_pool[skill.scene] = []
