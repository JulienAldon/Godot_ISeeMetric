extends Action

class_name UpgradeBuilding
#@export var shape: Shape2D
@export var building: Building
@export var upgrade_effect: EffectResource
var pos: Vector2
var player_id: int

func _ready():
	time.timeout.connect(upgrade_building)

func start(_pos: Vector2, _player_id: int):
	pos = _pos
	player_id = _player_id
	time.start()

func upgrade_building():
	if not building:
		ActionFinished.emit()
		return
	building.hitbox.apply_effect.rpc(upgrade_effect["effect_path"], upgrade_effect["base_duration"])

	ActionFinished.emit()
	time.stop()

#func get_overlapping_building(_pos: Vector2, _player_id: int):
	#var query = PhysicsShapeQueryParameters2D.new()
	#var space = get_world_2d().direct_space_state
	#query.shape = shape
	#query.collision_mask = 2
	#query.transform = Transform2D(0, _pos)
	#var result = space.intersect_shape(query)
	#return result.map(func(el): return el.collider).filter(func(el): return el.controlled_by == _player_id and el is TdBuilding)
