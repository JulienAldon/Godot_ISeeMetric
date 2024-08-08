extends Control
class_name PlayerUi
@export var name_label: Label

func set_player_name(value):
	name_label.text = value

func show_player_ui(value):
	self.visible = value
