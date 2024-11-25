extends Entity

class_name Building

@export_group("Dependencies")
@export var selection: SelectionComponent
@export var network: NetworkComponent
@export var movement: RallyPointComponent

var build_time: float = 0

func get_build_time() -> float:
	return build_time

func set_build_time(value: float) -> void:
	build_time = value

func command_navigation(pos: Vector2, _group, _path: Array) -> void:
	movement.global_position = pos
	movement.path = _path
	movement.target_position = pos

func deactivate_behaviour():
	GameManager.get_level_tilemap().bake_navigation()

func _ready():
	if network:
		network.set_authority(controlled_by)
	set_multiplayer_authority(controlled_by)
	GameManager.get_level_tilemap().bake_navigation()
