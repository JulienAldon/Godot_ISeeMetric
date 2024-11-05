extends Action

class_name RemoveBuilding
@export var building: Building

var pos: Vector2
var player_id: int

func _ready():
	time.timeout.connect(remove_building)

func start(_pos: Vector2, _player_id: int):
	pos = _pos
	player_id = _player_id
	time.start()

func remove_building():
	building.dispawn()

	ActionFinished.emit()
	time.stop()
