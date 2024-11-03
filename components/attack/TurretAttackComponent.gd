extends AttackComponent

class_name TurretAttackComponent

@export var attack_point: Node2D
@export var skill: Skill
@export var collision: CollisionShape2D
@export var range_delimiter: ColorRect

func apply_damage():
	pass
	#if target_in_attack_range():
		#target.hitbox.damage.rpc(5)

@rpc("call_local", "any_peer")
func trigger_skill(scene, informations):
	GameManager.spawn_entity(scene, informations)

func attack_target():
	super()
	var informations = {
		"target_path": target.get_path(),
		"initial_direction": Vector2(0, 0),
		"controlled_by": network.controlled_by,
		"position": attack_point.global_position,
		"rotation": 0,
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

func _process(_delta):
	range_delimiter.scale = Vector2(stats.get_range() / 100, stats.get_range() / 100)
	range_delimiter.position = Vector2(-stats.get_range(), -stats.get_range())
	collision.shape.radius = stats.get_range()
	
func _on_target_detection_body_entered(body):
	if body.controlled_by == network.controlled_by:
		return
	if "hitbox" in body:
		nearby_targets.append(body)

func _on_target_detection_body_exited(body):
	nearby_targets.erase(body)
