extends CanvasLayer
class_name PlayerUi

@export_category("Label")
@export var name_label: Label
@export var level: Label
@export var currency: Label

@export_category("UiPanel")
@export var minimap: Minimap
@export var informations_panel: InformationUi
@export var action_panel: ActionUi

func show_informations(entities: Array):
	informations_panel.show()
	informations_panel.set_source(entities)

func hide_informations():
	informations_panel.hide()
	informations_panel.set_source([])

func get_informations_source():
	return informations_panel.get_source()

func get_actions_from_source():
	return action_panel.get_saved_actions()

func get_actions_source():
	return action_panel.get_source()

func show_actions(entities: Array):
	action_panel.set_source(entities)

func hide_actions():
	action_panel.set_source([])

func set_currency(amount):
	currency.text = str(amount)

func set_player_name(value):
	name_label.text = value

func show_player_ui(value):
	self.visible = value

func set_player_level(value: int):
	level.text = str(value)
