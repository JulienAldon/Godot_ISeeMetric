extends AttackStyle

class_name InstantAttackStyle

var damage: int = 5
var damage_type: Skill.DamageType = Skill.DamageType.none

func set_damage(value: Damage):
	damage = value.calculate()

func apply_damage(target, controlled_by):
	target.hitbox.damage.rpc(damage, damage_type, controlled_by)
