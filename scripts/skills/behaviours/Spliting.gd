extends SkillBehaviour

class_name SplitingBehavior

@export var additinal_behaviours: Array[String]

func filter_behaviours(behaviour: String) -> bool:
	return not behaviour.contains("spliting") and not behaviour.contains("attached") and not behaviour.contains("damaging")

func add_behaviours(behaviours: Array):
	for added_behaviour in additinal_behaviours:
		if not added_behaviour in behaviours:
			behaviours.append(added_behaviour)
	return behaviours
	
func hit(_body):
	var behaviours = skill_entity.behaviours_models.filter(filter_behaviours)
	behaviours = add_behaviours(behaviours)
	#var choice =  randf_range(-0.1, 0.9)
	#if choice > 0:
		#return
	var random_offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	var throw_speed = skill_entity.throw_speed
	if skill_entity.throw_speed == 0:
		throw_speed = 400
	var informations = {
		"controlled_by": skill_entity.controlled_by,
		"position": skill_entity.global_position,
		"rotation": (skill_entity.initial_direction + random_offset).angle(),
		"animation_speed": skill_entity.animation_speed,
		"damage": skill_entity.damage,
		"ref": skill_entity.global_position,
		"invoker_path": skill_entity.get_path(),
		"throw_speed": throw_speed,
		"initial_direction": skill_entity.initial_direction + random_offset,
		"duration": skill_entity.duration,
		"mouse_pos": skill_entity.mouse_pos,
		"behaviours_models": behaviours,
		"effects": skill_entity.effects,
	}
	GameManager.spawn_entity.call_deferred(skill_entity.scene, informations)
