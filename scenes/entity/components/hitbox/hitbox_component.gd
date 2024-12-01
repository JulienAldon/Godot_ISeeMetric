extends CollisionShape2D
class_name HitboxComponent

@export var health_component: HealthComponent
@export var character: Node2D
@export var animation: AnimationController 

var current_effects: Array[Effect] = []

@rpc("any_peer", "call_local")
func damage(_damage: int, damage_type: SkillResource.DamageType, attacker_id: int):
	if health_component:
		var damage_amount = _damage
		if "stats" in character and _damage > 0:
			damage_amount = character.stats.calculate_hit_damage(_damage,damage_type)
		health_component.damage(damage_amount)
		character.attacker_id = attacker_id
		if animation:
			animation.set_is_hit()

@rpc("any_peer", "call_local")
func control():
	# stun, slow, bump
	pass

@rpc("any_peer", "call_local")
func apply_effect(effect_path: String, duration: float, effect_id: String):
	var effect = load(effect_path).instantiate()
	effect.duration = duration
	effect.effect_id = effect_id
	add_child(effect)
	effect.start(character)
	current_effects.append(effect)

@rpc("any_peer", "call_local")
func remove_effect(effect_name):
	for effect in current_effects:
		print(effect.effect_id," ", multiplayer.get_unique_id(), " ", effect_name)
		if effect.effect_id == effect_name:
			effect.stop()
			current_effects.erase(effect)
	
func get_effects():
	return current_effects

func has_effect(effect_id: String):
	for effect in current_effects:
		if effect.effect_id == effect_id:
			return true
	return false

func _process(delta):
	if not is_multiplayer_authority():
		return
	for effect in current_effects:
		if not effect.expired:
			effect.update(delta)
