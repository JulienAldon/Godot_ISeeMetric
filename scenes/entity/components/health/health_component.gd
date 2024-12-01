extends Node2D
class_name  HealthComponent

@export var max_health := 100.00
@export var stats: Node2D

@export var health := max_health

var regen_timer: Timer = Timer.new()

signal HealthChanged

func _ready():
	regen_timer.wait_time = 1
	regen_timer.autostart = false
	regen_timer.one_shot = false
	regen_timer.timeout.connect(regen_tick)
	add_child(regen_timer)
	if stats:
		health = stats.get_max_health()
		max_health = stats.get_max_health()
	HealthChanged.emit()

func regen_tick():
	self.heal(stats.get_health_regeneration())

func reset():
	health = max_health
	if stats:
		health = stats.get_max_health()
	HealthChanged.emit()

func change_max_health(value):
	var health_gap = value - max_health
	max_health = value
	health += health_gap
	HealthChanged.emit()
	
	if stats:
		if stats.get_health_regeneration() > 0:
			regen_timer.start()
		else:
			regen_timer.stop()

func damage(value: float):
	health -= value
	if health < 0:
		health = 0
	elif health > max_health:
		health = max_health
	HealthChanged.emit()
	return health

@rpc("any_peer", "call_local")
func heal(value: float):
	if health < max_health:
		health += value
		HealthChanged.emit()
	return health
