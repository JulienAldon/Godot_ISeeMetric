extends SkillBehaviour

class_name HitBehaviour

var bodies := []

func hit(body):
	if body in bodies:
		return
	if "hitbox" in body and skill_entity.damage:
		body.hitbox.damage.rpc(skill_entity.damage)
		if "attacker_id" in body:
			body.attacker_id = skill_entity.controlled_by
