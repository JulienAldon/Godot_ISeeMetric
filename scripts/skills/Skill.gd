extends Resource

class_name Skill

enum DamageType {
	physical,
	magic,
	none,
	#fire,
	#cold,
	#lightning,
}
enum SkillType {
	Attack,
	Spell
}

@export var type: SkillType
@export var damage_type: DamageType
@export var movement: bool = false
@export var cooldown: float # seconds
@export var area_of_effect: int # radius
@export var scene: String
# Multiplicator to damage to balance damages
@export var damage_effectiveness: float
@export var damage: Damage
@export var weapon_compatibility: Array[Weapon.WeaponTypes]
@export var projectiles: int
@export var base_duration: float #seconds
@export var projectiles_scallable: bool
@export var behaviours: Array[String]
@export var throw_speed: int
@export var effects: Array[EffectResource]

func is_skill_valid():
	return damage != null and scene != ""
