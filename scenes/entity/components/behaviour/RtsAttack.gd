extends RtsState

class_name RtsAttack

func trigger_attack():
	body.attack.attack_target()
	body.animation.set_is_attack(1 / body.stats.attack_speed, body.movement.current_direction, "Attack")

func update(_delta):
	if body.attack.is_attack_possible() and not body.animation.attacking:
		trigger_attack()
	else:
		body.animation.set_is_idle()
	#if body.attack.target == null and body.attack.has_target():
		#body.attack.set_target(body.attack.get_target())
