extends Action

class_name Produce

@export_file("*.tscn") var unit_scene: String
@export var rally_point: RallyPointComponent
var building_position: Vector2
var building_controller: int

func start(_building_position, building_ctrl):
	building_position = _building_position
	building_controller = building_ctrl
	time.start()
	
func _ready():
	time.timeout.connect(production_finished)

func production_finished():
	GameManager.spawn_character(unit_scene, {"position": rally_point.global_position, "controlled_by": building_controller, "spawn_path": rally_point.path})	
	ActionFinished.emit()
	time.stop()
