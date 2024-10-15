extends Building

class_name TdBuilding

var in_outpost_range: bool = false

@export var time_before_damage: float = 1
var health_lost = 50
var current_rime: float = 0

func is_in_outpost_range():
	var outposts = GameManager.get_level_outposts()
	for outpost in outposts:
		if outpost.controlled_by != controlled_by:
			continue
		if global_position.distance_to(outpost.global_position) < outpost.get_area_effect_range():
			return true
	return false
			
func _ready():
	super()
	in_outpost_range = is_in_outpost_range()

func take_damage_tick(delta):
	current_rime += delta
	if current_rime >= time_before_damage:
		self.hitbox.damage.rpc(health_lost)
		current_rime = 0

func _process(delta):
	if not in_outpost_range:
		take_damage_tick(delta)
