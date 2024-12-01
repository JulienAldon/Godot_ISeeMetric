extends Area2D

class_name EffectPropagationComponent

@export var entity: Entity
var local_entities: Array[Node2D]
var local_effects: Array[EffectResource]
var global_effects: Array[EffectResource]

func set_global_effects(effects: Array[EffectResource]):
	global_effects = effects

func add_global_effects(effects: Array[EffectResource]):
	global_effects += effects

func set_local_effects(effects: Array[EffectResource]):
	remove_local_entities_effects()
	local_effects = effects
	update_local_entities_effects()

func add_local_effects(effects: Array[EffectResource]):
	remove_local_entities_effects()
	local_effects += effects
	update_local_entities_effects()

func _ready():
	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)

func _body_entered(body):
	if not is_multiplayer_authority():
		return
	if body == entity:
		return
	if body.controlled_by != entity.controlled_by:
		return
	local_entities.append(body)
	update_local_entities_effects()

func _body_exited(body):
	if not is_multiplayer_authority():
		return
	if not body is Entity:
		return
	if body.controlled_by != entity.controlled_by:
		return
	for effect in local_effects:
		body.hitbox.remove_effect.rpc(str(entity.get_instance_id()) + effect.effect_id)
	local_entities.erase(body)
	update_local_entities_effects()

func update_local_entities_effects():
	if not is_multiplayer_authority():
		return
	print("update", local_entities, multiplayer.get_unique_id(), " ", get_multiplayer_authority())
	for body in local_entities:
		for effect in local_effects:
			if not body.hitbox.has_effect(str(entity.get_instance_id()) + effect.effect_id):
				body.hitbox.apply_effect.rpc(effect.effect_path, effect.base_duration, str(entity.get_instance_id()) + effect.effect_id)

func remove_local_entities_effects():
	if not is_multiplayer_authority():
		return
	print("remove", local_entities, multiplayer.get_unique_id(), " ", get_multiplayer_authority())
	for body in local_entities:
		for effect in local_effects:
			if body.hitbox.has_effect(str(entity.get_instance_id()) + effect.effect_id):
				body.hitbox.remove_effect.rpc(str(entity.get_instance_id()) + effect.effect_id)
