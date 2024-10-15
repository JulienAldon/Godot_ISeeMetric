extends PanelContainer

class_name QueuedAction

@export var queue_number: int = 0

@export_group("Control Access")
@export var icon: TextureRect
@export var hover_background: TextureRect
@export var queue_number_label: Label
@export var button: Button

var action: Action

signal QueuedActionButtonPressed

func _ready():
	queue_number_label.text = str(queue_number)

func set_informations(_action: Action):
	reset_informations()
	icon.texture = _action.icon
	action = _action
	icon.show()

func _process(_delta):
	if action and is_instance_valid(action):
		icon.texture = action.icon
		if action.get_progression() == 0:
			reset_informations()

func reset_informations():
	icon.hide()
	action = null

func _on_button_mouse_entered():
	if icon.visible:
		hover_background.show()

func _on_button_mouse_exited():
	hover_background.hide()

func _on_button_pressed():
	QueuedActionButtonPressed.emit()
