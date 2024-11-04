extends AttackComponent

class_name TurretAttackComponent

@export var collision: CollisionShape2D
@export var range_delimiter: ColorRect

func apply_damage():
	pass

func attack_target():
	super()
	attack_style.apply_damage(target, network.controlled_by)

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
