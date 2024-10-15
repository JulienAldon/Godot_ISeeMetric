extends Node2D

class_name BuildingPhaseComponent

@export_group("Dependencies")
@export var health: HealthComponent
@export var sprite: AnimatedSprite2D
@export var building: Building

@export_group("Intern")
@export var building_sprite: AnimatedSprite2D
@export var build_timer: Timer
@export var is_building: bool = false

var build_time: float

func _ready():
	if not is_multiplayer_authority():
		return
	is_building = true
	health.damage(health.max_health - 10)
	build_timer.wait_time = building.get_build_time()
	build_time = build_timer.wait_time
	build_timer.timeout.connect(build_phase_ended)
	build_timer.start()

func build_phase_ended():
	is_building = false

func _process(delta):
	sprite.visible = !is_building 
	building_sprite.visible = is_building
	if not is_multiplayer_authority():
		return
	if is_building:
		health.heal.rpc(health.max_health / (build_time / delta))
