extends AttackStyle

class_name InstantAttackStyle

func apply_damage(target, controlled_by):
	target.hitbox.damage.rpc(50, controlled_by)
