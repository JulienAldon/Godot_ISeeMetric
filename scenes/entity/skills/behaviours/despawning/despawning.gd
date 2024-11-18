extends HitBehaviour

class_name DespawningBehaviour

func hit(_bodies):
	if is_instance_valid(skill_entity.target) and skill_entity.target in _bodies:
		apply_single_hit(skill_entity.target)
		skill_entity.stop()
