extends AttackStyle

class_name InstantAttackStyle

@export var damage_resource: Damage

var damage: int = 5
var damage_type: SkillResource.DamageType = SkillResource.DamageType.NONE

func _ready():
	if damage_resource:
		set_damage(damage_resource)

func set_damage(value: Damage):
	damage = value.calculate()

func apply_damage(target, controlled_by):
	print(damage)
	target.hitbox.damage.rpc(damage, damage_type, controlled_by)
