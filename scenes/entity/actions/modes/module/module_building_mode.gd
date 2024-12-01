extends ActionMode

class_name ModuleBuildingMode

@export var entity: Entity
@export var effects: Array[EffectResource]

func _ready():
	time.timeout.connect(set_mode)

func reset_state():
	pass

func set_mode():
	entity.propagation.set_local_effects(effects)
	time.stop()
