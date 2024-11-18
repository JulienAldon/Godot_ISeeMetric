extends ActionMode

class_name UnitFocusMode

@export var attack: AttackComponent

func _ready():
	time.timeout.connect(set_focus_unit)

func reset_state():
	attack.set_focus_filter(func(el): return el)

func filter_unit_and_building(elem):
	return elem.is_in_group("player_entity")

func set_focus_unit():
	attack.set_focus_filter(filter_unit_and_building)
	ActionFinished.emit()
	time.stop()
