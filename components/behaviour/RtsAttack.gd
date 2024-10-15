extends RtsState

class_name RtsAttack

func physics_update(_delta):
	if body.attack.is_attack_possible():
		body.attack.attack_target()
		body.animation.set_is_attack(1 / body.stats.attack_speed, body.movement.current_direction, "Attack")
	else:
		body.animation.set_is_idle()
	#if body.attack.target == null and body.attack.has_target():
		#body.attack.set_target(body.attack.get_target())
