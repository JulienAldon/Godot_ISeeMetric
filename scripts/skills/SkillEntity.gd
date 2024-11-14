extends Entity

class_name SkillEntity

var invoker_path: NodePath
var invoker: Node
var target: Node2D

@export var behaviours_container: Node2D
var behaviours_models
var behaviours: Array[SkillBehaviour]

var entity_id: String

@export_category("Dependencies")
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var scallable_effect: Node2D
@export var effect_base_radius: float = 32
@export var shape: Shape2D = CircleShape2D.new()

var shape_offset: Vector2 = Vector2(0, 0)
var damage: float
var damage_type: float
var animation_duration: float
var animation_speed: float
var throw_speed: float = 0
var speed: float
var initial_direction: Vector2
var target_path: NodePath

var effects
var mouse_pos: Vector2
var duration: float
var query: PhysicsShapeQueryParameters2D
var radius: float = 10

func set_area_of_effect(value):
	if shape is CircleShape2D:
		shape.radius = value
	elif shape is RectangleShape2D:
		shape.set_size(Vector2(value, shape.size.y))
		shape_offset = Vector2(-shape.size.x/2, shape.size.y/2).rotated(rotation)

func _ready():
	is_active = false
	set_process(false)
	set_physics_process(false)
	for model in behaviours_models:
		var behaviour = load(model).instantiate()
		behaviour.skill_entity = self
		behaviours_container.add_child(behaviour)
		behaviours.append(behaviour)
	set_area_of_effect(radius)
	query = PhysicsShapeQueryParameters2D.new()
	configure()

func start():
	for behaviour in behaviours:
		behaviour.enter()
	animation_tree["parameters/idle/TimeScale/scale"] = animation_speed
	if "parameters/conditions/hit" in animation_tree:
		animation_tree["parameters/conditions/hit"] = false
	visible = true
	is_active = true
	animation_tree.set_active(true)
	set_process(true)
	set_physics_process(true)

func configure():
	if not multiplayer.is_server():
		return
	if invoker_path:
		invoker = get_node(invoker_path)
	if target_path:
		target = get_node(target_path)
	if throw_speed:
		speed = throw_speed
	set_area_of_effect(radius)
	if scallable_effect:
		scallable_effect.scale = Vector2(radius / effect_base_radius, radius / effect_base_radius)

func check_collision():
	query.set_shape(shape)
	query.collide_with_bodies = true
	query.collision_mask = 2
	var transfo = Transform2D(transform)
	transfo.origin = transform.origin - shape_offset
	query.transform = transfo
	var result := get_world_2d().direct_space_state.intersect_shape(query, 100)
	var hit_condition = result.size() > 0 and result[0].collider.controlled_by != controlled_by
	if hit_condition:
		_hit_body(result.map(func(el): return el.collider))
		if "parameters/conditions/hit" in animation_tree:
			animation_tree["parameters/conditions/hit"] = true
			stop()

func _process(delta):
	if not multiplayer.is_server():
		return
	if Engine.get_process_frames() % 20 == 0:
		check_collision()
	for behaviour in behaviours:
		behaviour.update(delta)

func stop():
	is_active = false
	visible = false
	if "parameters/conditions/hit" in animation_tree:
		animation_tree["parameters/conditions/hit"] = false
	animation_tree.set_active(false)
	for behaviour in behaviours:
		behaviour.stop()
	set_process(false)
	set_physics_process(false)
	
func _physics_process(delta):
	for behaviour in behaviours:
		behaviour.physics_update(delta)

func _hit_body(body_hit):
	var hit = body_hit.filter(func(el): return el.controlled_by != controlled_by)
	if multiplayer.is_server():
		for behaviour in behaviours:
			behaviour.hit(hit)
