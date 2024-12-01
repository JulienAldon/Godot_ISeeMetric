extends ActionMode

class_name SpawnTypeMode

@export var resource_spawner: SpawnResourceComponent
@export var resource: GameManager.CurrencyType

func _ready():
	time.timeout.connect(set_resource_to_spawn)

func reset_state():
	pass

func set_resource_to_spawn():
	resource_spawner.current_scene = resource
	ActionFinished.emit()
	time.stop()
