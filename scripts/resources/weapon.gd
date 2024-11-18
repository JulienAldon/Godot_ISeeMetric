extends Resource
class_name Weapon

enum WeaponTypes {
	LIGHT,
	HEAVY,
	PROJECTILES
}

var animations_speed = {
	WeaponTypes.LIGHT: 0.3,
	WeaponTypes.HEAVY: 0.5,
	WeaponTypes.PROJECTILES: 0.45,
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
