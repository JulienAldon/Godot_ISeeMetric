extends TextureRect

@export var stacks: Label
var effect: Effect

func set_informations(_passive):
	texture = _passive.icon
	stacks.text = "1"
	effect = _passive
	# TODO: Tooltip

func reset_information():
	pass
