extends Node2D

class_name SkillEntity

var controlled_by: int = 1
var invoker_path: NodePath
var invoker: Node
var target: Node2D

@export var behaviours_container: Node2D
var behaviours_models
var behaviours: Array[SkillBehaviour]

var scene: String
@export_category("Dependencies")
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer

@export_category("Spawn import")
@export var damage: float
@export var animation_duration: float
@export var ref: Vector2
@export var invoker_pos: Vector2
@export var animation_speed: float
@export var throw_speed: float = 0
@export var speed: float = 0
@export var initial_direction: Vector2
@export var target_path: NodePath

var effects
var mouse_pos: Vector2
var duration: float
var shape: CircleShape2D

var body_hit: Node2D

func _enter_tree():
	if not multiplayer.is_server():
		return
	invoker = get_node(invoker_path)
	shape = CircleShape2D.new()
	if target_path:
		target = get_node(target_path)
	shape.radius = 9
	for model in behaviours_models:
		var behaviour = load(model).instantiate()
		behaviour.skill_entity = self
		behaviours_container.add_child(behaviour)
		behaviours.append(behaviour)

func _ready():
	if not multiplayer.is_server():
		return
	for behaviour in behaviours:
		behaviour.enter()
	animation_tree["parameters/idle/TimeScale/scale"] = animation_speed
	#if duration > 0:
		#var anim = animation_player.get_animation(animation_player.current_animation)
		#anim.length = duration

func check_collision():
	var query := PhysicsShapeQueryParameters2D.new()
	query.set_shape(shape)
	query.collide_with_bodies = true
	query.collision_mask = 2
	query.transform = global_transform
	var result := get_world_2d().direct_space_state.intersect_shape(query, 1)
	if result.size() > 0 and result[0].collider.controlled_by != controlled_by:
		animation_tree["parameters/conditions/hit"] = true
		body_hit = result[0].collider

func _process(delta):
	if !multiplayer.is_server():
		return
	check_collision()
	for behaviour in behaviours:
		behaviour.update(delta)
	if not animation_player.is_playing() or ("death" in target and target.death.is_dead):
		queue_free()

func _physics_process(delta):
	for behaviour in behaviours:
		behaviour.physics_update(delta)

func _hit_body():
	if body_hit.controlled_by == controlled_by:
		return	
	if multiplayer.is_server():
		for behaviour in behaviours:
			behaviour.hit(body_hit)
