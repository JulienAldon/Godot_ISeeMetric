extends Node2D
class_name Controller

@export var move_controller: MoveController
@export var player: PlayerController
@export var camera: Camera2D
@export var color: Color
@export var player_id: int

func _ready():
	player_id = player.name.to_int()

func minimap_command_position(_pos: Vector2):
	pass

func minimap_command_action(_pos: Vector2):
	pass

func interact_entity(_entity: Entity):
	pass

func stop_interact_entity(_entity: Entity):
	pass

func select_entity(_entity: Entity):
	pass
