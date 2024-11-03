extends RtsState

class_name RtsIdle

func enter():
	stop()

func physics_update(_delta):
	body.animation.set_idle_blend(body.movement.current_direction)
	if body.attack.has_target():
		body.attack.set_target(body.attack.get_target())

func stop():
	body.attack.reset_target()
	body.movement.target_position = body.position
	body.movement.reset_state()
	body.animation.set_is_idle()
