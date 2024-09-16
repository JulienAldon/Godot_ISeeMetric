extends SkillBehaviour

class_name AttachedBehaviour

func enter():
	skill_entity.global_position = skill_entity.position

func physics_update(_delta):
	if multiplayer.is_server():
		if skill_entity.speed == 0:
			skill_entity.invoker_pos = skill_entity.invoker.position
	if skill_entity.invoker_pos != Vector2(0, 0) and skill_entity.speed == 0:
		skill_entity.position = skill_entity.ref + skill_entity.invoker_pos
