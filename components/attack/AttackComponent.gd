extends Node2D
class_name AttackComponent

var enemies_in_range := []
@export var body: CharacterBody2D

func has_target():
	if enemies_in_range.size() > 0:
		return true
	return false

func get_target():
	for enemy in enemies_in_range:
		if is_instance_valid(enemy):
			return enemy
		else:
			enemies_in_range.erase(enemy)

func _on_enemy_detection_body_entered(_body):
	#if _body.is_in_group("damageable"):
	if _body.is_in_group("player_entity"):
		if _body.controlled_by != body.controlled_by:
			enemies_in_range.append(_body)

func _on_enemy_detection_body_exited(_body):
	enemies_in_range.erase(_body)
