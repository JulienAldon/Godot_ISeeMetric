extends AttackStyle

class_name InstantAttackStyle

var damage: int = 5

func set_damage(value: Damage):
	damage = value.calculate()

func apply_damage(target, controlled_by):
	target.hitbox.damage.rpc(damage, controlled_by)
