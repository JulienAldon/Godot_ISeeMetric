extends Node2D

class_name SkillSlot

@export var skill: Skill
var can_trigger = true
@export var character: Node2D
@onready var stats: Node2D = character.stats

func _ready():
	$Timer.wait_time = 1 / stats.get_skill_speed(skill)
		

func set_timer(duration):
	$Timer.wait_time = duration

func reset_timer():
	$Timer.start()
	can_trigger = false

@rpc("any_peer", "call_local")
func trigger_skill(informations: Dictionary):
	if !skill:
		return false
	if !can_trigger:
		return false

	var final_rotation = informations['rotation']
	var flip = Vector2(1, 0).rotated(informations['rotation'])
	var attack_scale = Vector2(2, 2)
	var additionnal_informations = {
		"initial_direction": flip
	}
	informations.merge(additionnal_informations)
	
	if flip.x < 0 and flip.y > -0.9 and flip.y < 0.9:
		attack_scale = Vector2(-2, 2)
		final_rotation -= PI

	var circle_radius = 1
	var nb_projectiles = stats.get_projectiles_number(skill)
	if nb_projectiles > 10:
		nb_projectiles = 10
	var max_projectiles = 10
	var proj_offset = (max_projectiles - nb_projectiles) / 2
	var proj_placement = calculate_placement_points(PI, circle_radius, max_projectiles)
	for p in range(proj_offset, proj_offset + nb_projectiles):
		var point_pos = proj_placement[p]
		var rotation_offset = PI/2
		if attack_scale.x < 0:
			rotation_offset = -PI/2
		point_pos = point_pos.rotated(rotation_offset+final_rotation).normalized()
		informations["position"] = informations["position"] - point_pos
		informations["initial_direction"] = flip - point_pos
		informations["rotation"] = (flip - point_pos).angle()
		GameManager.spawn_entity(skill.scene, skill.id, informations)
		await get_tree().physics_frame

func calculate_placement_points(circle: float, radius: int, number: int) -> Array[Vector2]:
	var step = (circle)/(number)
	var proj_placement: Array[Vector2] = []
	for p in range(0, number):
		proj_placement.append(Vector2(radius * cos(step * p), radius * sin(step * p)))
	return proj_placement

func _on_timer_timeout():
	can_trigger = true
