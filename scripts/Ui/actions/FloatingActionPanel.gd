extends ActionUi

class_name FloatingBuildingAction

func get_saved_actions():
	return saved_actions

func get_source() -> Array:
	return selection

func _ready():
	super()

func hide_ui_actions():
	super()
	self.hide()

func show_ui_actions(actions):
	super(actions)
	self.show()

func set_source(_selection: Array):
	selection = _selection
	if _selection.size() <= 0:
		is_open = false
		hide_ui_actions()
		return
	entity_action = _selection[0]
	if not entity_action or not "action_controller" in entity_action or ("build_phase" in entity_action and entity_action.build_phase.is_building) :
		is_open = false
		return
	var actions = entity_action.action_controller.get_possible_actions()
	is_open = true
	if actions.size() <= 0:
		saved_actions = []
		return
	saved_actions = actions	
	show_ui_actions(actions)

func trigger_action(action: Action):
	super(action)
