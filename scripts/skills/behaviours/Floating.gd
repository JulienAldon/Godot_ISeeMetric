extends SkillBehaviour

class_name FloatingBehaviour

func enter():
	skill_entity.global_position = skill_entity.mouse_pos
