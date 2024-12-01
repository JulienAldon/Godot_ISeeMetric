extends SkillBehaviour

func enter():
	if skill_entity.invoker:
		skill_entity.invoker.dispawn()
