extends SkillBehaviour

class_name HitBehaviour

var bodies := []

func apply_single_hit(body):
	if "hitbox" in body and skill_entity.damage:
		body.hitbox.damage.rpc(skill_entity.damage, skill_entity.controlled_by)

func hit(hit_bodies):
	for body in hit_bodies:
		apply_single_hit(body)
