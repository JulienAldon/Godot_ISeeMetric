extends Control

class_name UnitInformationUi

@export var title: Label
@export var passives_container: GridContainer

var passives_ui: Array = []

func show_passives(passives: Array):
	var index = 0
	for passive_ui in passives_ui:
		if passives.size() > index:
			passive_ui.set_informations(passives[index])
			passive_ui.show()
		else:
			passive_ui.reset_information()
			passive_ui.hide()
		index += 1

func set_informations(_title: String, passives: Array):
	title.text = _title
	show_passives(passives)

func _ready():
	passives_ui = passives_container.get_children()
