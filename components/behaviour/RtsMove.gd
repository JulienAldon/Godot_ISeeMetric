extends RtsState

class_name RtsMove

func enter():
	body.animation.set_is_moving()

func update(delta):
	if body.attack.attack_move:
		body.attack.set_nearby_targets()
		if body.attack.has_target():
			body.attack.set_target(body.attack.get_target())
			Transitioned.emit("attack")
	body.movement.move_toward_target(delta)
	#temporary until 4 way animation
	body.animation.set_movement_blend(body.movement.current_direction)
	if body.movement.current_direction.x > 0:
		body.sprite.flip_h = false
	else:
		body.sprite.flip_h = true
