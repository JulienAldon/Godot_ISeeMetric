extends BuildMode

class_name SlotBuildMode

@export var buildings_slots: Node2D

var last_slot_selected: Node2D

func _ready():
	for elem in buildings_slots.get_children():
		elem.SlotSelected.connect(build_slot_selected)

func show_build_mode():
	super()
	buildings_slots.show()
	
func hide_build_mode():
	super()
	buildings_slots.hide()

func build_slot_selected(slot: Node2D):
	last_slot_selected = slot
	PositionConfirmed.emit(slot.global_position)

func reset_build_state():
	last_slot_selected.set_in_queue(false)
