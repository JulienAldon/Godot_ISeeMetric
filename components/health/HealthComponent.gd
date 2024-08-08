extends Node2D
class_name  HealthComponent

@export var max_health := 100
@export var health := max_health

signal healthChanged

@rpc("any_peer", "call_local")
func damage(value: int):
	health -= value
	healthChanged.emit()
	return health

func _process(_delta):
	if health <= 0:
		GameManager.destroy_unit.rpc(get_path())
