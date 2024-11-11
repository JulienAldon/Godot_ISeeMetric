extends ActionMode

class_name ResourceFocusMode

@export var attack: AttackComponent

func _ready():
	time.timeout.connect(set_focus_resource)

func reset_state():
	attack.set_focus_filter(func(el): return el)

func filter_resources_only(elem):
	return elem.is_in_group("resource")

func set_focus_resource():
	attack.set_focus_filter(filter_resources_only)
	ActionFinished.emit()
	time.stop()
