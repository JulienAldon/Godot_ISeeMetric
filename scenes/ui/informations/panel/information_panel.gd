extends Control

class_name InformationUi

@export var selection_unique: SelectionUnique
@export var selection_multiple: SelectionMultiple

var is_open: bool = false
var selection: Array = []

func get_source():
	return selection

func set_source(_selection: Array):
	selection = _selection
	var selection_size = selection.size()
	if selection_size <= 0:
		is_open = false
		selection_unique.clear_informations()
		selection_multiple.clear_informations()
		return
	if selection_size >= 2:
		is_open = true
		selection_multiple.update_informations(selection)
		selection_unique.clear_informations()
	else:
		is_open = true
		selection_unique.update_informations(selection[0])
		selection_multiple.clear_informations()
