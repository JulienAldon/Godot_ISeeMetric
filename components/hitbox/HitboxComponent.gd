extends Node2D
class_name HitboxComponent
@export var health_component: HealthComponent

func damage(_damage: Damage):
	if health_component:
		health_component.damage.rpc(_damage.calculate())
