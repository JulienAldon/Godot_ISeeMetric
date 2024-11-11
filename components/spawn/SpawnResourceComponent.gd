extends Node2D

class_name SpawnResourceComponent

@export var network: NetworkComponent
@export var resource_scene: String

@export var effect_shape: Shape2D
@export var spawned_entity_shape: Shape2D
@export var max_entity_spawn: int = 10
@export var spawn_timer: Timer
var can_spawn: bool = true
var entities: Array

func _ready():
	if not is_multiplayer_authority():
		return
	spawn_timer.timeout.connect(_spawn_cooldown_finish)
	start_effect()

func start_effect():
	spawn_timer.start()

func stop_effect():
	spawn_timer.stop()
	can_spawn = false

func find_point_in_effect_range():
	var final_point: Vector2 = Vector2.ZERO
	while final_point == Vector2.ZERO:
		var rand_x = randf_range(global_position.x - (effect_shape.size.x / 2), global_position.x + (effect_shape.size.x / 2) )
		var rand_y = randf_range(global_position.y - (effect_shape.size.y / 2), global_position.y + (effect_shape.size.y / 2) )
		if not is_overlapping_entity(spawned_entity_shape, Vector2(rand_x, rand_y)):
			final_point = Vector2(rand_x, rand_y)
	return final_point

func is_overlapping_entity(shape: Shape2D, pos: Vector2, filter_func = null, max_entity: int = 0):
	var query = PhysicsShapeQueryParameters2D.new()
	var space = get_world_2d().direct_space_state
	query.shape = shape
	query.collision_mask = pow(2, 3-1) + pow(2, 2-1) 
	query.transform = Transform2D(0, pos)
	var result = space.intersect_shape(query)
	if not filter_func:
		return result.size() > max_entity
	return result.filter(filter_func).size() > max_entity

func _spawn_cooldown_finish():
	if not can_spawn:
		return
	if is_overlapping_entity(effect_shape, global_position, func(el): return el.collider is Wheat, max_entity_spawn - 1):
		return
	var informations = {
		"position": find_point_in_effect_range(),
		"controlled_by": 0,
	}
	GameManager.spawn_entity(resource_scene, resource_scene, informations)
