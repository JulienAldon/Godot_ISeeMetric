extends Control

@export var tooltip: PackedScene
@export var information_node: Node
@export var information_variable: String

func _make_custom_tooltip(_for_text):
	var custom = tooltip.instantiate()
	custom.set_tooltip_information(information_node[information_variable])
	custom.show()
	return custom
