extends Action

class_name Build

@export var building_scene: String

var controlled_by: int
var build_pos: Vector2
@export var build_preview_texture: Texture2D

func start(pos, player_id):
	controlled_by = player_id
	build_pos = pos
	start_build()
	time.start()
	
func _ready():
	time.timeout.connect(build_finished)

func start_build():
	var informations = {
		"controlled_by": controlled_by,
		"position": build_pos,
		"build_time": time.wait_time
	}
	GameManager.spawn_character(building_scene, informations)

func build_finished():
	# notify player of new build
	ActionFinished.emit()
	time.stop()
