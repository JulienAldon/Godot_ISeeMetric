extends Control

class_name BuildingInformationUi

@export var production_queue: VBoxContainer
@export var production_container: HBoxContainer
@export var current_queued_action: QueuedAction
@export var name_label: Label
var building: Node2D

var production_progress: float = 0
var max_production_progress: float = 1
var productions_ui: Array = []

signal property_change

func _ready():
	productions_ui = production_container.get_children()

func set_productions(productions: Array[Action]):
	var production_size = productions.size()
	var index := 1
	
	if production_size <= 0:
		current_queued_action.reset_informations()
	else:
		current_queued_action.set_informations(productions[0])
	for production_ui in productions_ui:
		if production_size - 1 >= index:
			production_ui.set_informations(productions[index])
		else:
			production_ui.reset_informations()
		index += 1

func change_ui(_building):
	if not _building:
		return
	var has_build_phase = false
	if "build_phase" in building:
		has_build_phase = building.build_phase.is_building
	production_queue.visible = building.controlled_by != 0 and not has_build_phase and building.controlled_by == multiplayer.get_unique_id()
	var action = _building.action_controller.get_current_action()
	if action:
		max_production_progress = action.time.wait_time
		production_progress = action.get_progression()
	else:
		production_progress = 0
	property_change.emit()
	var production = _building.action_controller.get_action_queue()
	set_productions(production)
	set_identity()

func set_identity():
	name_label.text = building.display_name

func set_informations(_building):
	building = _building
	change_ui(_building)

func _process(_delta):
	change_ui(building)
	
