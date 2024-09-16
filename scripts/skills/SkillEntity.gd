extends Node2D

class_name SkillEntity

var controlled_by: int = 1
var invoker_path: NodePath
var invoker: Node


@export var behaviours_container: Node2D
var behaviours_models
var behaviours: Array[SkillBehaviour]

var scene: String

@export var animation_player: AnimationPlayer

var is_from_hit: bool
@export var damage: float
@export var animation_duration: float
@export var ref: Vector2
@export var invoker_pos: Vector2
@export var animation_speed: float
@export var throw_speed: float = 0
@export var speed: float = 0
@export var initial_direction: Vector2
var effects
var mouse_pos: Vector2
var duration: float
var shape: CircleShape2D

func _enter_tree():
	if not multiplayer.is_server():
		return
	invoker = get_node(invoker_path)
	shape = CircleShape2D.new()
	shape.radius = 9
	for model in behaviours_models:
		var behaviour = load(model).instantiate()
		behaviour.skill_entity = self
		behaviours_container.add_child(behaviour)
		behaviours.append(behaviour)

func _ready():
	if multiplayer.is_server():
		if behaviours.size() > 0:
			for behaviour in behaviours:
				behaviour.enter()
	if not animation_player:
		return
	animation_player.speed_scale = animation_speed
	if duration > 0:
		var anim = animation_player.get_animation(animation_player.current_animation)
		anim.length = duration

func _process(delta):
	if !multiplayer.is_server():
		return
	var query := PhysicsShapeQueryParameters2D.new()
	query.set_shape(shape)
	query.collide_with_bodies = true
	query.collision_mask = 1
	query.transform = global_transform
	var result := get_world_2d().direct_space_state.intersect_shape(query, 1)
	if result.size() > 0:
		_on_area_2d_body_entered(result[0].collider)
		
	if not animation_player.is_playing():
		queue_free()
	if behaviours.size() > 0:
		for behaviour in behaviours:
			behaviour.update(delta)

func _physics_process(delta):
	if behaviours.size() > 0:
		for behaviour in behaviours:
			behaviour.physics_update(delta)

func _on_area_2d_body_entered(body):
	if body.controlled_by == controlled_by and body.is_in_group("player_entity"):
		return
	if multiplayer.is_server():
		if behaviours.size() > 0:
			for behaviour in behaviours:
				behaviour.hit(body)
