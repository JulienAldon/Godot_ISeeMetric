extends Node

class_name AnimationController

@export_category("Dependencies")
@export var sprite: AnimatedSprite2D
@export var animation_tree: AnimationTree
@export var attack_controller: AttackComponent

@export_category("Configuration")
@export var attack_names: Array[String]

var attacking = false

func _ready():
	animation_tree.active = true
	animation_tree.animation_finished.connect(_anim_finished)
	print("anim connected")

# Get animation tree idle state
# @return: boolean true if entity is idle
func get_idle():
	return animation_tree["parameters/conditions/idle"]

# Get animation tree moving state
# @return: boolean true if entity is moving
func get_moving():
	return animation_tree["parameters/conditions/moving"]

# Get animation tree attack state
# @return: boolean true if entity is attacking
func get_attack():
	for attack in attack_names:
		if animation_tree["parameters/conditions/"+attack]:
			return true
	return false

# Set animation tree idle state
func set_is_idle():
	animation_tree["parameters/conditions/idle"] = true
	animation_tree["parameters/conditions/moving"] = false
	#animation_tree["parameters/conditions/attack"] = false

# Set animation tree death state
func set_is_dead():
	if "parameters/conditions/death" in animation_tree:
		animation_tree["parameters/conditions/death"] = true

# Set anmation tree moving state
func set_is_moving():
	animation_tree["parameters/conditions/idle"] = false
	animation_tree["parameters/conditions/moving"] = true

# Set anmation tree hit state
func set_is_hit():
	if "parameters/conditions/hit" in animation_tree:
		animation_tree["parameters/conditions/hit"] = true

# Set anmation tree attack state.
# @param: attack_speed: used to determine the animation speed.
# @param: direction: direction of the attack.
# @param: animation_name: name of the attack animation to set. 
func set_is_attack(attack_speed: float, direction: Vector2, animation_name: String):
	if attack_speed == 0:
		return
	attacking = true
	animation_tree["parameters/" + animation_name + "/blend_position"] = direction
	animation_tree["parameters/conditions/" + animation_name.to_lower()] = true
	animation_tree["parameters/" + animation_name + "/0/TimeScale/scale"] = 1 / attack_speed
	animation_tree["parameters/" + animation_name + "/1/TimeScale/scale"] = 1 / attack_speed
	animation_tree["parameters/" + animation_name + "/2/TimeScale/scale"] = 1 / attack_speed
	animation_tree["parameters/" + animation_name + "/3/TimeScale/scale"] = 1 / attack_speed


# Set animation tree idle blend 
# @params: direction in which the entity is facing
func set_idle_blend(direction: Vector2):
	animation_tree["parameters/Idle/blend_position"] = direction
	
# Set animation tree movement blend 
# @params: direction in which the entity is facing
func set_movement_blend(direction: Vector2):
	animation_tree["parameters/Walk/blend_position"] = direction

# Stop attack animation
func stop_attack(attack_types: Array[String]):
	attacking = false
	if attack_controller:
		attack_controller.stop_attack()
	for attack in attack_types:
		animation_tree["parameters/conditions/"+attack] = false

func _anim_finished(anim_name):
	if anim_name.contains("hit"):
		animation_tree["parameters/conditions/hit"] = false
	elif anim_name.contains("death"):
		animation_tree["parameters/conditions/death"] = false
	print("stop anim", anim_name, self)
	for i in attack_names:
		if anim_name.contains(i):
			stop_attack(attack_names)
			return
