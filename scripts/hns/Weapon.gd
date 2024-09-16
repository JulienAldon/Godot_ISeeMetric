extends Resource
class_name Weapon

enum WeaponTypes {
	Light,
	Heavy,
	Projectiles
}

var animations_speed = {
	WeaponTypes.Light: 0.3,
	WeaponTypes.Heavy: 0.5,
	WeaponTypes.Projectiles: 0.45,
}

@export var name: String
@export var style: int
@export var type: WeaponTypes
@export var damage: Damage
@export var damage_effectiveness: float
@export var throw_speed: float
@export var duration: float
@export var additionnal_behaviours: Array[String] = []

func get_animation_speed():
	return animations_speed[type]
