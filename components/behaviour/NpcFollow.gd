extends NpcState

class_name  NpcFollow

func enter():
	pass
	
func physics_update(delta):
	if !target:
		return
	var direction = target.global_position - body.global_position
	
	body.velocity = direction.normalized() * stats.move_speed 
	body.move_and_collide(body.velocity * delta)
	
func _on_target_detection_body_entered(_body):
	if is_multiplayer_authority():
		if _body.is_in_group("player_entity"):
			target = _body
			Transitioned.emit(self, "follow")
			
func _on_target_detection_body_exited(_body):
	if is_multiplayer_authority():
		if _body.is_in_group("player_entity") and _body == target:
			Transitioned.emit(self, "idle")
			target = null


