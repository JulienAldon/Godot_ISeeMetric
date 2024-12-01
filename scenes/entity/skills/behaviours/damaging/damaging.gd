extends HitBehaviour

class_name DamagingBehaviour

func hit(_bodies):
	super(_bodies)
	skill_entity.has_hit = true
