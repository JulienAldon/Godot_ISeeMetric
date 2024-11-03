extends AttackComponent

class_name CollectComponent

#func collect_resource():
	#entity.hitbox.damage.rpc(20)

func apply_damage():
	if target_in_attack_range():
		target.hitbox.damage.rpc(20, network.controlled_by)
