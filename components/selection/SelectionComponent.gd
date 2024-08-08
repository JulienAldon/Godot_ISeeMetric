extends Node2D
class_name SelectionComponent

var selected = { 'status': false}
@export var network_component: NetworkComponent
@export var health_component: HealthComponent
@export var sprite: AnimatedSprite2D
@export var informations: String

func _ready():
	sprite.material.set_shader_parameter('outline_color', GameManager.Players[network_component.controlled_by].color)

func set_selected(status):
	if network_component.controlled_by != multiplayer.get_unique_id():
		return	
	selected['status'] = status
	#health_component.visible = status
	if selected['status'] == true:
		sprite.material.set_shader_parameter('width', 0.5)
	else:
		sprite.material.set_shader_parameter('width', 0.0)

func _process(_delta):
	pass
	
