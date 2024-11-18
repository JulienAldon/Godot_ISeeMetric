extends Action

class_name Produce

@export var unit_scene: String
@export var rally_point: RallyPointComponent
var outpost_position: Vector2
var outpost_controller: int

func start(outpost_pos, outpost_ctrl):
	outpost_position = outpost_pos
	outpost_controller = outpost_ctrl
	time.start()
	
func _ready():
	time.timeout.connect(production_finished)

func production_finished():
	GameManager.spawn_character(unit_scene, {"position": outpost_position, "controlled_by": outpost_controller, "spawn_path": rally_point.path})	
	ActionFinished.emit()
	time.stop()
