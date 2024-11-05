extends Node

class_name AnimationComponent

@export_category("Dependencies")
@export var sprite: AnimatedSprite2D
@export var animation_tree: AnimationTree

@export_category("Configuration")
@export var attack_names: Array[String]

var attacking = false

func _ready():
	animation_tree.active = true
	animation_tree.animation_finished.connect(_on_animation_tree_animation_finished)

func get_idle():
	return animation_tree["parameters/conditions/idle"]

func get_moving():
	return animation_tree["parameters/conditions/moving"]

func get_attack():
	for attack in attack_names:
		if animation_tree["parameters/conditions/"+attack]:
			return true
	return false

func set_is_idle():
	animation_tree["parameters/conditions/idle"] = true
	animation_tree["parameters/conditions/moving"] = false
	#animation_tree["parameters/conditions/attack"] = false

func set_is_dead():
	if "parameters/conditions/death" in animation_tree:
		animation_tree["parameters/conditions/death"] = true

func set_idle_blend(last_direction):
	animation_tree["parameters/Idle/blend_position"] = last_direction
	
func set_movement_blend(direction):
	animation_tree["parameters/Walk/blend_position"] = direction

func set_is_moving():
	#sprite.speed_scale = 1
	animation_tree["parameters/conditions/idle"] = false
	animation_tree["parameters/conditions/moving"] = true
	#animation_tree["parameters/conditions/attack"] = false

func set_is_hit():
	if "parameters/conditions/hit" in animation_tree:
		animation_tree["parameters/conditions/hit"] = true

func set_is_attack(attack_speed, direction, anim_name):
	if attack_speed == 0:
		return
	attacking = true
	animation_tree["parameters/" + anim_name + "/blend_position"] = direction
	animation_tree["parameters/conditions/" + anim_name.to_lower()] = true
	animation_tree["parameters/" + anim_name + "/0/TimeScale/scale"] = 1 / attack_speed
	animation_tree["parameters/" + anim_name + "/1/TimeScale/scale"] = 1 / attack_speed
	animation_tree["parameters/" + anim_name + "/2/TimeScale/scale"] = 1 / attack_speed
	animation_tree["parameters/" + anim_name + "/3/TimeScale/scale"] = 1 / attack_speed

func stop_attack(attack_types: Array[String]):
	attacking = false
	for attack in attack_types:
		animation_tree["parameters/conditions/"+attack] = false

func _on_animation_tree_animation_finished(anim_name):
	if anim_name.contains("hit"):
		animation_tree["parameters/conditions/hit"] = false
	elif anim_name.contains("death"):
		animation_tree["parameters/conditions/death"] = false
	for i in attack_names:
		if anim_name.contains(i):
			stop_attack(attack_names)
			return
