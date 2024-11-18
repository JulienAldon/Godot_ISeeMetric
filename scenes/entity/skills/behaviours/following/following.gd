extends SkillBehaviour

func physics_update(delta):
	if multiplayer.is_server():
		if (not is_instance_valid(skill_entity.target) 
			or (is_instance_valid(skill_entity.target) 
			and "death" in skill_entity.target 
			and skill_entity.target.death.is_dead)):
			skill_entity.stop()
			return
		skill_entity.position += skill_entity.position.direction_to(skill_entity.target.global_position) * (skill_entity.throw_speed + skill_entity.speed) * delta
