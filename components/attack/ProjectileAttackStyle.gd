extends AttackStyle

class_name ProjectileAttackStyle

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
		"position": attack_point.global_position,
		"rotation": (target.global_position - attack_point.global_position).angle() + (PI / 2),
		"animation_speed": 1,
		"damage": stats.calculate_skill_damage(skill).calculate(),
		"ref": attack_point.global_position,
		"invoker_path": self.get_path(),
		"throw_speed": stats.get_skill_throw_speed(skill),
		"duration": stats.get_skill_duration(skill),
		"mouse_pos": target.position,
		"behaviours_models": stats.get_skill_behaviours(skill),
		"effects": stats.get_skill_effects(skill),
	}
	trigger_skill.rpc_id(1, skill.scene, informations)
