extends CollisionShape2D
class_name HitboxComponent

@export var health_component: HealthComponent
@export var character: Node2D
@export var animation: AnimationComponent 

var current_effects: Array[Effect] = []

@rpc("any_peer", "call_local")
func damage(_damage: int, attacker_id: int):
	if health_component:
		var damage_amount = _damage
		if "stats" in character:
			damage_amount = character.stats.calculate_hit_damage(_damage)
		health_component.damage(damage_amount)
		character.attacker_id = attacker_id
		if animation:
			animation.set_is_hit()

@rpc("any_peer", "call_local")
func control():
	# stun, slow, bump
	pass

@rpc("any_peer", "call_local")
func apply_effect(effect_path: String, duration: float):
	if not is_multiplayer_authority():
		return
	var effect = load(effect_path).instantiate()
	effect.duration = duration
	add_child(effect)
	effect.start(character)
	current_effects.append(effect)

func _process(delta):
	if not is_multiplayer_authority():
		return
	for effect in current_effects:
		if not effect.expired:
			effect.update(delta)
		else:
			effect.stop()
			current_effects.erase(effect)
