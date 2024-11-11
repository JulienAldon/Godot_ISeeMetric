extends Action

class_name ChangeModeBuilding

@export var possible_mode: Array[ActionMode]
@export var building_ui: FloatingBuildingAction

var current_mode: int = 0
var pos: Vector2
var player_id: int

func _ready():
	time.timeout.connect(update_building_mode)
	possible_mode[current_mode].start()
	icon = possible_mode[current_mode].icon
	title = possible_mode[current_mode].title
	description = possible_mode[current_mode].description

func start(_pos: Vector2, _player_id: int):
	pos = _pos
	player_id = _player_id
	time.start()

func update_building_mode():
	possible_mode[current_mode].reset_state()
	if possible_mode.size() <= 0:
		return
	current_mode += 1
	if current_mode > possible_mode.size() - 1:
		current_mode = 0
	icon = possible_mode[current_mode].icon
	title = possible_mode[current_mode].title
	description = possible_mode[current_mode].description
	possible_mode[current_mode].start()
	building_ui.set_source(building_ui.get_source())
	ActionFinished.emit()
	time.stop()
