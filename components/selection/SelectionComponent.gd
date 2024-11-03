extends Node2D
class_name SelectionComponent

@export_group("Dependencies")
#@export var health_component: HealthComponent
@export var network: NetworkComponent
@export var sprites: Array[AnimatedSprite2D]
@export var body: Entity

@export_group("Configuration")
@export var has_colored_outline: bool = false
@export var show_node_on_hover: bool = false
@export var node_shown_on_hover: Array[Node]

@export_group("Intern")
@export var target_cursor: Sprite2D

var selected = { 'status': false, 'is_target': false}
var is_mouse_hover: bool = false

func _ready():
	body.mouse_entered.connect(_on_mouse_entered)
	body.mouse_exited.connect(_on_mouse_exited)
	body.input_event.connect(_body_input_event)
	
	if has_colored_outline:
		for sprite in sprites:
			sprite.material.set_shader_parameter('outline_color', GameManager.Players[network.controlled_by].color)
	
func _body_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
			GameManager.get_player(multiplayer.get_unique_id()).interact_entity(body)
			_viewport.set_input_as_handled()
		elif event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			set_target_indicator(false)
			GameManager.get_player(multiplayer.get_unique_id()).select_entity(body)
			_viewport.set_input_as_handled()

#func _input(event):
	#if event is InputEventMouseButton:
		#if event.is_pressed():
			#set_target_indicator(false)
		

func set_target_indicator(status):
	selected['is_target'] = status
	if selected['is_target']:
		target_cursor.show()
	else:
		target_cursor.hide()
	
func set_selected(status):
	selected['status'] = status
	for sprite in sprites:
		sprite.material.set_shader_parameter('width', 1.0 if selected['status'] else 0.0)

func show_hover_nodes():
	if show_node_on_hover:
		for elem in node_shown_on_hover:
			elem.show()

func hide_hover_nodes():
	if show_node_on_hover:
		for elem in node_shown_on_hover:
			elem.hide()

func _on_mouse_entered():
	is_mouse_hover = true
	show_hover_nodes()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		GameManager.get_player(multiplayer.get_unique_id()).interact_entity(body)
	for sprite in sprites:
		sprite.material.set_shader_parameter('width', 1)

func _on_mouse_exited():
	is_mouse_hover = false
	hide_hover_nodes()
	if not selected["status"]:
		for sprite in sprites:
			sprite.material.set_shader_parameter('width', 0)
	GameManager.get_player(multiplayer.get_unique_id()).stop_interact_entity(body)
