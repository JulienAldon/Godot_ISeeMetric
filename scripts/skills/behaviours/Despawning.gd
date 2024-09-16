extends HitBehaviour

class_name DespawningBehaviour

func hit(body):
	super.hit(body)
	skill_entity.call_deferred("queue_free")
