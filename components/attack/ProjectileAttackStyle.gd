extends AttackStyle

class_name ProjectileAttackStyle

@export var body: Entity
@export var attack_point: Node2D
@export var skill: Skill

@rpc("call_local", "any_peer")
func trigger_skill(scene, informations):
	GameManager.spawn_entity(scene, informations)

func apply_damage(target: Node2D, controlled_by: int):
	var informations = {
		"target_path": target.get_path(),
		"initial_direction": Vector2(0, 0),
		"controlled_by": controlled_by,
		"global_position": attack_point.global_position,
		"rotation": (target.global_position - attack_point.global_position).angle(),
		"animation_speed": 1,
		"damage": stats.calculate_skill_damage(skill).calculate(),
		"invoker_path": body.get_path(),
		"throw_speed": stats.get_skill_throw_speed(skill),
		"duration": stats.get_skill_duration(skill),
		"mouse_pos": target.position,
		"behaviours_models": stats.get_skill_behaviours(skill),
		"effects": stats.get_skill_effects(skill),
		"radius": skill.area_of_effect,
		"damage_type": skill.damage_type
	}
	trigger_skill.rpc_id(1, skill.scene, informations)
