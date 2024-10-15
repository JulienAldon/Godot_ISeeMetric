extends PanelContainer

class_name ActionUi

@export var action_container: Control
var ui_actions: Array = []
var selection: Array = []
var entity_action: Entity
var is_open: bool = false
var saved_actions: Array = []

func get_saved_actions():
	return saved_actions

func get_source() -> Array:
	return selection

func _ready():
	ui_actions = action_container.get_children()
	for ui_action in ui_actions:
		ui_action.hide()
		ui_action.ActionButtonPressed.connect(trigger_action)

func hide_ui_actions():
	for ui_action in ui_actions:
		ui_action.hide()
	saved_actions = []

func show_ui_actions(actions):
	var index = 0
	for ui_action in ui_actions:
		if actions.size() - 1 >= index:
			ui_action.set_action_icon(actions[index])
		else:
			ui_action.hide()
		index += 1 

func get_entity_in_majority(entities):
	var count = {}
	if entities.size() <= 0:
		return
	for entity in entities:
		if not count.has(entity.str_type):
			count[entity.str_type] = []
		count[entity.str_type].append(entity)
	
	var index = count.keys()[0]
	var max_count = count[index].size()
	for i in count.keys():
		if max_count < count[i].size():
			index = i
			max_count = count[i].size()
	return count[index][0]

func set_source(_selection: Array):
	selection = _selection
	if _selection.size() <= 0:
		is_open = false
		hide_ui_actions()
		return
	entity_action = get_entity_in_majority(_selection)
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
	if not self.is_open:
		return
	if selection.size() <= 0:
		return
	var entities = selection.filter(func(el): return el.str_type == entity_action.str_type)
	for entity in entities:
		var act = entity.action_controller.get_possible_actions().filter(func(el): return el.title == action.title)
		entity.trigger_action(act[0])
