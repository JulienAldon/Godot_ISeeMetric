extends NpcState

class_name NpcIdle

var move_direction : Vector2
var wander_time : float

func randomize_wander():
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(1, 3)
	
func enter():
	randomize_wander()

func update(delta: float):
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()
	
func physics_update(delta: float):
	if body:
		body.velocity = move_direction * stats.move_speed
		body.move_and_collide(body.velocity * delta)
