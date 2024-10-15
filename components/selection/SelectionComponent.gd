extends Node2D
class_name SelectionComponent

@export_group("Dependencies")
#@export var health_component: HealthComponent
@export var network: NetworkComponent
@export var sprites: Array[AnimatedSprite2D]
@export var body: Entity

@export_group("Configuration")
@export var has_colored_outline: bool = false

@export_group("Intern")
@export var target_cursor: Sprite2D

var selected = { 'status': false, 'is_target': false}
var is_mouse_hover: bool = false

func _ready():
	body.mouse_entered.connect(_on_mouse_entered)
	body.mouse_exited.connect(_on_mouse_exited)
	
	if has_colored_outline:
		for sprite in sprites:
			sprite.material.set_shader_parameter('outline_color', GameManager.Players[network.controlled_by].color)

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

func _unhandled_input(event):
	#if multiplayer.get_unique_id() != network.controlled_by:
		#return
	var multiplayer_id = multiplayer.get_unique_id()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_mouse_hover:
				body.show_informations_to(multiplayer_id)
				body.show_actions_to(multiplayer_id)
				set_selected(true)
			else:
				body.hide_informations_to(multiplayer_id)
				body.hide_actions_to(multiplayer_id)
				set_selected(false)

func _on_mouse_entered():
	is_mouse_hover = true
	for sprite in sprites:
		sprite.material.set_shader_parameter('width', 1)

func _on_mouse_exited():
	is_mouse_hover = false	
	if not selected["status"]:
		for sprite in sprites:
			sprite.material.set_shader_parameter('width', 0)
