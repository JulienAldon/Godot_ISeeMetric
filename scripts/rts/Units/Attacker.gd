extends "UnitController.gd"

@export var attack_cooldown := 400
var can_attack = true

func _physics_process(delta):
	attack_nearby_target_entity()

func filter_hostile_entity(e):
	return str(e.controlled_by).to_int() != multiplayer.get_unique_id()

func attack_nearby_target_entity():
	var entities_in_range = $AttackRange.get_overlapping_bodies()
	if len(entities_in_range) < 0:
		return
	var hostile_entities = entities_in_range.filter(filter_hostile_entity)
	if len(hostile_entities) > 0 and can_attack:
		for entity in hostile_entities:
			entity.hit.rpc(10)
		$AttackCooldown.start()
		can_attack = false

func _on_attack_cooldown_timeout():
	can_attack = true
