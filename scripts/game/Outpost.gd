extends Building

class_name Outpost

@export_group("Dependencies")
@export var action_controller: ActionComponent
@export var capture: CaptureComponent
@export var income: IncomeComponent
@export var build: BuildComponent
@export var effect_shape: CollisionShape2D

func get_area_effect_range():
	return effect_shape.shape.radius

func _ready():
	super()
	controlled_by = 0
