extends SkillBehaviour

class_name ProjectileBehaviour

func enter():
	skill_entity.global_position = skill_entity.position

func physics_update(delta):
	if multiplayer.is_server():
		if visible:
			skill_entity.position += skill_entity.initial_direction * (skill_entity.throw_speed + skill_entity.speed) * delta
