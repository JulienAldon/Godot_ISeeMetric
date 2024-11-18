extends SkillBehaviour

class_name ReturningBehavior

@export var timer: Timer

func enter():
	var duration = skill_entity.duration / 2.3
	if duration <= 0:
		return
	timer.wait_time = duration
	timer.start()
	timer.timeout.connect(on_timer_finish)
	
func update(_delta):
	pass

func on_timer_finish():
	if not multiplayer.is_server():
		return
	timer.stop()
	skill_entity.initial_direction *= -1
	skill_entity.rotation += -PI
	skill_entity.speed *= 3
