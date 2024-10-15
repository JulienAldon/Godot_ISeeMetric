extends Control

class_name SelectionMultiple

@export var selection_panel: GridContainer

var entity_ui: Array

func _ready():
	entity_ui = selection_panel.get_children()
	for ui in entity_ui:
		ui.hide()
func clear_informations():
	self.hide()

func set_entity_info(selection):
	var index := 0
	for ui in entity_ui:
		if selection.size() - 1 >= index:
			ui.set_source(selection[index])
			ui.show()
		else:
			ui.hide()
		index += 1

func set_entity_compiled(selection):
	var count = {}
	for entity in selection:
		if not count.has(entity.str_type):
			count[entity.str_type] = [entity]
		else:
			count[entity.str_type].append(entity)
	
	var indexes = count.keys()
	var index = 0
	for ui in entity_ui:
		if indexes.size() - 1 >= index:
			ui.set_source(count[indexes[index]][0], count[indexes[index]].size())
			ui.show()
		else:
			ui.hide()
		index += 1
	
func update_informations(_selection: Array):
	self.show()
	if _selection.size() > 17:
		set_entity_compiled(_selection)
	else:
		set_entity_info(_selection)
	
	# if selection.size > 17 count then show with numbers
