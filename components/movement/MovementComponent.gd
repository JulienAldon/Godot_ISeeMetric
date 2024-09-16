extends Node2D
class_name MovementComponent

@export var acceleration := 10
@export var body: CharacterBody2D
@export var input_axis: Vector2 = Vector2(0,0)
var motion: Vector2
@export var attacking := false
@export var tmp_input_axis = Vector2(0,0)
@onready var animation_tree : AnimationTree = $"../AnimationTree"
@export var walk_blend: Vector2

@export var dash_timer: Timer
@export var dash_cooldown: Timer
var dash_offset: Vector2 = Vector2(0, 0)
var is_dashing: bool = false
var can_dash: bool = true

func set_input_axis(_input_axis):
	input_axis = _input_axis

func _ready():
	animation_tree.active = true
	dash_timer.timeout.connect(end_dash)
	dash_cooldown.timeout.connect(dash_cooldown_end)

func attack(animation_scale: float, weapon_type: Weapon.WeaponTypes) -> void:
	var possibilities = [
		"Attack",
		"Projectile_Attack"
	]
	var choice = 0
	if weapon_type == Weapon.WeaponTypes.Projectiles:
		choice = 1
	#var animation = animation_tree.get("parameters/playback")
	#animation.start(possibilities[choice])
	attacking = true
	animation_tree["parameters/conditions/" + possibilities[choice].to_lower()] = true
	animation_tree["parameters/" + possibilities[choice] + "/0/TimeScale/scale"] = animation_scale
	animation_tree["parameters/" + possibilities[choice] + "/1/TimeScale/scale"] = animation_scale
	animation_tree["parameters/" + possibilities[choice] + "/2/TimeScale/scale"] = animation_scale
	animation_tree["parameters/" + possibilities[choice] + "/3/TimeScale/scale"] = animation_scale
	animation_tree["parameters/" + possibilities[choice] + "/blend_position"] =  (get_global_mouse_position() - body.global_position).normalized()

func dash_cooldown_end():
	can_dash = true

func end_dash():
	is_dashing = false
	dash_offset = Vector2(0, 0)
	dash_cooldown.start()
	can_dash = false
	
func dash(dir: Vector2):
	if can_dash:
		is_dashing = true
		dash_offset = dir
		dash_timer.start()
		can_dash = false

var dash_speed = 800

func _physics_process(_delta):
	if !is_multiplayer_authority():
		return
	var normal_speed = body.stats.move_speed
	var normal_acceleration = acceleration
	input_axis = input_axis.normalized()
	if is_dashing:
		normal_acceleration = dash_speed
		input_axis = dash_offset
		normal_speed = dash_speed
	body.velocity.x = move_toward(body.velocity.x, (normal_speed) * input_axis.x, normal_acceleration)
	body.velocity.y = move_toward(body.velocity.y, (normal_speed) * input_axis.y, normal_acceleration)
	if input_axis == Vector2.ZERO:
		idle()
		body.velocity = body.velocity.move_toward(Vector2.ZERO, body.stats.move_speed)
	else:
		tmp_input_axis = input_axis
		walk_blend = input_axis
		move()
	if not is_attacking() or is_dashing:
		body.move_and_slide()

func is_any_skill_pressed():
	return (Input.is_action_pressed("spell_slot_1") or Input.is_action_pressed("spell_slot_3")
		or Input.is_action_pressed("spell_slot_2") or Input.is_action_pressed("spell_slot_4"))

func is_attacking():
	return (attacking == true)

func _process(_delta):
	animation_tree["parameters/Walk/blend_position"] = walk_blend
	animation_tree["parameters/Idle/blend_position"] = tmp_input_axis

func idle():
	animation_tree["parameters/conditions/idle"] = true
	animation_tree["parameters/conditions/moving"] = false

func move():
	animation_tree["parameters/conditions/idle"] = false
	animation_tree["parameters/conditions/moving"] = true

func stop_attack():
	attacking = false
	animation_tree["parameters/conditions/attack"] = false
	animation_tree["parameters/conditions/projectile_attack"] = false

func _on_animation_tree_animation_finished(anim_name):
	if anim_name.contains("attack"):
		stop_attack()
