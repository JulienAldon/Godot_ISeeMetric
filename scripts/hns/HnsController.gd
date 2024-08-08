extends Controller
class_name HnsController

var input_axis: Vector2
@export var character: Node2D
	
func _ready():
	color = player.color
	player_id = player.name.to_int()
	character.controlled_by = player_id
	var has_control = player_id == multiplayer.get_unique_id()
	player.gui.show_player_ui(has_control)
	camera.enabled = has_control
	self.visible = has_control

func move(entities):
	for child in entities:
		child.movement.set_input_axis(input_axis)
	if entities.size() > 0 and player_id == multiplayer.get_unique_id():
		var pos = entities[0].position
		camera.position = pos
		player.gui.position = pos

func _physics_process(_delta):
	input_axis.x = Input.get_axis("Left", "Right")
	input_axis.y = Input.get_axis("Top", "Bottom")
	move([character])
