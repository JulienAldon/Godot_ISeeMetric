extends AttackComponent

class_name CollectComponent


var repair_mode: bool = false

@export var repair_skill: Skill
@export var attack_skill: Skill

func set_repair_mode(value: bool):
	repair_mode = value

func apply_damage():
	if is_target_in_attack_range():
		attack_style.set_damage(stats.calculate_skill_damage(attack_skill))
		if repair_mode:
			attack_style.set_damage(stats.calculate_skill_damage(repair_skill))
		attack_style.apply_damage(target, network.controlled_by)
