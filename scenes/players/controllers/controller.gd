extends Node2D
class_name Controller

@export var move_controller: MoveController
@export var player: PlayerController
@export var camera: Camera2D
@export var color: Color
@export var player_id: int

var center_offset: Vector2 = Vector2(0, 0)

func _ready():
	player_id = player.name.to_int()

func get_player_offset() -> Vector2:
	return center_offset

func minimap_command_position(_pos: Vector2):
	pass

func minimap_command_action(_pos: Vector2):
	pass

# Right click interaction
func interact_entity(_entity: Entity):
	pass

# Remove _entity from selection
func stop_interact_entity(_entity: Entity):
	pass
# Add _entity to selection
func select_entity(_entity: Entity):
	pass

# Add all entities to selection
func mass_select_entity(_entities: Array):
	pass
