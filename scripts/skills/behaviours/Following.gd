extends SkillBehaviour

func physics_update(delta):
	if multiplayer.is_server():
		if visible:
			skill_entity.position += skill_entity.position.direction_to(skill_entity.target.global_position) * (skill_entity.throw_speed + skill_entity.speed) * delta
