extends TextureRect

@export var stacks: Label

func set_informations(_passive):
	texture = _passive.icon
	stacks.text = "1"
	# TODO: Tooltip

func reset_information():
	pass
