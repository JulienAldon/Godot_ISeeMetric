extends Node2D
class_name AttackComponent

@export_category("Dependencies")
@export var stats: CharacterStats
@export var network: NetworkComponent
@export var attack_style: AttackStyle
var range_shape: Shape2D = CircleShape2D.new()

@export_category("Configuration")
@export var attack_timer: Timer

var focus_filter: Callable = func(el): return el

var target: Node2D
var can_attack: bool = true
var attack_move: bool = false
var force_move: bool = false

var nearby_targets: Array = []

func set_focus_filter(filter: Callable):
	focus_filter = filter

func _ready():
	attack_timer.wait_time = 1 / stats.attack_speed
	attack_timer.timeout.connect(stop_attack_cooldown)
	range_shape.radius = stats.get_range()

func _process(_delta):
	range_shape.radius = stats.get_range()

func set_target(_target) -> void:
	if is_instance_valid(_target):
		target = _target
	else:
		target = null

func has_target() -> bool:
	if nearby_targets.size() > 0:
		return true
	return false

func get_target() -> Node2D:
	if nearby_targets.size() <= 0:
		return null
	var filtered = nearby_targets.filter(focus_filter)
	if filtered.size() <= 0:
		return null
	return filtered[randi_range(0, filtered.size() - 1)]

func stop_attack_cooldown() -> void:
	attack_timer.stop()
	can_attack = true

func stop_attack():
	pass

func is_in_range(pos: Vector2) -> bool:
	if not is_instance_valid(target):
		return false
	return pos.distance_to(target.global_position) < stats.get_range()

func is_target_in_attack_range() -> bool:
	if !target:
		return false
	if "death" in target and target.death.is_dead:
		return false
	return global_position.distance_to(target.get_global_position()) <= stats.get_range()

func apply_damage() -> void:
	if is_target_in_attack_range():
		var damage_type = Skill.DamageType.none
		target.hitbox.damage.rpc(5, damage_type, network.controlled_by)

func is_attack_possible() -> bool:
	if not is_instance_valid(target):
		return false
	if not target.is_in_group("player_entity") and not target.is_in_group("resource"):
		return false
	if "death" in target and target.death.is_dead:
		return false
	return can_attack 

func attack_target() -> void:
	attack_timer.wait_time = 1 / stats.attack_speed
	attack_timer.start()
	can_attack = false

func compute_nearby_target() -> Array:
	var query = PhysicsShapeQueryParameters2D.new()
	var space = get_world_2d().direct_space_state
	query.shape = range_shape
	query.collision_mask = 2
	query.transform = Transform2D(0, global_position)
	var result = space.intersect_shape(query)
	return result.map(func(el): return el.collider)
