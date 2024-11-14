extends SkillBehaviour

class_name ExplodingBehaviour

@export var explosion_scene: String
@export var behaviours: Array[String]

func hit(_body):
	var informations = {
		"controlled_by": skill_entity.controlled_by,
		"position": skill_entity.global_position,
		"rotation": skill_entity.rotation,
		"animation_speed": skill_entity.animation_speed,
		"damage": skill_entity.damage,
		"invoker_path": skill_entity.get_path(),
		"throw_speed": skill_entity.throw_speed,
		"initial_direction": skill_entity.initial_direction,
		"duration": skill_entity.duration,
		"mouse_pos": get_global_mouse_position(),
		"behaviours_models": behaviours,
		"effects": skill_entity.effects,
		"damage_type": skill_entity.damage_type
	}
	GameManager.call_deferred(explosion_scene, informations)
	
