extends Control

@export var tooltip: PackedScene
@export var action_ui: ActionButton

func _make_custom_tooltip(_for_text):
	var custom = tooltip.instantiate()
	custom.set_tooltip_information(action_ui.action)
	custom.show()
	return custom
