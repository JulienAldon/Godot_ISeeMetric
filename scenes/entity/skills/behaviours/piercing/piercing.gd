extends HitBehaviour

class_name PiearceBehaviour

var can_hit: bool = true
var last_hit_time: float
var time_elapsed: float = 0.0
var tick_damage_threshold: float = 0.2

func _process(delta):
	if not can_hit:
		time_elapsed += delta
	if time_elapsed >= 0.2:
		can_hit = true
		time_elapsed = 0

func hit(_bodies):
	if can_hit:
		super.hit(_bodies)
		can_hit = false
