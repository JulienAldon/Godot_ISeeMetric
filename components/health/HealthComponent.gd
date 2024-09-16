extends Node2D
class_name  HealthComponent

@export var max_health := 100
@export var stats: Node2D

@export var health := max_health

signal HealthChanged

func _ready():
	if stats:
		health = stats.get_max_health()
		max_health = stats.max_health
	HealthChanged.emit()

func reset():
	health = max_health
	if stats:
		health = stats.max_health
	HealthChanged.emit()

func damage(value: int):
	health -= value
	HealthChanged.emit()
	return health
