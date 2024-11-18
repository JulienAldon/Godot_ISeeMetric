extends Area2D

signal SlotSelected

var mouse_hover: bool = false
var buildings: Array[Node2D] = []
var color: Color
var is_in_queue: bool = false

func _ready():
	color = $Delimiter.material.get_shader_parameter("color")

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and mouse_hover:
			set_in_queue(true)
			SlotSelected.emit(self)
			get_viewport().set_input_as_handled()

func set_in_queue(value):
	is_in_queue = value

func _on_mouse_entered():
	mouse_hover = true
	$Delimiter.material.set_shader_parameter("color", Color(color.r, color.g, color.b, 0.8))

func _on_mouse_exited():
	mouse_hover = false
	$Delimiter.material.set_shader_parameter("color", color)

func _on_body_entered(body):
	if body.is_in_group("building"):
		self.hide()
		buildings.append(body)

func _on_body_exited(body):
	buildings.erase(body)
	check_visibility()

func check_visibility():
	if buildings.size() <= 0 and not is_in_queue:
		self.show()
	else:
		self.hide()

func _process(_delta):
	check_visibility()
