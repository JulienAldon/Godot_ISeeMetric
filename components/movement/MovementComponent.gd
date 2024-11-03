extends Node2D
class_name MovementComponent

@export_group("Dependencies")
@export var body: CharacterBody2D
@export var animation: AnimationComponent

@export_group("Multiplayer")
@export var doing_action := false
@export var input_axis: Vector2 = Vector2(0,0)
@export var tmp_input_axis = Vector2(0,0)
@export var walk_blend: Vector2

@export_group("Configuration")
@export var acceleration := 10
@export var dash_speed = 800
@export var dash_timer: Timer
@export var dash_cooldown: Timer

var dash_offset: Vector2 = Vector2(0, 0)
var is_dashing: bool = false
var can_dash: bool = true

func set_input_axis(_input_axis):
	input_axis = _input_axis

func _ready():
	dash_timer.timeout.connect(end_dash)
	dash_cooldown.timeout.connect(dash_cooldown_end)

#func attack(animation_scale: float, weapon_type: Weapon.WeaponTypes) -> void:

	#var choice = 0
	#if weapon_type == Weapon.WeaponTypes.Projectiles:
		#choice = 1
	##var animation = animation_tree.get("parameters/playback")
	##animation.start(possibilities[choice])
	#doing_action = true
	#animation_tree["parameters/conditions/" + possibilities[choice].to_lower()] = true
	#animation_tree["parameters/" + possibilities[choice] + "/0/TimeScale/scale"] = animation_scale
	#animation_tree["parameters/" + possibilities[choice] + "/1/TimeScale/scale"] = animation_scale
	#animation_tree["parameters/" + possibilities[choice] + "/2/TimeScale/scale"] = animation_scale
	#animation_tree["parameters/" + possibilities[choice] + "/3/TimeScale/scale"] = animation_scale
	#animation_tree["parameters/" + possibilities[choice] + "/blend_position"] =  (get_global_mouse_position() - body.global_position).normalized()

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
		animation.set_is_idle()
		animation.set_idle_blend(tmp_input_axis)
		body.velocity = body.velocity.move_toward(Vector2.ZERO, body.stats.move_speed)
	else:
		tmp_input_axis = input_axis
		walk_blend = input_axis
		animation.set_is_moving()
		animation.set_movement_blend(walk_blend)
	if not is_doing_action() or is_dashing:
		body.move_and_slide()

func is_any_skill_pressed():
	return (Input.is_action_pressed("action_slot_1") or Input.is_action_pressed("action_slot_3")
		or Input.is_action_pressed("action_slot_2") or Input.is_action_pressed("action_slot_4"))

func is_doing_action():
	return (doing_action == true)
