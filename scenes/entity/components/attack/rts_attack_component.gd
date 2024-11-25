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

func stop_attack():
	apply_damage()

func attack_target():
	super()

func compute_nearby_target() -> Array:
	var res = super()
	return res.filter(func(el): return el.controlled_by != network.controlled_by and not el.is_in_group("resource"))
