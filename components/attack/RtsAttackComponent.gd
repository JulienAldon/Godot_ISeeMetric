extends AttackComponent

class_name RtsAttackComponent

func _ready():
	super()
	nearby_targets = compute_nearby_target()

func apply_damage() -> void:
	if not is_instance_valid(target):
		return
	if is_target_in_attack_range():
		attack_style.apply_damage(target, network.controlled_by)

func set_nearby_targets() -> void:
	nearby_targets = compute_nearby_target()

func reset_target() -> void:
	nearby_targets = compute_nearby_target()
	set_target(null)

func compute_nearby_target() -> Array[Node2D]:
	var query = PhysicsShapeQueryParameters2D.new()
	var space = get_world_2d().direct_space_state
	query.shape = range_shape
	query.collision_mask = 2
	query.transform = Transform2D(0, global_position)
	var result = space.intersect_shape(query)
	return result.map(func(el): return el.collider).filter(func(el): return el.controlled_by != network.controlled_by and not el.is_in_group("resource"))
