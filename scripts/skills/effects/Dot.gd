extends Effect

class_name DotEffect

@export var dot_tick_time: float
var trigger_timer: float

func update(delta):
	if trigger_timer >= dot_tick_time:
		character.hitbox.damage.rpc(10)
		trigger_timer = 0
	trigger_timer += delta
