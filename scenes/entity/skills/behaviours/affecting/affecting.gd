extends SkillBehaviour

class_name EffectBehaviour

func hit(_body):
	if "hitbox" in _body and skill_entity.effects.size() > 0:
		for effect in skill_entity.effects:
			_body.hitbox.apply_effect.rpc(effect["path"], effect["duration"], str(skill_entity.get_instance_id()) + effect.effect_id)
