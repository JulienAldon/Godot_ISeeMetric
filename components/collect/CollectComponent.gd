extends AttackComponent

class_name CollectComponent

func apply_damage():
	if is_target_in_attack_range():
		attack_style.apply_damage(target, network.controlled_by)
