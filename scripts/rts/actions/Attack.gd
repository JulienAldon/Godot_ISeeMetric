extends Action

class_name Attack

@export var attack_state: State

var controlled_by: int
var build_pos: Vector2

func start(pos, player_id):
	controlled_by = player_id
	build_pos = pos
	start_attack()
	time.start()
	
func _ready():
	time.timeout.connect(attack_command_finish)

func start_attack():
	attack_state.body.attack.set_target(attack_state.body)
	attack_state.trigger_attack()

func attack_command_finish():
	# notify player of new build
	ActionFinished.emit()
	time.stop()
