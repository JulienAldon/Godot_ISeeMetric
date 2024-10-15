extends Node2D
class_name AttackComponent

@export var stats: CharacterStats
@export var network: NetworkComponent

@export var attack_timer: Timer
@export var shape: Shape2D

var target: Node2D
var can_attack: bool = true
var attack_move: bool
var nearby_targets: Array = []

func _ready():
	attack_timer.wait_time = 1 / stats.attack_speed
	attack_timer.timeout.connect(stop_attack_cooldown)
	shape.radius = stats.get_range()

func _process(delta):
	shape.radius = stats.get_range()

func set_target(_target):
	if is_instance_valid(_target):
		target = _target
	else:
		target = null

func has_target():
	if nearby_targets.size() > 0:
		return true
	return false

func get_target():
	if nearby_targets.size() <= 0:
		return null
	return nearby_targets[0]

func stop_attack_cooldown():
	attack_timer.stop()
	can_attack = true

func target_in_attack_range():
	if !target:
		return false
	if "death" in target and target.death.is_dead:
		return false
	return global_position.distance_to(target.get_global_position()) <= stats.get_range()

func apply_damage():
	if target_in_attack_range():
		target.hitbox.damage.rpc(5)

func is_attack_possible():
	if not is_instance_valid(target):
		return false
	if not target.is_in_group("player_entity"):
		return false
	if "death" in target and target.death.is_dead:
		return false
	return can_attack 

func attack_target():
	attack_timer.wait_time = 1 / stats.attack_speed
	attack_timer.start()
	can_attack = false

#func _on_enemy_detection_body_entered(_body):
	#if _body.controlled_by == body.controlled_by:
		#return
	#if _body.is_in_group("player_entity"):
		#if _body.controlled_by != body.controlled_by:
			#enemies_in_range.append(_body)
#
#func _on_enemy_detection_body_exited(_body):
	#if _body in enemies_in_range:
		#enemies_in_range.erase(_body)
	#if _body == target:
		#reset_target()
