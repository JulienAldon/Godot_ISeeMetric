extends SkillBehaviour

class_name HitBehaviour

var bodies := []

func hit(body):
	if body in bodies:
		return
	if "hitbox" in body and skill_entity.damage:
		body.hitbox.damage.rpc(skill_entity.damage, skill_entity.controlled_by)
